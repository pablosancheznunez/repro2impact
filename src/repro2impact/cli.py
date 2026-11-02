from __future__ import annotations
import argparse
from pathlib import Path
import pandas as pd
from .analysis import load_articles, score_transparency, describe, fit_count_models


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze a REPRO2IMPACT article dataset")
    parser.add_argument("--input", required=True, help="CSV conforming to docs/data_dictionary.csv")
    parser.add_argument("--output", default="results", help="Output directory")
    args = parser.parse_args()
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    articles = score_transparency(load_articles(args.input))
    articles.to_csv(output / "scored_articles.csv", index=False)
    for name, table in describe(articles).items():
        table.to_csv(output / f"{name}.csv", index=False)
    if articles["transparency_score"].notna().sum() >= 30:
        for name, table in fit_count_models(articles).items():
            table.to_csv(output / f"model_{name}.csv", index=False)
    else:
        pd.DataFrame([{"status": "not_fit", "reason": "Fewer than 30 scored records"}]).to_csv(
            output / "model_status.csv", index=False
        )
    print(f"Wrote analysis outputs to {output.resolve()}")

if __name__ == "__main__":
    main()
