import brightway2 as bw

for db in bw.databases:
    del bw.databases[db]
