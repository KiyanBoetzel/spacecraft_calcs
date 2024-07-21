function [spacecraft, results] = satellite_power_subsystem_design(spacecraft, filename)
    % Load data from the components table with original column headers
    opts = detectImportOptions(filename, 'VariableNamingRule', 'preserve');
    data = readtable(filename, opts);

    % Extract relevant columns
    power_consumption = data.Power_Consumption;
    num_components = data.Number_components;
    subsystem = data.Subsystem;

    % Check for NaN values in extracted columns
    if any(isnan(power_consumption))
        error('Power consumption contains NaN values.');
    end
    if any(isnan(num_components))
        error('Number of components contains NaN values.');
    end

    % Initialize total power consumption variables
    total_power_daylight = 0;
    total_power_eclipse = 0;
    worst_case_power = 0;

    for i = 1:length(subsystem)
        if strcmp(subsystem{i}, 'Payload1') || strcmp(subsystem{i}, 'TTC') || strcmp(subsystem{i}, 'Power1')
            % Components active during both phases
            total_power_daylight = total_power_daylight + power_consumption(i) * num_components(i);
            total_power_eclipse = total_power_eclipse + power_consumption(i) * num_components(i);
        elseif strcmp(subsystem{i}, 'ADCS') || strcmp(subsystem{i}, 'Power2')
            % Components active only during the day
            total_power_daylight = total_power_daylight + power_consumption(i) * num_components(i);
        elseif strcmp(subsystem{i}, 'Propulsion')
            % Components active only during the day, but only for activation time
            total_power_daylight = total_power_daylight + power_consumption(i) * num_components(i);
        elseif strcmp(subsystem{i}, 'Thermal')
            % Components active only during eclipse
            total_power_eclipse = total_power_eclipse + power_consumption(i) * num_components(i);
        elseif strcmp(subsystem{i}, 'Payload2')
            % Components active only during eclipse
            total_power_daylight = total_power_daylight + power_consumption(i) * num_components(i);
        end

        % Include all subsystems for the worst case scenario
        worst_case_power = worst_case_power + power_consumption(i) * num_components(i);
    end

    % Check for NaN values in power calculations
    if isnan(total_power_daylight)
        error('Total power for daylight contains NaN values.');
    end
    if isnan(total_power_eclipse)
        error('Total power for eclipse contains NaN values.');
    end

    % Assign total power consumption to daylight and eclipse
    average_power_daylight = total_power_daylight;
    average_power_eclipse = total_power_eclipse;

    % Efficiency parameters from the struct
    initial_efficiency = 0.30; % Efficiency of the solar panels (30%)
    inherent_degradation = spacecraft.power.inherent_degradation; % Inherent degradation per year
    design_lifetime = spacecraft.power.design_lifetime; % Design lifetime in years

    % Calculate the final efficiency after degradation over the design lifetime
    final_efficiency = initial_efficiency * ((1 - inherent_degradation) ^ design_lifetime);

    % Power parameters from the struct
    mass_per_area = spacecraft.power.mass_per_area; % kg/m²
    nominal_battery_voltage = spacecraft.power.nominal_battery_voltage; % Nominal voltage of the battery in V
    sun_flux = spacecraft.orbit.sun_flux; % Solar constant in W/m²
    efficiency_system = spacecraft.power.efficiency_system; % Efficiency of the system

    % Orbital parameters from the struct
    orbital_period = spacecraft.orbit.period / 3600; % Orbital period in hours
    eclipse_duration = spacecraft.orbit.eclipse_duration / 3600; % Eclipse duration in hours

    % Solar array calculations for the last year of the mission
    daylight_duration = orbital_period - eclipse_duration; % Daylight duration in hours
    average_solar_power_required = (average_power_daylight * daylight_duration + average_power_eclipse * eclipse_duration) / daylight_duration;

    % Calculate total panel area based on provided total power output
    single_panel_power = spacecraft.power.single_panel_power; % W, assumed power output of a single panel
    single_panel_area = single_panel_power / (sun_flux * initial_efficiency * efficiency_system); % m²

    % Correct the calculation of required solar array area
    required_solar_array_area = average_solar_power_required / (sun_flux * final_efficiency * efficiency_system);
    estimated_mass_of_solar_array = required_solar_array_area * mass_per_area;

    % Calculate number of panels needed
    num_panels_required = ceil(required_solar_array_area / single_panel_area);
    num_panels_normal = num_panels_required;

    % Total power provided by solar panels
    total_power_solar_panels = num_panels_required * single_panel_power;

    % Worst Case scenario coverage
    while total_power_solar_panels < worst_case_power
        total_power_solar_panels = num_panels_required * single_panel_power;
        num_panels_required = num_panels_required + 1;
    end

    % Number or cycles
    cycles = (spacecraft.power.design_lifetime * (365*24*3600)) / spacecraft.orbit.period;

    % Depth of Discharge
    DoD = [20, 50, 80, 100];
    CycleLife = [30000, 10000, 7000, 5000];
    
    % Interpolation to find the corresponding DoD
    battery_dod = interp1(CycleLife, DoD, cycles, 'linear') / 100;

    % Battery sizing calculations for the last year of the mission
    energy_required_during_eclipse = average_power_eclipse * eclipse_duration; % Energy required during eclipse in Wh
    total_battery_storage_capacity_required = energy_required_during_eclipse / battery_dod; % Total battery capacity required in Wh
    battery_capacity_required = total_battery_storage_capacity_required / nominal_battery_voltage; % Battery capacity in Ah

    % Battery configuration based on the provided datasheet
    battery_capacity = spacecraft.power.battery_capacity; % Wh per battery pack
    battery_mass = spacecraft.power.battery_mass; % kg per battery pack

    % Determine the number of battery packs needed
    num_battery_packs = ceil(total_battery_storage_capacity_required / battery_capacity);

    % Update spacecraft struct with results
    spacecraft.power.final_efficiency = final_efficiency;
    spacecraft.power.required_power_production = average_solar_power_required;
    spacecraft.power.required_solar_array_area = required_solar_array_area;
    spacecraft.power.estimated_mass_of_solar_array = estimated_mass_of_solar_array;
    spacecraft.power.energy_required_during_eclipse = energy_required_during_eclipse;
    spacecraft.power.total_battery_storage_capacity_required = total_battery_storage_capacity_required;
    spacecraft.power.battery_capacity_required = battery_capacity_required;
    spacecraft.power.num_battery_packs = num_battery_packs;
    spacecraft.power.total_battery_mass = num_battery_packs * battery_mass;
    spacecraft.power.num_panels_required = num_panels_required;
    spacecraft.power.battery_dod = battery_dod;

    % Create results struct
    results = struct();
    results.final_efficiency = final_efficiency;
    results.total_power_daylight = total_power_daylight;
    results.total_power_eclipse = total_power_eclipse;
    results.energy_required_during_eclipse = energy_required_during_eclipse;
    results.numer_of_cycles = cycles;
    results.depth_of_discharge = battery_dod;
    results.total_battery_storage_capacity_required = total_battery_storage_capacity_required;
    results.battery_capacity_required = battery_capacity_required;
    results.num_battery_packs = num_battery_packs;
    results.total_battery_mass = spacecraft.power.total_battery_mass;
    results.single_panel_area = single_panel_area;
    results.required_solar_array_area = required_solar_array_area;
    results.estimated_mass_of_solar_array = estimated_mass_of_solar_array;
    results.num_panels_required = num_panels_required;
    results.total_power_solar_panels = total_power_solar_panels;
    results.worst_case_power = worst_case_power;
    results.num_panels_normal = num_panels_normal;





end
