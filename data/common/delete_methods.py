#!/usr/bin/env python
import bw2data
import bw2io

bw2data.projects.set_current("textile")
for i in list(bw2data.methods):
    del bw2data.methods[i]

# del bw2data.databases["biosphere3"]
# bw2io.bw2setup()
