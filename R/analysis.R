# Analyses of protocol section 4. Every function takes the analysis frame
# built by build_analysis_frame() and returns a plain data frame, so results
# can be written to CSV and to the dashboard without further processing.

build_analysis_frame <- function(articles, profiles) {
  df <- merge(articles, profiles, by = "doi", all.x = TRUE)
  df$cell <- factor(paste(df$stratum, df$year, sep = ":"))
  df$international <- df$n_countries > 1
  df$log_authors <- log(pmax(df$n_authors, 1))
  df$log_refs <- log1p(df$n_references)
  df$log_institutions <- log1p(df$n_institutions)
  df$journal_id <- factor(ifelse(is.na(df$source_id), "unknown", df$source_id))
  df
}

# Below this many exposed (or unexposed) articles no estimate is reported.
min_group <- 10L

covariate_terms <- c("is_oa", "log_authors", "international", "log_refs",
                     "funded", "log_institutions")

wilson <- function(x, n, conf = 0.95) {
  z <- stats::qnorm(1 - (1 - conf) / 2)
  p <- ifelse(n > 0, x / n, NA_real_)
  centre <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  data.frame(p = p, lo = centre - half, hi = centre + half)
}

# O2: prevalence by stratum, year and open access status (the dashboard
# filters on all three); unverifiable cases are counted, not placed in the
# denominator.
prevalence <- function(df, indicators = study_config()$indicators) {
  oa <- if ("is_oa" %in% names(df)) ifelse(df$is_oa, "open", "closed") else rep("all", nrow(df))
  out <- list()
  for (ind in indicators) {
    for (key in split(seq_len(nrow(df)), list(df$stratum, df$year, oa), drop = TRUE)) {
      v <- df[[ind]][key]
      yes <- sum(v == "yes", na.rm = TRUE)
      n <- sum(v %in% c("yes", "no"))
      w <- wilson(yes, n)
      out[[length(out) + 1]] <- data.frame(
        indicator = ind, stratum = df$stratum[key[1]], year = df$year[key[1]], access = oa[key[1]],
        yes = yes, n_verifiable = n, n_unverifiable = sum(v == "unverifiable", na.rm = TRUE),
        prevalence = w$p, lo = w$lo, hi = w$hi)
    }
  }
  do.call(rbind, out)
}

indicator_subset <- function(df, indicator, outcome) {
  d <- df[df[[indicator]] %in% c("yes", "no") & !is.na(df[[outcome]]), , drop = FALSE]
  d$exposed <- as.integer(d[[indicator]] == "yes")
  d
}

# O3: negative binomial mixed model, one indicator at a time.
fit_association <- function(df, indicator, outcome = "cit_5y", random_journal = TRUE) {
  d <- indicator_subset(df, indicator, outcome)
  n_unver <- sum(df[[indicator]] == "unverifiable", na.rm = TRUE)
  rhs <- c("exposed", covariate_terms, if (nlevels(droplevels(d$cell)) > 1) "cell")
  if (random_journal && length(unique(d$journal_id)) > 1) rhs <- c(rhs, "(1 | journal_id)")
  f <- stats::as.formula(paste(outcome, "~", paste(rhs, collapse = " + ")))
  # Social outcomes are mostly zeros: a hurdle model separates "any mention"
  # from "how many"; the reported ratio is for the count part.
  hurdle <- outcome != "cit_5y" && mean(d[[outcome]] == 0) > 0.5 && sum(d[[outcome]] > 0) >= 10
  method <- if (hurdle) "hurdle_nb" else "nb_glmm"
  na_row <- data.frame(indicator = indicator, outcome = outcome, method = method,
                       rr = NA, lo = NA, hi = NA, p = NA, n = nrow(d),
                       n_exposed = sum(d$exposed), n_unverifiable = n_unver)
  if (sum(d$exposed) < min_group || sum(d$exposed) > nrow(d) - min_group || all(d[[outcome]] == 0)) return(na_row)
  m <- tryCatch(suppressWarnings(
    if (hurdle) glmmTMB::glmmTMB(f, data = d, family = glmmTMB::truncated_nbinom2(), ziformula = ~ exposed)
    else glmmTMB::glmmTMB(f, data = d, family = glmmTMB::nbinom2())),
    error = function(e) NULL)
  if (is.null(m) || is.na(summary(m)$coefficients$cond["exposed", "Std. Error"])) return(na_row)
  co <- summary(m)$coefficients$cond["exposed", ]
  data.frame(indicator = indicator, outcome = outcome, method = method,
             rr = exp(co[["Estimate"]]),
             lo = exp(co[["Estimate"]] - 1.96 * co[["Std. Error"]]),
             hi = exp(co[["Estimate"]] + 1.96 * co[["Std. Error"]]),
             p = co[["Pr(>|z|)"]], n = nrow(d), n_exposed = sum(d$exposed),
             n_unverifiable = n_unver)
}

