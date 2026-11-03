# Subestudio de reproducción computacional (O5)

## Objetivo

Estimar en qué proporción los artículos que comparten datos **y** código permiten reproducir su resultado principal. Así se contrasta la reproducibilidad potencial (el perfil de transparencia) con la reproducibilidad real.

## Muestra

- **40 artículos** de la muestra principal con `data_shared = yes` y `code_shared = yes` según el consenso manual.
- Muestreo aleatorio estratificado por campo: 14 de Psicología, 13 de Comunicación y 13 de Ciencias sociales computacionales.
- Quedan excluidos los análisis que requieran datos restringidos, *hardware* especial o más de 8 horas de cómputo. Las exclusiones se registran con su motivo.

## Procedimiento

1. **Resultado objetivo.** Antes de ejecutar nada, un investigador identifica el resultado principal del artículo: el primer contraste del resumen o, si no lo hay, el primero de la sección de resultados. Anota su valor exacto.
2. **Entorno.** Se ejecuta en un contenedor limpio con la versión de software declarada o, si no se declara, la más próxima a la fecha de publicación (Rocker para R; imagen de Python con las versiones de `requirements`).
3. **Esfuerzo acotado.** Se dedican como máximo 4 horas a la ejecución, más 2 horas de depuración documentada. Cada cambio necesario se anota en `reproduction_log.csv`.
4. **Contacto con los autores.** Si la ejecución falla por un archivo ausente, se escribe una vez a los autores y se esperan 4 semanas.
5. **Clasificación.**

| Código | Resultado |
| --- | --- |
| `exact` | Reproducido sin cambios, idéntico hasta el redondeo publicado |
| `minor` | Reproducido con cambios menores (rutas, paquetes) o diferencias que no cambian la conclusión |
| `substantive` | Se ejecuta, pero el resultado difiere de forma que cambia la magnitud o la significación |
| `not_executable` | No se pudo ejecutar dentro del esfuerzo acotado |
| `incomplete` | Faltan datos o código necesarios para el resultado objetivo |

## Análisis

- Proporciones de cada categoría con IC de Wilson, por campo.
- Relación de cada categoría con los indicadores de documentación del artículo (archivo README, gestor de entornos, semilla declarada).
- Los resultados se informan por artículo de forma anónima, salvo que los autores acepten ser identificados.

## Ética

Se informa a los autores del resultado antes de publicarlo y se les ofrece responder. El objetivo es medir prácticas, no señalar a personas.
