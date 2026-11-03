# REPRO2IMPACT

**Diseño e implementación de indicadores de reproducibilidad para la medición del impacto académico y social de la investigación.**

*Designing and implementing reproducibility indicators to measure the academic and social impact of research.*

REPRO2IMPACT develops open, transparent and verifiable ways of documenting reproducibility and open research practices, so that research assessment can recognise them alongside, and not behind, traditional output counts. Every result is released as open software or open data, with a persistent identifier and documented limitations.

## Outputs

| Output | What it does | Use it | Cite |
| --- | --- | --- | --- |
| **OpenResearchMetrics** | Nine open science indicators in five families (availability, accessibility, reuse, declared reproducibility, methodological transparency), each reported on its own with its evidence and limits; no composite score | [Web tool](https://pablosancheznunez.com/openresearchmetrics/) · [Code](https://github.com/pablosancheznunez/openresearchmetrics) | [10.5281/zenodo.23881633](https://doi.org/10.5281/zenodo.23881633) |
| **ReproImage** | Integrity, provenance and reproducibility checks for scientific images: identical files, identical pixels and visually similar images in eight orientations, with RO-Crate provenance; Python tool and R package | [Documentation](https://pablosancheznunez.com/reproimage/) · [Code](https://github.com/pablosancheznunez/reproimage) | [10.5281/zenodo.23881635](https://doi.org/10.5281/zenodo.23881635) |
| **Narrative CV Crosswalk** | Links the sections of narrative CVs (R4RI, Spanish CVA) to the evidence held by ORCID, OpenAlex, DataCite and OpenAIRE, showing what infrastructures can document and what only the researcher can tell; web tool and R package | [Web tool](https://pablosancheznunez.com/narrative-cv-crosswalk/) · [R package](https://pablosancheznunez.com/narrative-cv-crosswalk/r/) · [Code](https://github.com/pablosancheznunez/narrative-cv-crosswalk) | [10.5281/zenodo.23881631](https://doi.org/10.5281/zenodo.23881631) |
| **research-tools-ops** | Shared maintenance that keeps the tools working with minimal human time while every scientific change waits for review | [Code](https://github.com/pablosancheznunez/research-tools-ops) | [10.5281/zenodo.23881629](https://doi.org/10.5281/zenodo.23881629) |

## Empirical study

Do transparency practices that make research reproducible (open data, open code, preregistration, open materials) go with more academic and social impact, and do journal policies change them? The study follows the approved proposal, with the design revised so that it measures what it claims:

- **A profile, not an index.** Each practice is reported on its own; a composite appears only as a sensitivity analysis over random weightings.
- **Potential vs actual reproducibility.** The profile measures *conditions* for reproducibility; a reproduction substudy of 40 articles measures how often they hold.
- **Association vs effect.** Article-level comparisons are adjusted associations with E-values; causal language is kept for the staggered difference-in-differences on journal policies.
- **Unverifiable is not no.** Articles whose full text cannot be read are reported apart, never counted as not sharing.

| Document | Content |
| --- | --- |
| [Protocolo](protocol/protocolo.md) | Full study protocol (Spanish), with every change from the proposal and its reason |
| [Preregistration](protocol/preregistration.md) | Draft for OSF: hypotheses H1–H4, analysis plan, inference criteria |
| [Libro de códigos](protocol/codebook.md) | Manual coding instrument and agreement threshold (κ ≥ 0.70) |
| [Reproducción](protocol/reproduction.md) | Computational reproduction substudy |
| [Revisión sistemática](protocol/revision-sistematica.md) | PRISMA 2020 review of transparency and impact (phase 1) |
| [Validación con expertos](protocol/validacion-expertos.md) | Two-round Delphi on the content validity of each indicator |
| [Gestión de datos](protocol/plan-gestion-datos.md) | Data management plan, FAIR, licences and DPIA screening |
| [Data dictionary](outputs/README.md) | Every column of every output file |
| [Panel](https://pablosancheznunez.com/repro2impact/dashboard/) | Prevalence by field and year and associations with citations |

**Run it.** R ≥ 4.3 with `targets`, `httr2`, `jsonlite`, `digest`, `glmmTMB`, `MASS`, `MatchIt`, `cobalt` and `fixest`:

```r
targets::tar_make()                                           # pilot: 20 articles per field x year
Sys.setenv(REPRO2IMPACT_PHASE = "main"); targets::tar_make()  # main study: 300 per cell
testthat::test_dir("tests/testthat")                          # detectors and analyses, offline
```

Optional keys, read from environment variables: `OPENALEX_API_KEY` (larger daily budget), `ALTMETRIC_KEY` and `OVERTON_KEY`. Without them the corresponding outcomes are missing, never zero. Every API response is cached in `data/cache/`, so a run can be repeated and audited offline. Journal policies are curated by hand in [`data-raw/journal_policies.csv`](data-raw/journal_policies.csv); only rows with a source URL enter the analysis.

## Principles

- **Responsible assessment.** Aligned with the San Francisco Declaration on Research Assessment (DORA) and the Agreement on Reforming Research Assessment (CoARA): indicators support qualitative judgement and never replace it.
- **No single score.** Indicators are reported separately, with their evidence; nothing is added up into a ranking.
- **Verifiable.** Every result can be traced to its sources. When something cannot be verified it is reported as such, never as zero or absence.
- **Reproducible.** Algorithms and definitions are written down and versioned; independent implementations are tested against the same expected results.
- **Open.** Code under the MIT License, data and documentation under CC BY 4.0, versions archived in Zenodo with DOIs.

## Resumen en español

REPRO2IMPACT desarrolla formas abiertas, transparentes y verificables de documentar la reproducibilidad y las prácticas de ciencia abierta, para que la evaluación de la investigación pueda reconocerlas. Sus resultados son herramientas y datos abiertos con identificador persistente: indicadores de ciencia abierta sin puntuación agregada (OpenResearchMetrics), comprobaciones de integridad y procedencia de imágenes científicas (ReproImage) y una correspondencia entre los CV narrativos y las evidencias de las infraestructuras abiertas (Narrative CV Crosswalk).

## Contact

Pablo Sánchez-Núñez, Universidad Carlos III de Madrid, [OpenScienceLab](https://opensciencelab.uc3m.es/) · [pablosancheznunez.com](https://pablosancheznunez.com) · ORCID [0000-0001-7845-9506](https://orcid.org/0000-0001-7845-9506)

Issues and suggestions are welcome in each output's repository.

## License

The text of this repository is licensed under [CC BY 4.0](LICENSE.md). Each output has its own license, stated in its repository.