# O3 robustness: propensity score matching, exact on field x year.
fit_matched <- function(df, indicator, outcome = "cit_5y") {
  d <- indicator_subset(df, indicator, outcome)
  d <- d[stats::complete.cases(d[, covariate_terms]), ]
  ps <- stats::as.formula(paste("exposed ~", paste(covariate_terms, collapse = " + ")))
  mm <- tryCatch(MatchIt::matchit(ps, data = d, method = "nearest", caliper = 0.2,
                                  exact = ~cell, replace = FALSE),
                 error = function(e) NULL)
  na_row <- data.frame(indicator = indicator, outcome = outcome, method = "psm",
                       rr = NA, lo = NA, hi = NA, p = NA, n = NA, n_exposed = NA,
                       n_unverifiable = NA, max_smd = NA)
  if (is.null(mm)) return(na_row)
  md <- MatchIt::match.data(mm)
  if (sum(md$exposed) < min_group) return(na_row)
  bal <- cobalt::bal.tab(mm, un = FALSE)$Balance
  fit <- tryCatch(MASS::glm.nb(stats::as.formula(paste(outcome, "~ exposed")),
                               data = md, weights = md$weights), error = function(e) NULL)
  if (is.null(fit)) return(na_row)
  co <- summary(fit)$coefficients["exposed", ]
  data.frame(indicator = indicator, outcome = outcome, method = "psm",
             rr = exp(co[[1]]), lo = exp(co[[1]] - 1.96 * co[[2]]),
             hi = exp(co[[1]] + 1.96 * co[[2]]), p = co[[4]],
             n = nrow(md), n_exposed = sum(md$exposed), n_unverifiable = NA,
             max_smd = max(abs(bal$Diff.Adj), na.rm = TRUE))
}

# Poisson pseudo-likelihood with field x year fixed effects and errors
# clustered by journal: consistent for rate ratios even under
# overdispersion. Used as a robustness check and as the outcome model for
# the weighting estimators below.
fit_poisson <- function(df, indicator, outcome = "cit_5y", weights = NULL,
                        method = "poisson", adjust = TRUE) {
  d <- if (is.null(weights)) indicator_subset(df, indicator, outcome) else df
  rhs <- c("exposed", if (adjust) covariate_terms)
  f <- stats::as.formula(paste(outcome, "~", paste(rhs, collapse = " + "), "| cell"))
  na_row <- data.frame(indicator = indicator, outcome = outcome, method = method,
                       rr = NA, lo = NA, hi = NA, p = NA, n = nrow(d),
                       n_exposed = sum(d$exposed), n_unverifiable = NA)
  if (sum(d$exposed) < min_group || all(d[[outcome]] == 0)) return(na_row)
  m <- tryCatch(suppressMessages(fixest::fepois(f, data = d, weights = weights,
                                                cluster = ~journal_id)),
                error = function(e) NULL)
  if (is.null(m) || !"exposed" %in% names(stats::coef(m))) return(na_row)
  ct <- fixest::coeftable(m)["exposed", ]
  data.frame(indicator = indicator, outcome = outcome, method = method,
             rr = exp(ct[[1]]), lo = exp(ct[[1]] - 1.96 * ct[[2]]),
             hi = exp(ct[[1]] + 1.96 * ct[[2]]), p = ct[[4]],
             n = stats::nobs(m), n_exposed = sum(d$exposed), n_unverifiable = NA)
}

covariate_matrix <- function(d) {
  X <- stats::model.matrix(stats::as.formula(paste("~", paste(c(covariate_terms, "cell"), collapse = " + "))), d)
  X[, colnames(X) != "(Intercept)" & apply(X, 2, stats::sd) > 0, drop = FALSE]
}

