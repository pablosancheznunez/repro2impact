"""Exploratory citation pilot using PLOS Open Science Indicators v11.

Sampling frame: PLOS cohort, publication years 2018-2021. The full v11 archive is
retrieved from Figshare; a balanced random sample is drawn within year x data-sharing
x code-sharing strata. OpenAlex cited_by_count is collected at run time. All estimates
are weighted back to stratum population counts and are descriptive associations only.
"""
from __future__ import annotations
import hashlib
import json
import random
import time
import urllib.parse
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd

SEED = 20261102
YEARS = [2018, 2019, 2020, 2021]
N_PER_STRATUM = 125
BATCH_SIZE = 50
N_BOOT = 1000
FIGSHARE_ZIP = "https://ndownloader.figshare.com/files/66066221"
FIGSHARE_DOI = "10.6084/m9.figshare.21687686.v11"
ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
PILOT_DIR = ROOT / "data" / "pilot"
REPORT_DIR = ROOT / "reports" / "pilot_osi_v11"
ZIP_PATH = RAW_DIR / "PLOS-OSI-Dataset_v11.zip"


def fetch(url: str, *, timeout: int = 120) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "REPRO2IMPACT exploratory research workflow"})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return response.read()


def prepare_frame() -> tuple[pd.DataFrame, str]:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    if not ZIP_PATH.exists():
        ZIP_PATH.write_bytes(fetch(FIGSHARE_ZIP))
    digest = hashlib.sha256(ZIP_PATH.read_bytes()).hexdigest()
    extract_dir = RAW_DIR / "v11"
    csv_path = extract_dir / "Data files" / "PLOS-Dataset_v11_Jun26.csv"
    if not csv_path.exists():
        with zipfile.ZipFile(ZIP_PATH) as archive:
            archive.extractall(extract_dir)
    df = pd.read_csv(csv_path, low_memory=False)
    df = df[df["Publication_Year"].isin(YEARS)].copy()
    df = df[df["DOI"].notna()].copy()
    for col in ["Data_Shared", "Code_Shared"]:
        df = df[df[col].notna()].copy()
        df[col] = df[col].astype(bool)
    return df, digest


