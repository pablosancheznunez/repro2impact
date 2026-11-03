# Protocolo del estudio empírico de REPRO2IMPACT

**Prácticas de transparencia, reproducibilidad e impacto académico y social de la investigación**

Versión 1.0 · Noviembre de 2026 · IP: Pablo Sánchez-Núñez (UC3M)

Este protocolo desarrolla el proyecto aprobado en la convocatoria 2025 del Programa Propio de Investigación de la UC3M. Mantiene su pregunta, su calendario y su presupuesto, y corrige cinco aspectos del diseño de la memoria; la sección 2 detalla cada cambio y su motivo. Antes de recoger los datos del estudio principal, el protocolo se prerregistrará en OSF (borrador en inglés en [`preregistration.md`](preregistration.md)).

---

## 1. Pregunta y objetivos

**Pregunta.** ¿Se asocian las prácticas de transparencia que hacen posible la reproducibilidad (datos, código y documentación metodológica abiertos) con el impacto académico y social de los artículos? ¿Las políticas editoriales que las promueven cambian esas prácticas y ese impacto?

**Objetivos**

- **O1. Medir.** Construir y validar un perfil de prácticas de transparencia por artículo, detectable automáticamente y contrastado con codificación manual.
- **O2. Describir.** Estimar la prevalencia de cada práctica por campo y año.
- **O3. Asociar.** Estimar la asociación de cada práctica con el impacto académico (citas normalizadas) y social (Wikipedia, documentos de política y atención altmétrica), ajustando por confusores observables.
- **O4. Políticas.** Estimar el efecto de la adopción de políticas editoriales (insignias de apertura, TOP, informes registrados) sobre las prácticas y el impacto mediante diferencias en diferencias.
- **O5. Validar.** Reproducir computacionalmente una submuestra para saber cuánto de la "reproducibilidad potencial" se traduce en reproducibilidad real.
- **O6. Abrir.** Publicar los datos, el código, el libro de códigos y un panel interactivo con DOI.

---

## 2. Cambios respecto a la memoria y motivo

| Memoria | Protocolo | Motivo |
| --- | --- | --- |
| Índice compuesto de cuatro dimensiones (25 % cada una) que clasifica los artículos en niveles | **Perfil de indicadores separados.** El índice solo se usa como análisis de sensibilidad, con muchos esquemas de pesos | Coherencia con DORA, CoARA y OpenResearchMetrics: sumar oculta lo que la evaluación responsable necesita ver |
| "Artículos reproducibles / no reproducibles" | **Prácticas de transparencia** o **reproducibilidad potencial**; la reproducibilidad real se mide en la submuestra de O5 | Validez de constructo: que un análisis se pueda reproducir solo se sabe volviendo a ejecutarlo |
| Política editorial como cuarta dimensión del índice del artículo | **Variable de nivel revista** en los modelos multinivel y tratamiento del análisis de diferencias en diferencias | Es una característica de la revista y confunde niveles; además está correlacionada con el prestigio |
| Emparejamiento y modelos multinivel presentados como "métodos experimentales" con "validez causal" | **Asociación ajustada** con análisis de sensibilidad (E-value). El lenguaje causal se reserva para O4 | Los métodos de emparejamiento solo controlan confusores observados |
| Reutilización de datos y código como resultado comparado entre grupos | **Solo dentro de los artículos que comparten** | Fuera de ese grupo la reutilización es imposible por definición: la comparación sería circular |
| MetaROR y OECD Data Explorer como fuentes | **DataCite, Crossref, OpenAIRE y Europe PMC** para los objetos vinculados; **Overton o Sage Policy Profiles** para menciones en política | MetaROR es una plataforma de revisión abierta y OECD Data Explorer no recoge menciones de artículos |

---

## 3. Diseño

Es un estudio observacional retrospectivo de cohortes de artículos, con un componente cuasiexperimental (diferencias en diferencias escalonadas) y un subestudio de reproducción.

### 3.1 Población y muestra

- **Tipo:** artículos de investigación (`type:article` en OpenAlex), sin retractar, en inglés o español.
- **Años:** 2016–2020. Así cada artículo tiene al menos cinco años completos de citas y el periodo cubre la extensión de las insignias y las TOP Guidelines.
- **Estratos (campos):** definidos con la clasificación de OpenAlex y versionados en [`R/config.R`](../R/config.R).
  - **Psicología:** subcampos 3205 (*Experimental and Cognitive Psychology*) y 3207 (*Social Psychology*).
  - **Comunicación:** subcampo 3315 (*Communication*).
  - **Ciencias sociales computacionales:** tema T13910 (*Computational and Text Analysis Methods*).
