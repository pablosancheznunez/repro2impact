# Revisión sistemática (fase 1, meses 1–6)

**Pregunta.** ¿Qué evidencia empírica hay sobre la relación entre las prácticas de transparencia o reproducibilidad de un artículo (datos, código, prerregistro, materiales, insignias) y su impacto académico o social?

Sigue PRISMA 2020. El protocolo se registrará en OSF junto con el del estudio principal.

## Criterios de elegibilidad

| | Incluir | Excluir |
| --- | --- | --- |
| Diseño | Estudios empíricos cuantitativos (observacionales, cuasiexperimentales, experimentales) | Opiniones, editoriales, revisiones narrativas (se usan solo para buscar referencias) |
| Exposición | Disponibilidad de datos, código o materiales; prerregistro; informes registrados; insignias; políticas TOP | Acceso abierto como única exposición |
| Resultado | Citas, métricas normalizadas, altmetrías, menciones en política, reutilización | Solo descargas o lecturas sin otra medida |
| Idioma y fecha | Inglés o español, 2005–2026 | — |

## Fuentes y ecuaciones de búsqueda

- **Fuentes:** Web of Science Core Collection, Scopus, OpenAlex, Dimensions y medRxiv/OSF Preprints (literatura gris).
- **Búsqueda complementaria:** encadenamiento hacia atrás y hacia delante de los estudios incluidos (*snowballing*) con OpenAlex.

Ecuación base (WoS, campo `TS`), adaptada a cada fuente:

```
TS=(("data sharing" OR "open data" OR "data availability" OR "code sharing" OR "open code"
     OR "preregist*" OR "pre-regist*" OR "registered report*" OR "open science badge*"
     OR "TOP guidelines" OR "reproducib*" OR "transparen* practice*")
    AND ("citation*" OR "citation advantage" OR "altmetric*" OR "policy document*"
     OR "research impact" OR "societal impact" OR "reuse"))
```

La ecuación final para cada fuente, con su fecha y número de resultados, se guarda en `review/searches.csv`.

## Proceso

1. **Deduplicación** por DOI y, si no lo hay, por título normalizado.
2. **Cribado de título y resumen:** dos revisores independientes. Se calcula κ en una muestra inicial de 200 registros, con objetivo ≥ 0,70.
3. **Lectura del texto completo:** dos revisores; los desacuerdos los resuelve un tercero.
4. **Extracción:**
   - diseño;
   - campo;
   - número de artículos;
   - exposición y su operacionalización;
   - resultado;
   - estimador del efecto (razón de tasas, diferencia de medias o porcentaje) con su IC;
   - variables de ajuste.
5. **Riesgo de sesgo:** ROBINS-E para los estudios observacionales, adaptado a la metainvestigación. Los juicios se hacen por dominio, sin puntuación total.
6. **Síntesis:** síntesis narrativa estructurada (SWiM).
   - Si hay al menos cinco estudios con un resultado comparable (por ejemplo, razón de citas por datos compartidos), se hará un metaanálisis de efectos aleatorios (REML, Hartung-Knapp).
   - La heterogeneidad se informará con τ² e intervalos de predicción.

## Uso en el proyecto

La revisión alimenta tres decisiones del estudio principal:

- las definiciones y los patrones de los detectores;
- los confusores que hay que ajustar;
- los tamaños de efecto esperados para el cálculo de potencia, que ahora usa RR = 1,20 a partir de Colavizza et al. (2020).
