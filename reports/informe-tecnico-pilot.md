# REPRO2IMPACT · Informe técnico

Fase: **pilot** · Fecha de los datos: 2026-11-03 · Protocolo v1.0.0 · Detectores v1.1.0

> **Resultados del piloto.** Sirven para calibrar detectores y procedimientos, no para extraer conclusiones: el tamaño de muestra no permite inferencia.

## 1. Muestra y cobertura

- Artículos: **300** (Psicología, Comunicación, Ciencias sociales computacionales, 2016–2020).
- Texto completo legible por los detectores: **12.3 %** de los artículos. El resto es *no verificable* en los indicadores de texto y no cuenta como «no».
- Fuentes del texto: europepmc 13, oa_landing 24, unavailable 263.

## 2. Prevalencia de cada práctica

| Práctica | Sí / verificables | Prevalencia (IC 95 %) | No verificables |
| --- | --- | --- | --- |
| Declaración de disponibilidad de datos | 5 / 37 | 13.5 % (5.9 %–28.0 %) | 263 |
| Datos compartidos en repositorio | 7 / 40 | 17.5 % (8.7 %–31.9 %) | 260 |
| Código compartido | 2 / 37 | 5.4 % (1.5 %–17.7 %) | 263 |
| Prerregistro enlazado | 1 / 37 | 2.7 % (0.5 %–13.8 %) | 263 |
| Materiales compartidos | 0 / 37 | 0.0 % (0.0 %–9.4 %) | 263 |

Datos compartidos por campo:

| Campo | Prevalencia | Verificables |
| --- | --- | --- |
| Psicología | 5.6 % | 18 |
| Comunicación | 10.0 % | 10 |
| Ciencias sociales computacionales | 41.7 % | 12 |

## 3. Asociación con las citas a cinco años

Razón de tasas ajustada (binomial negativa multinivel; revista como efecto aleatorio). Es una asociación, no un efecto causal.

| Práctica | RR | Expuestos |
| --- | --- | --- |
| Declaración de disponibilidad de datos | no estimable | 5 |
| Datos compartidos en repositorio | no estimable | 7 |
| Código compartido | no estimable | 2 |
| Prerregistro enlazado | no estimable | 1 |
| Materiales compartidos | no estimable | 0 |

Las estimaciones de robustez (Poisson, emparejamiento, ponderación inversa y equilibrado por entropía) y los E-values están en `outputs/associations.csv`.

## 4. Limitaciones

- Los indicadores describen condiciones de reproducibilidad, no reproducibilidad real; el subestudio de reproducción lo contrasta.
- La cobertura de texto completo limita los indicadores de texto; la codificación manual y el acceso TDM institucional la amplían.
- Las asociaciones pueden deberse a confusores no medidos (p. ej., prestigio del grupo); los E-values indican cuánto.
- No se publica ninguna puntuación agregada ni clasificación de artículos, revistas o personas.
