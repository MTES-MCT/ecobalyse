import pandas as pd
import pygwalker as pyg
import streamlit as st
import streamlit.components.v1 as components

# Adjust the width of the Streamlit page
st.set_page_config(page_title="Ecobalyse - Suivi des scores", layout="wide")

# Add Title
st.title("Ecobalyse - Suivi des scores")

# Import your data
df = pd.read_csv("score_history.csv")


def load_config(file_path):
    with open(file_path, "r") as config_file:
        config_str = config_file.read()
    return config_str


config = load_config("config.json")

# Generate the HTML using Pygwalker
pyg_html = pyg.to_html(df, spec=config, dark="light")

# Embed the HTML into the Streamlit app
components.html(pyg_html, height=1000, scrolling=True)
