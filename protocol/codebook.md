# Libro de códigos · codificación manual

Versión 1.0 · Se aplica a la submuestra de validación (450 artículos) y al piloto (300).

## Procedimiento

1. Cada codificador recibe la hoja `coding_sheet.csv` generada por `make_coding_sheet()`, con el DOI, el título y el enlace al texto completo. **No** ve el resultado de los detectores automáticos.
2. Lee el artículo completo, incluidos los materiales suplementarios y las notas finales, y rellena una fila por artículo.
3. Para cada indicador anota el **valor** y, si es "sí", la **evidencia**: la URL o el identificador y la página o sección donde aparece.
4. Si no puede acceder al texto completo, marca `unverifiable` en todos los indicadores y anota el motivo.
5. Las dos codificaciones se comparan con `irr_report()`. Las discrepancias las resuelve un tercer codificador y se registran en `consensus.csv`.

Valores permitidos en todos los indicadores: `yes`, `no`, `unverifiable`.

## Indicadores

### `data_statement`: declaración de disponibilidad de datos
**Sí** si hay una sección o frase explícita sobre la disponibilidad de los datos, aunque diga "disponibles bajo petición" o "no se pueden compartir".
**No** si no hay ninguna declaración.
*Ejemplo de sí:* "Data Availability Statement: The data are available from the corresponding author upon reasonable request."

### `data_shared`: datos depositados y accesibles
**Sí** si los datos que sustentan los resultados principales están en un repositorio o en material suplementario descargable, con enlace funcional. Sirven, por ejemplo, OSF, Zenodo, Dryad, figshare, Dataverse, ICPSR, UK Data Service, PsychArchives o el suplemento de la editorial.
**No** si los datos solo están "bajo petición", si el enlace no funciona o si solo hay datos de terceros sin enlace.
**Caso límite:** si los datos son públicos de terceros (por ejemplo, una encuesta del CIS) y se da el identificador exacto, es **sí**. Indíquelo en las notas.

### `code_shared`: código de análisis disponible
**Sí** si el código o la sintaxis de análisis (R, Python, Stata, SPSS, Mplus…) están en un repositorio o un suplemento con enlace funcional.
**No** si solo se nombra el software usado, o si el código está "disponible bajo petición".

### `preregistered`: prerregistro
**Sí** si se enlaza un prerregistro del estudio: OSF Registries, AsPredicted, ClinicalTrials.gov, PROSPERO, AEA RCT Registry o un informe registrado.
**No** si no hay prerregistro, o si solo se menciona sin enlace.

### `materials_shared`: materiales disponibles
**Sí** si los estímulos, cuestionarios, protocolos o guiones necesarios para replicar el procedimiento están disponibles, completos y enlazados.
**No** si solo aparecen ejemplos de ítems o descripciones.

### `registered_report`: informe registrado
**Sí** si el artículo se publicó como informe registrado (*Registered Report*, con aceptación en etapa 1).

## Campos de control

| Campo | Contenido |
| --- | --- |
| `coder` | Iniciales del codificador |
| `minutes` | Tiempo dedicado al artículo |
| `fulltext_source` | Dónde se leyó: editorial, PMC, repositorio o preprint |
| `notes` | Observaciones, casos límite |

## Umbral de calidad

κ de Cohen ≥ 0,70 en cada indicador. Si un indicador queda por debajo, se revisa la definición, se añade un ejemplo de los casos en desacuerdo y se recodifica una nueva tanda de 50 artículos.
