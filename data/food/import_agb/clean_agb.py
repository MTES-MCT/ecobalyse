#!/usr/bin/env python
from bw2data import databases

for db in databases:
    del databases[db]
