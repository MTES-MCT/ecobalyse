#!/usr/bin/env python
from bw2data import databases

for db in list(databases.keys()):
    del databases[db]
