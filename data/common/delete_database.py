#!/usr/bin/env python
import sys

import bw2data

if len(sys.argv) != 2:
    print("Provide the database as 1st arg")
    sys.exit(1)
database = sys.argv[1]
bw2data.projects.set_current("default")
print(f"Deleting database: {database}...")
if database in bw2data.databases:
    del bw2data.databases[database]
else:
    print(f"Could not find database {database}")
print("done")
