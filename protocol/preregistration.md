# Preregistration (OSF Preregistration template) · DRAFT

**Title:** Transparency practices and the academic and social impact of research: a stratified cohort study with a staggered difference-in-differences design

**Status:** draft, to be registered on OSF before the main sample is drawn (pilot data only have been collected). The full protocol in Spanish is [`protocolo.md`](protocolo.md).

## 1. Hypotheses

Confirmatory:

- **H1.** Articles whose data are openly shared (`data_shared`) receive more citations in the five years after publication than comparable articles without shared data. One-sided; rate ratio > 1.
- **H2.** Articles with openly shared analysis code (`code_shared`) receive more citations, under the same specification. One-sided.
- **H3.** Articles that link a preregistration (`preregistered`) receive more citations. Two-sided, because the literature gives no clear direction.
- **H4.** The adoption of open-practice badges or TOP data policies by a journal increases the share of its articles with `data_shared` (first stage). One-sided.

Exploratory: associations with Wikipedia citations, policy mentions and Altmetric attention; the policy → citation effect; heterogeneity by field and open access status; reuse of shared objects among sharers.

## 2. Design

Observational, retrospective cohort of research articles published 2016–2020. The sample is stratified by field (Psychology: OpenAlex subfields 3205 and 3207; Communication: subfield 3315; Computational social science: topic T13910) and by year, with 300 articles per cell (N = 4,500), drawn with the seeded OpenAlex `sample` parameter. The seed is fixed in `R/config.R` before registration.

## 3. Variables

**Exposures.** These are article-level indicators, each coded `yes`, `no` or `unverifiable`:

- `data_shared`
- `data_statement`
- `code_shared`
- `preregistered`
- `materials_shared`

They are detected by versioned rules applied to DataCite and Crossref relations and to open full text. Detector accuracy is validated against double manual coding of 450 articles (Cohen's κ ≥ .70). Indicators are never summed into a score for confirmatory tests.

**Outcomes.**

- Primary: `cit_5y`, citations in publication years +1 to +5 (OpenAlex `counts_by_year`).
- Secondary: field-year normalised citations; FWCI; Wikipedia citing articles; policy mentions; Altmetric attention.

**Covariates.** Field × year, journal, open access status, number of authors, international collaboration, number of references, declared funding and number of institutions.

## 4. Analysis plan

- **H1–H3.** Negative binomial mixed models (`glmmTMB`, `nbinom2`): `cit_5y ~ indicator + covariates + field×year + (1 | journal)`. Each hypothesis is tested in its own model; Holm correction across H1–H3 at α = .05. `unverifiable` cases are excluded from the corresponding model, and their number is reported.
- **Robustness.** Propensity-score matching (nearest neighbour, caliper 0.2 SD, exact on field × year), inverse-probability weighting, and E-values for unmeasured confounding.
- **H4.** Staggered difference-in-differences at article level with the Sun and Abraham (2021) estimator (`fixest::sunab`), using journal and year fixed effects and errors clustered by journal; event window −3 to +4. Pre-trends are checked with a joint test of the leads.
- **Sensitivity of any composite.** Associations are recomputed under 1,000 Dirichlet weight vectors; only the distribution is reported.

## 5. Inference criteria

Rate ratios and 95% CIs are reported throughout. A confirmatory hypothesis is supported if the Holm-adjusted p < .05 and the direction matches the hypothesis. Null results will be reported with equivalence bounds of RR in [0.90, 1.11].

## 6. Data exclusion

The following are excluded:

- retracted articles;
- paratext and editorials;
- articles without a DOI;
- journals with fewer than 2 sampled articles, from the random-effect models only (a sensitivity analysis keeps them).

## 7. Sample size justification

With 4,500 articles, an expected `data_shared` prevalence of about 15% and a negative binomial dispersion estimated from the pilot, the design has more than 90% power to detect RR = 1.20 at α = .05 (simulation in `R/simulate.R`, `power_sim()`).
