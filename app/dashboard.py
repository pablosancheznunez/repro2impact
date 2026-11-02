from pathlib import Path
import sys
import pandas as pd
import streamlit as st
import plotly.express as px

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from repro2impact.analysis import load_articles, score_transparency

st.set_page_config(page_title="REPRO2IMPACT", layout="wide")
st.title("REPRO2IMPACT")
st.caption("Panel de exploración · transparencia de artículos y métricas de impacto")
st.info("La puntuación representa prácticas observables de transparencia. No demuestra reproducibilidad ni efecto causal. Sube datos solo si tienes autorización y licencia para tratarlos.")
upload = st.file_uploader("Carga un CSV según el diccionario de datos", type=["csv"])
if upload is None:
    st.markdown("Elige un CSV de datos autorizado. No hay datos de investigación incluidos en este proyecto.")
    st.stop()
try:
    df = score_transparency(load_articles(upload))
except Exception as exc:
    st.error(f"No se pudo validar el archivo: {exc}")
    st.stop()
scored = df.dropna(subset=["transparency_score"])
c1, c2, c3 = st.columns(3)
c1.metric("Artículos", f"{len(df):,}")
c2.metric("Con puntuación", f"{len(scored):,}")
c3.metric("Transparencia media", "—" if scored.empty else f"{scored.transparency_score.mean():.2f}")
fields = sorted(df["discipline"].dropna().astype(str).unique())
selected = st.multiselect("Disciplina", fields, default=fields)
view = df[df["discipline"].astype(str).isin(selected)]
if not view.empty:
    by_field = view.groupby("discipline", as_index=False).agg(
        articles=("work_id", "size"), transparency=("transparency_score", "mean"),
        citations_median=("citations", "median"))
    st.subheader("Resumen por disciplina")
    st.dataframe(by_field, use_container_width=True, hide_index=True)
    plot = by_field.dropna(subset=["transparency"])
    if not plot.empty:
        st.plotly_chart(px.bar(plot, x="discipline", y="transparency", range_y=[0, 1],
                               title="Puntuación media de transparencia"), use_container_width=True)
    st.subheader("Registros")
    st.dataframe(view, use_container_width=True, hide_index=True)
    st.download_button("Descargar selección CSV", view.to_csv(index=False).encode("utf-8"),
                       file_name="repro2impact_selection.csv", mime="text/csv")
