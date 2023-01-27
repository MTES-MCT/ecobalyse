import brightway2 as bw
from brightway2 import *

for db in bw.databases:
    del bw.databases[db]
