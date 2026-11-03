# Transparency indicators (protocol section 3.2). Each indicator is "yes",
# "no" or "unverifiable"; it is never summed with the others. The rules are
# deliberately explicit so that every "yes" can be traced to its evidence.

detector_version <- "1.0.0"

repo_pattern <- paste0(
  "(osf\\.io/[a-z0-9]{4,}|zenodo\\.org|doi\\.org/10\\.5281/zenodo|datadryad\\.org|",
  "doi\\.org/10\\.5061/dryad|figshare\\.com|doi\\.org/10\\.6084/m9\\.figshare|",
  "dataverse|icpsr\\.umich\\.edu|openicpsr|ukdataservice|reshare\\.ukdataservice|",
  "psycharchives|data\\.mendeley\\.com|doi\\.org/10\\.17632|gesis\\.org|",
  "doi\\.org/10\\.7910/dvn|zenodo|open science framework)"
)
code_host_pattern <- "(github\\.com/[A-Za-z0-9_.-]+|gitlab\\.com/|bitbucket\\.org/|codeocean\\.com|software heritage)"
data_words <- "\\b(data|dataset|datasets|datos|raw data|replication (files|package))\\b"
code_words <- "\\b(code|codes|script|scripts|syntax|analysis files|replication (files|package)|código)\\b"
material_words <- "\\b(materials|stimuli|questionnaires?|instruments?|survey items|protocols?|codebook|materiales|estímulos|cuestionarios?)\\b"
statement_pattern <- paste0(
  "(data availability( statement)?|availability of data|data accessibility statement|",
  "data sharing statement|open practices statement|disponibilidad de (los )?datos)"
)
on_request_pattern <- "(up)?on (reasonable )?request|from the corresponding author|bajo petición|previa solicitud"
prereg_pattern <- paste0(
  "(pre-?regist\\w*.{0,120}(osf\\.io/[a-z0-9]{4,}|aspredicted|clinicaltrials\\.gov|socialscienceregistry)|",
  "(osf\\.io/[a-z0-9]{4,}|aspredicted\\.org/[a-z0-9]+|aspredicted #?\\d+).{0,120}pre-?regist\\w*|",
  "aspredicted\\.org|\\bNCT\\d{8}\\b|\\bCRD42\\d{6,}\\b|AEARCTR-\\d+|registered report)"
)

split_sentences <- function(text) {
  s <- unlist(strsplit(text, "(?<=[.!?;])\\s+(?=[A-ZÁÉÍÓÚ(\\[])", perl = TRUE))
  s[nchar(s) > 0]
}

# Sentences matching all patterns, case-insensitive.
find_sentences <- function(sentences, ...) {
  pats <- list(...)
  hit <- rep(TRUE, length(sentences))
  for (p in pats) hit <- hit & grepl(p, sentences, ignore.case = TRUE, perl = TRUE)
  sentences[hit]
}

detect_text <- function(text) {
  empty <- list(value = "unverifiable", evidence = NA_character_)
  if (is.na(text) || !nzchar(text)) {
    return(stats::setNames(rep(list(empty), 5), study_config()$indicators))
  }
  s <- split_sentences(text)
  verdict <- function(hits, exclude = NULL) {
    if (!is.null(exclude)) hits <- hits[!grepl(exclude, hits, ignore.case = TRUE, perl = TRUE) |
                                          grepl(repo_pattern, hits, ignore.case = TRUE, perl = TRUE)]
    if (length(hits)) list(value = "yes", evidence = substr(hits[1], 1, 400))
    else list(value = "no", evidence = NA_character_)
  }
  list(
    data_statement = verdict(find_sentences(s, statement_pattern)),
    data_shared = verdict(find_sentences(s, data_words, repo_pattern), exclude = on_request_pattern),
    code_shared = verdict(c(find_sentences(s, code_words, repo_pattern),
                            find_sentences(s, code_words, code_host_pattern)),
                          exclude = on_request_pattern),
    preregistered = verdict(find_sentences(s, prereg_pattern)),
    materials_shared = verdict(c(find_sentences(s, material_words, repo_pattern),
                                 find_sentences(s, material_words, code_host_pattern)))
  )
}

# Research objects linked to the article in DataCite (datasets, software)
# and their reuse counts. Returns an empty frame when nothing is linked.
datacite_links <- function(doi) {
  res <- tryCatch(http_get("https://api.datacite.org/dois", list(
    query = sprintf('relatedIdentifiers.relatedIdentifier:"%s"', doi),
    `page[size]` = 50)), error = function(e) NULL)
  items <- res$data %||% list()
  if (!length(items)) {
    return(data.frame(doi = character(), object_doi = character(), type = character(),
                      citations = integer(), views = integer(), downloads = integer()))
  }
  do.call(rbind, lapply(items, function(x) {
    a <- x$attributes
    data.frame(doi = doi, object_doi = tolower(x$id),
               type = a$types$resourceTypeGeneral %||% NA_character_,
               citations = as.integer(a$citationCount %||% 0L),
               views = as.integer(a$viewCount %||% 0L),
               downloads = as.integer(a$downloadCount %||% 0L))
  }))
}

# Supplementary material declared by the publisher in Crossref.
crossref_supplement <- function(doi) {
  res <- tryCatch(http_get(paste0("https://api.crossref.org/works/", utils::URLencode(doi, reserved = TRUE)),
                           list(mailto = study_config()$mailto)), error = function(e) NULL)
  rel <- res$message$relation %||% list()
  keys <- intersect(names(rel), c("is-supplemented-by", "has-related-material", "references"))
  ids <- unlist(lapply(rel[keys], function(r) vapply(r, function(x) x$id %||% "", "")))
  ids[nzchar(ids)]
}

# Combine metadata and text into the article profile.
profile_article <- function(doi, text, links = datacite_links(doi), supplements = character()) {
  p <- detect_text(text)
  meta_data <- any(links$type %in% c("Dataset", "Collection")) ||
    any(grepl(repo_pattern, supplements, ignore.case = TRUE))
  meta_code <- any(links$type %in% c("Software", "ComputationalNotebook")) ||
    any(grepl(code_host_pattern, supplements, ignore.case = TRUE))
  if (meta_data && p$data_shared$value != "yes") {
    p$data_shared <- list(value = "yes", evidence = paste("metadata:", paste(links$object_doi, collapse = " ")))
  }
  if (meta_code && p$code_shared$value != "yes") {
    p$code_shared <- list(value = "yes", evidence = paste("metadata:", paste(links$object_doi, collapse = " ")))
  }
  p
}

profile_to_row <- function(doi, p, fulltext_source) {
  row <- data.frame(doi = doi, fulltext_source = fulltext_source,
                    detector_version = detector_version, stringsAsFactors = FALSE)
  for (k in names(p)) {
    row[[k]] <- p[[k]]$value
    row[[paste0(k, "_evidence")]] <- p[[k]]$evidence
  }
  row
}
