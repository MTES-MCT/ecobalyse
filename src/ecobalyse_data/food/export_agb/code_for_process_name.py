#!/usr/bin/env python
# coding: utf-8

"""Recherche dans agribalyse d'un nom de procédé, et affichage des codes correspondants."""

import argparse
import brightway2 as bw


def open_db(dbname):
    bw.projects.set_current("EF calculation")
    bw.bw2setup()
    return bw.Database(dbname)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Display process codes for a given process name"
    )
    parser.add_argument(
        "process_name",
        help="The process name to look up in the agribalyse database",
    )

    args = parser.parse_args()

    agb = open_db("agribalyse3")
    results = agb.search(args.process_name)

    for activity in results:
        if activity["name"] == args.process_name:
            print(">>> EXACT MATCH >>> ", end="")
        print(f"{activity['name']}: {activity._data['code']}")
