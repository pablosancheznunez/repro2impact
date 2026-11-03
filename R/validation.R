# Manual coding: sheets for coders, inter-rater agreement and detector
# accuracy against the consensus (protocol section 5.1).

make_coding_sheet <- function(df, n = 450, seed = study_config()$seed, path = NULL) {
  set.seed(seed)
  # Stratified: the same number of articles from every field x year cell.
  per_cell <- ceiling(n / nlevels(droplevels(df$cell)))
  idx <- unlist(lapply(split(seq_len(nrow(df)), df$cell, drop = TRUE),
                       function(i) i[sample.int(length(i), min(per_cell, length(i)))]))
  sheet <- df[idx, c("doi", "title", "journal", "year", "stratum", "oa_url")]
  sheet$link <- paste0("https://doi.org/", sheet$doi)
  for (k in c(study_config()$indicators, "registered_report")) {
    sheet[[k]] <- ""
    sheet[[paste0(k, "_evidence")]] <- ""
  }
  sheet$coder <- ""
  sheet$minutes <- ""
  sheet$fulltext_source <- ""
  sheet$notes <- ""
  if (!is.null(path)) dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  if (!is.null(path)) utils::write.csv(sheet, path, row.names = FALSE, na = "")
  sheet
}

cohen_kappa <- function(a, b, levels = c("yes", "no", "unverifiable")) {
  keep <- !is.na(a) & !is.na(b) & a != "" & b != ""
  a <- factor(a[keep], levels = levels)
  b <- factor(b[keep], levels = levels)
  tab <- table(a, b)
  n <- sum(tab)
  if (n == 0) return(c(kappa = NA, agreement = NA, n = 0))
  po <- sum(diag(tab)) / n
  pe <- sum(rowSums(tab) * colSums(tab)) / n^2
  c(kappa = if (pe == 1) NA else (po - pe) / (1 - pe), agreement = po, n = n)
}

irr_report <- function(coder1, coder2, threshold = 0.70) {
  m <- merge(coder1, coder2, by = "doi", suffixes = c(".1", ".2"))
  inds <- intersect(c(study_config()$indicators, "registered_report"),
                    sub("\\.1$", "", grep("\\.1$", names(m), value = TRUE)))
  res <- do.call(rbind, lapply(inds, function(k) {
    s <- cohen_kappa(m[[paste0(k, ".1")]], m[[paste0(k, ".2")]])
    data.frame(indicator = k, kappa = s[["kappa"]], agreement = s[["agreement"]], n = s[["n"]])
  }))
  res$meets_threshold <- !is.na(res$kappa) & res$kappa >= threshold
  res
}

# Sensitivity, specificity and PPV of each automatic detector against the
# manual consensus, on articles both sides could verify.
detector_accuracy <- function(auto, consensus) {
  m <- merge(auto, consensus, by = "doi", suffixes = c(".auto", ".manual"))
  do.call(rbind, lapply(study_config()$indicators, function(k) {
    a <- m[[paste0(k, ".auto")]]
    h <- m[[paste0(k, ".manual")]]
    ok <- a %in% c("yes", "no") & h %in% c("yes", "no")
    a <- a[ok] == "yes"; h <- h[ok] == "yes"
    tp <- sum(a & h); fn <- sum(!a & h); tn <- sum(!a & !h); fp <- sum(a & !h)
    se <- wilson(tp, tp + fn); sp <- wilson(tn, tn + fp); ppv <- wilson(tp, tp + fp)
    data.frame(indicator = k, n = sum(ok), sensitivity = se$p, sens_lo = se$lo,
               specificity = sp$p, spec_lo = sp$lo, ppv = ppv$p,
               needs_manual = !is.na(se$p) & se$p < 0.80)
  }))
}

# Delphi content validity (protocol/validacion-expertos.md): I-CVI per item is
# the share of experts rating relevance 3 or 4; S-CVI/Ave is their mean.
content_validity <- function(ratings, item_threshold = 0.78) {
  # ratings: one row per expert x item, columns expert, item, relevance (1-4).
  agg <- stats::aggregate(relevance ~ item, data = ratings,
                          FUN = function(r) mean(r >= 3))
  names(agg)[2] <- "i_cvi"
  agg$n_experts <- as.integer(table(ratings$item)[agg$item])
  agg$meets_threshold <- agg$i_cvi >= item_threshold
  attr(agg, "s_cvi_ave") <- mean(agg$i_cvi)
  agg
}