- **Muestreo:** aleatorio estratificado por campo × año con la muestra reproducible de OpenAlex (`sample` + `seed`). Son 300 artículos por celda (3 campos × 5 años × 300 = **4.500**), dentro del rango de 3.000–5.000 de la memoria.
- **Piloto:** 20 artículos por celda (300), para calibrar los detectores y la codificación manual.

### 3.2 Exposiciones: perfil de transparencia (nivel artículo)

Cada indicador se registra por separado con tres valores posibles: **sí**, **no** y **no verificable** (no hay texto completo accesible ni metadatos suficientes). "No verificable" nunca se convierte en "no".

| Familia | Indicador | Fuentes automáticas |
| --- | --- | --- |
| Datos | `data_shared`: datos depositados en un repositorio con enlace persistente | Relaciones en DataCite y Crossref; enlaces a repositorios en el texto completo |
| Datos | `data_statement`: declaración de disponibilidad de datos | Patrones en el texto completo |
| Código | `code_shared`: código depositado (GitHub, GitLab, Zenodo, OSF, Code Ocean…) | Relaciones en DataCite (tipo *Software*); patrones en el texto |
| Documentación | `preregistered`: prerregistro enlazado (OSF Registries, AsPredicted, ClinicalTrials.gov, PROSPERO) | Patrones en el texto |
| Documentación | `materials_shared`: materiales o protocolo completos disponibles | Patrones en el texto |

Los detectores son reglas explícitas y versionadas (`R/detect.R`), inspiradas en rtransparent (Serghiou et al., 2021) y ODDPub (Riedel et al., 2020), y se validan contra la codificación manual (sección 5).

### 3.3 Políticas editoriales (nivel revista)

Para cada revista se registra si ha adoptado insignias de apertura, el nivel TOP de sus políticas de datos y código, y si acepta informes registrados, con el **año de adopción** y la **fuente documental** de cada dato (`data-raw/journal_policies.csv`). Se rellena a mano a partir de las páginas de política de cada revista y de las listas del Center for Open Science. No se imputa nada que no tenga fuente.

### 3.4 Resultados

**Impacto académico**

- `cit_5y`: citas recibidas entre el año siguiente a la publicación y los cinco posteriores (OpenAlex, `counts_by_year`).
- `cit_norm`: `cit_5y` dividido por la media de su celda campo × año en la muestra.
- `fwci`: FWCI de OpenAlex, como contraste externo.
- **Contraste institucional opcional:** CNCI de InCites.

**Impacto social**

- `wikipedia`: número de artículos de Wikipedia (en inglés y español) que citan el DOI.
- `policy`: menciones en documentos de política (Overton o Sage Policy Profiles), si hay acceso.
- `altmetric`: Altmetric Attention Score y desglose por fuente, si hay acceso.

**Reutilización (solo artículos que comparten)**

- Citas, visitas y descargas de los datasets y el software vinculados (DataCite).

### 3.5 Covariables (confusores observables)

- Campo × año (efectos fijos).
- Revista (efecto aleatorio).
- Estado de acceso abierto.
- Número de autores.
- Colaboración internacional.
- Número de referencias.
- Financiación declarada.
- Número de instituciones.

El prestigio del grupo no está bien medido por ninguna de ellas; por eso la sección 4 incluye un análisis de sensibilidad a confusores no observados.

---

## 4. Análisis

Todos los análisis están en `R/analysis.R`, se ejecutan con `{targets}` y se prueban antes con datos simulados de efecto conocido (`R/simulate.R`).

1. **Prevalencia (O2).** Proporción de cada indicador por campo × año con intervalos de Wilson. Los casos "no verificables" se informan aparte y no entran en el denominador.
2. **Asociación (O3).** Regresión binomial negativa multinivel (`glmmTMB`) de `cit_5y`, con cada indicador por separado y todos juntos, efectos fijos campo × año, efecto aleatorio de revista y las covariables de 3.5. Para los resultados sociales, muy cargados de ceros, se usan modelos de vallas (*hurdle*). Se informan razones de tasas con IC del 95 %.
3. **Emparejamiento (O3, robustez).** Emparejamiento por puntuación de propensión con calibre de 0,2 DE, exacto por campo × año (`MatchIt`), con diagnóstico de balance (`cobalt`). Se compara con la ponderación por probabilidad inversa.
4. **Sensibilidad a confusores no observados.** E-value (VanderWeele y Ding, 2017) para cada razón de tasas.
5. **Políticas (O4).** Diferencias en diferencias escalonadas a nivel artículo con el estimador de Sun y Abraham (`fixest::sunab`) y estudio de eventos de −3 a +4 años. Hay dos etapas: primero política → prácticas (primera etapa), y después política → impacto. Se comprueba que no haya tendencias previas.
6. **Índice compuesto, solo como sensibilidad.** Se recalcula la asociación con 1.000 vectores de pesos aleatorios (Dirichlet) para mostrar que la conclusión no depende de una ponderación arbitraria. El índice no se publica como clasificación.
7. **Correcciones.** La familia de contrastes de O3 se ajusta con Holm. Las hipótesis confirmatorias son las del prerregistro; todo lo demás se etiqueta como exploratorio.

