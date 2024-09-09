#!/usr/bin/env python
import bw2data

METHODNAME = "Environmental Footprint 3.1 (adapted) patch wtu"
bw2data.projects.set_current("default")
print(f"Deleting method: {METHODNAME}...")
for m in list(bw2data.methods):
    if METHODNAME == m[0]:
        del bw2data.methods[m]
print("done")
