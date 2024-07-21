clear all
clc

function thermal_analysis()
    % Constants
    sigma = 5.67e-8; % Stefan-Boltzmann constant (W/m^2/K^4)
    T_space = 2.7; % Space temperature in K

    % Surface areas
    A_solar = 0; % Area of one side surface
    A_earth = 1.47; % Area of bottom surface
    A_total = 2.28; % Total surface area without the solar array

    % Mission profile parameters
    P_avg = 200; % Average internal power dissipation (W)

    % Temperature requirements
    T_internal_min = 5 + 273.15; % Minimum temperature in K
    T_internal_max = 35 + 273.15; % Maximum temperature in K

    % Thermal properties for SSO orbit (given in tables from SMAD)
    S_cold = 1317; % Solar constant cold case (W/m^2)
    S_hot = 1419; % Solar constant hot case (W/m^2)
    Q_albedo_cold = 217; % Earth IR for cold case (W/m^2)
    Q_albedo_hot = 261; % Earth IR for hot case (W/m^2)
    beta = 60; % Sun angle in degrees

    % Albedo coefficients from SMAD
    alpha_cold = 0.32;
    alpha_hot = 0.42;

    % Solar incident energy
    Q_solar_cold = S_cold * cosd(beta) * A_solar * 0.25; % Adjusted for surface coverage
    Q_solar_hot = S_hot * cosd(beta) * A_solar * 0.25;

    % Albedo incident energy
    Q_albedo_cold = Q_albedo_cold * A_earth * alpha_cold;
    Q_albedo_hot = Q_albedo_hot * A_earth * alpha_hot;

    % Infrared incident energy
    Q_IR_cold = 217 * A_earth;
    Q_IR_hot = 261 * A_earth;

    % Total absorbed energy for different cases
    Q_absorbed_cold = Q_IR_cold; % Q_solar_cold + Q_albedo_cold;
    Q_absorbed_hot = Q_solar_hot + Q_albedo_hot + Q_IR_hot;

    % No insulation or coating case
    epsilon_no_insulation = 0.85; % Assumed average emissivity without insulation or coating
    T_cold_no_insulation = ((Q_absorbed_cold + P_avg) / (sigma * epsilon_no_insulation * A_total) + T_space^4)^(1/4);
    T_hot_no_insulation = ((Q_absorbed_hot + P_avg) / (sigma * epsilon_no_insulation * A_total) + T_space^4)^(1/4);

    % Convert temperatures to Celsius
    T_cold_no_insulation_C = T_cold_no_insulation - 273.15;
    T_hot_no_insulation_C = T_hot_no_insulation - 273.15;

    % Print no insulation or coating case results
    fprintf('Without Insulation or Coating:\n');
    fprintf('---------------------------------\n');
    fprintf('Cold Case Temperature: %.2f °C\n', T_cold_no_insulation_C);
    fprintf('Hot Case Temperature: %.2f °C\n\n', T_hot_no_insulation_C);

    % Storage for results and accepted solutions
    results = {};
    accepted_solutions = {};

    % Narrower range Multilayer Insulation (MLI) options similar to Double Aluminized Mylar
    MLI_options = {
        'CG 250 / 5mil silvered teflon (5 mil)', 0.05, 0.78;
        'Black Kapton (1 mil)', 0.19, 0.34;
        'Double Aluminized Mylar (2 mil)', 0.07, 0.19;
        'Aluminized Teflon (2 mil)', 0.11, 0.24;
        'Aluminized Mylar (2 mil)', 0.08, 0.21;
        'Double Aluminized Polyimide (2 mil)', 0.06, 0.18;
        'Aluminized Polyimide (2 mil)', 0.07, 0.20;
        'Double Aluminized Kapton (2 mil)', 0.08, 0.16;
        'Double Aluminized Polyester (2 mil)', 0.07, 0.18;
        'Double Aluminized Polypropylene (2 mil)', 0.09, 0.17
    };

    % Print header
    fprintf('%-40s %-25s %-25s\n', 'Condition', 'Cold Case Temperature (°C)', 'Hot Case Temperature (°C)');

    % Iterate over MLI options
    for j = 1:size(MLI_options, 1)
        MLI_name = MLI_options{j, 1};
        absorptivity_MLI = MLI_options{j, 2};
        emissivity_MLI = MLI_options{j, 3};

        % Adjust absorbed energy based on MLI properties
        Q_absorbed_cold_MLI = Q_IR_cold; % (Q_solar_cold * absorptivity_MLI) + Q_albedo_cold;
        Q_absorbed_hot_MLI = (Q_solar_hot * absorptivity_MLI) + Q_albedo_hot + Q_IR_hot;

        % Solve for MLI equilibrium temperatures using Stefan-Boltzmann law
        T_cold_MLI = ((Q_absorbed_cold_MLI + P_avg) / (sigma * emissivity_MLI * A_total) + T_space^4)^(1/4);
        T_hot_MLI = ((Q_absorbed_hot_MLI + P_avg) / (sigma * emissivity_MLI * A_total) + T_space^4)^(1/4);

        % Convert MLI temperatures to Celsius
        T_cold_MLI_C = T_cold_MLI - 273.15;
        T_hot_MLI_C = T_hot_MLI - 273.15;

        % Print MLI results
        fprintf('%-40s %-25.2f %-25.2f\n', MLI_name, T_cold_MLI_C, T_hot_MLI_C);

        % Check if within acceptable temperature range
        if T_cold_MLI >= T_internal_min && T_cold_MLI <= T_internal_max && T_hot_MLI >= T_internal_min && T_hot_MLI <= T_internal_max
            accepted_solutions{end+1} = MLI_name;
        end
    end

    % Coatings options
    coatings = {'Silcolloy 1000', 'White Paint S13G-LO', 'White Paint Z93', 'Beta Cloth'};
    absorptivity_coatings = [0.10, 0.20, 0.18, 0.32];
    emissivity_coatings = [0.87, 0.85, 0.91, 0.86];

    % Iterate over coatings
    for i = 1:length(coatings)
        coating_name = coatings{i};
        absorptivity_coating = absorptivity_coatings(i);
        emissivity_coating = emissivity_coatings(i);

        % Adjust absorbed energy based on coating properties
        Q_absorbed_cold_coating = Q_IR_cold; % (Q_solar_cold * absorptivity_coating) + Q_albedo_cold;
        Q_absorbed_hot_coating = (Q_solar_hot * absorptivity_coating) + Q_albedo_hot + Q_IR_hot;

        % Solve for coating equilibrium temperatures using Stefan-Boltzmann law
        T_cold_coating = ((Q_absorbed_cold_coating + P_avg) / (sigma * emissivity_coating * A_total) + T_space^4)^(1/4);
        T_hot_coating = ((Q_absorbed_hot_coating + P_avg) / (sigma * emissivity_coating * A_total) + T_space^4)^(1/4);

        % Convert coating temperatures to Celsius
        T_cold_coating_C = T_cold_coating - 273.15;
        T_hot_coating_C = T_hot_coating - 273.15;

        % Print coating results
        fprintf('%-40s %-25.2f %-25.2f\n', coating_name, T_cold_coating_C, T_hot_coating_C);

        % Check if within acceptable temperature range
        if T_cold_coating >= T_internal_min && T_cold_coating <= T_internal_max && T_hot_coating >= T_internal_min && T_hot_coating <= T_internal_max
            accepted_solutions{end+1} = coating_name;
        end
    end

    % Print accepted solutions
    fprintf('\nThose are possible thermal solutions:\n');
    for i = 1:length(accepted_solutions)
        fprintf('%s\n', accepted_solutions{i});
    end
end

% Call the function to run the thermal analysis
thermal_analysis();
