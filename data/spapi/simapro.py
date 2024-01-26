import win32com.client
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

server = win32com.client.Dispatch("SimaPro.SimaProServer")
server.Server = "local server"
server.alias = r"C:\Users\Public\Documents\SimaPro\Database"
server.Database = "Professional"
server.OpenDatabase()
server.OpenProject("AGB3.1.1 2023-03-06", "")

api = FastAPI()

@api.get("/surface", response_class=JSONResponse)
async def surface(request: Request, process: str):
    """exemple:
    project: process: "Soft wheat grain, organic, 15% moisture, Central Region, at feed plant {FR} U"
    """
    server.Analyse("AGB3.1.1 2023-03-06", 0, process, "Methods", "Selected LCI results", "")
    return {
         "surface": server.AnalyseResult(0, 5).Amount,
         "unit": server.AnalyseResult(0, 5).UnitName
    }
