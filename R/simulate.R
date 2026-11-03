# Simulated study data with known effects. Used by the tests to check that
# the analysis recovers what was put in, and by power_sim() for the
# preregistered sample size justification.

simulate_study <- function(n = 4500, rr_data = 1.2, rr_code = 1.0, rr_prereg = 1.0,
                           theta = 1.2, p_unverifiable = 0.25, n_journals = 400,
                           seed = 1) {
  set.seed(seed)
  cfg <- study_config()
  strata <- names(cfg$strata)
  df <- data.frame(
    doi = sprintf("10.0000/sim.%05d", seq_len(n)),
    stratum = sample(strata, n, TRUE),
    year = sample(cfg$years, n, TRUE),
    source_id = sprintf("S%03d", sample.int(n_journals, n, TRUE)),
    is_oa = stats::rbinom(n, 1, 0.45) == 1,
    n_authors = stats::rpois(n, 3) + 1L,
    n_countries = stats::rpois(n, 0.4) + 1L,
    n_references = stats::rpois(n, 45),
    funded = stats::rbinom(n, 1, 0.5) == 1,
    n_institutions = stats::rpois(n, 1.5) + 1L,
    stringsAsFactors = FALSE
  )
  journal_effect <- stats::setNames(stats::rnorm(n_journals, 0, 0.5), sprintf("S%03d", seq_len(n_journals)))
  # Confounding: open access and larger teams share more and are cited more.
  lp_share <- -2 + 0.6 * df$is_oa + 0.15 * log(df$n_authors) + 0.3 * (df$year - 2016) / 4
  data <- stats::rbinom(n, 1, stats::plogis(lp_share))
  code <- stats::rbinom(n, 1, stats::plogis(lp_share - 0.5 + 1.5 * data))
  prereg <- stats::rbinom(n, 1, stats::plogis(-2.5 + 0.5 * (df$stratum == "psychology")))
  mu <- exp(1.8 + 0.3 * df$is_oa + 0.2 * log(df$n_authors) + 0.1 * log1p(df$n_references) +
              journal_effect[df$source_id] +
              log(rr_data) * data + log(rr_code) * code + log(rr_prereg) * prereg)
  df$cit_5y <- stats::rnbinom(n, size = theta, mu = mu)
  lab <- function(x) {
    v <- ifelse(x == 1, "yes", "no")
    v[stats::runif(n) < p_unverifiable] <- "unverifiable"
    v
  }
  df$data_shared <- lab(data)
  df$data_statement <- ifelse(data == 1, "yes", lab(stats::rbinom(n, 1, 0.3)))
  df$code_shared <- lab(code)
  df$preregistered <- lab(prereg)
  df$materials_shared <- lab(stats::rbinom(n, 1, 0.15))
  df$cell <- factor(paste(df$stratum, df$year, sep = ":"))
  df$international <- df$n_countries > 1
  df$log_authors <- log(df$n_authors)
  df$log_refs <- log1p(df$n_references)
  df$log_institutions <- log1p(df$n_institutions)
  df$journal_id <- factor(df$source_id)
  df
}

power_sim <- function(n_sims = 200, n = 4500, rr = 1.2, ...) {
  hits <- vapply(seq_len(n_sims), function(s) {
    d <- simulate_study(n = n, rr_data = rr, seed = s, ...)
    r <- fit_association(d, "data_shared")
    isTRUE(r$p < 0.05 && r$rr > 1)
  }, logical(1))
  c(power = mean(hits), n_sims = n_sims)
}
