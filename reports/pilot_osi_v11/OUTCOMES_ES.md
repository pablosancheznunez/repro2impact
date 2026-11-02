# Outcomes del piloto REPRO2IMPACT (PLOS OSI v11)

**Fecha de extracción:** 2 noviembre 2026 · **Estado:** análisis exploratorio, no confirmatorio.

## Pregunta

En artículos PLOS de 2018–2021, ¿la señal de compartir datos o código se asocia con más citas recibidas? Este piloto estima asociaciones observacionales y no prueba que compartir cause más citas.

## Datos y método

- Fuente: PLOS Open Science Indicators v11, cohorte PLOS; licencia CC BY 4.0. DOI: [10.6084/m9.figshare.21687686.v11](https://doi.org/10.6084/m9.figshare.21687686.v11).
- Marco: 77.334 artículos de investigación 2018–2021 con DOI y estado observado para datos y código.
- Muestra estratificada por año × compartir datos × compartir código: 1.913 registros (hasta 125 por estrato), ponderada a los tamaños poblacionales.
- Resultado: `cited_by_count` de OpenAlex consultado el 2026-11-02. Coincidencia DOI: 1.913/1.913 (100%). Conteo acumulado, no ventana fija.
- Modelo: Poisson ponderado, ajustado por año de publicación y campo temático PLOS; campos con n muestral <100 agrupados; IC 95% bootstrap estratificado (500 réplicas convergentes).

## Hallazgos

| Práctica observada | Razón de medias ajustada | IC 95% | Lectura |
|---|---:|---:|---|
| Datos compartidos | 1,18 | 1,00–1,40 | Asociación estimada de +17,7% en citas |
| Código compartido | 1,24 | 1,01–1,47 | Asociación estimada de +23,6% en citas |

Los IC son limítrofes respecto a 1. Los resultados son compatibles con asociaciones positivas pequeñas/moderadas, pero también reflejan confusión residual y selección. No deben presentarse como efectos causales ni como “impacto social”.

Como descripción secundaria estandarizada por año (sin ajuste por campo), la diferencia de medias fue +5,92 citas para datos (34,72 frente a 28,81; IC 95% 1,14–11,69) y +9,58 para código (41,69 frente a 32,11; IC 95% 3,41–15,87). La proporción de datos compartidos pasó de 70,4% en 2018 a 74,5% en 2021; código, de 10,0% a 14,0%.

## Interpretación para presentar

> En una muestra ponderada de 1.913 artículos PLOS de 2018–2021, las señales de compartir datos y código se asociaron con más citas en un modelo ajustado por año y campo. Es evidencia exploratoria observacional; no demuestra causalidad y no mide reutilización ni impacto social.

## Límites que deben mantenerse visibles

1. PLOS únicamente: sesgo de editorial, disciplinas y selección de artículos; no extrapolar al conjunto de la ciencia.
2. Los indicadores OSI son detecciones documentales/algorítmicas, no auditorías de reproducibilidad o reutilización efectiva.
3. Citas acumuladas actuales de OpenAlex, no una ventana común de seguimiento.
4. Ajuste limitado a año y campo; persiste confusión por calidad, colaboración, acceso abierto, tipo de artículo y otras variables.
5. Los campos infrecuentes se agruparon; el modelo Poisson se usa como aproximación para conteos y no establece causalidad.
6. Sin resultados sociales, documentos de política, descargas o reutilización: no atribuir “impacto social”.

## Novedad y siguiente fase

Ya existe un estudio revisado por pares sobre datos, código y preprints y su relación con citas usando una versión anterior de OSI. Por tanto, este piloto es una extensión de v11, no la primera evaluación del tema. La contribución defendible es ampliar el periodo/versión, explotar indicadores adicionales (protocolos y registros), validar manualmente una muestra de las detecciones y ampliar la cobertura fuera de PLOS.

Antes del estudio confirmatorio: congelar protocolo e hipótesis; predefinir marco, muestra y ventana fija de citas; validar a doble codificación los indicadores; decidir covariables y sensibilidades; documentar licencias y aprobar fuentes de outcomes sociales antes de recogerlos. No sustituir fuentes sociales no disponibles a posteriori.

## Reproducibilidad

Ejecutar `python scripts/pilot_osi_v11.py` desde la raíz del proyecto. El script descarga el archivo fuente desde Figshare, conserva intermedios de texto únicamente en `data/raw/` (ignorado por Git), consulta OpenAlex y genera tablas en `reports/pilot_osi_v11/`. El CSV público `data/pilot/analysis_sample.csv` omite textos de declaraciones y contiene DOI, indicadores, campo, citas y pesos.

Hash SHA-256 del archivo Figshare usado: `1c15e54c8a79015e92b501bc651da646d6b1100dbab25079b48a01559c7e1d47`.

## Fuentes

- PLOS Open Science Indicators v11: https://plos.figshare.com/articles/dataset/PLOS_Open_Science_Indicators/21687686
- OpenAlex API y filtros: https://help.openalex.org/api/ · https://help.openalex.org/api/filtering/
- Estudio previo sobre prácticas abiertas y citas (OSI v5): https://pmc.ncbi.nlm.nih.gov/articles/PMC11524460/
