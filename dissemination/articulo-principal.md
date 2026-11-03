# Main article: draft skeleton

**Target journals** (from the proposal): *Quantitative Science Studies* (open, accepts preregistered studies), *Scientometrics*, *Research Evaluation*, *Journal of Informetrics*. QSS is recommended first: it is diamond open access and fits the study's open principles.

**Format:** Stage 1 Registered Report, if the journal accepts it before the main sample is drawn; otherwise a preregistered research article.

---

## Title (provisional)

Do transparency practices pay off? Data, code and preregistration and the academic and social impact of research in the social sciences

## Abstract (structured, ≤ 250 words)

- **Purpose.** [One sentence.]
- **Design.** Preregistered stratified cohort of 4,500 articles in Psychology, Communication and Computational social science (2016–2020); transparency practices reported as a profile of separate indicators; negative binomial mixed models, matching, weighting and E-values; staggered difference-in-differences for journal policies.
- **Findings.** [Fill in from `reports/informe-tecnico-main.md`.]
- **Originality.** [No composite score; unverifiable vs absent; actual reproducibility substudy.]

## 1. Introduction

1. The replication debate and the move to transparency (OSC 2015; Camerer et al. 2016, 2018; Hardwicke et al. 2020).
2. What is known about the citation advantage of open data (Piwowar & Vision 2013; Colavizza et al. 2020) and about altmetrics as complementary signals (Haustein 2016). Gaps:
   - mostly biomedical;
   - availability is conflated with reproducibility;
   - composite indices;
   - associations are presented as effects.
3. Research questions: RQ1 prevalence; RQ2 association with academic and social impact; RQ3 effect of journal policies; RQ4 potential vs actual reproducibility.
4. Alignment with responsible assessment (DORA, CoARA): why a profile and not a score.

## 2. Methods

*Adapted from `protocol/protocolo.md`; report any deviation from the preregistration in a table.*

### 2.1 Sample
Seeded stratified random sample from OpenAlex; strata and filters as in `R/config.R`; exclusions.

### 2.2 Transparency profile
- Five indicators, each with three values (yes, no, unverifiable).
- Sources: Europe PMC, publisher TDM, open access landing pages, DataCite, Crossref.
- Detector rules and version.
- Validation: double manual coding of 450 articles; κ; sensitivity, specificity and PPV of each detector.

### 2.3 Journal policies
Hand-curated adoption years with documentary sources.

### 2.4 Outcomes
- Citations in years +1 to +5.
- Field–year normalisation; FWCI and CNCI as checks.
- Wikipedia, policy documents, Altmetric.
- Reuse among sharers only.

### 2.5 Analysis
- Negative binomial mixed models (hurdle models for zero-heavy outcomes).
- Robustness: Poisson pseudo-likelihood, PSM, IPW and entropy balancing.
- E-values.
- Holm correction for H1–H3.
- Sun–Abraham difference-in-differences.
- Dirichlet weight sensitivity.
- Heterogeneity analyses.

### 2.6 Reproduction substudy
Forty articles; bounded effort; five-level classification.

### 2.7 Open materials
Repository, Zenodo DOI, licences, offline rerun from the cache.

## 3. Results

- **Table 1.** Sample and full-text coverage by field and year.
- **Figure 1.** Prevalence of each practice by year and field, with Wilson CIs; unverifiable shown separately.
- **Table 2.** Detector accuracy against manual coding.
- **Table 3.** Rate ratios by indicator and outcome across estimators, with E-values.
- **Figure 2.** Event study of journal policy adoption (first stage: practices; second stage: citations).
- **Figure 3.** Distribution of the composite association over random weightings.
- **Table 4.** Reproduction outcomes.

## 4. Discussion

1. Main findings, as associations (causal claims only for the difference-in-differences).
2. Potential vs actual reproducibility.
3. Coverage as a finding: what assessment systems cannot see.
4. Implications for journals, funders and universities (link to the policy brief).
5. Limitations:
   - unmeasured confounding (prestige);
   - detector error;
   - field selection;
   - English and Spanish only;
   - OpenAlex classification.

## 5. Conclusion

## Declarations

- **Preregistration:** [OSF link].
- **Data and code:** [Zenodo DOI].
- **Funding:** Programa Propio de Investigación, UC3M (convocatoria 2025).
- **Author contributions (CRediT):** [fill in].
- **Competing interests:** none.
- **Use of AI tools:** [declare as required by the journal; aitrail can produce the statement].
