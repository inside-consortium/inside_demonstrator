using CSV, DataFrames, Plots

base_path = joinpath(pwd())
base_experiment = "final_tests"

function compare_concentrations(location, rain_scenarios, hydraulics_settings, output_path)
    p = plot()
    for rain_scenario in rain_scenarios
        for hydraulics_setting in hydraulics_settings
            experiment_name = base_experiment*"/"*rain_scenario*"/"*hydraulics_setting
            # preparation
            tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
            df = CSV.read(joinpath(tandler_output_path, "concentration_curves.csv"), DataFrame, delim=",")
            # plot
            df_sub = df[(df.location.==location),:]
            t = df_sub.time 
            c = df_sub[!,"COV19"]
            plot!(t/60, c, xlabel="t (h)", label="$(rain_scenario)_$(hydraulics_setting)", legend = :outertopright, 
                ylabel="RNA concentration", thickness_scaling = 1.6, size=(1400,600), title=location)
        end
    end
    p
    savefig(p, joinpath(output_path, "concentration_$location.png"))
end

function compare_rain_scenarios(hydraulic_setting)
    rain_scenarios = ["1_KeinRegen", "2_Nieselregen", "3_MittelstarkerRegen"]
    hydraulics_settings = [hydraulic_setting] # ["0_recalculate_hydraulics", "a_constant_hydraulics_avg", "b_constant_hydraulics_same"]

    output_path = joinpath(base_path, "analysis/plots/++systems/$base_experiment/compare_rain_scenarios/$(hydraulic_setting)")
    isdir(output_path) || mkpath(output_path)

    experiment_name = base_experiment*"/"*rain_scenarios[1]*"/"*hydraulics_setting
    tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
    df = CSV.read(joinpath(tandler_output_path, "concentration_curves.csv"), DataFrame, delim=",")
    for location in unique(df.location)
        compare_concentrations(location, rain_scenarios, hydraulics_settings, output_path)
    end
end

compare_rain_scenarios("0_recalculate_hydraulics")
compare_rain_scenarios("a_constant_hydraulics_avg")
compare_rain_scenarios("b_constant_hydraulics_same")

function compare_degradation_scenarios(rain_scenario)
    rain_scenarios = [rain_scenario]
    hydraulics_settings = ["0_recalculate_hydraulics", "a_constant_hydraulics_avg", "b_constant_hydraulics_same"]
    output_path = joinpath(base_path, "analysis/plots/++systems/$base_experiment/compare_hydraulics_settings/$(rain_scenario)")
    
    isdir(output_path) || mkpath(output_path)

    experiment_name = base_experiment*"/"*rain_scenario*"/"*hydraulics_settings[1]
    tandler_output_path = joinpath(base_path, "tandler_output/preprocessed/$experiment_name")
    df = CSV.read(joinpath(tandler_output_path, "concentration_curves.csv"), DataFrame, delim=",")
    for location in unique(df.location)
        compare_concentrations(location, rain_scenarios, hydraulics_settings, output_path)
    end
end

compare_degradation_scenarios("1_KeinRegen")
compare_degradation_scenarios("2_Nieselregen")
compare_degradation_scenarios("3_MittelstarkerRegen")