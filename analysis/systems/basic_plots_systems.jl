using CSV, DataFrames, Plots

base_path = joinpath(pwd(), "inside_demonstrator")
experiment_name = "last_day/MittelstarkerRegen"

tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
output_path = joinpath(base_path, "analysis/plots/++systems/$experiment_name")

#####################
# preparation
#####################
# preparation
df = CSV.read(joinpath(tandler_output_path, "concentration_curves.csv"), DataFrame, delim=",")
# check whether output path exists

isdir(output_path) || mkpath(output_path)

#####################
# Create plots
#####################

# each location individually
for location in unique(df.location)
    df_sub = df[(df.location.==location),:]
    t = df_sub.time 
    c = df_sub[!,"COV19"] 
    p1 = plot(t/60, c, xlabel="t (h)", label=missing, ylabel="RNA concentration", thickness_scaling = 1.6)
    savefig(p1, joinpath(output_path, "concentration_$location.png"))
end


# all of them together
location = unique(df.location)[1]
df_sub = df[(df.location.==location),:]
t = df_sub.time 
c = df_sub[!,"COV19"] 
p1 = plot(t/60, c, xlabel="t (h)", label=location, ylabel="RNA concentration", thickness_scaling = 1.2)
for location in unique(df.location)[2:end]
    df_sub = df[(df.location.==location),:]
    t = df_sub.time 
    c = df_sub[!,"COV19"] 
    plot!(t/60, c, xlabel="t (h)", label=location, ylabel="RNA concentration", thickness_scaling = 1.2, legend=:outertopright)
end
p1
savefig(p1, joinpath(output_path, "concentration_all_stations.png"))