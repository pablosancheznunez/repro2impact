# Plan de gestión de datos y evaluación de impacto en protección de datos

## Datos que se generan

| Conjunto | Contenido | Formato | Licencia | Dónde |
| --- | --- | --- | --- | --- |
| Muestra y perfiles | DOI, metadatos bibliográficos, valores de los indicadores y su evidencia textual (≤ 400 caracteres) | CSV y JSON | CC BY 4.0 | GitHub y Zenodo (DOI por versión) |
| Codificación manual | Codificaciones de cada codificador, consenso y acuerdo | CSV | CC BY 4.0 | Zenodo |
| Resultados | Tablas de prevalencia, asociaciones y sensibilidad | CSV y JSON | CC BY 4.0 | GitHub, Zenodo y el panel |
| Caché de las API | Respuestas originales de OpenAlex, Crossref, DataCite, Europe PMC y Wikipedia | JSON y texto | Las de cada fuente | Servidor de la UC3M; no se publica |
| Fuentes con licencia | Altmetric, Overton, InCites | — | Restrictiva | No se redistribuyen; solo resultados agregados |
| Reproducción | Registros de ejecución y clasificación | CSV y Markdown | CC BY 4.0 | Zenodo, anonimizado por artículo |
| Validación con expertos | Valoraciones del Delphi | CSV | — | Solo agregadas; los datos brutos, en el servidor de la UC3M |

## FAIR

- **Localizable:** cada versión de datos y código tiene su DOI en Zenodo, y los metadatos se describen con DataCite.
- **Accesible:** acceso abierto sin registro.
- **Interoperable:** CSV con diccionario de variables (`outputs/README.md`); identificadores persistentes (DOI, ID de OpenAlex, ISSN-L).
- **Reutilizable:** licencias explícitas, versión de los detectores en cada fila y procedencia de cada valor (fuente y evidencia).

## Conservación

Los datos se conservan al menos 10 años en Zenodo, más una copia en el servidor institucional de la UC3M y el repositorio en GitHub.

## Evaluación de impacto en protección de datos (DPIA): cribado

| Pregunta | Respuesta |
| --- | --- |
| ¿Se tratan datos personales? | Sí, de forma limitada: los nombres de autores que figuran en metadatos públicos (OpenAlex). No se publican como variable de análisis; se usan solo los recuentos de autores, instituciones y países. |
| ¿Datos de redes sociales? | Solo recuentos agregados de Altmetric. No se guardan *handles* ni textos de publicaciones. |
| ¿Datos de los expertos del Delphi? | Nombre y correo para el contacto, guardados aparte de las respuestas y borrados al terminar el proyecto. Las respuestas son seudónimas. |
| ¿Decisiones automatizadas sobre personas? | No. Los indicadores describen artículos, no evalúan a personas, y no se publican clasificaciones de autores ni de instituciones. |
| ¿Hace falta una DPIA completa? | No, según el cribado: el tratamiento es de bajo riesgo (art. 35 del RGPD). Se documenta este cribado y se consultará a la DPD de la UC3M antes del Delphi. |

**Base jurídica:** misión de interés público en investigación (art. 6.1.e y 89 del RGPD); consentimiento informado para el panel Delphi.
