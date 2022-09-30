#!/usr/bin/env python
# coding: utf-8

"""
Debug script to compute the impact of a ciqual product at every step according to 2 methods : 
- additive : impact_output = sum(impact_input) (biosphere flows at the step are neglected)
- exhaustive :  biosphere flows emitted at the step are taken into account (for example emissions of refrigerant gases for frozen food product at storage/supermarket)

Output: 
simplified_diff.xlsx
simplified_diff_details.xlsx
 """

import json
from impacts import impacts_ecobalyse
import pandas as pd
import time

def read_json(filename):
    with open(filename, "r") as infile:
        return json.load(infile)


def compute_pef(impacts_dic):
    pef = 0
    for k in impacts_ecobalyse.keys():
        if k == "pef":
            continue
        norm = impacts_ecobalyse[k]["pef"]["normalization"]
        weight = impacts_ecobalyse[k]["pef"]["weighting"]
        pef += impacts_dic[k] * weight / norm
    return pef


if __name__ == "__main__":
    start_time = time.time()
    products_filename = "products.json"
    processes_filename = "processes.json"
    products = read_json(products_filename)
    processes = read_json(processes_filename)

    impacts_list = impacts_ecobalyse.keys()
    processes

    data = []
    list_dic = []
    detail_list_dic = []

    for ciqual_product, product in products.items():
        previous_main_process = None
        for step_name, step in product.items(): 

            main_process = step["mainProcess"]  
            if main_process is None:
                break

            # list all processes at the step
            processes_amount = {}
            for affectation, process_list in step.items():
                if affectation != "mainProcess":
                    for process_obj in process_list:                        
                            processes_amount[process_obj["processName"]] = processes_amount.get(process_obj["processName"],0) + process_obj["amount"]                          
            
            ## AT CONSUMER (exception because the process is the ciqual product) 
            if step_name == "consumer":
                exhaustive_dic = {
                    "ciqual_product":ciqual_product,
                    "name" : ciqual_product,
                    "method" : "exhaustive"
                }             
        
                exhaustive_impact_dic = {}
                for trigram, impact in processes[ciqual_product]["impacts"].items():                    
                    if trigram not in ["ccb", "ccf","ccl"]:                        
                        exhaustive_impact_dic[trigram] = impact  *  1  # the amount of a ciqual product at consumer is always 1 kg

                exhaustive_impact_dic["pef"] = compute_pef(exhaustive_impact_dic)

                list_dic.append(exhaustive_dic | exhaustive_impact_dic)

            ## ADDITIVE
            if previous_main_process is None:
                previous_main_process = ciqual_product


            additive_dic = {
                "ciqual_product":ciqual_product,
                "name": previous_main_process,
                "method": "additive",
                "max_diff":"",
            }            

            additive_impact_dic = {}
        
            other_processes_amount = processes_amount.copy()

            detail_step_process_list = []

            for process, amount in other_processes_amount.items():
                detail_dic = {
                    "ciqual_product":ciqual_product,
                    "name": previous_main_process,                    
                    "process": None,
                    "amount": None,
                    "max_diff":"",
                }
                for trigram, impact in processes[process]["impacts"].items():                    
                    if trigram not in ["ccb", "ccf","ccl"]:                        
                        additive_impact_dic[trigram] =  additive_impact_dic.get(trigram,0) + amount * impact
                        detail_dic["process"] = process
                        detail_dic["amount"] = amount
                        detail_dic[trigram] = amount * impact                    
                detail_dic["pef"] = compute_pef(detail_dic)
                detail_step_process_list.append(detail_dic)

            additive_impact_dic["pef"] = compute_pef(additive_impact_dic)
                
            list_dic.append(additive_dic | additive_impact_dic)
            detail_list_dic += detail_step_process_list

            ## DIFF

            diff_impact_dic = {
                "ciqual_product":ciqual_product,
                "method" : "diff",
                "name" : previous_main_process                    
            }

            for trigram in impacts_ecobalyse.keys():                    
                diff_impact_dic[trigram] = abs(additive_impact_dic[trigram] - exhaustive_impact_dic[trigram])/exhaustive_impact_dic[trigram]
            diff_impact_dic["pef_diff"] = abs(additive_impact_dic["pef"] - exhaustive_impact_dic["pef"])/exhaustive_impact_dic["pef"]
            list_dic.append(diff_impact_dic)
            

            ## EXHAUSTIVE

            if step_name == "plant":
                break

            exhaustive_dic = {
                "ciqual_product":ciqual_product,
                "name" : main_process,
                "method" : "exhaustive"
            }             
    
            exhaustive_impact_dic = {}
            for trigram, impact in processes[main_process]["impacts"].items():                    
                if trigram not in ["ccb", "ccf","ccl"]:                        
                    exhaustive_impact_dic[trigram] = impact  * processes_amount[main_process]   

            exhaustive_impact_dic["pef"] = compute_pef(exhaustive_impact_dic)

            list_dic.append(exhaustive_dic | exhaustive_impact_dic)

            previous_main_process = main_process

                    
    df = pd.DataFrame.from_records(list_dic)
    cols = list(df.columns.values)

    start_column = 3

    # reorganize columns

    cols.remove("pef")
    cols.insert(start_column,"pef")  
    cols.remove("pef_diff")
    cols.insert(start_column,"pef_diff")  
    df = df[cols]
    df.reset_index()
    df.to_csv("simplified_diff.csv")
    df.to_excel("simplified_diff.xlsx", index = False, header = True,freeze_panes = (1,start_column+1)) 

    detail_df = pd.DataFrame.from_records(detail_list_dic)
    detail_df.to_excel("simplified_diff_details.xlsx", index = False, header = True, freeze_panes= (1,1))

    print("--- %s seconds ---" % (time.time() - start_time))