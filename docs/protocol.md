# Protocolo de investigación REPRO2IMPACT

**Versión:** borrador operativo 0.1 · 2 de noviembre de 2026  
**Estado:** protocolo de trabajo actualizado tras un piloto exploratorio; no es un preregistro. Congelar pregunta, población, exposiciones y outcomes con el equipo antes del análisis confirmatorio.

## Pregunta y alcance

¿En qué medida las prácticas de transparencia observables en artículos de investigación se asocian con resultados académicos y sociales, una vez ajustadas diferencias observables entre publicaciones? El estudio mide transparencia y disponibilidad verificable de artefactos. No equipara esas prácticas con reproducibilidad computacional ni replicabilidad empírica.

## Objetivos

1. Construir y validar un protocolo de codificación de prácticas de transparencia a nivel de artículo.
2. Estimar asociaciones ajustadas entre transparencia y citación, con resultados sociales secundarios solo cuando exista una fuente con cobertura, licencia y ventana temporal documentadas.
3. Describir heterogeneidad por campo y características de publicación sin sobreinterpretarla como causal.
4. Publicar código, protocolo y datos derivados solo en la medida permitida por las fuentes y las aprobaciones institucionales.

## Diseño y unidad

Estudio observacional multidisciplinar; unidad primaria: artículo. El diseño principal no es experimental. Las políticas editoriales se codifican a nivel revista-periodo y se usan como contexto; no se agregan a la puntuación del artículo. Los análisis de diferencias en diferencias quedan fuera del análisis principal y solo se habilitan si se identifica una política con fecha precisa, revistas tratadas y comparadoras plausibles, datos pre y post, y una estrategia preespecificada para evaluar tendencias previas y cambios concomitantes.

## Decisiones que el equipo debe fijar antes de extraer datos

- `[DECIDIR]` Campos y justificación de su inclusión; evitar una muestra oportunista de disciplinas.
- `[DECIDIR]` Años de publicación y ventanas de resultados; considerar que las publicaciones recientes tienen menos tiempo para recibir citas.
- `[DECIDIR]` Fuente bibliográfica primaria y plan de respaldo, consulta exacta, fecha de extracción y procedimiento de deduplicación.
- `[DECIDIR]` Tamaño muestral viable y estrategia de muestreo estratificado. La cifra 3.000–5.000 de la memoria es un objetivo, no un cálculo de potencia.
- `[DECIDIR]` Resultado primario. Propuesta para deliberación: conteo acumulado de citas de una única fuente, congelado en la fecha de extracción. Como la edad de los artículos afecta la exposición a citas, fijar un periodo de publicación suficientemente maduro y ajustar por año; añadir análisis de sensibilidad por cohorte. No llamar a este conteo “ventana fija” salvo que se reconstruya explícitamente.
- `[DECIDIR]` Fuentes y resultados sociales secundarios. Definir proveedor, cobertura, periodo, deduplicación y licencia; si no se confirma, eliminar la variable en vez de sustituirla a posteriori.
- `[DECIDIR]` Número de codificadores, tamaño de doble codificación, estadístico de acuerdo y umbral para revisar el manual.
- `[DECIDIR]` Covariables y forma de medirlas: acceso abierto, colaboración internacional, tipo de artículo, año y campo.
- `[DECIDIR]` Repositorio final, licencia de código y condiciones de acceso a datos derivados.
- `[DECIDIR]` Fecha de inicio real, duración y entregables según resolución de financiación.

## Exposición primaria: transparencia de artefactos

El índice provisional de la memoria tiene cuatro dimensiones binarias `yes`, `no`, `unclear` o `not_applicable`: datos, código, documentación de métodos/materiales y política editorial/certificaciones efectivas. El preregistro/protocolo se codifica como subindicador de documentación metodológica. `yes` requiere evidencia vinculada al artículo o a su revista y vigente en el periodo pertinente. `no` requiere búsqueda documentada sin evidencia localizada. `unclear` indica evidencia ambigua o enlace fallido; no se convierte en cero. `not_applicable` requiere justificación.

El índice se expresa provisionalmente de 0 a 1 como media equitativa de dimensiones determinables, siempre que haya al menos tres de cuatro observadas. Se acompaña del número de dimensiones observadas y la cobertura de datos. Dado que la política es contextual y no una propiedad del artefacto del artículo, se informarán también resultados separados del componente editorial y de un subíndice de prácticas del artículo (datos, código, métodos). No llamar a ninguno “reproducibilidad verificada”. Los pesos y validez externa quedan pendientes de consulta a expertos.

## Resultados y modelos

Resultado primario propuesto: conteo acumulado de citas hasta una fecha de extracción común, pendiente de decisión final. El pipeline estima una regresión Poisson con errores estándar HC3, ajustando por año, campo y covariables disponibles preespecificadas. La regresión binomial negativa se reporta como sensibilidad si converge. Revisar sobredispersión, observaciones influyentes, colinealidad, solapamiento de covariables, faltantes y definición alternativa de la exposición. Si el modelo no resulta apropiado, documentar la desviación antes de interpretar. El ajuste por año no elimina por completo las diferencias de tiempo de exposición; por ello se debe fijar el periodo de publicación y reportar sensibilidad por cohorte.

Menciones sociales, documentos de política, descargas y reutilizaciones son resultados secundarios distintos; no se combinan en un único “impacto”. Se informan cobertura y ceros estructurales por fuente. Toda inferencia causal se evita en el análisis observacional. Si se aprueba un análisis de política editorial, documentar estimando, tratamiento, comparador, tendencias pre, anticipación, cambios simultáneos y análisis de sensibilidad.

## Muestreo, extracción y control de calidad

Publicar la estrategia de búsqueda y filtros antes de ver los resultados. Guardar consulta, versión/fecha de API, recuento por etapa, identificadores, duplicados y exclusiones. Mantener un registro de cambios y decisiones. Piloto estratificado; doble codificación de `[DECIDIR]%`; informar acuerdo e intervalos; resolver discrepancias y congelar manual antes de codificación principal. No raspar ni conservar datos cuando los términos de servicio lo prohíban.

## Ética, privacidad y gestión

Usar metadatos de publicaciones, minimizando identificadores de personas. Revisar con la unidad institucional competente si el plan final incorpora datos personales o trazas de redes sociales. No afirmar que existe aprobación ética o evaluación de impacto hasta obtenerla. Guardar datos comerciales/licenciados en almacenamiento aprobado; publicar solo código y datos que se puedan redistribuir. Registrar procedencia y restricciones en cada tabla.

## Transparencia y desviaciones

Depositar protocolo y fecha de congelación antes del análisis confirmatorio. Mantener un log de desviaciones con fecha, motivo y si la decisión ocurrió antes o después de inspeccionar resultados. Publicar scripts, entorno y documentación; versionar resultados y evitar credenciales en repositorios. Informar resultados nulos y limitaciones de cobertura.

## Cronograma relativo

- Meses 1–3: cerrar decisiones, consulta, licencias, protocolo y piloto.
- Meses 4–8: extracción, deduplicación y codificación principal.
- Meses 9–14: validación, análisis principal y sensibilidades.
- Meses 15–20: artículos e informe de política.
- Meses 21–24: documentación, publicación de recursos y cierre.

Este cronograma es un borrador relativo; comienza en la fecha de inicio aprobada, no en la fecha de firma de la memoria.
