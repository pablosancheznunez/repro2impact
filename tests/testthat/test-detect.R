test_that("data shared in a repository is detected with its evidence", {
  txt <- paste("Method. Participants completed the task.",
               "Data Availability Statement. All data and analysis scripts are openly available at https://osf.io/ab3cd/.",
               "Results. The effect was large.")
  p <- detect_text(txt)
  expect_equal(p$data_statement$value, "yes")
  expect_equal(p$data_shared$value, "yes")
  expect_equal(p$code_shared$value, "yes")
  expect_match(p$data_shared$evidence, "osf.io/ab3cd")
})

test_that("data on request is a statement but not sharing", {
  txt <- "Data availability. The data that support the findings are available from the corresponding author upon reasonable request. Results follow."
  p <- detect_text(txt)
  expect_equal(p$data_statement$value, "yes")
  expect_equal(p$data_shared$value, "no")
  expect_equal(p$code_shared$value, "no")
})

test_that("missing full text is unverifiable, never no", {
  p <- detect_text(NA_character_)
  expect_true(all(vapply(p, `[[`, "", "value") == "unverifiable"))
})

test_that("preregistrations are recognised", {
  expect_equal(detect_text("The study was preregistered at https://osf.io/x7k2p before data collection.")$preregistered$value, "yes")
  expect_equal(detect_text("Hypotheses were registered at AsPredicted (aspredicted.org/blind.php?x=ab12cd).")$preregistered$value, "yes")
  expect_equal(detect_text("This trial is registered as NCT01234567.")$preregistered$value, "yes")
  expect_equal(detect_text("We did not register the study. Data were analysed in R.")$preregistered$value, "no")
})

test_that("code on GitHub is detected and naming software alone is not", {
  expect_equal(detect_text("The analysis code is available at https://github.com/lab/study.")$code_shared$value, "yes")
  expect_equal(detect_text("Analyses were run in R 4.1 using the lme4 package.")$code_shared$value, "no")
})

test_that("Spanish statements are recognised", {
  p <- detect_text("Disponibilidad de los datos. Los datos y el código están disponibles en https://zenodo.org/records/123456.")
  expect_equal(p$data_statement$value, "yes")
  expect_equal(p$data_shared$value, "yes")
  expect_equal(p$code_shared$value, "yes")
})

test_that("metadata links upgrade the profile", {
  links <- data.frame(doi = "10.1/x", object_doi = "10.5281/zenodo.1", type = "Dataset",
                      citations = 0L, views = 0L, downloads = 0L)
  p <- profile_article("10.1/x", "Some text without links. Nothing else here.", links)
  expect_equal(p$data_shared$value, "yes")
  expect_match(p$data_shared$evidence, "metadata")
})

test_that("markup keeps link targets", {
  x <- strip_markup('<p>Data at <a href="https://osf.io/qwe12/">OSF</a>.</p><script>var a=1;</script>')
  expect_match(x, "osf.io/qwe12")
  expect_false(grepl("var a", x))
})

test_that("JATS front matter and publisher menus do not produce indicators", {
  xml <- paste0("<article><front><custom-meta-group><custom-meta>pmc-status-live yes</custom-meta>",
                "<custom-meta>registered report</custom-meta></custom-meta-group></front>",
                "<body><p>We analysed survey data.</p></body></article>")
  expect_false(grepl("registered report", jats_text(xml)))
  html <- paste0("<html><nav><ul><li>Registered reports</li><li>Open research</li></ul></nav>",
                 "<article>", strrep("<p>Participants read texts and answered questions.</p>", 200),
                 "</article></html>")
  expect_equal(detect_text(strip_markup(article_region(html)))$preregistered$value, "no")
})

test_that("headings do not merge into the next sentence", {
  s <- split_sentences(strip_markup("<h2>Data availability</h2><p>Data are at https://osf.io/abc12.</p>"))
  expect_gte(length(s), 2)
})
