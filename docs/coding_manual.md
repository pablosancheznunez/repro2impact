# Manual breve de codificación

Codificar evidencia visible en la fecha de revisión. Registrar URL, fecha, decisión y nota para cada dimensión en el sistema de gestión de datos del equipo. El CSV de análisis contiene los códigos; conservar el registro de evidencia separado y con acceso aprobado.

## Códigos comunes

- `yes`: artefacto o documento enlazado y accesible, identificado como perteneciente al artículo.
- `no`: revisión realizada y no se encontró evidencia tras seguir reglas de búsqueda predefinidas.
- `unclear`: evidencia ambigua, enlace roto o asociación dudosa. No es ausencia.
- `not_applicable`: el equipo justifica que la dimensión no aplica al diseño o artículo; no usar para evitar una búsqueda.

## Dimensiones

- `data_status`: conjunto de datos analíticos disponible o declaración explícita de su ubicación/acceso. Datos embargados o restringidos: codificar `yes` solo si la ruta de acceso está descrita y el criterio de accesibilidad se aprueba en el manual detallado.
- `code_status`: código analítico para el resultado principal accesible o depositado, con vínculo claro al artículo. No basta con que el autor mencione una herramienta.
- `methods_status`: métodos, materiales y pasos suficientes según rúbrica específica del campo para entender la ejecución. En la fase piloto, definir una lista por campo; no juzgar “reproducible” en abstracto.
- `methods_status`: métodos, materiales y pasos suficientes según rúbrica específica del campo para entender la ejecución; registrar por separado si existe preregistro/protocolo fechado, público y anterior al análisis (`prereg_status`). Una mención posterior no cuenta como preregistro.
- `journal_policy_status`: política editorial y certificaciones en vigor durante el periodo del artículo (p. ej., requisitos de datos/código, TOP, badges o registered reports). Guardar versión/URL, fecha de vigencia y nivel de implementación; la mera adhesión declarada no equivale a verificación.

## Índice provisional del proyecto

La memoria propone cuatro dimensiones con peso inicial igual: datos, código, documentación metodológica y política editorial. El código calcula de forma provisional la media de dimensiones determinables (requiere al menos tres de cuatro); `unclear` y `not_applicable` no se convierten en cero. Deben presentarse puntuación, dimensiones observadas y cobertura por separado. Preregistro es un indicador detallado de documentación, no una quinta dimensión. La validez externa y los pesos finales quedan pendientes de consulta a expertos; no llamar al puntaje “reproducibilidad verificada”.

## Aseguramiento de calidad

Pilotar en todas las disciplinas. Revisar casos con desacuerdo y actualizar ejemplos antes de congelar el manual. No cambiar códigos tras ver asociaciones sin registrar desviación. Mantener las decisiones originales y adjudicadas en un registro con trazabilidad.
