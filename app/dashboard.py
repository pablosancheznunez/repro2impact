from pathlib import Path
import sys

import pandas as pd
import plotly.express as px
import streamlit as st

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from repro2impact.analysis import load_articles, score_transparency

st.set_page_config(page_title="REPRO2IMPACT", layout="wide")
st.title("REPRO2IMPACT")
st.caption("Transparencia de artículos y outcomes académicos")
st.info("Los indicadores documentales no son auditorías de reproducibilidad. Las asociaciones con citas no son efectos causales ni medidas de impacto social.")

pilot_tab, upload_tab = st.tabs(["Piloto PLOS OSI v11", "Explorar datos autorizados"])

with pilot_tab:
    path = ROOT / "data" / "pilot" / "analysis_sample.csv"
    if not path.exists():
        st.warning("No está disponible la muestra del piloto. Consulta reports/pilot_osi_v11/ para los resultados resumidos.")
    else:
        df = pd.read_csv(path)
        year_options = sorted(df["Publication_Year"].dropna().astype(int).unique())
        years = st.multiselect("Año", year_options, default=year_options)
        fields = sorted(df["Primary_Topic_Field"].dropna().astype(str).unique())
        selected_fields = st.multiselect("Campo temático PLOS", fields, default=fields)
        view = df[df["Publication_Year"].isin(years) & df["Primary_Topic_Field"].astype(str).isin(selected_fields)]

        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Artículos", f"{len(view):,}")
        c2.metric("Citas medianas", "—" if view.empty else f"{view.cited_by_count.median():.0f}")
        c3.metric("Comparte datos", "—" if view.empty else f"{view.Data_Shared.mean():.1%}")
        c4.metric("Comparte código", "—" if view.empty else f"{view.Code_Shared.mean():.1%}")

        if not view.empty:
            left, right = st.columns(2)
            practice = view.melt(
                id_vars=["Publication_Year"],
                value_vars=["Data_Shared", "Code_Shared"],
                var_name="Práctica", value_name="Compartido",
            )
            practice["Práctica"] = practice["Práctica"].map({"Data_Shared": "Datos", "Code_Shared": "Código"})
            practice["Compartido"] = practice["Compartido"].astype(bool)
            rates = practice.groupby(["Publication_Year", "Práctica"], as_index=False)["Compartido"].mean()
            left.plotly_chart(px.line(rates, x="Publication_Year", y="Compartido", color="Práctica", markers=True,
                                      range_y=[0, 1], labels={"Publication_Year": "Año", "Compartido": "Proporción"},
                                      title="Prácticas observadas por año"), use_container_width=True)

            citation_view = view.melt(id_vars=["cited_by_count"], value_vars=["Data_Shared", "Code_Shared"],
                                      var_name="Práctica", value_name="Compartido")
            citation_view["Práctica"] = citation_view["Práctica"].map({"Data_Shared": "Datos", "Code_Shared": "Código"})
            citation_view["Compartido"] = citation_view["Compartido"].map({True: "Sí", False: "No"})
            right.plotly_chart(px.box(citation_view, x="Compartido", y="cited_by_count", color="Compartido",
                                      facet_col="Práctica", points=False,
                                      labels={"Compartido": "Recurso compartido", "cited_by_count": "Citas acumuladas"},
                                      title="Distribución descriptiva de citas"), use_container_width=True)

            st.caption("La muestra está estratificada y ponderada para el análisis. Los gráficos interactivos muestran la muestra seleccionada sin ponderación; utiliza las tablas del informe para las estimaciones poblacionales.")
            st.dataframe(view, use_container_width=True, hide_index=True)
            st.download_button("Descargar muestra filtrada CSV", view.to_csv(index=False).encode("utf-8"),
                               file_name="repro2impact_pilot_sample.csv", mime="text/csv")

with upload_tab:
    st.markdown("Carga un CSV conforme a `docs/data_dictionary.csv`. Solo procesa datos con autorización y licencia adecuadas.")
    upload = st.file_uploader("CSV del proyecto", type=["csv"], key="project_csv")
    if upload is not None:
        try:
            df = score_transparency(load_articles(upload))
        except Exception as exc:
            st.error(f"No se pudo validar el archivo: {exc}")
        else:
            scored = df.dropna(subset=["transparency_score"])
            c1, c2, c3 = st.columns(3)
            c1.metric("Artículos", f"{len(df):,}")
            c2.metric("Con puntuación", f"{len(scored):,}")
            c3.metric("Transparencia media", "—" if scored.empty else f"{scored.transparency_score.mean():.2f}")
            if not scored.empty:
                by_field = scored.groupby("discipline", as_index=False).agg(
                    articles=("work_id", "size"), transparency=("transparency_score", "mean"),
                    citations_median=("citations", "median"),
                )
                st.subheader("Resumen por disciplina")
                st.dataframe(by_field, use_container_width=True, hide_index=True)
                st.plotly_chart(px.bar(by_field, x="discipline", y="transparency", range_y=[0, 1],
                                       title="Puntuación media de transparencia"), use_container_width=True)
                st.dataframe(scored, use_container_width=True, hide_index=True)
