# Social impact outcomes (protocol section 3.4). Wikipedia is open; Altmetric
# and Overton need institutional keys and are skipped (NA) when absent, never
# filled with zeros.

wikipedia_citations <- function(doi, langs = c("en", "es")) {
  total <- 0L
  for (l in langs) {
    res <- tryCatch(http_get(sprintf("https://%s.wikipedia.org/w/api.php", l), list(
      action = "query", list = "search", format = "json", srlimit = 1,
      srsearch = sprintf('insource:"%s"', doi))), error = function(e) NULL)
    if (is.null(res)) return(NA_integer_)
    total <- total + as.integer(res$query$searchinfo$totalhits %||% 0L)
  }
  total
}

altmetric_score <- function(doi) {
  key <- Sys.getenv("ALTMETRIC_KEY")
  if (!nzchar(key)) return(NA_real_)
  res <- tryCatch(http_get(paste0("https://api.altmetric.com/v1/doi/", doi), list(key = key)),
                  error = function(e) NULL)
  # A 404 from Altmetric means no attention was recorded: a real zero.
  if (is.null(res)) return(0)
  as.numeric(res$score %||% 0)
}

policy_mentions <- function(doi) {
  key <- Sys.getenv("OVERTON_KEY")
  if (!nzchar(key)) return(NA_integer_)
  res <- tryCatch(http_get("https://app.overton.io/documents.php", list(
    cites_doi = doi, format = "json", api_key = key)), error = function(e) NULL)
  if (is.null(res)) return(NA_integer_)
  as.integer(res$query$total_results %||% 0L)
}

add_normalised_citations <- function(df) {
  cell <- paste(df$stratum, df$year)
  means <- tapply(df$cit_5y, cell, mean, na.rm = TRUE)
  df$cit_norm <- df$cit_5y / as.numeric(means[cell])
  df
}
