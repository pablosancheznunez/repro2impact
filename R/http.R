# Polite, cached HTTP. Every response is stored under cache_dir keyed by the
# request URL, so the pipeline can be rerun offline and audited later.
# Failures are cached too (as .err files with the status), so a site that
# refuses automated access is asked once, not on every run.

cache_dir <- function() {
  d <- Sys.getenv("REPRO2IMPACT_CACHE", file.path("data", "cache"))
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  d
}

http_get <- function(url, query = list(), as = c("json", "text"),
                     headers = list(), cache = TRUE, pause = 0.1,
                     tries = 4, timeout = 60) {
  as <- match.arg(as)
  req <- httr2::request(url)
  if (length(query)) req <- httr2::req_url_query(req, !!!query)
  key <- digest::digest(req$url, algo = "sha1")
  path <- file.path(cache_dir(), paste0(key, if (as == "json") ".json" else ".txt"))
  err_path <- file.path(cache_dir(), paste0(key, ".err"))

  if (cache && file.exists(path)) {
    body <- readr_lines(path)
  } else {
    if (cache && file.exists(err_path)) {
      status <- as.integer(readLines(err_path, warn = FALSE)[1])
      if (status == 404) return(NULL)
      stop(sprintf("HTTP %s (cached) for %s", status, req$url), call. = FALSE)
    }
    req <- httr2::req_user_agent(req, study_config()$user_agent)
    req <- httr2::req_timeout(req, timeout)
    if (length(headers)) req <- httr2::req_headers(req, !!!headers)
    if (tries > 1) {
      req <- httr2::req_retry(req, max_tries = tries, max_seconds = 60,
                              is_transient = function(r) httr2::resp_status(r) %in% c(429, 500, 502, 503, 504))
    }
    req <- httr2::req_error(req, is_error = function(r) FALSE)
    resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
    Sys.sleep(pause)
    status <- if (is.null(resp)) 599L else httr2::resp_status(resp)
    if (status >= 400) {
      if (cache) writeLines(as.character(status), err_path)
      if (status == 404) return(NULL)
      stop(sprintf("HTTP %s for %s", status, req$url), call. = FALSE)
    }
    body <- httr2::resp_body_string(resp)
    if (cache) writeLines(body, path, useBytes = TRUE)
  }
  if (as == "json") jsonlite::fromJSON(body, simplifyVector = FALSE) else body
}

readr_lines <- function(path) paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x
