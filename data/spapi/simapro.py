# encoding: utf-8
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import json
import os.path
import win32com.client

server = win32com.client.Dispatch("SimaPro.SimaProServer")
server.Server = "local server"
server.alias = r"C:\Users\Public\Documents\SimaPro\Database"
server.Database = "Professional"
server.OpenDatabase()
server.OpenProject("AGB3.1.1 2023-03-06", "")

surfaces = {}
if os.path.exists("surfaces.json"):
    surfaces = json.load(open("surfaces.json"))

api = FastAPI()


@api.get("/surface", response_class=JSONResponse)
async def surface(_: Request, process: str):
    """exemple:
    project: process: "Soft wheat grain, organic, 15% moisture, Central Region, at feed plant {FR} U"
    """
    global surfaces  # 🤮
    if process not in surfaces:
        server.Analyse(
            "AGB3.1.1 2023-03-06", 0, process, "Methods", "Selected LCI results", ""
        )
        amount = server.AnalyseResult(0, 5).Amount
        surfaces[process] = amount
        with open("surfaces.json", "w") as fp:
            json.dump(surfaces, fp, ensure_ascii=False)
    else:
        amount = surfaces[process]
    return {"surface": amount}
