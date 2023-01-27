import json
import fjson

f = open("processes_pre_correction.json")
processes = json.load(f)


for process in processes:
    if process["info"] == "Energie > Electricité > Mix moyen":
        process["impacts"]["ior"] = process["impacts"]["ior"]/4.5


processes_string = "["
for process in processes:
    proc_formatted = fjson.dumps(process, float_format=".5e")
    processes_string += proc_formatted + ","
processes_string = processes_string[:-1] + "]"


with open("processes_post_correction.json", "w") as outfile:
    outfile.write(processes_string)

