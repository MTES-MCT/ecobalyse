import json


path  = "processes.json"

def read_json(filename):
    with open(filename, "r") as infile:
        return json.load(infile)



processes = read_json(path)
stopwords = ["at plant","at packaging","at distribution", "at supermarket", "at consumer"]
processes_lite_dic = {k:v for k,v in processes.items() if all(stopword not in k for stopword in stopwords )}


with open("processes_lite.json","w") as outfile:
    json.dump(processes_lite_dic, outfile)