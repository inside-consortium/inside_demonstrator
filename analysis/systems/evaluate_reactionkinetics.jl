using CSV, DataFrames, Plots

base_path = joinpath(pwd())

tandler_output_path = joinpath(base_path, "tandler_output/original/Reaktionstests")
output_path = joinpath(base_path, "analysis/plots/++systems/Reaktionstests")
isdir(output_path) || mkpath(output_path)

# load data
df_R0 = CSV.read(joinpath(tandler_output_path, "R0.csv"), DataFrame, delim="\t")
df_R1 = CSV.read(joinpath(tandler_output_path, "R1.csv"), DataFrame, delim="\t")
df_R2 = CSV.read(joinpath(tandler_output_path, "R2.csv"), DataFrame, delim="\t")

function visualize_viral_decay(t)
    v_R0 = Array(df_R0[df_R0.time.==t,["MW059", "MW058", "MW057", "MW056", "MW055", "MW054", "MW053"]])[1,:]
    v_R1 = Array(df_R1[df_R1.time.==t,["MW059", "MW058", "MW057", "MW056", "MW055", "MW054", "MW053"]])[1,:]
    v_R2 = Array(df_R2[df_R2.time.==t,["MW059", "MW058", "MW057", "MW056", "MW055", "MW054", "MW053"]])[1,:]
    p = plot(1:7, v_R0, label="R0", xlabel="x", ylabel="COV19", title="time: $t")
    plot!(1:7, v_R1, label="R1", xlabel="x", ylabel="COV19", title="time: $t")
    plot!(1:7, v_R2, label="R2", xlabel="x", ylabel="COV19", title="time: $t")
    savefig(p, joinpath(output_path, "viral_decay_t$t.png"))
    p
end

for t in unique(df_R0.time)[[1, 100, 1000, 1900, 2000]]
    visualize_viral_decay(t)
end