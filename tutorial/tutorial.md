# Tutorial: medir prácticas de transparencia con ejemplos reales

Material docente de REPRO2IMPACT para posgrado (másteres en Documentación, Comunicación, Ciencias Sociales Computacionales) y para formación del personal investigador. Duración: unas 2 horas. Requiere R ≥ 4.3 y los paquetes del README.

**Objetivos de aprendizaje.** Al terminar, el estudiante sabrá:
1. distinguir entre transparencia, reproducibilidad potencial y reproducibilidad real;
2. comprobar si un artículo comparte datos, código o prerregistro, y documentar la evidencia;
3. explicar por qué «no verificable» no equivale a «no»;
4. interpretar una asociación ajustada sin darle lectura causal;
5. argumentar por qué no conviene sumar indicadores en un índice.

```r
# Desde la carpeta del repositorio
for (f in list.files("R", full.names = TRUE)) source(f)
```

---

## 1. ¿Qué dice un artículo sobre sus datos? (20 min)

Los detectores son reglas explícitas. Pruébalos con frases reales:

```r
detect_text("Data availability. All data and scripts are available at https://osf.io/ab3cd/.")
detect_text("The data are available from the corresponding author upon reasonable request.")
detect_text("Analyses were run in R using the lme4 package.")
detect_text(NA)  # sin texto: todo "unverifiable"
```

**Ejercicio 1.** Escribe tres frases que el detector clasifique mal: un falso positivo, un falso negativo y un caso dudoso. Por ejemplo, ¿qué pasa si el artículo cita el código *de otro autor*? Anota qué regla falla y cómo la cambiarías.

## 2. Un artículo real, de principio a fin (25 min)

```r
doi <- "10.1371/journal.pone.0161442"   # o el DOI de un artículo tuyo
w <- http_get(paste0("https://api.openalex.org/works/doi:", doi))
a <- flatten_work(w)
ft <- get_fulltext(a$doi, a$pmcid, a$oa_url)
ft$source
p <- profile_article(a$doi, ft$text, datacite_links(a$doi), crossref_supplement(a$doi))
str(p)
```

**Ejercicio 2.** Abre el artículo y codifícalo a mano con el [libro de códigos](../protocol/codebook.md). Después compara tu codificación con la del detector. ¿Dónde estaba la evidencia: en el texto, en los metadatos o en ambos?

## 3. Lo que no se puede ver (15 min)

```r
articles <- targets::tar_read(articles)   # muestra piloto
table(targets::tar_read(frame)$fulltext_source)
```

**Discusión.** En el piloto solo el 12 % de los artículos tenía un texto completo accesible para los detectores. ¿Qué pasaría si los demás se contaran como «no comparte»? Calcula la prevalencia de `data_shared` de las dos maneras y compáralas:

```r
f <- targets::tar_read(frame)
mean(f$data_shared == "yes")                                # contando lo no verificable como "no"
mean(f$data_shared[f$data_shared != "unverifiable"] == "yes")  # solo verificables
```

## 4. Asociación no es efecto (25 min)

Con datos simulados se conoce la verdad. En esta simulación compartir datos multiplica las citas por 1,3, pero el acceso abierto influye a la vez en compartir y en ser citado:

```r
d <- simulate_study(n = 3000, rr_data = 1.3, seed = 1)
fit_poisson(d, "data_shared", adjust = FALSE)   # sin ajustar
fit_poisson(d, "data_shared")                   # ajustando por covariables
fit_association(d, "data_shared")               # modelo multinivel del protocolo
evalue(1.3, 1.1, 1.5)
```

**Ejercicio 3.** ¿Cuánto cambia la razón de tasas al ajustar? Explica con el E-value qué fuerza debería tener un confusor no medido, como el prestigio del grupo, para que la asociación desapareciera.

## 5. ¿Por qué no un índice? (20 min)

```r
s <- weight_sensitivity(d, n_draws = 200)
quantile(s$rr_per_sd, c(.025, .5, .975), na.rm = TRUE)
hist(s$rr_per_sd, main = "La conclusión según cómo se pondere", xlab = "RR por DE del índice")
```

**Ejercicio 4.** Si un índice con pesos del 25 % diera una conclusión y otro con pesos distintos diera otra, ¿cuál sería la «verdadera»? Relaciona tu respuesta con los principios de DORA y CoARA.

## 6. Para llevar (15 min)

- Deposita los datos y el código de tu próximo trabajo en Zenodo u OSF, con DOI, y enlázalos desde el artículo.
- Escribe una declaración de disponibilidad que un detector y una persona puedan verificar.
- Si evalúas a otras personas, pide evidencias de cada práctica por separado, no una puntuación.

---

*Licencia CC BY 4.0. Cita: véase `CITATION.cff`.*
