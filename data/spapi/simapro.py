# encoding: utf-8
import json
import os.path
from pprint import pprint

import win32com.client
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

server = win32com.client.Dispatch("SimaPro.SimaProServer")
server.Server = "SimaProNexusDB@51.159.211.95"
server.alias = r"Default"
server.Database = "Professional"
print("Opening database...")
server.OpenDatabase()
server.logout()
server.login("API", "")

projects = [server.Projects(i) for i in range(server.Projects.Count())]
print("Existing projects:")
pprint(projects)
api = FastAPI()


@api.get("/impact", response_class=JSONResponse)
async def impact(
    _: Request, project: str, process: str, method: str, library: str | None = None
):
    """exemple:
    project: "Agribalyse 3.2"
    library: "AGRIBALYSE - unit"
    method: "Environmental Footprint 3.1 (adapted)"
    process: "Egg, Bleu Blanc Coeur, outdoor system, at farm gate {FR} U"
    """
    print(f"Project: {project}")
    print(f"Library: {library}")
    print(f"Process: {process}")
    print(f"Method: {method}")

    if not library:
        library = project

    impacts = {}
    if os.path.exists("impacts.json"):
        impacts = json.load(open("impacts.json"))

    if impacts.get(f"{project}/{library}/{process}", {}).get(method, {}):
        return impacts.get(f"{project}/{library}/{process}", {}).get(method, {})
    else:
        if project not in projects:
            return f"project {project} does not exist in SimaPro"
        if library not in projects:
            return f"library {library} does not exist in SimaPro"
        if not server.ProjectOpen or project != server.CurrentProject:
            print(f"Opening project {project}...")
            server.OpenProject(project, "")

        print("Computing results...")
        existing = [
            e
            for e in [
                ((i, server.FindProcess(library, i, process)[0])) for i in range(12)
            ]
            if e[1]
        ]
        found = existing[0] if len(existing) else None
        if found:
            try:
                server.Analyse(library, found[0], process, "Methods", method, "")
                results, i = {}, 0
            except Exception as e:
                return {"error": repr(e)}

            try:
                # try the first and stop if it raises (typically on a Dummy process.
                # Seems a bug in the COM intf)
                server.AnalyseResult(0, 0)
            except Exception:
                impacts.setdefault(f"{project}/{library}/{process}", {})
                impacts[f"{project}/{library}/{process}"][method] = results
                with open("impacts.json", "w") as fp:
                    json.dump(impacts, fp, ensure_ascii=False)
                return {}
            while (r := server.AnalyseResult(0, i)).IndicatorName:
                results[r.IndicatorName] = {"amount": r.Amount, "unit": r.UnitName}
                i += 1
            impacts.setdefault(f"{project}/{library}/{process}", {})
            if not results:
                return results
            impacts[f"{project}/{library}/{process}"][method] = results
            with open("impacts.json", "w") as fp:
                json.dump(impacts, fp, ensure_ascii=False)
            return results
        else:
            return {
                "error": f'Process "{process}" not found in library "{library}" of project "{project}"'
            }
