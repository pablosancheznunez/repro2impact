# Study configuration. Changing anything here after preregistration is a
# protocol deviation and must be recorded in protocol/deviations.md.

study_config <- function() {
  list(
    version = "1.0.0",
    years = 2016:2020,
    strata = list(
      psychology = "primary_topic.subfield.id:3205|3207",
      communication = "primary_topic.subfield.id:3315",
      computational_social_science = "primary_topic.id:T13910"
    ),
    per_cell_main = 300L,
    per_cell_pilot = 20L,
    seed = 20261103L,
    citation_window = 1:5,
    mailto = Sys.getenv("REPRO2IMPACT_MAILTO", "psnunez@bib.uc3m.es"),
    user_agent = "repro2impact/1.0 (https://github.com/pablosancheznunez/repro2impact)",
    indicators = c("data_statement", "data_shared", "code_shared",
                   "preregistered", "materials_shared")
  )
}