# Stabilised inverse probability weights (ATE), trimmed at the 1st and
# 99th percentiles.
ipw_weights <- function(d) {
  ps <- stats::fitted(stats::glm(stats::as.formula(paste(
    "exposed ~", paste(c(covariate_terms, "cell"), collapse = " + "))), data = d, family = stats::binomial()))
  p1 <- mean(d$exposed)
  w <- ifelse(d$exposed == 1, p1 / ps, (1 - p1) / (1 - ps))
  q <- stats::quantile(w, c(.01, .99))
  pmin(pmax(w, q[[1]]), q[[2]])
}

# Entropy balancing (Hainmueller 2012), ATT: control weights that reproduce
# the treated means of every covariate exactly, closest to uniform.
ebal_weights <- function(d) {
  X <- scale(covariate_matrix(d))
  X[is.na(X)] <- 0
  t <- d$exposed == 1
  target <- colMeans(X[t, , drop = FALSE])
  Xc <- X[!t, , drop = FALSE]
  dual <- function(l) log(sum(exp(Xc %*% l))) - sum(l * target)
  grad <- function(l) { e <- exp(Xc %*% l); as.numeric(crossprod(Xc, e) / sum(e)) - target }
  opt <- stats::optim(rep(0, ncol(X)), dual, grad, method = "BFGS", control = list(maxit = 500))
  wc <- as.numeric(exp(Xc %*% opt$par)); wc <- wc / sum(wc) * sum(!t)
  w <- rep(1, nrow(d)); w[!t] <- wc
  attr(w, "max_imbalance") <- max(abs(colSums(Xc * wc) / sum(wc) - target))
  w
}

fit_weighted <- function(df, indicator, outcome = "cit_5y", method = c("ipw", "ebal")) {
  method <- match.arg(method)
  d <- indicator_subset(df, indicator, outcome)
  d <- d[stats::complete.cases(d[, covariate_terms]), ]
  if (sum(d$exposed) < min_group || sum(1 - d$exposed) < min_group) {
    return(data.frame(indicator = indicator, outcome = outcome, method = method,
                      rr = NA, lo = NA, hi = NA, p = NA, n = nrow(d),
                      n_exposed = sum(d$exposed), n_unverifiable = NA, max_smd = NA))
  }
  w <- tryCatch(if (method == "ipw") ipw_weights(d) else ebal_weights(d), error = function(e) NULL)
  if (is.null(w)) {
    return(data.frame(indicator = indicator, outcome = outcome, method = method,
                      rr = NA, lo = NA, hi = NA, p = NA, n = nrow(d),
                      n_exposed = sum(d$exposed), n_unverifiable = NA, max_smd = NA))
  }
  # Doubly robust: the weighted outcome model still adjusts for covariates.
  r <- fit_poisson(d, indicator, outcome, weights = as.numeric(w), method = method)
  r$max_smd <- attr(w, "max_imbalance") %||% NA
  r
}

# VanderWeele & Ding (2017) E-value for a rate ratio and its CI bound
# closest to the null.
evalue <- function(rr, lo, hi) {
  e <- function(r) { if (is.na(r)) return(NA_real_); r <- if (r < 1) 1 / r else r; r + sqrt(r * (r - 1)) }
  bound <- if (is.na(rr)) NA else if (rr >= 1) lo else hi
  ci <- if (is.na(bound) || (rr >= 1 && bound <= 1) || (rr < 1 && bound >= 1)) 1 else e(bound)
  c(evalue_point = e(rr), evalue_ci = ci)
}

association_table <- function(df, outcomes = "cit_5y",
                              confirmatory = c("data_shared", "code_shared", "preregistered")) {
  rows <- list()
  for (o in outcomes) for (ind in study_config()$indicators) {
    rows[[length(rows) + 1]] <- fit_association(df, ind, o)
    rows[[length(rows) + 1]] <- fit_matched(df, ind, o)
    rows[[length(rows) + 1]] <- fit_poisson(df, ind, o)
    rows[[length(rows) + 1]] <- fit_weighted(df, ind, o, "ipw")
    rows[[length(rows) + 1]] <- fit_weighted(df, ind, o, "ebal")
  }
  res <- do.call(rbind, lapply(rows, function(r) { if (!"max_smd" %in% names(r)) r$max_smd <- NA; r }))
  ev <- t(mapply(evalue, res$rr, res$lo, res$hi))
  res$evalue_point <- ev[, 1]
  res$evalue_ci <- ev[, 2]
  conf <- res$method == "nb_glmm" & res$outcome == "cit_5y" & res$indicator %in% confirmatory &
    !is.na(res$p)
  res$confirmatory <- conf
  res$p_holm <- NA_real_
  res$p_holm[conf] <- stats::p.adjust(res$p[conf], method = "holm")
  rownames(res) <- NULL
  res
}

