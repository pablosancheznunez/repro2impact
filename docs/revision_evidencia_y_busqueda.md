# Revisión de evidencia y protocolo de búsqueda

**Versión:** 0.1 · **Fecha de actualización documental:** 2 noviembre 2026 · **Estado:** actualización exploratoria; no es una revisión sistemática terminada.

## Pregunta de revisión

En publicaciones científicas, ¿cómo se han operacionalizado las prácticas de transparencia/reproducibilidad y qué asociaciones se han estudiado con citas normalizadas, atención pública, referencias en políticas y reutilización de datos o código? ¿Cómo varían por disciplina y qué diseños permiten interpretar las asociaciones?

## Por qué se corrige la novedad

La memoria afirma que no existe una comparación amplia. Un estudio publicado con Open Science Indicators v5 examinó aproximadamente 122.000 publicaciones PLOS y de comparación PMC (2018–2023), encontrando asociaciones entre preprints/datos y citas, sin ventaja significativa general de código. Por tanto, los outcomes de citas no constituyen por sí solos un vacío nuevo. La contribución potencial defendible debe centrarse en OSI v11, validez manual de indicadores, diferencias disciplinares, ventana y normalización de citas y outcomes adicionales con fuente verificable.

## Búsqueda formal propuesta

### Fuentes

1. OpenAlex (API abierta) para descubrimiento de registros bibliográficos y DOI.
2. PubMed/PMC para estudios de metaciencia en salud y artículos de texto completo abiertos.
3. Crossref y listas de referencias de estudios incluidos para búsqueda hacia atrás/adelante.
4. Web of Science/Dimensions solo tras confirmar acceso institucional, exportación permitida y licencia.
5. Fuentes específicas de políticas y altmetrics solo tras verificar cobertura, consulta reproducible y términos de uso.

### Cadena de búsqueda inicial (adaptar sintaxis por fuente)

```text
("open science" OR reproducib* OR "research transparency" OR "data sharing" OR "code sharing")
AND
(citation* OR altmetric* OR "policy mention*" OR reuse OR reuse OR "data citation" OR "code reuse")
```

La cadena se pilotará por campo y se archivará literalmente con fecha, filtros y recuentos. No aplicar restricción de idioma o fecha sin justificarla. Deduplicar por DOI y título normalizado; conservar identificador de cada registro y motivo de exclusión.

### Inclusión/exclusión preliminar

- Incluir estudios empíricos en artículos de investigación que midan al menos una práctica abierta/documental y un outcome académico/social o reutilización.
- Incluir estudios de métodos/validación de indicadores de disponibilidad, política editorial, data/code reuse, altmetrics y policy impact como evidencia metodológica.
- Excluir opinión sin datos, estudios puramente técnicos sin resultado de práctica/impacto, editoriales y registros duplicados; documentar excepciones.
- Extraer disciplina, periodo, unidad, fuente, definición operacional, tamaño de muestra, covariables, diseño, efecto e intervalo, cobertura/licencia y riesgos de sesgo.

### Selección y síntesis

Dos personas cribarán títulos/resúmenes y textos completos independientemente. Un piloto de al menos 50 registros servirá para afinar criterios; registrar desacuerdos y acuerdo antes de cribar el conjunto. Sintetizar por familia de outcome y disciplina; no combinar proveedores o outcomes incompatibles en una puntuación única. Aplicar guía PRISMA 2020 para informar el flujo, adaptándola al alcance y tipo de revisión. No atribuir a PRISMA el diseño de la conducta de búsqueda por sí sola.

## Evidencia localizada en esta actualización

- Estudio con OSI v5 y ~122.000 publicaciones: análisis de preprints, datos, código y citas; reporta asociación positiva de citas con preprints y datos, pero no ventaja significativa general para código. Estudio observacional, con cobertura PLOS/PMC; requiere lectura y extracción formal antes de incorporarlo a una síntesis cuantitativa.
- Consenso de prácticas básicas de ciencia abierta en biomedicina: incluye la citación de datasets como posible medida de reutilización; sirve como referencia de operacionalización, no como prueba universal de validez.
- TOP Guidelines/TOP Factor: permite medir adopción de políticas editoriales por estándares y niveles. Las políticas declaradas no equivalen a cumplimiento de autores ni a impacto de artículos.
- PRISMA 2020: aporta checklist y diagrama para transparencia de informes de revisión; no reemplaza un manual de conducción ni la doble selección.

Esta actualización se basó en búsqueda web dirigida de fuentes y no tiene un flujo PRISMA, recuentos exhaustivos, cribado independiente ni evaluación formal de riesgo de sesgo. Por eso no se llama revisión sistemática.

## Fuentes de inicio

- Estudio OSI v5: https://pmc.ncbi.nlm.nih.gov/articles/PMC11524460/
- Consenso de prácticas en biomedicina: https://pmc.ncbi.nlm.nih.gov/articles/PMC9873153/
- TOP Guidelines: https://www.cos.io/initiatives/top-guidelines
- Evaluación de políticas TOP (TRUST): https://researchintegrityjournal.biomedcentral.com/articles/10.1186/s41073-021-00112-8
- PRISMA 2020: https://www.prisma-statement.org/prisma-2020
