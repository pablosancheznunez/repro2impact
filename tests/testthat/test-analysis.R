test_that("citation window counts years +1..+5 and is NA if incomplete", {
  counts <- list(list(year = 2017, cited_by_count = 2), list(year = 2019, cited_by_count = 3),
                 list(year = 2023, cited_by_count = 10))
  expect_equal(window_citations(counts, 2016, current_year = 2026), 5L)
  expect_equal(window_citations(counts, 2022, current_year = 2026), NA_integer_)
})

test_that("Wilson interval matches a known value", {
  w <- wilson(10, 100)
  expect_equal(round(w$lo, 4), 0.0552)
  expect_equal(round(w$hi, 4), 0.1744)
})

test_that("Cohen's kappa handles perfect and chance agreement", {
  a <- c("yes", "no", "yes", "no")
  expect_equal(cohen_kappa(a, a)[["kappa"]], 1)
  expect_equal(cohen_kappa(c("yes", "yes", "no", "no"), c("yes", "no", "yes", "no"))[["kappa"]], 0)
})

test_that("E-value follows VanderWeele and Ding", {
  e <- evalue(1.5, 1.2, 1.9)
  expect_equal(round(e[["evalue_point"]], 3), round(1.5 + sqrt(1.5 * 0.5), 3))
  expect_equal(evalue(1.1, 0.9, 1.3)[["evalue_ci"]], 1)
})

test_that("prevalence leaves unverifiable cases out of the denominator", {
  d <- data.frame(stratum = "psychology", year = 2018,
                  data_shared = c("yes", "no", "no", "unverifiable"))
  p <- prevalence(d, "data_shared")
  expect_equal(p$n_verifiable, 3)
  expect_equal(p$n_unverifiable, 1)
  expect_equal(p$prevalence, 1 / 3)
})

test_that("the mixed model recovers a known rate ratio", {
  d <- simulate_study(n = 3000, rr_data = 1.5, seed = 7)
  r <- fit_association(d, "data_shared")
  expect_true(r$lo < 1.5 && r$hi > 1.5)
  expect_true(r$p < 0.05)
  null <- fit_association(d, "preregistered")
  expect_true(null$lo < 1 && null$hi > 1)
})

test_that("matching and the association table run end to end", {
  d <- simulate_study(n = 1500, rr_data = 1.4, seed = 3)
  tab <- association_table(d)
  expect_true(all(c("nb_glmm", "psm") %in% tab$method))
  expect_equal(sum(tab$confirmatory), 3)
  expect_false(any(is.na(tab$p_holm[tab$confirmatory])))
})

test_that("weight sensitivity returns a distribution, not a score", {
  d <- simulate_study(n = 800, seed = 5)
  s <- weight_sensitivity(d, n_draws = 20)
  expect_equal(nrow(s), 20)
  expect_true(all(s$rr_per_sd > 0, na.rm = TRUE))
})

test_that("policy DiD refuses to run without adopting journals", {
  d <- simulate_study(n = 500, seed = 2)
  r <- fit_policy_did(d, data.frame(source_id = character(), adoption_year = integer()))
  expect_false(r$ok)
})

test_that("policy DiD estimates an effect with staggered adoption", {
  d <- simulate_study(n = 4000, n_journals = 60, seed = 11)
  pol <- data.frame(source_id = sprintf("S%03d", 1:20), adoption_year = rep(2017:2019, length.out = 20))
  treated <- d$source_id %in% pol$source_id &
    d$year >= pol$adoption_year[match(d$source_id, pol$source_id)]
  flip <- treated & d$data_shared == "no" & stats::runif(nrow(d)) < 0.5
  d$data_shared[flip] <- "yes"
  r <- fit_policy_did(d, pol)
  expect_true(r$ok)
  expect_gt(r$att["ATT", "Estimate"], 0.1)
})

test_that("heterogeneity returns one row per group and indicator", {
  d <- simulate_study(n = 1500, seed = 9)
  h <- heterogeneity(d, "data_shared")
  expect_true(all(c("field", "open_access", "collaboration") %in% h$by))
  expect_equal(nrow(h), 3 + 2 + 2)
})

test_that("zero-heavy social outcomes use a hurdle model", {
  d <- simulate_study(n = 2000, seed = 4)
  set.seed(4)
  d$wikipedia <- ifelse(stats::runif(nrow(d)) < 0.85, 0L, stats::rpois(nrow(d), 2) + 1L)
  r <- fit_association(d, "data_shared", "wikipedia")
  expect_equal(r$method, "hurdle_nb")
})

test_that("content validity follows the I-CVI definition", {
  r <- data.frame(expert = rep(1:5, 2), item = rep(c("a", "b"), each = 5),
                  relevance = c(4, 4, 3, 3, 2, 1, 2, 4, 2, 1))
  cv <- content_validity(r)
  expect_equal(cv$i_cvi, c(0.8, 0.2))
  expect_equal(cv$meets_threshold, c(TRUE, FALSE))
  expect_equal(attr(cv, "s_cvi_ave"), 0.5)
})

test_that("reuse summary works with and without linked objects", {
  expect_equal(nrow(reuse_summary(NULL)), 0)
  l <- data.frame(doi = c("a", "b"), object_doi = c("x", "y"), type = "Dataset",
                  citations = c(0L, 2L), views = 1L, downloads = c(3L, 5L))
  expect_equal(reuse_summary(l)$cited_share, 0.5)
})

test_that("review records deduplicate by DOI and title", {
  a <- data.frame(doi = c("10.1/a", ""), title = c("A", "Same Title"), year = 2020, venue = NA,
                  abstract = NA, source = "wos", screen_reviewer1 = "", screen_reviewer2 = "", reason = "")
  b <- a; b$source <- "openalex"; b$title[2] <- "same title!"
  m <- merge_records(a, b)
  expect_equal(nrow(m), 2)
  expect_equal(m$sources[1], "openalex;wos")
})
