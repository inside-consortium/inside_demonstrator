using CSV, DataFrames, Plots

base_path = joinpath(pwd(), "inside_demonstrator")
experiment_name = "last_day/"

tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
output_path = joinpath(base_path, "analysis/plots/++systems/$experiment_name")

# load data
df_Nieselregen = CSV.read(joinpath(tandler_output_path, "Nieselregen/flow_rates.csv"), DataFrame, delim=",")
df_MittelstarkerRegen = CSV.read(joinpath(tandler_output_path, "MittelstarkerRegen/flow_rates.csv"), DataFrame, delim=",")
df_keinRegen = CSV.read(joinpath(tandler_output_path, "keinRegen/flow_rates.csv"), DataFrame, delim=",")

# plot for one location
loc = "RW134"
df_sub = dropmissing(df_Nieselregen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot(df_sub.time, df_sub.flow_rate, label="Nieselregen")
df_sub = dropmissing(df_MittelstarkerRegen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot!(df_sub.time, df_sub.flow_rate, label="MittelstarkerRegen")
df_sub = dropmissing(df_keinRegen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot!(df_sub.time, df_sub.flow_rate, label="keinRegen", xlabel="time (min)", ylabel="flow rate (l/s)")