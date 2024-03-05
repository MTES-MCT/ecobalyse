# encoding: utf-8
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import json
import os.path
from time import sleep
import win32com.client

server = win32com.client.Dispatch("SimaPro.SimaProServer")
server.Server = "local server"
server.alias = r"C:\Users\Public\Documents\SimaPro\Database"
server.Database = "Professional"
print("Opening database...")
server.OpenDatabase()

api = FastAPI()
lock: bool = False
current_project = None

@api.get("/impact", response_class=JSONResponse)
async def impact(_: Request, project: str, process: str, method: str):
    """exemple:
    project: "AGB3.1.1 2023-03-06"
    method: "Environmental Footprint 3.1 (adapted) patch wtu"
    process: "Soft wheat grain, organic, 15% moisture, Central Region, at feed plant {FR} U"
    """
    print(f"{project}/{process}/{method}")
    global lock
    global current_project
    while lock:
         print("waiting for lock release...")
         sleep(1)

    lock = True

    if os.path.exists("impacts.json"):
        impacts = json.load(open("impacts.json"))
    try:
        if not impacts.get(f"{project}/{process}", {}).get(method, {}):
            if project != current_project:
                print("Opening project...")
                server.OpenProject(project, "")
                current_project = project

            print("Computing results...")
            server.Analyse(project, 0, process, "Methods", method, "")
            results, i = {}, 0
            while (r := server.AnalyseResult(0, i)).IndicatorName:
                 results[r.IndicatorName] = {'amount': r.Amount, 'unit': r.UnitName}
                 i += 1
            impacts.setdefault(f"{project}/{process}", {})
            impacts[f"{project}/{process}"][method] = results
            with open("impacts.json", "w") as fp:
                json.dump(impacts, fp, ensure_ascii=False)
        else:
            results = impacts.get(f"{project}/{process}", {}).get(method, {})
    except Exception as e:
            results = repr(e)
    lock = False
    print(results)
    return {"impact": results}
