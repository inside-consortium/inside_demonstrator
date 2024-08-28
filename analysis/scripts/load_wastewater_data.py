import pandas as pd
import os

def load_systems_data(experiment_series, substance, rain_scenario, degradation_setting, file_type="concentrations"):
    df_res = pd.read_csv(os.path.join("../..", "preprocessing/preprocessed_data/wastewater_model", experiment_series, file_type, f"{substance}_{rain_scenario}_{degradation_setting}.csv"))
    df_res.time = pd.to_datetime(df_res.time)

    # drop MW064, RW156 (invalid calculations of ++systems)
    df_res = df_res.loc[~df_res.sampling_point.isin(["MW064", "RW156"]), :]
    # rename sampling locations according to naming in the paper
    df_res.sampling_point = df_res.sampling_point.map({"MW022": "1", "MW023": "2", "MW017": "3", "MW043": "4", "MW048": "5", 
                        "RW157": "6", "MW046": "7", "MW061": "8", "RW143": "9", "RW141": "10",
                        "RW155": "11", "MW059": "12", "RW211": "13", "MW054": "14",
                        "RW126": "15", "MW052": "16"})
    
    df_res.time = pd.to_datetime(df_res.time)
    
    if file_type=="flow_rates":
        # ensure time consistency with concentration data
        df_res.minutes = df_res.minutes - 70
        df_res["time"] = df_res["time"] - pd.Timedelta("70 minutes")
    
    # only use "valid" time points and not those from presimulation phase
    df_res = df_res.loc[df_res.minutes>0,:]
    
    df_res["time_in_days"] = (df_res["time"] - df_res["time"].min()).dt.total_seconds() / (60 * 60 * 24)
    return df_res