#!/usr/bin/env python
import bw2data

bw2data.projects.delete_project("Ecobalyse")
bw2data.projects.purge_deleted_directories()
