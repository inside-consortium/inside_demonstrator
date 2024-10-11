import pandas as pd
import os

def load_systems_data(experiment_series, resolution, rain_scenario, degradation_setting, file_type="concentrations"):
    df_res = pd.read_csv(os.path.join("../..", "preprocessing/preprocessed_data/wastewater_model", experiment_series, file_type, f"{resolution}_{rain_scenario}_{degradation_setting}.csv"))

    # rename sampling locations according to naming in the paper
    df_res.sampling_point = df_res.sampling_point.map({"MW022": "1", "MW023": "2", "MW017": "3", "MW043": "4", "MW048": "5", 
                        "RW157": "6", "MW046": "7", "MW061": "8", "RW143": "9", "RW141": "10",
                        "RW155": "11", "MW059": "12", "RW211": "13", "MW054": "14",
                        "RW126": "15", "MW052": "16"})
        
    # only use "valid" time points and not those from presimulation phase
    df_res = df_res.loc[df_res.minutes>0,:]
    
    return df_res