#!/usr/bin/env python
import bw2data

bw2data.projects.set_current("textile")
for i in list(bw2data.methods):
    del bw2data.methods[i]
