# Seguimiento de la memoria científico-técnica

**Corte:** 2 noviembre 2026 · **Documento fuente:** memoria firmada el 25 septiembre 2025 · **Alcance:** auditoría de entregables verificables en este repositorio; no acredita ejecución institucional ni actividades del equipo.

## Matriz de cumplimiento

| Compromiso de la memoria | Estado comprobable | Evidencia / brecha |
|---|---|---|
| Revisión de literatura sobre reproducibilidad, bibliometría y altmetría | Parcial | Hay una actualización exploratoria y una estrategia de revisión; falta búsqueda sistemática multi-base, cribado duplicado y diagrama PRISMA. |
| Índice de cuatro dimensiones | Prototipo | Código, plantilla y manual ahora alinean datos, código, documentación y política editorial. Pesos iguales son provisionales; validación externa con editores y Spanish Reproducibility Network no realizada. |
| Preregistro OSF | Pendiente | No se ha depositado un preregistro. El piloto ya examinó resultados, así que debe mantenerse separado de cualquier análisis confirmatorio. |
| Fuentes bibliométricas y citas normalizadas | Parcial | Piloto OSI v11/OpenAlex de 3.424 registros, años 2018–2021, citas acumuladas. No integra Web of Science, InCites o Dimensions; no tiene ventana fija ni percentiles normalizados oficiales. |
| Muestra estratificada de 3.000–5.000 artículos | Parcial | Se alcanza el tamaño nominal (3.424) en un corpus editorial PLOS. No es la muestra multidisciplinar propuesta ni representa todo el marco de publicación. |
| Codificación automatizada y validación manual | Parcial | Los indicadores OSI son detecciones automatizadas; no se ha realizado validación manual doble ni estimado acuerdo entre codificadores. |
| Altmetrics, Wikipedia/medios y documentos de política | Pendiente | No hay datos en el piloto. Requiere fuentes y licencias/cobertura confirmadas; no inferir impacto social a partir de citas. |
| Reutilización de datos y código | Pendiente | Compartir no equivale a reutilizar. Falta enlazar objetos persistentes con trabajos posteriores y definir reglas de atribución/deduplicación. |
| Modelos Poisson y binomial negativa | Parcial | El piloto usa Poisson ponderado y bootstrap. La sensibilidad NegBin no forma parte de este análisis específico. |
| Modelos multinivel, PSM/CBPS y diferencias en diferencias | Pendiente | Sin identificador y muestra suficiente de revistas/políticas, no hay diseño de política comparable. Matching/ponderación no elimina confusión no observada ni vuelve causal una comparación transversal. |
| Heterogeneidad por disciplina, OA y colaboración | Parcial | Ajuste por campo en el piloto; falta evaluación robusta de subgrupos y covariables OA/colaboración. |
| Dashboard interactivo | Parcial | Prototipo actual con pestaña del piloto y carga de datos autorizados; la vista de PLOS es descriptiva y la muestra no está ponderada visualmente. |
| Scripts, datos FAIR y DOI en OSF/Zenodo | Parcial | Script, metadatos, muestra derivada y código están en GitHub; falta depósito versionado con DOI y evaluación FAIR completa. |
| Informe técnico y policy brief | Parcial | Informe de outcomes del piloto listo; falta síntesis multi-outcome y policy brief para universidades, revistas y financiadores. |
| Artículos y congresos | Pendiente / fuera de este agente | No se han enviado manuscritos ni abstracts. IAMCR julio 2026 ya pasó; no se presupone asistencia ni presentación. Metascience e ISSI 2027 requieren decisión y autorización del equipo. |

## Resultado que puede comunicarse ahora

La muestra PLOS v11 de 2018–2021 contiene 3.424 artículos y todos los DOI de la muestra se enlazaron con OpenAlex. En el modelo Poisson ponderado ajustado por año y campo, datos compartidos: razón de medias 1,12 (IC 95% 0,99–1,27); código compartido: 1,19 (1,05–1,34). Asociación observacional, con muestreo por estado de compartir datos/código; no es efecto causal ni evidencia de impacto social. El ajuste, intervalo y la cobertura de fuente deben acompañar siempre a estas cifras.

## Correcciones necesarias de la memoria

1. La afirmación de que falta toda evaluación comparativa amplia está desactualizada: existe un estudio de unas 122.000 publicaciones con OSI v5 que examinó datos, código, preprints y citas. La novedad debe formularse como extensión de versión, disciplinas, outcomes y validación, no como primera prueba del vínculo apertura-citas.
2. La memoria usa “reproducibilidad” para señales documentales de apertura. Disponibilidad de datos/código y políticas no demuestra que un análisis se reproduzca. Informar por separado transparencia, reproducibilidad computacional y replicabilidad empírica.
3. PSM, CBPS y efectos fijos no garantizan validez causal por sí mismos. Diferencias en diferencias solo procede con política fechada, grupo comparador defendible, suficientes periodos pre/post y evaluación de tendencias previas y cambios simultáneos.
4. La política editorial pertenece al nivel revista-periodo; no debe presentarse como atributo observado del artículo sin enlazar vigencia y mecanismo de cumplimiento. Informar el índice compuesto y sus componentes por separado.

## Dependencias que requieren al equipo/IP

- Confirmar fecha de inicio, periodo contractual, población y disciplinas antes de llamar a esto cumplimiento de hitos.
- Elegir y autorizar proveedores para altmetrics y policy mentions; verificar acceso institucional y licencia antes de extracción.
- Nombrar codificadores y expertos validadores, y aprobar muestreo, doble codificación, protocolo y umbral de acuerdo.
- Decidir si el análisis de políticas se limita a un estudio observacional o si hay una intervención editorial evaluable; no presentar el piloto como evaluación de política.
- Aprobar depósitos públicos OSF/Zenodo y cualquier envío externo.
