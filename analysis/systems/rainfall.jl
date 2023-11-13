using CSV, DataFrames, Plots

base_path = joinpath(pwd(), "inside_demonstrator")
experiment_name = "2_weeks"

tandler_input_path = joinpath(base_path, "tandler_output", "original", experiment_name)
output_path = joinpath(base_path, "analysis/plots/++systems/$experiment_name")


df_Nieselregen = CSV.read(joinpath(tandler_input_path, "nieselregen.tsv"), DataFrame, delim="\t")
p = plot(df_Nieselregen[!, "Zeit [min]"], df_Nieselregen[!, "Intensität [l/s*ha]"], label="Nieselregen", xlabel="time (min)", ylabel="Intensität (l/s*ha)", color = 5)
savefig(p, joinpath(output_path, "Nieselregen.png"))

df_MittelstarkerRegen = CSV.read(joinpath(tandler_input_path, "mittelstarkerRegen.tsv"), DataFrame, delim="\t")
p = plot(df_MittelstarkerRegen[!, "Zeit [min]"], df_MittelstarkerRegen[!, "Intensität [l/s*ha]"], label="Mittelstarker Regen", xlabel="time (min)", ylabel="Intensität (l/s*ha)", color = 6)
savefig(p, joinpath(output_path, "MittelstarkerRegen.png"))

