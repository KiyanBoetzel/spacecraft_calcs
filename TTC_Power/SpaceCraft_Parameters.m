% Main program to initialize spacecraft struct and call the TTC and Power subsystem design functions

% Initialize the spacecraft struct
spacecraft = struct();
spacecraft.orbit = struct();
spacecraft.payload = struct();
spacecraft.power = struct();
spacecraft.thermal = struct();
spacecraft.propulsion = struct();
spacecraft.structure = struct();
spacecraft.adcs = struct();
spacecraft.ttc = struct();

% Orbital parameters
spacecraft.orbit.period = 6051.3874; % [sec]
spacecraft.orbit.sma = 7177.323 * 10^3; % [m]
spacecraft.orbit.inclination = 98.6; % [deg]
spacecraft.orbit.eclipse_duration = 1208.2; % [sec]
spacecraft.orbit.sun_flux = 1361; % Solar constant in W/m²
spacecraft.orbit.altitude = 799e3; % altitude of the satellite in LEO [m]
spacecraft.orbit.earth_radius = 6371e3; % Earth Radius
spacecraft.orbit.satellite_longitude = 0; % Satellite longitude

% Structure parameters
spacecraft.structure.length = 3; % [m]
spacecraft.structure.width = 3; % [m]
spacecraft.structure.height = 3; % [m]
spacecraft.structure.mass = 300; % [kg]

% Power parameters derived from the solar panel data
spacecraft.power.initial_efficiency = 0.30; % Initial efficiency (30%)
spacecraft.power.inherent_degradation = 0.005; % Inherent degradation per year (0.5%)
spacecraft.power.efficiency_system = 0.7; % System efficiency
spacecraft.power.design_lifetime = 5; % Design lifetime in years
spacecraft.power.mass_per_area = 0.27 / (21.04 * 0.512); % kg/m² (mass per area based on voltage and current)
spacecraft.power.bus_voltage = 28; % V (common value)
spacecraft.power.battery_capacity = 99; % Wh per battery pack
spacecraft.power.battery_mass = 0.65; % kg per battery pack
spacecraft.power.nominal_battery_voltage = 28; % Nominal battery voltage in V
spacecraft.power.single_panel_power = 354; % W, assumed power output of a single panel

% TTC subsystem parameters (updated)

% TTC subsystem parameters (updated)
spacecraft.ttc.G_ant_dB = 7; % Antenna gain in dBi (converted from dBic)
spacecraft.ttc.G_ant_dB2 = 40;
spacecraft.ttc.T_sistema_K = 290; % System noise temperature in Kelvin
spacecraft.ttc.f_Hz = 2100e6; % Frequency in Hz (2.26 GHz)
spacecraft.ttc.P_trans_dBm = 36.02; % Transmitter power in dBm (10 watts)
spacecraft.ttc.Cable_atten_dB = 0.1122; % Cable attenuation in dB
spacecraft.ttc.data_rate_bps = 20e6; % Data rate in bits per second (20 Mbps)
spacecraft.ttc.modulation_factor = 2; % Modulation factor (QPSK)
spacecraft.ttc.FEC = 0.5; % Forward Error Correction
spacecraft.ttc.d_m = spacecraft.orbit.altitude; % Distance in meters (1 km)
spacecraft.ttc.G_tx_dB = 7; % Gain of the transmitting antenna in dB (same as G_ant_dB)
spacecraft.ttc.G_rx_dB = 40; % Gain of the receiving antenna in dB (ground antenna)


spacecraft.ttc.g_station_ny_latitude = 40.7128; % Nueva York
spacecraft.ttc.g_station_ny_longitude = 365-74.0060; % Nueva York

spacecraft.ttc.g_station_madrid_latitude = 40.4168; % Madrid
spacecraft.ttc.g_station_madrid_longitude = 365-3.7038; % Madrid

spacecraft.ttc.g_station_rome_latitude = 41.9028; % Roma
spacecraft.ttc.g_station_rome_longitude = 12.4964; % Roma

