# Systematic review support (protocol/revision-sistematica.md): an OpenAlex
# search exported as a screening sheet, and citation chaining of included
# studies. WoS, Scopus and Dimensions exports are merged with merge_records().

review_search_openalex <- function(search, from = 2005, to = 2026, max = 2000) {
  out <- list()
  cursor <- "*"
  while (!is.null(cursor) && length(out) < max) {
    res <- http_get("https://api.openalex.org/works", openalex_query(
      search = search, filter = sprintf("from_publication_date:%d-01-01,to_publication_date:%d-12-31", from, to),
      per_page = 200, cursor = cursor, select = "id,doi,title,publication_year,primary_location,abstract_inverted_index"))
    if (!length(res$results)) break
    out <- c(out, res$results)
    cursor <- res$meta$next_cursor
  }
  review_records(out, source = "openalex")
}

review_snowball <- function(dois) {
  recs <- list()
  for (d in dois) {
    w <- http_get(paste0("https://api.openalex.org/works/doi:", d), openalex_query(select = "id,referenced_works"))
    if (is.null(w)) next
    ids <- sub("https://openalex.org/", "", unlist(w$referenced_works))
    back <- if (length(ids)) http_get("https://api.openalex.org/works", openalex_query(
      filter = paste0("openalex:", paste(utils::head(ids, 100), collapse = "|")), per_page = 100,
      select = "id,doi,title,publication_year,primary_location,abstract_inverted_index"))$results else list()
    fwd <- http_get("https://api.openalex.org/works", openalex_query(
      filter = paste0("cites:", sub("https://openalex.org/", "", w$id)), per_page = 200,
      select = "id,doi,title,publication_year,primary_location,abstract_inverted_index"))$results
    recs <- c(recs, back, fwd)
  }
  review_records(recs, source = "snowball")
}

review_records <- function(works, source) {
  if (!length(works)) return(data.frame())
  abstract <- function(inv) {
    if (is.null(inv)) return(NA_character_)
    pos <- unlist(lapply(names(inv), function(w) stats::setNames(unlist(inv[[w]]), rep(w, length(inv[[w]])))))
    paste(names(sort(pos)), collapse = " ")
  }
  df <- do.call(rbind, lapply(works, function(w) data.frame(
    doi = sub("^https://doi.org/", "", tolower(w$doi %||% NA_character_)),
    title = w$title %||% NA_character_, year = w$publication_year %||% NA,
    venue = w$primary_location$source$display_name %||% NA_character_,
    abstract = abstract(w$abstract_inverted_index), source = source,
    stringsAsFactors = FALSE)))
  df$screen_reviewer1 <- ""
  df$screen_reviewer2 <- ""
  df$reason <- ""
  df
}

# Deduplicate by DOI, then by normalised title.
merge_records <- function(...) {
  df <- do.call(rbind, list(...))
  key <- ifelse(is.na(df$doi) | df$doi == "", tolower(gsub("[^a-z0-9]", "", tolower(df$title))), df$doi)
  df$sources <- ave(df$source, key, FUN = function(s) paste(sort(unique(s)), collapse = ";"))
  df[!duplicated(key), , drop = FALSE]
}
