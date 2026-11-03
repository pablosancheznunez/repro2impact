# Technical report and policy brief, written from the pipeline results so
# that every number in them comes from the data of the current run.

indicator_labels <- c(
  data_statement = "Declaración de disponibilidad de datos",
  data_shared = "Datos compartidos en repositorio",
  code_shared = "Código compartido",
  preregistered = "Prerregistro enlazado",
  materials_shared = "Materiales compartidos"
)
field_labels <- c(psychology = "Psicología", communication = "Comunicación",
                  computational_social_science = "Ciencias sociales computacionales")

fmt_pct <- function(x) ifelse(is.na(x), "–", sprintf("%.1f %%", 100 * x))
fmt_rr <- function(rr, lo, hi) ifelse(is.na(rr), "no estimable",
                                      sprintf("%.2f (IC 95 %% %.2f–%.2f)", rr, lo, hi))

prevalence_overall <- function(prevalence_tab) {
  do.call(rbind, lapply(split(prevalence_tab, prevalence_tab$indicator), function(x) {
    yes <- sum(x$yes); n <- sum(x$n_verifiable); w <- wilson(yes, n)
    data.frame(indicator = x$indicator[1], yes = yes, n = n,
               unverifiable = sum(x$n_unverifiable), p = w$p, lo = w$lo, hi = w$hi)
  }))
}

write_reports <- function(frame, prevalence_tab, assoc, phase = "pilot", dir = "reports") {
  dir.create(dir, showWarnings = FALSE)
  ov <- prevalence_overall(prevalence_tab)
  ov <- ov[match(names(indicator_labels), ov$indicator), ]
  coverage <- mean(frame$fulltext_source != "unavailable")
  main <- assoc[assoc$outcome == "cit_5y" & assoc$method == "nb_glmm", ]
  main <- main[match(names(indicator_labels), main$indicator), ]
  phase_note <- if (phase == "pilot") {
    "> **Resultados del piloto.** Sirven para calibrar detectores y procedimientos, no para extraer conclusiones: el tamaño de muestra no permite inferencia."
  } else ""

  prev_table <- paste0("| ", indicator_labels, " | ", ov$yes, " / ", ov$n, " | ", fmt_pct(ov$p),
                       " (", fmt_pct(ov$lo), "–", fmt_pct(ov$hi), ") | ", ov$unverifiable, " |")
  assoc_table <- paste0("| ", indicator_labels, " | ", fmt_rr(main$rr, main$lo, main$hi), " | ",
                        ifelse(is.na(main$n_exposed), "–", main$n_exposed), " |")
  by_field <- vapply(names(field_labels), function(f) {
    x <- prevalence_tab[prevalence_tab$stratum == f & prevalence_tab$indicator == "data_shared", ]
    w <- wilson(sum(x$yes), sum(x$n_verifiable))
    sprintf("| %s | %s | %d |", field_labels[[f]], fmt_pct(w$p), sum(x$n_verifiable))
  }, "")

  report <- c(
    "# REPRO2IMPACT · Informe técnico", "",
    sprintf("Fase: **%s** · Fecha de los datos: %s · Protocolo v%s · Detectores v%s",
            phase, format(Sys.Date()), study_config()$version, detector_version), "",
    phase_note, "",
    "## 1. Muestra y cobertura", "",
    sprintf("- Artículos: **%d** (%s, %d–%d).", nrow(frame),
            paste(field_labels, collapse = ", "), min(frame$year), max(frame$year)),
    sprintf("- Texto completo legible por los detectores: **%s** de los artículos. El resto es *no verificable* en los indicadores de texto y no cuenta como «no».", fmt_pct(coverage)),
    sprintf("- Fuentes del texto: %s.", paste(sprintf("%s %d", names(table(frame$fulltext_source)),
                                                        as.integer(table(frame$fulltext_source))), collapse = ", ")), "",
    "## 2. Prevalencia de cada práctica", "",
    "| Práctica | Sí / verificables | Prevalencia (IC 95 %) | No verificables |",
    "| --- | --- | --- | --- |", prev_table, "",
    "Datos compartidos por campo:", "",
    "| Campo | Prevalencia | Verificables |", "| --- | --- | --- |", by_field, "",
    "## 3. Asociación con las citas a cinco años", "",
    "Razón de tasas ajustada (binomial negativa multinivel; revista como efecto aleatorio). Es una asociación, no un efecto causal.", "",
    "| Práctica | RR | Expuestos |", "| --- | --- | --- |", assoc_table, "",
    "Las estimaciones de robustez (Poisson, emparejamiento, ponderación inversa y equilibrado por entropía) y los E-values están en `outputs/associations.csv`.", "",
    "## 4. Limitaciones", "",
    "- Los indicadores describen condiciones de reproducibilidad, no reproducibilidad real; el subestudio de reproducción lo contrasta.",
    "- La cobertura de texto completo limita los indicadores de texto; la codificación manual y el acceso TDM institucional la amplían.",
    "- Las asociaciones pueden deberse a confusores no medidos (p. ej., prestigio del grupo); los E-values indican cuánto.",
    "- No se publica ninguna puntuación agregada ni clasificación de artículos, revistas o personas."
  )
  writeLines(report, file.path(dir, sprintf("informe-tecnico-%s.md", phase)), useBytes = TRUE)

  brief <- c(
    "# Transparencia en la investigación: qué compartimos y qué ganamos",
    "*Policy brief · REPRO2IMPACT (UC3M)*", "", phase_note, "",
    "## Mensajes clave", "",
    sprintf("1. **Compartir datos sigue siendo minoritario.** En la muestra, el %s de los artículos verificables comparte sus datos en un repositorio y el %s comparte su código.",
            fmt_pct(ov$p[ov$indicator == "data_shared"]), fmt_pct(ov$p[ov$indicator == "code_shared"])),
    sprintf("2. **Gran parte de la ciencia no se puede comprobar de forma automática.** El %s de los artículos no tiene un texto completo accesible para verificar estas prácticas.",
            fmt_pct(1 - coverage)),
    "3. **[Completar con el resultado principal del estudio: asociación de datos y código compartidos con citas e impacto social, con su magnitud e incertidumbre.]**",
    "4. **[Completar con el resultado de las políticas editoriales (diferencias en diferencias).]**", "",
    "## Recomendaciones", "",
    "- **Universidades y agencias:** reconocer en la evaluación los datos, el código y los prerregistros como resultados de investigación, informados por separado y con su evidencia, nunca sumados en una puntuación (DORA, CoARA).",
    "- **Revistas:** exigir declaraciones de disponibilidad con enlace persistente y depositar el texto completo en formatos legibles por máquina.",
    "- **Investigadores:** depositar datos y código en repositorios con DOI (Zenodo, OSF) y enlazarlos desde el artículo y los metadatos (DataCite, Crossref).", "",
    "## Método en una línea", "",
    sprintf("Muestra aleatoria estratificada de %d artículos (%s, %d–%d); prácticas detectadas automáticamente y validadas con codificación manual; impacto medido con citas a cinco años, Wikipedia y documentos de política.",
            nrow(frame), paste(field_labels, collapse = ", "), min(frame$year), max(frame$year)), "",
    "Datos, código y protocolo abiertos: <https://github.com/pablosancheznunez/repro2impact>"
  )
  writeLines(brief, file.path(dir, sprintf("policy-brief-%s.md", phase)), useBytes = TRUE)
  file.path(dir, sprintf(c("informe-tecnico-%s.md", "policy-brief-%s.md"), phase))
}