spacecraft.ttc.g_station_athens_latitude = 37.9838; % Atenas
spacecraft.ttc.g_station_athens_longitude = 23.7275; % Atenas

spacecraft.ttc.g_station_tokyo_latitude = 35.6895; % Tokio
spacecraft.ttc.g_station_tokyo_longitude = 139.6917; % Tokio

spacecraft.ttc.g_station_beijing_latitude = 39.9042; % Beijing
spacecraft.ttc.g_station_beijing_longitude = 116.4074; % Beijing

% Call the function to design the TTC subsystem
spacecraft = satellite_ttc_subsystem_design(spacecraft);

% Display TTC results
fprintf('\nTTC Results:\n');
fprintf('G/T (dB): %.2f\n', spacecraft.ttc.G_T_dB);
fprintf('Effective Antenna Aperture (m^2): %.4e\n', spacecraft.ttc.A_e_m2);
fprintf('EIRP (dBm): %.2f\n', spacecraft.ttc.EIRP_dBm);
fprintf('Free Space Path Loss (dB): %.2f\n', spacecraft.ttc.FSPL_dB);
fprintf('Symbol Rate (symbols/s): %.2f\n', spacecraft.ttc.SR_symb_s);


% Call the function to perform the power subsystem design
%filename = '/Users/ales/Desktop/MASTER TUM/SEMESTER 4/spacecraft_design/code/TTC_Power/components.xlsx';
%[spacecraft, results] = satellite_power_subsystem_design(spacecraft, filename);

% Get the directory of the current script
currentDir = fileparts(mfilename('fullpath'));

% Define the relative path to the file
relativePath = fullfile(currentDir, 'components.xlsx');

% Call the function to perform the power subsystem design
filename = relativePath;

[spacecraft, results] = satellite_power_subsystem_design(spacecraft, filename);

% Display the power subsystem results
fprintf('\nPower Subsystem Results:\n');
fprintf('Initial efficiency: %.2f%%\n', spacecraft.power.initial_efficiency * 100);
fprintf('Final efficiency: %.2f%%\n', results.final_efficiency * 100);
fprintf('Total power required during daylight (W): %.2f\n', results.total_power_daylight);
fprintf('Total power required during eclipse (W): %.2f\n', results.total_power_eclipse);
fprintf('Worst Case Power Consumption: %.2f\n',results.worst_case_power);
fprintf('Energy required during eclipse (Wh): %.2f\n', results.energy_required_during_eclipse);
fprintf('Number of Cycles: %.2f\n', results.numer_of_cycles);
fprintf('Depth of Discharge (percentage): %.2f\n', results.depth_of_discharge);
fprintf('Total battery storage capacity required (Wh): %.2f\n', results.total_battery_storage_capacity_required);
fprintf('Battery capacity required (Ah): %.2f\n', results.battery_capacity_required);
fprintf('Number of battery packs required: %d\n', results.num_battery_packs);
fprintf('Total battery mass (kg): %.2f\n', results.total_battery_mass);
fprintf('Required solar array area (m^2): %.2f\n', results.required_solar_array_area);
fprintf('Singel panel Area (m^2): %.2f\n',results.single_panel_area);
%fprintf('Estimated mass of solar array (kg): %.2f\n', results.estimated_mass_of_solar_array);
fprintf('Number of solar panels required: %d\n', results.num_panels_required);
fprintf('Total solar panel provided power: %.2f\n', results.total_power_solar_panels);
fprintf('Number solar normal operation: %.2f\n', results.num_panels_normal);

% % Display elevations of ground stations
% fprintf('\nElevations of Ground Stations (degrees):\n');
% city_names = {'New York', 'Madrid', 'Rome', 'Athens', 'Tokyo', 'Beijing'};
% for i = 1:length(results.elevations)
%     fprintf('%s: %.2f\n', city_names{i}, results.elevations(i));
% end

