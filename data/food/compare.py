#!/usr/bin/env python
"""export.compare_impacts() exports a `comparison.json` file. This script read `comparison.json` and output one PNG file for each process showing a comparison between impacts from brightway and simapro"""

import json

import matplotlib.pyplot as plt
import numpy as np

with open("comparison.json") as f:
    data_dict = dict(list(json.load(f).items()))
with open("../public/data/impacts.json") as f:
    impacts = json.load(f)


def plot_impacts(ingredient_name, simapro, brightway):
    categories = [
        c
        for c in simapro.keys()
        if c not in ("etf-o", "etf-i", "htn-o", "htn-i", "htc-i", "htc-o")
    ]

    simapro_values = [
        simapro[cat] / impacts[cat]["pef"]["normalization"] for cat in categories
    ]
    brightway_values = [
        brightway[cat] / impacts[cat]["pef"]["normalization"] for cat in categories
    ]

    x = np.arange(len(categories))
    width = 0.35

    fig, ax = plt.subplots(figsize=(12, 8))

    ax.bar(x - width / 2, simapro_values, width, label="SimaPro")
    ax.bar(x + width / 2, brightway_values, width, label="Brightway")

    ax.set_xlabel("Impact Categories")
    ax.set_ylabel("Impact Values")
    ax.set_title(f"Environmental Impacts for {ingredient_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(categories, rotation=90)
    ax.legend()

    plt.tight_layout()
    plt.savefig(f"{ingredient_name}.png")
    plt.close()


for ingredient_name, values in data_dict.items():
    print(f"Plotting {ingredient_name}")
    simapro_impacts = values["simapro impacts"]
    brightway_impacts = values["brightway impacts"]
    plot_impacts(ingredient_name, simapro_impacts, brightway_impacts)

print("Charts have been generated and saved as PNG files.")
