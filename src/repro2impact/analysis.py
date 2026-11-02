"""Validation and analysis routines for the REPRO2IMPACT article-level dataset."""
from __future__ import annotations
from pathlib import Path
import warnings
import pandas as pd

STATUS_COLUMNS = ["data_status", "code_status", "methods_status", "prereg_status"]
ALLOWED = {"yes", "no", "unclear", "not_applicable"}
REQUIRED = {"work_id", "publication_year", "discipline", "citations", *STATUS_COLUMNS}


def load_articles(path: str | Path) -> pd.DataFrame:
    df = pd.read_csv(path, dtype={"work_id": "string", "discipline": "string"})
    missing = REQUIRED - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {', '.join(sorted(missing))}")
    if df["work_id"].isna().any() or df["work_id"].duplicated().any():
        raise ValueError("work_id must be present and unique")
    if df["discipline"].isna().any() or df["discipline"].str.strip().eq("").any():
        raise ValueError("discipline must be present for every record")
    df["publication_year"] = pd.to_numeric(df["publication_year"], errors="coerce")
    df["citations"] = pd.to_numeric(df["citations"], errors="coerce")
    if df[["publication_year", "citations"]].isna().any().any():
        raise ValueError("publication_year and citations must be numeric and non-missing")
    if (df["citations"] < 0).any():
        raise ValueError("citations must be non-negative")
    if (df["publication_year"] % 1 != 0).any():
        raise ValueError("publication_year must contain whole years")
    df["publication_year"] = df["publication_year"].astype(int)
    df["citations"] = df["citations"].astype(int)
    for col in STATUS_COLUMNS:
        df[col] = df[col].astype("string").str.strip().str.lower()
        if df[col].isna().any() or df[col].eq("").any():
            raise ValueError(f"{col} cannot be blank; use unclear when evidence is insufficient")
        invalid = set(df[col].dropna().unique()) - ALLOWED
        if invalid:
            raise ValueError(f"Invalid values in {col}: {sorted(invalid)}")
    return df


def score_transparency(df: pd.DataFrame, minimum_observed: int = 3) -> pd.DataFrame:
    """Create a 0-1 transparency score; unknown codes stay missing, never zero."""
    out = df.copy()
    mapping = {"yes": 1.0, "no": 0.0, "unclear": float("nan"), "not_applicable": float("nan")}
    item_scores = pd.DataFrame({c: out[c].map(mapping) for c in STATUS_COLUMNS}, index=out.index)
    out["transparency_items_observed"] = item_scores.notna().sum(axis=1)
    out["transparency_score"] = item_scores.mean(axis=1).where(
        out["transparency_items_observed"] >= minimum_observed
    )
    out["transparency_score_label"] = "article-level transparency; not reproducibility"
    return out


def describe(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    scored = score_transparency(df)
    overall = pd.DataFrame([{
        "articles": len(scored), "scored_articles": int(scored["transparency_score"].notna().sum()),
        "mean_transparency_score": scored["transparency_score"].mean(),
        "median_citations": scored["citations"].median(),
    }])
    by_discipline = scored.groupby("discipline", dropna=False).agg(
        articles=("work_id", "size"), scored_articles=("transparency_score", "count"),
        mean_transparency_score=("transparency_score", "mean"),
        median_citations=("citations", "median"), mean_citations=("citations", "mean"),
    ).reset_index()
    return {"overall": overall, "by_discipline": by_discipline}


def fit_count_models(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Fit adjusted association models; outputs are not causal estimates."""
    scored = score_transparency(df).dropna(subset=["transparency_score"]).copy()
    if len(scored) < 30:
        raise ValueError("At least 30 scored articles are required for this provisional model.")
    if scored["transparency_score"].nunique() < 2:
        raise ValueError("transparency_score has no variation")
    try:
        import statsmodels.api as sm
        import statsmodels.formula.api as smf
    except ImportError as exc:
        raise RuntimeError("Install the analysis dependencies listed in pyproject.toml") from exc
    terms = ["transparency_score"]
    for col in ["open_access", "international_collaboration"]:
        if col in scored and scored[col].notna().sum() > 0:
            scored[col] = pd.to_numeric(scored[col], errors="coerce")
            if scored[col].nunique(dropna=True) > 1:
                scored[col] = scored[col].fillna(scored[col].median())
                terms.append(col)
    for col in ["discipline", "publication_year"]:
        if scored[col].nunique() > 1:
            terms.append(f"C({col})")
    formula = "citations ~ " + " + ".join(terms)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        poisson = smf.glm(formula, data=scored, family=sm.families.Poisson()).fit(cov_type="HC3")
    poisson_table = _coefficient_table(poisson, "Poisson robust HC3", len(scored))
    try:
        nb = smf.negativebinomial(formula, data=scored).fit(disp=False, cov_type="HC3")
        nb_table = _coefficient_table(nb, "Negative binomial robust HC3 sensitivity", len(scored))
    except Exception as exc:
        nb_table = pd.DataFrame([{
            "model": "Negative binomial sensitivity", "term": "MODEL_NOT_FIT",
            "estimate": None, "std_error": None, "ci_low": None, "ci_high": None,
            "p_value": None, "n": len(scored), "note": str(exc)[:250],
        }])
    return {"poisson": poisson_table, "negative_binomial": nb_table}


def _coefficient_table(model, model_name: str, n: int) -> pd.DataFrame:
    ci = model.conf_int()
    return pd.DataFrame({
        "model": model_name, "term": model.params.index, "estimate": model.params.values,
        "std_error": model.bse.values, "ci_low": ci.iloc[:, 0].values,
        "ci_high": ci.iloc[:, 1].values, "p_value": model.pvalues.values,
        "n": n, "note": "Adjusted association; not a causal effect",
    })
