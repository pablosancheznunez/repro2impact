# REPRO2IMPACT

Open research project studying how article-level transparency practices relate to scholarly and societal attention. This repository contains a preregistration draft, coding schema, reproducible analysis pipeline, interactive dashboard, and an exploratory pilot on PLOS Open Science Indicators v11. The pilot extends prior work; it is not confirmatory or causal.

## Start here

1. Read `docs/protocol.md` and resolve every `[DECIDIR]` item with the research team before collecting data.
2. Copy `data/template_articles.csv` to a working data folder and code a pilot using `docs/data_dictionary.csv` and `docs/coding_manual.md`.
3. Obtain the required institutional approvals and confirm database licenses and redistribution limits.
4. Install the package and dashboard dependencies: `python -m pip install -e ".[dashboard]"`
5. Run the analysis: `python -m repro2impact.cli --input data/articles.csv --output results`
6. Start the dashboard: `streamlit run app/dashboard.py`

The provisional project index is a **transparency and policy-context score**, not a verified measure of reproducibility. It has four dimensions: data, code, methods documentation, and the journal policy effective for the article. Because policy is contextual, report the composite alongside its components and an article-practice subscore. Do not describe an association as causal unless a defensible policy-change design has been specified and its assumptions examined.

## Project layout

- `docs/protocol.md` — preregistration-ready protocol draft and unresolved design choices.
- `docs/coding_manual.md` — coding rules for observable evidence and unknown values.
- `docs/data_dictionary.csv` — fields, types, definitions, allowed values.
- `data/template_articles.csv` — empty input template.
- `src/repro2impact/` — validation, scoring, descriptive analysis, and adjusted count models.
- `app/dashboard.py` — upload-and-explore dashboard. In local use, data stays in the local process; if hosted, uploaded files are sent to that host and its storage/logging policy must be reviewed before use.
- `results/` — generated locally; keep raw or licensed data out of public releases.

## Data provenance

OpenAlex can be considered as an open metadata source, subject to a documented query and retrieval date. The current pipeline does not download or silently select a population. Freeze the sampling frame and query before extraction. Commercial sources mentioned in the application (for example Web of Science, InCites, Altmetric.com, or Dimensions) require confirmed institutional access and license review. Do not upload or redistribute licensed records.

## Analysis boundaries

- Unknown or ambiguous coding is not silently treated as absence.
- The score is calculated only when at least three of four practices have determinate codes.
- Journal policy is not included in the article score.
- The default model is an adjusted Poisson regression with HC3 robust standard errors and discipline/year fixed effects when estimable. A negative-binomial model is provided as a sensitivity analysis.
- These models estimate adjusted associations. Unmeasured confounding, source coverage, selection into sharing, and differential citation windows remain limitations.

## Current project status

An exploratory PLOS OSI v11 citation pilot (2018–2021; n=3,424; 100% DOI match) is available in `reports/pilot_osi_v11/`. See `reports/pilot_osi_v11/OUTCOMES_ES.md` for Spanish presentation wording and limitations. This reaches the proposal's sample-size range but does not supply its cross-publisher, social-impact, policy-impact, or reuse analyses.

## Pilot outcomes

The exploratory weighted Poisson model found adjusted citation mean ratios of 1.12 for data sharing (95% CI 0.99–1.27) and 1.19 for code sharing (1.05–1.34), adjusted for publication year and PLOS topic field. These are observational associations, not causal effects. Full method, caveats, and citations: `reports/pilot_osi_v11/OUTCOMES_ES.md`. The full source archive and text-rich intermediates are excluded from Git; the public derived sample is minimized.
