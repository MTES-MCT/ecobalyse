#!/usr/bin/env python
import bw2data

from config import settings

METHODNAME = settings.bw.method

bw2data.projects.set_current(settings.bw.project)
print(f"Deleting method: {METHODNAME}...")
for m in list(bw2data.methods):
    if METHODNAME == m[0]:
        del bw2data.methods[m]
print("done")