# O4: staggered difference-in-differences (Sun & Abraham) at article level.
# policies: data frame with source_id and adoption_year (NA = never adopted).
fit_policy_did <- function(df, policies, outcome = "data_shared") {
  d <- merge(df, policies[, c("source_id", "adoption_year")], by = "source_id", all.x = TRUE)
  d$cohort <- ifelse(is.na(d$adoption_year), 10000L, as.integer(d$adoption_year))
  if (outcome %in% study_config()$indicators) {
    d <- d[d[[outcome]] %in% c("yes", "no"), ]
    d$y <- as.integer(d[[outcome]] == "yes")
  } else {
    d <- d[!is.na(d[[outcome]]), ]
    d$y <- log1p(d[[outcome]])
  }
  treated <- unique(d$source_id[d$cohort < 10000])
  if (length(treated) < 2) {
    return(list(ok = FALSE, reason = "fewer than two adopting journals with sampled articles",
                n = nrow(d)))
  }
  m <- fixest::feols(y ~ sunab(cohort, year) | source_id + year, data = d,
                     cluster = ~source_id)
  agg <- summary(m, agg = "ATT")$coeftable
  list(ok = TRUE, att = agg, event_study = stats::coef(m), n = nrow(d),
       n_treated_journals = length(treated))
}

# Composite only as a sensitivity analysis: distribution of the citation
# association over random weightings of the indicators.
weight_sensitivity <- function(df, n_draws = 1000, seed = study_config()$seed) {
  inds <- study_config()$indicators
  ok <- stats::complete.cases(df[, c("cit_5y", covariate_terms)]) &
    apply(df[, inds], 1, function(r) all(r %in% c("yes", "no")))
  d <- df[ok, ]
  if (nrow(d) < 30) return(data.frame(rr = numeric()))
  X <- sapply(inds, function(i) as.integer(d[[i]] == "yes"))
  set.seed(seed)
  rr <- vapply(seq_len(n_draws), function(k) {
    w <- stats::rgamma(length(inds), 1); w <- w / sum(w)
    d$index <- as.numeric(scale(X %*% w))
    if (!is.finite(stats::sd(d$index))) return(NA_real_)
    fit <- tryCatch(MASS::glm.nb(stats::as.formula(paste(
      "cit_5y ~ index +", paste(c(covariate_terms, "cell"), collapse = " + "))), data = d),
      error = function(e) NULL)
    if (is.null(fit)) NA_real_ else exp(stats::coef(fit)[["index"]])
  }, numeric(1))
  data.frame(draw = seq_len(n_draws), rr_per_sd = rr)
}

# Exploratory heterogeneity: the rate ratio of each indicator within each
# field, by open access status and by international collaboration.
heterogeneity <- function(df, indicators = c("data_shared", "code_shared", "preregistered")) {
  groups <- list(
    field = df$stratum,
    open_access = ifelse(df$is_oa, "open", "closed"),
    collaboration = ifelse(df$international, "international", "national")
  )
  out <- list()
  for (g in names(groups)) for (lev in sort(unique(stats::na.omit(groups[[g]])))) {
    sub <- df[!is.na(groups[[g]]) & groups[[g]] == lev, , drop = FALSE]
    for (ind in indicators) {
      r <- fit_association(sub, ind, "cit_5y", random_journal = FALSE)
      out[[length(out) + 1]] <- cbind(data.frame(by = g, group = lev), r)
    }
  }
  do.call(rbind, out)
}

# Reuse of shared objects, among articles that share them only.
reuse_summary <- function(links) {
  if (is.null(links) || !nrow(links)) {
    return(data.frame(type = character(), objects = integer(), cited_share = numeric(),
                      median_citations = numeric(), median_downloads = numeric()))
  }
  do.call(rbind, lapply(split(links, links$type), function(x) data.frame(
    type = x$type[1], objects = nrow(x), cited_share = mean(x$citations > 0),
    median_citations = stats::median(x$citations), median_downloads = stats::median(x$downloads))))
}
