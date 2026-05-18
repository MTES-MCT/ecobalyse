from typing import List, Optional

import bw2data
import typer

from common.export import IMPACTS_JSON
from common.impacts import impacts as impacts_py
from common.impacts import main_method


def bw_databases_validation(values: Optional[List[str]]):
    available_bw_databases = ", ".join(bw2data.databases)

    for value in values:
        if value not in bw2data.databases:
            raise typer.BadParameter(
                f"Database not present in Brightway. Available databases are: {available_bw_databases}."
            )

    return values


def bw_database_validation(value: Optional[str]):
    if value:
        return bw_databases_validation([value])[0]

    return value


def ecobalyse_impact_validation(values: Optional[List[str]]):
    if values:
        for value in values:
            if value not in IMPACTS_JSON:
                available_impacts = ", ".join(IMPACTS_JSON.keys())
                raise typer.BadParameter(
                    f"Impact not present in ecobalyse format. Available impacts are: {available_impacts}."
                )

    return values


def method_impact_validation(value: Optional[str]):
    if value and value not in impacts_py:
        available_impacts = ", ".join(impacts_py.keys())
        raise typer.BadParameter(
            f"Impact not present in method '{main_method}'. Available impacts are: {available_impacts}."
        )

    return value
