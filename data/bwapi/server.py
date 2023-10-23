from bw2data.project import projects
from bw2data.utils import get_activity
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from typing import Union
import bw2calc
import bw2data

api = FastAPI()

# projects and databases

@api.get("/projects", response_class=JSONResponse)
async def projects(_: Request, project: str = "default"):
    return list(bw2data.projects)


@api.get("/{project}/databases", response_class=JSONResponse)
async def databases(_: Request, project: str = "default"):
    projects.set_current(project)
    return list(bw2data.databases)


# search


@api.get("/{project}/{dbname}/search/", response_class=JSONResponse)
async def search(
    _: Request,
    project: str = "default",
    dbname: str = "",
    q: Union[str, None] = "",
    limit: Union[int, None] = 20,
):
    projects.set_current(project)
    return [a.as_dict() for a in bw2data.Database(dbname).search(q, limit=limit)]


# activity data and graph


@api.get("/{project}/{dbname}/{code}/data", response_class=JSONResponse)
async def data(_: Request, project: str, dbname: str, code: str):
    projects.set_current(project)
    return get_activity((dbname, code)).as_dict()


@api.get("/{project}/{dbname}/{code}/technosphere", response_class=JSONResponse)
async def technosphere(_: Request, project: str, dbname: str, code: str):
    projects.set_current(project)
    return [
        exchange.as_dict() for exchange in get_activity((dbname, code)).technosphere()
    ]


@api.get("/{project}/{dbname}/{code}/biosphere", response_class=JSONResponse)
async def biosphere(_: Request, project: str, dbname: str, code: str):
    projects.set_current(project)
    return [exchange.as_dict() for exchange in get_activity((dbname, code)).biosphere()]


@api.get("/{project}/{dbname}/{code}/substitution", response_class=JSONResponse)
async def substitution(_: Request, project: str, dbname: str, code: str):
    projects.set_current(project)
    return [
        exchange.as_dict() for exchange in get_activity((dbname, code)).substitution()
    ]


# methods


@api.get("/{project}/methods", response_class=JSONResponse)
async def methods(_: Request, project: str):
    projects.set_current(project)
    return sorted({m[0] for m in bw2data.methods})


@api.get("/{project}/methods/{method}", response_class=JSONResponse)
async def method(_: Request, project: str, method: str):
    projects.set_current(project)
    return sorted({m for m in bw2data.methods if m[0] == method})


@api.get(
    "/{project}/methods/{method}/{impact_category:path}",
    response_class=JSONResponse,
)
async def impact_category(_: Request, project: str, method: str, impact_category: str):
    projects.set_current(project)
    try:
        return bw2data.methods[(method,) + tuple(impact_category.split("/"))]
    except KeyError:
        return JSONResponse(
            status_code=404, content={"message": "Impact category not found"}
        )


@api.get(
    "/{project}/characterization_factors/{method}/{impact_category:path}",
    response_class=JSONResponse,
)
async def characterization_factors(
    _: Request, project: str, method: str, impact_category: str
):
    projects.set_current(project)
    try:
        return bw2data.Method((method,) + tuple(impact_category.split("/"))).load()
    except:
        return JSONResponse(
            status_code=404, content={"message": "Impact category not found"}
        )


# impacts


@api.get("/{project}/{dbname}/{code}/impacts/{method}", response_class=JSONResponse)
async def impacts(_: Request, project: str, dbname: str, code: str, method: str):
    projects.set_current(project)
    lca = bw2calc.LCA({get_activity((dbname, code)): 1})
    lca.lci()
    impacts = []
    for m in [m for m in list(bw2data.methods) if m[0] == method]:
        lca.switch_method(m)
        lca.lcia()
        impacts.append(
            {
                "method": m,
                "score": lca.score,
                "unit": bw2data.methods[m].get("unit", "(no unit)"),
            }
        )
    return impacts


