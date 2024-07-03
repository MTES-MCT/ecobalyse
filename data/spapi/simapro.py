# encoding: utf-8
import json
import os.path

import win32com.client
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

server = win32com.client.Dispatch("SimaPro.SimaProServer")
server.Server = "local server"
server.alias = r"C:\Users\Public\Documents\SimaPro\Database"
server.Database = "Professional"
print("Opening database...")
server.OpenDatabase()
projects = [server.Projects(i) for i in range(server.Projects.Count())]
print(f"Existing projects: {', '.join(projects)}")

api = FastAPI()


@api.get("/impact", response_class=JSONResponse)
async def impact(_: Request, project: str, process: str, method: str):
    """exemple:
    project: "AGB3.1.1 2023-03-06"
    method: "Environmental Footprint 3.1 (adapted) patch wtu"
    process: "Soft wheat grain, organic, 15% moisture, Central Region, at feed plant {FR} U"
    """
    print(f"{project}/{process}/{method}")

    impacts = {}
    if os.path.exists("impacts.json"):
        impacts = json.load(open("impacts.json"))

    if impacts.get(f"{project}/{process}", {}).get(method, {}):
        return impacts.get(f"{project}/{process}", {}).get(method, {})
    else:
        if project not in projects:
            return f"project {project} does not exist in SimaPro"
        if not server.ProjectOpen or project != server.CurrentProject:
            print(f"Opening project {project}...")
            server.OpenProject(project, "")

        print("Computing results...")
        existing = [
            e
            for e in [
                ((i, server.FindProcess(project, i, process)[0])) for i in range(12)
            ]
            if e[1]
        ]
        found = existing[0] if len(existing) else None
        if found:
            server.Analyse(project, found[0], process, "Methods", method, "")
            results, i = {}, 0
            try:
                # try the first and stop if it raises (typically on a Dummy process.
                # Seems a bug in the COM intf)
                server.AnalyseResult(0, 0)
            except Exception:
                impacts.setdefault(f"{project}/{process}", {})
                impacts[f"{project}/{process}"][method] = results
                with open("impacts.json", "w") as fp:
                    json.dump(impacts, fp, ensure_ascii=False)
                return {}
            while (r := server.AnalyseResult(0, i)).IndicatorName:
                results[r.IndicatorName] = {"amount": r.Amount, "unit": r.UnitName}
                i += 1
            impacts.setdefault(f"{project}/{process}", {})
            impacts[f"{project}/{process}"][method] = results
            with open("impacts.json", "w") as fp:
                json.dump(impacts, fp, ensure_ascii=False)
            return results
        else:
            return {}