---

## 5. Validación: codificación manual y reproducción

### 5.1 Codificación manual (O1)

- Dos codificadores independientes codifican una submuestra aleatoria estratificada de **450 artículos** (10 %) con el libro de códigos ([`codebook.md`](codebook.md)).
- Se calcula el acuerdo entre codificadores con kappa de Cohen y porcentaje de acuerdo. El umbral es κ ≥ 0,70; por debajo se revisa el libro de códigos y se recodifica.
- Las discrepancias las resuelve un tercer codificador.
- Se mide el rendimiento de cada detector automático frente al consenso manual: sensibilidad, especificidad y valor predictivo positivo con IC.
- Si un detector tiene una sensibilidad < 0,80, ese indicador se codifica a mano en toda la muestra o se informa con su tasa de error.

### 5.2 Subestudio de reproducción (O5)

- Se toman **40 artículos** con datos y código abiertos (muestreo estratificado por campo) y se intenta reproducir el resultado principal.
- La reproducción se clasifica en cinco niveles: exacta, con diferencias menores, con diferencias sustanciales, no ejecutable o materiales incompletos.
- El protocolo completo está en [`reproduction.md`](reproduction.md).

---

## 6. Datos, ética y apertura

- Solo se usan metadatos bibliográficos y textos completos en acceso abierto.
- No se tratan datos personales salvo los nombres de autores que ya figuran en los metadatos públicos.
- Las menciones en redes sociales se usan en forma agregada (recuentos), sin identificadores de usuarios.
- **Licencias:** el código, con licencia MIT; los datos derivados y la documentación, con CC BY 4.0. Cada versión se archiva en Zenodo con DOI.
- Los datos de fuentes con licencia restrictiva (Altmetric, Overton, InCites) no se redistribuyen. Se publica el código que los obtiene y los resultados agregados.

---

## 7. Calendario (24 meses)

| Meses | Fase | Entregables |
| --- | --- | --- |
| 1–6 | Diseño | Protocolo y prerregistro en OSF; libro de códigos; piloto de 300 artículos; calibración de los detectores |
| 7–16 | Implementación y análisis | Muestra de 4.500 artículos; codificación manual de 450; tabla de políticas editoriales; análisis O2–O4; subestudio de reproducción |
| 17–24 | Síntesis y transferencia | Artículos, *policy brief*, panel interactivo, datos con DOI |

La difusión en congresos la planifica el equipo en un documento interno. Cualquier subestudio que se añada para una comunicación se incorporará a este protocolo y al prerregistro antes de recoger sus datos.

---

## 8. Referencias clave

- Colavizza, G., Hrynaszkiewicz, I., Staden, I., Whitaker, K. y McGillivray, B. (2020). The citation advantage of linking publications to research data. *PLOS ONE*, 15(4), e0230416.
- Kidwell, M. C. et al. (2016). Badges to acknowledge open practices. *PLOS Biology*, 14(5), e1002456.
- Nosek, B. A. et al. (2015). Promoting an open research culture. *Science*, 348(6242), 1422–1425.
- Piwowar, H. A. y Vision, T. J. (2013). Data reuse and the open data citation advantage. *PeerJ*, 1, e175.
- Riedel, N., Kip, M. y Bobrov, E. (2020). ODDPub – a text-mining algorithm to detect data sharing in biomedical publications. *Data Science Journal*, 19, 42.
- Serghiou, S. et al. (2021). Assessment of transparency indicators across the biomedical literature. *PLOS Biology*, 19(3), e3001107.
- Sun, L. y Abraham, S. (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. *Journal of Econometrics*, 225(2), 175–199.
- VanderWeele, T. J. y Ding, P. (2017). Sensitivity analysis in observational research: introducing the E-value. *Annals of Internal Medicine*, 167(4), 268–274.
