import base64
import csv
import io
import json

import ipywidgets
import pandas
from matplotlib import pyplot

print("Please wait...")

IMPACTS = {}
with open("/home/jovyan/ecobalyse/public/data/impacts.json") as f:
    IMPACTS = json.load(f)


def scores(impacts):
    "return a dict of 16 scores give a dict of characterizations"
    return dict(
        [("name", impacts["name"][:50])]
        + list(
            {
                trigram: impacts[trigram]
                / IMPACTS[trigram]["pef"]["normalization"]
                * IMPACTS[trigram]["pef"]["weighting"]
                for trigram in [
                    t
                    for t in IMPACTS.keys()
                    if t not in ("ecs", "pef", "htn-c", "etf-c", "htc-c", "name")
                ]
            }.items()
        )
    )


def csv_button(contents):
    return ipywidgets.HTML(
        """
      <a download="{filename}" href="data:text/csv;base64,{payload}" download>
      <button class="p-Widget jupyter-widgets jupyter-button widget-button mod-warning">Download CSV</button>
      </a>
    """.format(
            payload=base64.b64encode(contents.encode()).decode(), filename="export.csv"
        )
    )


textile_processes = json.load(open("../ecobalyse/public/data/textile/processes.json"))
csvfile = io.StringIO()
writer = csv.DictWriter(
    csvfile, fieldnames=["name"] + list(textile_processes[0]["impacts"].keys())
)
writer.writeheader()
for p in textile_processes:
    line = p["impacts"]
    line["name"] = p["name"]
    writer.writerow(line)

csvfile.seek(0)
df = pandas.read_csv(csvfile).apply(
    lambda row: pandas.Series(scores(row.to_dict())), axis=1
)
names = df.iloc[:, 0]
data = df.iloc[:, 1:]
fig, ax = pyplot.subplots(figsize=(20, 60))
data.plot(kind="barh", stacked=True, ax=ax)
ax.set_yticklabels(names)
ax.set_xlabel("Impacts")
ax.set_ylabel("Names")
ax.set_title("Textile processes")

pyplot.tight_layout()
csvfile.seek(0)
display(
    ipywidgets.HTML(
        """
      <a download="{filename}" href="data:text/csv;base64,{payload}" download>
      <button class="p-Widget jupyter-widgets jupyter-button widget-button mod-warning">Download CSV</button>
      </a>
    """.format(
            payload=base64.b64encode(csvfile.read().encode()).decode(),
            filename="export.csv",
        )
    )
)
pyplot.show()
