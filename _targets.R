# REPRO2IMPACT study pipeline. Run with targets::tar_make().
# REPRO2IMPACT_PHASE=pilot (default) draws 20 articles per cell; =main draws 300.

library(targets)
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) source(f)
tar_option_set(packages = c("httr2", "jsonlite", "digest", "glmmTMB", "MASS",
                            "MatchIt", "cobalt", "fixest"))

phase <- Sys.getenv("REPRO2IMPACT_PHASE", "pilot")
per_cell <- if (phase == "main") study_config()$per_cell_main else study_config()$per_cell_pilot

list(
  tar_target(articles, draw_sample(per_cell)),
  tar_target(collected, collect_profiles(articles)),
  tar_target(social, collect_social(articles)),
  tar_target(frame, add_normalised_citations(
    merge(build_analysis_frame(articles, collected$profiles), social, by = "doi"))),
  tar_target(policies, read_policies()),
  tar_target(prevalence_tab, prevalence(frame)),
  tar_target(assoc, association_table(frame, outcomes = c("cit_5y", "wikipedia"))),
  tar_target(sensitivity, weight_sensitivity(frame, n_draws = if (phase == "main") 1000 else 200)),
  tar_target(did, fit_policy_did(frame, policies)),
  tar_target(coding_sheet, make_coding_sheet(frame, n = if (phase == "main") 450 else 60,
                                             path = file.path("outputs", paste0("coding_sheet_", phase, ".csv")))),
  tar_target(hetero, heterogeneity(frame)),
  tar_target(reuse, reuse_summary(collected$links)),
  tar_target(outputs, write_outputs(frame, prevalence_tab, assoc, sensitivity, did,
                                    collected$links, hetero, reuse), format = "file")
)
