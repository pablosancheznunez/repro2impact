# Stratified, seeded sample of articles from OpenAlex (protocol section 3.1).

openalex_fields <- c(
  "id", "doi", "title", "publication_year", "language", "type",
  "primary_location", "open_access", "best_oa_location", "authorships",
  "counts_by_year", "cited_by_count", "fwci", "referenced_works_count",
  "funders", "ids", "institutions_distinct_count", "countries_distinct_count",
  "primary_topic", "is_retracted"
)

openalex_query <- function(...) {
  q <- list(..., mailto = study_config()$mailto)
  key <- Sys.getenv("OPENALEX_API_KEY")
  if (nzchar(key)) q$api_key <- key
  q
}

draw_cell <- function(stratum, year, n, seed) {
  cfg <- study_config()
  filter <- paste(
    cfg$strata[[stratum]],
    paste0("publication_year:", year),
    "type:article", "has_doi:true", "is_retracted:false", "language:en|es",
    sep = ","
  )
  # OpenAlex returns at most 200 per page; a seeded sample is stable across pages.
  out <- list()
  pages <- ceiling(n / 200)
  for (p in seq_len(pages)) {
    res <- http_get("https://api.openalex.org/works", openalex_query(
      filter = filter, sample = n, seed = seed, per_page = min(200, n),
      page = p, select = paste(openalex_fields, collapse = ",")
    ))
    out <- c(out, res$results)
  }
  works <- lapply(out[seq_len(min(n, length(out)))], flatten_work)
  df <- do.call(rbind, works)
  df$stratum <- rep(stratum, nrow(df))
  df
}

draw_sample <- function(per_cell = study_config()$per_cell_pilot) {
  cfg <- study_config()
  cells <- expand.grid(stratum = names(cfg$strata), year = cfg$years,
                       stringsAsFactors = FALSE)
  parts <- Map(function(s, y, i) draw_cell(s, y, per_cell, cfg$seed + i),
               cells$stratum, cells$year, seq_len(nrow(cells)))
  df <- do.call(rbind, parts)
  # A work can fall in two strata only through topic overlap; keep the first.
  df[!duplicated(df$openalex_id), , drop = FALSE]
}

flatten_work <- function(w) {
  src <- w$primary_location$source
  pmcid <- w$ids$pmcid %||% NA_character_
  if (!is.na(pmcid)) pmcid <- paste0("PMC", sub(".*/", "", pmcid))
  doi <- sub("^https://doi.org/", "", tolower(w$doi %||% NA_character_))
  data.frame(
    openalex_id = sub("https://openalex.org/", "", w$id),
    doi = doi,
    title = w$title %||% NA_character_,
    year = as.integer(w$publication_year),
    language = w$language %||% NA_character_,
    journal = src$display_name %||% NA_character_,
    issn_l = src$issn_l %||% NA_character_,
    source_id = sub("https://openalex.org/", "", src$id %||% NA_character_),
    oa_status = w$open_access$oa_status %||% NA_character_,
    is_oa = isTRUE(w$open_access$is_oa),
    oa_url = w$best_oa_location$landing_page_url %||% NA_character_,
    pmcid = pmcid,
    n_authors = length(w$authorships),
    n_institutions = as.integer(w$institutions_distinct_count %||% NA),
    n_countries = as.integer(w$countries_distinct_count %||% NA),
    n_references = as.integer(w$referenced_works_count %||% NA),
    funded = length(w$funders) > 0,
    cited_by_count = as.integer(w$cited_by_count %||% 0),
    fwci = as.numeric(w$fwci %||% NA),
    cit_5y = window_citations(w$counts_by_year, w$publication_year),
    subfield = w$primary_topic$subfield$display_name %||% NA_character_,
    stringsAsFactors = FALSE
  )
}

# Citations received in publication years +1..+5. Years missing from
# counts_by_year had zero citations. NA if the window is not complete yet.
window_citations <- function(counts, pub_year, window = study_config()$citation_window,
                             current_year = as.integer(format(Sys.Date(), "%Y"))) {
  years <- pub_year + window
  if (max(years) >= current_year) return(NA_integer_)
  got <- vapply(counts, function(x) as.integer(x$year), integer(1))
  n <- vapply(counts, function(x) as.integer(x$cited_by_count), integer(1))
  as.integer(sum(n[got %in% years]))
}
