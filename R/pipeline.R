# Steps called by _targets.R. Kept as functions so they can also be run by
# hand on a handful of DOIs.

collect_profiles <- function(articles, use_landing = TRUE) {
  rows <- vector("list", nrow(articles))
  links <- vector("list", nrow(articles))
  for (i in seq_len(nrow(articles))) {
    a <- articles[i, ]
    ft <- get_fulltext(a$doi, a$pmcid, a$oa_url, use_landing = use_landing)
    lk <- datacite_links(a$doi)
    sup <- crossref_supplement(a$doi)
    rows[[i]] <- profile_to_row(a$doi, profile_article(a$doi, ft$text, lk, sup), ft$source)
    links[[i]] <- lk
  }
  list(profiles = do.call(rbind, rows), links = do.call(rbind, links))
}

collect_social <- function(articles) {
  data.frame(
    doi = articles$doi,
    wikipedia = vapply(articles$doi, wikipedia_citations, integer(1)),
    altmetric = vapply(articles$doi, altmetric_score, numeric(1)),
    policy = vapply(articles$doi, policy_mentions, integer(1)),
    row.names = NULL
  )
}

read_policies <- function(path = "data-raw/journal_policies.csv") {
  p <- utils::read.csv(path, stringsAsFactors = FALSE)
  # Only documented policies enter the analysis.
  p[nzchar(p$source_url) & !is.na(p$adoption_year), , drop = FALSE]
}

write_outputs <- function(frame, prevalence_tab, assoc, sensitivity, did, links,
                          hetero = data.frame(), reuse = data.frame(), dir = "outputs") {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  public <- frame[, setdiff(names(frame), c("altmetric", "policy"))]
  utils::write.csv(public, file.path(dir, "articles.csv"), row.names = FALSE, na = "")
  utils::write.csv(prevalence_tab, file.path(dir, "prevalence.csv"), row.names = FALSE, na = "")
  utils::write.csv(assoc, file.path(dir, "associations.csv"), row.names = FALSE, na = "")
  utils::write.csv(sensitivity, file.path(dir, "weight_sensitivity.csv"), row.names = FALSE, na = "")
  utils::write.csv(links, file.path(dir, "linked_objects.csv"), row.names = FALSE, na = "")
  utils::write.csv(hetero, file.path(dir, "heterogeneity.csv"), row.names = FALSE, na = "")
  utils::write.csv(reuse, file.path(dir, "reuse.csv"), row.names = FALSE, na = "")
  dash <- list(
    generated = format(Sys.time(), "%Y-%m-%d"),
    config = study_config()[c("version", "years")],
    detector_version = detector_version,
    n_articles = nrow(frame),
    coverage = as.list(table(frame$fulltext_source)),
    prevalence = prevalence_tab,
    associations = assoc,
    heterogeneity = hetero,
    reuse = reuse,
    sensitivity = if (nrow(sensitivity)) as.list(stats::quantile(sensitivity$rr_per_sd,
                                                  c(.025, .5, .975), na.rm = TRUE)) else NULL,
    policy_did = if (isTRUE(did$ok)) "estimated" else did$reason
  )
  jsonlite::write_json(dash, file.path("dashboard", "results.json"), auto_unbox = TRUE,
                       digits = 4, na = "null", pretty = TRUE)
  file.path(dir, c("articles.csv", "prevalence.csv", "associations.csv"))
}
