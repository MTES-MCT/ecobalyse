from bw2data.project import projects
from bw2data.utils import get_activity
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from typing import Union
import bw2data

api = FastAPI()


@api.get("/{project}/databases", response_class=JSONResponse)
async def databases(
    _: Request, project: str = "default", dbname: str = "", terms: str = ""
):
    projects.set_current(project)
    return list(bw2data.databases)

@api.get("/{project}/{dbname}/search/", response_class=JSONResponse)
async def search(
        _: Request, project: str = "default", dbname: str = "", q: Union[str, None] = "", limit: Union[int, None] = 20
):
    projects.set_current(project)
    return [a.as_dict() for a in bw2data.Database(dbname).search(q, limit=limit)]

@api.get("/{project}/{dbname}/activity/{code}", response_class=JSONResponse)
async def search(
      _: Request, project: str = "default", dbname: str = "", code: str = ""
  ):
      projects.set_current(project)
      return get_activity((dbname, code)).as_dict()

