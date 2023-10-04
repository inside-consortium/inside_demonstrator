using CSV, DataFrames, Plots

base_path = joinpath(pwd(), "inside_demonstrator")
experiment_name = "base"
output_path = joinpath(base_path, "analysis/plots/memilio/$experiment_name")


#####################
# preparation
#####################

# check whether output path exists
isdir(output_path) || mkdir(output_path)

# read in data
df = CSV.read(joinpath(base_path, "memilio_output/$experiment_name/console_output.csv"), DataFrame, delim=" ")[:,1:9]


first(df, 3)

#####################
# Create plots
#####################

#=
plot(df.t, df.S, label="S", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.E, label="E", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.C, label="C", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I, label="I", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_s, label="I_s", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_c, label="I_c", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.R, label="R", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.R, label="D", legend=:outertopright, thickness_scaling = 1.8)


plot(df.t, df.E, label="E", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.C, label="C", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I, label="I", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_s, label="I_s", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_c, label="I_c", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.R, label="R", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.R, label="D", legend=:outertopright, thickness_scaling = 1.8)
=#

plot(df.t, df.I, label="I", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_s, label="I_s", legend=:outertopright, thickness_scaling = 1.8)
plot!(df.t, df.I_c, label="I_c", legend=:outertopright, thickness_scaling = 1.8)


p1 = plot(df.t, sum.(eachrow(df[:,[:I, :I_s, :I_c]])), xlabel="t (days)", ylabel="Infections", label=missing, thickness_scaling = 1.8)
savefig(p1, joinpath(output_path, "infections.png"))

p1 = plot(df.t, sum.(eachrow(df[:,[:I, :I_s, :I_c]])), xlabel="t (days)", ylabel="N", label="I", thickness_scaling = 1.8)
plot!(df.t, df.R, label="R", legend=:outertopright, thickness_scaling = 1.8)
savefig(p1, joinpath(output_path, "infections_recovered.png"))
