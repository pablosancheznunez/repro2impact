# Open full text for the detectors. Only legally open sources are used:
# Europe PMC (open access subset) and, optionally, the open access landing
# page reported by OpenAlex. Anything else is recorded as unavailable, which
# makes the text-based indicators "unverifiable" rather than "no".

get_fulltext <- function(doi, pmcid = NA, oa_url = NA, use_landing = TRUE) {
  # OpenAlex sometimes points to the PMC page rather than giving the PMCID.
  if (is.na(pmcid) && !is.na(oa_url) && grepl("ncbi.nlm.nih.gov/pmc/articles/", oa_url)) {
    pmcid <- paste0("PMC", sub("^PMC", "", sub(".*/articles/([^/]+).*", "\\1", oa_url)))
    oa_url <- NA
  }
  if (!is.na(pmcid)) {
    xml <- tryCatch(
      http_get(sprintf("https://www.ebi.ac.uk/europepmc/webservices/rest/%s/fullTextXML", pmcid),
               as = "text"),
      error = function(e) NULL)
    if (!is.null(xml) && nchar(xml) > 2000) {
      return(list(text = strip_markup(xml), source = "europepmc"))
    }
  }
  if (use_landing && !is.na(oa_url)) {
    html <- tryCatch(http_get(oa_url, as = "text", pause = 1, tries = 1, timeout = 20),
                     error = function(e) NULL)
    if (!is.null(html)) {
      txt <- strip_markup(html)
      # Landing pages that only carry an abstract are too short to judge.
      if (nchar(txt) > 15000) return(list(text = txt, source = "oa_landing"))
    }
  }
  list(text = NA_character_, source = "unavailable")
}

strip_markup <- function(x) {
  x <- gsub("(?s)<(script|style)[^>]*>.*?</\\1>", " ", x, perl = TRUE)
  # Keep link targets: repository URLs often live only in href attributes.
  x <- gsub("<a[^>]+href=\"([^\"]+)\"[^>]*>", " \\1 ", x, perl = TRUE)
  x <- gsub("<ext-link[^>]+xlink:href=\"([^\"]+)\"[^>]*>", " \\1 ", x, perl = TRUE)
  x <- gsub("<[^>]+>", " ", x)
  x <- gsub("&nbsp;|&#160;", " ", x)
  x <- gsub("&amp;", "&", x)
  gsub("\\s+", " ", x)
}
