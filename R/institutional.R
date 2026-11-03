# Institutional sources named in the proposal (Web of Science, InCites,
# Dimensions). They need UC3M credentials, read from environment variables;
# without them every value is NA, never zero. Their raw data are not
# redistributed (protocol section 6). Check the endpoints against the
# documentation of your licence before the main run.

# Web of Science Starter API: times cited in the WoS Core Collection.
wos_citations <- function(doi) {
  key <- Sys.getenv("WOS_STARTER_KEY")
  if (!nzchar(key)) return(NA_integer_)
  res <- tryCatch(http_get("https://api.clarivate.com/apis/wos-starter/v1/documents",
                           list(q = sprintf('DO=("%s")', doi), db = "WOS", limit = 1),
                           headers = list(`X-ApiKey` = key), pause = 0.25),
                  error = function(e) NULL)
  hits <- res$hits %||% list()
  if (!length(hits)) return(NA_integer_)
  cites <- Filter(function(x) identical(x$db, "WOS"), hits[[1]]$citations %||% list())
  if (!length(cites)) 0L else as.integer(cites[[1]]$count)
}

# InCites: the document-level export (CSV) with DOI and Category Normalized
# Citation Impact, downloaded by hand from InCites for the sample's DOIs.
read_incites_export <- function(path) {
  x <- utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  doi_col <- grep("^DOI$", names(x), ignore.case = TRUE, value = TRUE)[1]
  cnci_col <- grep("Category Normalized Citation Impact|CNCI", names(x), ignore.case = TRUE, value = TRUE)[1]
  if (is.na(doi_col) || is.na(cnci_col)) stop("The export needs DOI and CNCI columns.", call. = FALSE)
  data.frame(doi = tolower(trimws(x[[doi_col]])), cnci = suppressWarnings(as.numeric(x[[cnci_col]])))
}

# Dimensions Analytics API: citations, field citation ratio and relative
# citation ratio, queried in batches of up to 400 DOIs.
dimensions_metrics <- function(dois) {
  key <- Sys.getenv("DIMENSIONS_KEY")
  empty <- data.frame(doi = dois, dim_citations = NA_integer_, dim_fcr = NA_real_, dim_rcr = NA_real_)
  if (!nzchar(key)) return(empty)
  token <- tryCatch({
    r <- httr2::req_perform(httr2::req_body_json(
      httr2::request("https://app.dimensions.ai/api/auth"), list(key = key)))
    httr2::resp_body_json(r)$token
  }, error = function(e) NULL)
  if (is.null(token)) return(empty)
  out <- list()
  for (batch in split(dois, ceiling(seq_along(dois) / 400))) {
    q <- sprintf('search publications where doi in [%s] return publications[doi+times_cited+field_citation_ratio+relative_citation_ratio] limit 1000',
                 paste0('"', batch, '"', collapse = ","))
    res <- tryCatch({
      r <- httr2::req_perform(httr2::req_body_raw(httr2::req_headers(
        httr2::request("https://app.dimensions.ai/api/dsl"), Authorization = paste("JWT", token)), q))
      httr2::resp_body_json(r)$publications
    }, error = function(e) list())
    Sys.sleep(2)
    out <- c(out, lapply(res, function(p) data.frame(
      doi = tolower(p$doi), dim_citations = as.integer(p$times_cited %||% NA),
      dim_fcr = as.numeric(p$field_citation_ratio %||% NA),
      dim_rcr = as.numeric(p$relative_citation_ratio %||% NA))))
  }
  got <- if (length(out)) do.call(rbind, out) else empty[0, ]
  merge(data.frame(doi = dois), got, by = "doi", all.x = TRUE)
}

collect_institutional <- function(articles, incites_path = Sys.getenv("INCITES_EXPORT")) {
  d <- data.frame(doi = articles$doi,
                  wos_citations = vapply(articles$doi, wos_citations, integer(1)),
                  row.names = NULL)
  d <- merge(d, dimensions_metrics(articles$doi), by = "doi", all.x = TRUE)
  if (nzchar(incites_path) && file.exists(incites_path)) {
    d <- merge(d, read_incites_export(incites_path), by = "doi", all.x = TRUE)
  } else {
    d$cnci <- NA_real_
  }
  d
}
