using CSV, DataFrames, Plots

base_path = joinpath(pwd())
experiment_name = "final_tests"
hydraulic_setting = "b_constant_hydraulics_same"

tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
output_path = joinpath(base_path, "analysis/plots/++systems/$experiment_name")

# load data
df_keinRegen = CSV.read(joinpath(tandler_output_path, "1_KeinRegen/$(hydraulic_setting)/flow_rates.csv"), DataFrame, delim=",")
df_Nieselregen = CSV.read(joinpath(tandler_output_path, "2_Nieselregen/$(hydraulic_setting)/flow_rates.csv"), DataFrame, delim=",")
df_MittelstarkerRegen = CSV.read(joinpath(tandler_output_path, "3_MittelstarkerRegen/$(hydraulic_setting)/flow_rates.csv"), DataFrame, delim=",")

# plot for one location
loc = "RW157"

df_sub = dropmissing(df_Nieselregen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot(df_sub.time, df_sub.flow_rate, label="Nieselregen", xlabel="time (min)", ylabel="flow rate (l/s)", title="$loc")
df_sub = dropmissing(df_MittelstarkerRegen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot!(df_sub.time, df_sub.flow_rate, label="MittelstarkerRegen")
df_sub = dropmissing(df_keinRegen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot!(df_sub.time, df_sub.flow_rate, label="keinRegen", xlabel="time (min)", ylabel="flow rate (l/s)")
savefig(joinpath(output_path, "flow_rate_$loc.png"))

df_sub = dropmissing(df_Nieselregen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot(df_sub.time, df_sub.flow_rate, label="Nieselregen", xlabel="time (min)", ylabel="flow rate (l/s)", title="$loc")
df_sub = dropmissing(df_keinRegen, :location)
df_sub = df_sub[df_sub.location.==loc,:]
plot!(df_sub.time, df_sub.flow_rate, label="keinRegen", xlabel="time (min)", ylabel="flow rate (l/s)")
savefig(joinpath(output_path, "flow_rate_kein_und_niesel_$loc.png"))