def draw_sample(frame: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    groups = ["Publication_Year", "Data_Shared", "Code_Shared"]
    population = frame.groupby(groups, observed=True).size().rename("population_n").reset_index()
    sampled = []
    for key, part in frame.groupby(groups, observed=True, sort=True):
        n = min(N_PER_STRATUM, len(part))
        sampled.append(part.sample(n=n, random_state=SEED + int(key[0]) * 100 + int(key[1]) * 10 + int(key[2])))
    result = pd.concat(sampled, ignore_index=True)
    result["doi"] = result["DOI"].astype(str).str.strip()
    result["doi_norm"] = result["doi"].str.lower().str.replace(r"^https?://(dx\.)?doi\.org/", "", regex=True)
    result["doi_norm"] = result["doi_norm"].str.replace(r"^doi:", "", regex=True)
    return result, population


def query_openalex(dois: list[str]) -> pd.DataFrame:
    rows = []
    for start in range(0, len(dois), BATCH_SIZE):
        chunk = dois[start:start + BATCH_SIZE]
        values = "|".join("https://doi.org/" + d for d in chunk)
        params = urllib.parse.urlencode({
            "filter": "doi:" + values,
            "select": "id,doi,cited_by_count,publication_year,primary_topic",
            "per_page": "100",
        }, safe=":|/")
        url = "https://api.openalex.org/works?" + params
        error = None
        for attempt in range(4):
            try:
                payload = json.loads(fetch(url, timeout=60))
                rows.extend(payload.get("results", []))
                error = None
                break
            except Exception as exc:
                error = exc
                time.sleep(2 ** attempt)
        if error:
            raise RuntimeError(f"OpenAlex batch failed at DOI {start + 1}: {error}")
        time.sleep(0.15)
    if not rows:
        return pd.DataFrame(columns=["id", "doi_norm", "cited_by_count", "oa_year", "openalex_field"])
    result = pd.json_normalize(rows)
    result = result.rename(columns={"id": "openalex_id", "publication_year": "openalex_year"})
    result["doi_norm"] = result["doi"].astype(str).str.lower().str.replace(
        r"^https?://(dx\.)?doi\.org/", "", regex=True
    )
    result["cited_by_count"] = pd.to_numeric(result["cited_by_count"], errors="coerce")
    result["openalex_field"] = result.get("primary_topic.field.display_name")
    return result[["openalex_id", "doi_norm", "cited_by_count", "openalex_year", "openalex_field"]].drop_duplicates("doi_norm")


def weighted_mean(values: np.ndarray, weights: np.ndarray) -> float:
    ok = np.isfinite(values) & np.isfinite(weights) & (weights > 0)
    return float(np.average(values[ok], weights=weights[ok])) if ok.any() else float("nan")


def build_outcomes(joined: pd.DataFrame, population: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    keys = ["Publication_Year", "Data_Shared", "Code_Shared"]
    nmatched = joined.groupby(keys, observed=True).size().rename("matched_n").reset_index()
    joined = joined.merge(population, on=keys, how="left").merge(nmatched, on=keys, how="left")
    joined["analysis_weight"] = joined["population_n"] / joined["matched_n"]
    # Marginal descriptive associations use the matched sample, reweighted to every
    # source stratum. They are not adjusted for topic field or unobserved confounding.
    rows = []
    for practice in ["Data_Shared", "Code_Shared"]:
        for flag, label in [(True, "yes"), (False, "no")]:
            subset = joined[joined[practice].eq(flag)]
            rows.append({
                "practice": practice,
                "level": label,
                "matched_n": len(subset),
                "weighted_population_n": float(subset["analysis_weight"].sum()),
                "weighted_mean_citations": weighted_mean(subset["cited_by_count"].to_numpy(float), subset["analysis_weight"].to_numpy(float)),
                "weighted_median_citations_unweighted_sample": float(subset["cited_by_count"].median()),
                "share_zero_citations_weighted": weighted_mean((subset["cited_by_count"].to_numpy(float) == 0).astype(float), subset["analysis_weight"].to_numpy(float)),
            })
    outcomes = pd.DataFrame(rows)
    # Year-specific rates and differences; uncertainty is bootstrap percentile CI,
    # resampling inside the original sampling strata.
    rng = np.random.default_rng(SEED)
    boot_rows = []
    groups = list(joined.groupby(keys, observed=True, sort=True))
    overall_year_population = population.groupby("Publication_Year")["population_n"].sum()
    overall_year_weights = (overall_year_population / overall_year_population.sum()).to_dict()
    for practice in ["Data_Shared", "Code_Shared"]:
        point = {}
        for level in [False, True]:
            per_year = {}
            for year in YEARS:
                q = joined[(joined["Publication_Year"] == year) & (joined[practice] == level)]
                per_year[year] = weighted_mean(q["cited_by_count"].to_numpy(float), q["analysis_weight"].to_numpy(float))
            point[level] = sum(overall_year_weights[y] * per_year[y] for y in YEARS)
        point_diff = point[True] - point[False]
        point_ratio = point[True] / point[False] if point[False] else np.nan
        rep_diffs, rep_ratios = [], []
        for _ in range(N_BOOT):
            bmeans = {False: {}, True: {}}
            for _, group in groups:
                year = int(group["Publication_Year"].iloc[0])
                for level in [False, True]:
                    g = group[group[practice] == level]
                    if g.empty:
                        continue
                    sample_idx = rng.integers(0, len(g), len(g))
                    s = g.iloc[sample_idx]
                    bmeans[level].setdefault(year, []).append(
                        (weighted_mean(s["cited_by_count"].to_numpy(float), s["analysis_weight"].to_numpy(float)),
                         float(s["analysis_weight"].sum()))
                    )
            means = {}
            for level in [False, True]:
                means[level] = {}
                for year in YEARS:
                    pieces = bmeans[level].get(year, [])
                    means[level][year] = (
                        sum(v * w for v, w in pieces) / sum(w for _, w in pieces)
                        if pieces and sum(w for _, w in pieces) else np.nan
                    )
            a = sum(overall_year_weights[y] * means[True][y] for y in YEARS)
            b = sum(overall_year_weights[y] * means[False][y] for y in YEARS)
            rep_diffs.append(a - b)
            rep_ratios.append(a / b if b else np.nan)
        boot_rows.append({
            "practice": practice, "year_standardized_mean_yes": point[True],
            "year_standardized_mean_no": point[False], "difference_citations": point_diff,
            "difference_ci_low": float(np.nanpercentile(rep_diffs, 2.5)),
            "difference_ci_high": float(np.nanpercentile(rep_diffs, 97.5)),
            "ratio_yes_vs_no": point_ratio,
            "ratio_ci_low": float(np.nanpercentile(rep_ratios, 2.5)),
            "ratio_ci_high": float(np.nanpercentile(rep_ratios, 97.5)),
            "bootstrap_replicates": N_BOOT,
            "note": "Descriptive association standardized to the cohort publication-year distribution; not causal and not adjusted for field.",
        })
    return outcomes, pd.DataFrame(boot_rows)


def _design_matrix(data: pd.DataFrame, years: list[int], fields: list[str]) -> tuple[np.ndarray, list[str]]:
    field_values = data["Primary_Topic_Field"].fillna("Unknown").astype(str)
    columns = [np.ones(len(data)), data["Data_Shared"].astype(float).to_numpy(),
               data["Code_Shared"].astype(float).to_numpy()]
    names = ["intercept", "data_shared", "code_shared"]
    for year in years[1:]:
        columns.append((data["Publication_Year"].to_numpy() == year).astype(float))
        names.append(f"year_{year}")
    for field in fields[1:]:
        columns.append((field_values.to_numpy() == field).astype(float))
        names.append("field_" + field)
    return np.column_stack(columns), names


def _weighted_poisson_irls(x: np.ndarray, y: np.ndarray, weights: np.ndarray) -> np.ndarray:
    beta = np.zeros(x.shape[1], dtype=float)
    for _ in range(100):
        mu = np.exp(np.clip(x @ beta, -20, 20))
        information = x.T @ (x * (weights * mu)[:, None])
        score = x.T @ (weights * (y - mu))
        step = np.linalg.solve(information, score)
        beta_next = beta + step
        if np.max(np.abs(step)) < 1e-8:
            return beta_next
        beta = beta_next
    raise RuntimeError("Poisson IRLS did not converge")


def fit_field_adjusted_model(joined: pd.DataFrame, population: pd.DataFrame, n_boot: int = 500) -> pd.DataFrame:
    """Survey-stratified bootstrap for year/field-adjusted Poisson mean ratios."""
    data = joined.copy()
    keys = ["Publication_Year", "Data_Shared", "Code_Shared"]
    matched_n = data.groupby(keys, observed=True).size().rename("matched_n").reset_index()
    data = data.merge(population, on=keys, how="left").merge(matched_n, on=keys, how="left")
    data["analysis_weight"] = data["population_n"] / data["matched_n"]
    data["Primary_Topic_Field"] = data["Primary_Topic_Field"].fillna("Unknown").astype(str)
    field_counts = data["Primary_Topic_Field"].value_counts()
    rare_fields = field_counts[field_counts < 100].index
    data.loc[data["Primary_Topic_Field"].isin(rare_fields), "Primary_Topic_Field"] = "Other (field sample n<100)"
    years = sorted(int(v) for v in data["Publication_Year"].unique())
    fields = sorted(data["Primary_Topic_Field"].unique())
    x, names = _design_matrix(data, years, fields)
    y = data["cited_by_count"].to_numpy(float)
    weights = data["analysis_weight"].to_numpy(float)
    beta = _weighted_poisson_irls(x, y, weights)
    strata = list(data.groupby(["Publication_Year", "Data_Shared", "Code_Shared"], observed=True, sort=True).indices.values())
    rng = np.random.default_rng(SEED + 1)
    draws = []
    for _ in range(n_boot):
        indexes = np.concatenate([rng.choice(idx, size=len(idx), replace=True) for idx in strata])
        try:
            draws.append(_weighted_poisson_irls(x[indexes], y[indexes], weights[indexes]))
        except (RuntimeError, np.linalg.LinAlgError, FloatingPointError):
            continue
    boot = np.asarray(draws)
    output = []
    for term in ["data_shared", "code_shared"]:
        i = names.index(term)
        lo, hi = np.percentile(boot[:, i], [2.5, 97.5])
        output.append({
            "term": term,
            "mean_ratio": float(np.exp(beta[i])),
            "ci95_low": float(np.exp(lo)),
            "ci95_high": float(np.exp(hi)),
            "bootstrap_replicates_requested": n_boot,
            "bootstrap_replicates_converged": len(boot),
            "n": len(data),
            "adjustment": "Publication year and PLOS Primary_Topic_Field (fields with sample n<100 pooled); sampling-stratum bootstrap",
            "interpretation": "Adjusted association; not a causal effect",
        })
    return pd.DataFrame(output)


def main() -> None:
    PILOT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    frame, archive_sha256 = prepare_frame()
    sample, population = draw_sample(frame)
    sample_path = RAW_DIR / "osi_v11_plos_sample.csv"
    sample.to_csv(sample_path, index=False)
    doi_path = RAW_DIR / "openalex_doi_input.txt"
    dois = sample["doi_norm"].drop_duplicates().tolist()
    doi_path.write_text("\n".join(dois), encoding="utf-8")
    openalex_path = PILOT_DIR / "openalex_citations_asof_2026-11-02.csv"
    if openalex_path.exists():
        openalex = pd.read_csv(openalex_path)
    else:
        openalex = query_openalex(dois)
        openalex.to_csv(openalex_path, index=False)
    joined = sample.merge(openalex, on="doi_norm", how="left")
    joined["cited_by_count"] = pd.to_numeric(joined["cited_by_count"], errors="coerce")
    # No citation record is a missing match, not a zero-citation article.
    matched = joined.dropna(subset=["cited_by_count"]).copy()
    public_columns = ["doi", "Publication_Year", "Primary_Topic_Field", "Data_Shared", "Code_Shared", "Preprint_Match", "Protocol_Shared", "Registration_Shared", "cited_by_count", "openalex_id", "openalex_field", "analysis_weight"]
    strata = ["Publication_Year", "Data_Shared", "Code_Shared"]
    matched_n = matched.groupby(strata, observed=True).size().rename("matched_n").reset_index()
    public_sample = matched.merge(population, on=strata, how="left").merge(matched_n, on=strata, how="left")
    public_sample["analysis_weight"] = public_sample["population_n"] / public_sample["matched_n"]
    public_sample[[c for c in public_columns if c in public_sample.columns]].to_csv(PILOT_DIR / "analysis_sample.csv", index=False)
    matched.to_csv(RAW_DIR / "analysis_sample_full.csv", index=False)
    population.to_csv(RAW_DIR / "source_population_strata.csv", index=False)
    outcomes, standardized = build_outcomes(matched, population)
    model = fit_field_adjusted_model(matched, population)
    outcomes.to_csv(REPORT_DIR / "citation_descriptives.csv", index=False)
    standardized.to_csv(REPORT_DIR / "year_standardized_associations.csv", index=False)
    model.to_csv(REPORT_DIR / "field_adjusted_poisson.csv", index=False)
    yearly = frame.groupby("Publication_Year", observed=True).agg(
        articles=("DOI", "size"), data_share_rate=("Data_Shared", "mean"),
        code_share_rate=("Code_Shared", "mean"), preprint_rate=("Preprint_Match", "mean"),
        protocol_share_rate=("Protocol_Shared", lambda s: (s == "Yes").mean()),
        registration_rate=("Registration_Shared", "mean"),
    ).reset_index()
    yearly.to_csv(REPORT_DIR / "yearly_practices.csv", index=False)
    coverage = joined.groupby(["Publication_Year", "Data_Shared", "Code_Shared"], observed=True).agg(
        sampled=("doi_norm", "size"), openalex_matched=("cited_by_count", "count")
    ).reset_index()
    coverage.to_csv(REPORT_DIR / "openalex_match_coverage.csv", index=False)
    manifest = {
        "source": "PLOS Open Science Indicators v11",
        "source_doi": FIGSHARE_DOI,
        "archive_sha256": archive_sha256,
        "archive_url": FIGSHARE_ZIP,
        "scope": "PLOS research articles with 2018-2021 publication year and data/code sharing values",
        "sampling": {"seed": SEED, "n_per_year_data_code_stratum": N_PER_STRATUM,
                     "strata": ["Publication_Year", "Data_Shared", "Code_Shared"]},
        "citation_source": "OpenAlex works API, cited_by_count",
        "citation_snapshot_date": "2026-11-02",
        "api_batch_size": BATCH_SIZE,
        "bootstrap_replicates": N_BOOT,
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "sample_rows": len(sample), "openalex_matched_rows": len(matched),
        "license": "CC BY 4.0 (source dataset); derived sample contains DOI and article-level indicators only",
        "limitations": ["PLOS corpus only; publisher-specific and research-article selection bias",
                        "OSI flags are automated indicators, not direct reproducibility audits",
                        "OpenAlex citation counts retrieved on 2026-11-02; year- and topic-adjusted model",
                        "Observational association; no causal interpretation",
                        "Comparator, altmetric and policy outcomes are not part of this citation pilot"],
    }
    (REPORT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print("PLOS frame", len(frame), "sample", len(sample), "OpenAlex matched", len(matched))
    print("archive sha256", archive_sha256)
    print("yearly practices\n", yearly.to_string(index=False))
    print("year standardized association\n", standardized.to_string(index=False))
    print("field adjusted Poisson association\n", model.to_string(index=False))
    print("unadjusted weighted descriptives\n", outcomes.to_string(index=False))
    print("OpenAlex match rates by status\n", coverage.to_string(index=False))

if __name__ == "__main__":
    main()
