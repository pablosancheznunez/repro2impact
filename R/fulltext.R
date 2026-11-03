# Full text for the detectors, from legal sources only, in this order:
#   1. Europe PMC (open access subset)
#   2. Publisher text-and-data-mining (TDM) links declared in Crossref, using
#      the institution's subscription: works from the UC3M network or with
#      ELSEVIER_API_KEY / WILEY_TDM_TOKEN set (protocol section 3.2)
#   3. The open access landing page reported by OpenAlex
# Anything else is recorded as unavailable, which makes the text-based
# indicators "unverifiable" rather than "no".

get_fulltext <- function(doi, pmcid = NA, oa_url = NA, use_landing = TRUE,
                         use_tdm = Sys.getenv("REPRO2IMPACT_TDM", "false") == "true") {
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
    if (!is.null(xml) && nchar(xml, allowNA = TRUE) %in% 2001:1e8) {
      return(list(text = jats_text(xml), source = "europepmc"))
    }
  }
  if (use_tdm) {
    txt <- tdm_fulltext(doi)
    if (!is.null(txt)) return(list(text = txt, source = "publisher_tdm"))
  }
  if (use_landing && !is.na(oa_url)) {
    html <- tryCatch(http_get(oa_url, as = "text", pause = 1, tries = 1, timeout = 20),
                     error = function(e) NULL)
    if (!is.null(html)) {
      txt <- strip_markup(article_region(html))
      # Landing pages that only carry an abstract are too short to judge.
      if (nchar(txt) > 15000) return(list(text = txt, source = "oa_landing"))
    }
  }
  list(text = NA_character_, source = "unavailable")
}

# JATS: keep body and back matter (where data availability statements and
# notes live); drop front matter, whose processing metadata produced false
# positives in the pilot.
jats_text <- function(xml) {
  xml <- gsub("(?s)<front>.*?</front>", " ", xml, perl = TRUE)
  xml <- gsub("(?s)<custom-meta-group>.*?</custom-meta-group>", " ", xml, perl = TRUE)
  strip_markup(xml)
}

# Keep the article itself: navigation, headers, footers and menus on
# publisher pages produced false positives in the pilot.
article_region <- function(html) {
  html <- gsub("(?s)<(nav|header|footer|aside|form)\\b[^>]*>.*?</\\1>", " ", html, perl = TRUE)
  m <- regmatches(html, regexpr("(?s)<article\\b.*</article>", html, perl = TRUE))
  if (length(m) && nchar(m) > 5000) return(m)
  m <- regmatches(html, regexpr("(?s)<main\\b.*</main>", html, perl = TRUE))
  if (length(m) && nchar(m) > 5000) return(m)
  html
}

# Publisher TDM through the links Crossref declares for text mining.
tdm_fulltext <- function(doi) {
  res <- tryCatch(http_get(paste0("https://api.crossref.org/works/", utils::URLencode(doi, reserved = TRUE)),
                           list(mailto = study_config()$mailto)), error = function(e) NULL)
  links <- res$message$link %||% list()
  links <- Filter(function(l) identical(l$`intended-application`, "text-mining"), links)
  headers <- list()
  if (nzchar(Sys.getenv("ELSEVIER_API_KEY"))) headers$`X-ELS-APIKey` <- Sys.getenv("ELSEVIER_API_KEY")
  if (nzchar(Sys.getenv("WILEY_TDM_TOKEN"))) headers$`Wiley-TDM-Client-Token` <- Sys.getenv("WILEY_TDM_TOKEN")
  # Prefer XML or HTML; PDF only if pdftools is installed.
  ord <- order(!grepl("xml|html", vapply(links, function(l) l$`content-type` %||% "", "")))
  for (l in links[ord]) {
    type <- l$`content-type` %||% ""
    if (grepl("pdf", type)) {
      if (!requireNamespace("pdftools", quietly = TRUE)) next
      path <- file.path(cache_dir(), paste0(digest::digest(l$URL, algo = "sha1"), ".pdf"))
      ok <- file.exists(path) || tryCatch({
        req <- httr2::req_headers(httr2::request(l$URL), !!!headers)
        httr2::req_perform(httr2::req_timeout(req, 60), path = path); TRUE
      }, error = function(e) FALSE)
      if (ok) {
        txt <- tryCatch(paste(pdftools::pdf_text(path), collapse = " "), error = function(e) "")
        if (nchar(txt) > 15000) return(gsub("\\s+", " ", txt))
      }
    } else {
      body <- tryCatch(http_get(l$URL, as = "text", headers = headers, tries = 1, timeout = 30),
                       error = function(e) NULL)
      if (!is.null(body)) {
        txt <- strip_markup(article_region(body))
        if (nchar(txt) > 15000) return(txt)
      }
    }
  }
  NULL
}

strip_markup <- function(x) {
  # Pages in legacy encodings would otherwise yield NA lengths downstream.
  raw <- x
  x <- iconv(raw, from = "UTF-8", to = "UTF-8", sub = " ")
  if (is.na(x)) x <- iconv(raw, from = "latin1", to = "UTF-8", sub = " ")
  if (is.na(x)) return("")
  x <- gsub("(?s)<(script|style)[^>]*>.*?</\\1>", " ", x, perl = TRUE)
  # Keep link targets: repository URLs often live only in href attributes.
  x <- gsub("<a[^>]+href=\"([^\"]+)\"[^>]*>", " \\1 ", x, perl = TRUE)
  x <- gsub("<ext-link[^>]+xlink:href=\"([^\"]+)\"[^>]*>", " \\1 ", x, perl = TRUE)
  # Block-level tags end a sentence, so headings and menu items do not merge.
  x <- gsub("</?(p|div|li|h[1-6]|sec|title|td|tr|br)\\b[^>]*>", " . ", x, perl = TRUE)
  x <- gsub("<[^>]+>", " ", x)
  x <- gsub("&nbsp;|&#160;", " ", x)
  x <- gsub("&amp;", "&", x)
  gsub("\\s+", " ", x)
}
