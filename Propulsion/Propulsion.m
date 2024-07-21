clc;
clear all;

% Constants
mu_Earth = 398600; % Earth's gravitational parameter (km^3/s^2)
r_Earth = 6371; % Earth's radius (km)
g0 = 9.80665; % Standard gravity (m/s^2)
P_hydrazine_tank = 22e5; % Pa (22 bar for hydrazine tank)
P_pressurant_initial = 50e5; % Pa (50 bar initial for pressurant tank)
P_pressurant_final = 22e5; % Pa (22 bar final for pressurant tank)
T_pressurant_initial = 293; % K (initial temperature for pressurant)
T_pressurant_final = 238; % K (final temperature for pressurant)
R_N2 = 296.8; % J/(kg·K) (specific gas constant for nitrogen)
rho_hydrazine = 1021; % kg/m^3 (density of hydrazine)
rho_tank_material = 2700; % kg/m^3 (density of aluminum)
sigma_yield_tank_material = 275e6; % Pa (yield strength of aluminum)
min_thickness = 0.0015; % Minimum practical wall thickness (1.5 mm)
safety_factor = 1.5; % Safety factor

% Spacecraft parameters
spacecraft.mass = 300; % Mass of the spacecraft (kg)
spacecraft.orbit.inclination = 98.6; % Inclination (degrees)
spacecraft.orbit.SMA = 7177.323; % Semi-Major Axis (km)
spacecraft.orbit.period = 6051.3874; % Orbital Period (seconds)
spacecraft.orbit.altitude = 799.323; % Altitude (km)
spacecraft.orbit.eccentricity = 0; % Eccentricity (circular orbit)

spacecraft.propulsion.ion.Isp = 3000; % Specific impulse of ion thruster (s)
spacecraft.propulsion.cold_gas.Isp = 60; % Specific impulse of cold gas thruster (s)
spacecraft.propulsion.monopropellant.Isp = 250; % Specific impulse of monopropellant thruster (s)
spacecraft.propulsion.ion.efficiency = 0.7; % Efficiency of ion thruster
spacecraft.propulsion.cold_gas.efficiency = 0.5; % Efficiency of cold gas thruster
spacecraft.propulsion.monopropellant.efficiency = 0.55; % Efficiency of monopropellant thruster
spacecraft.propulsion.ion.propellant = 'Xenon'; % Propellant used by ion thruster
spacecraft.propulsion.monopropellant.propellant = 'Hydrazine'; % Propellant used by monopropellant thruster
spacecraft.propulsion.cold_gas.propellant = 'Nitrogen'; % Propellant used by cold gas thruster
spacecraft.propulsion.monopropellant.pressurant = 'Nitrogen'; % Pressurant used for monopropellant

% Additional parameters
A = 1.5 + 1.9 * 2.9  ;% Cross-sectional area (m^2, assumed)
mission_duration_years = 5;
seconds_per_year = 365.25 * 24 * 60 * 60;
Cd = 2.2; % Drag coefficient (assumed)
rho = 1e-12; % Atmospheric density at 799.323 km altitude (kg/m^3, approximate)
P_SRP = 4.57e-6; % N/m^2
c = 299792458; % Speed of light (m/s)
H_i = spacecraft.orbit.altitude; % Initial altitude (km)
H_e = 300; % Reentry perigee altitude (km)
n = 1.12; % Polytropic exponent
M_N2 = 0.0280134; % kg/mol (molar mass of N2)

% Apply a 10% margin to ensure the tanks are not completely emptied
margin_factor = 1.10;

% Estimated propulsion system masses (excluding propellant)
mass_monopropellant_thrusters = 4 * 0.6; % kg (weight of the thrusters)
mass_ion_thrusters = 10; % kg (weight of ion thrusters)
mass_cold_gas_thrusters = 5; % kg (weight of cold gas thrusters)

%%%%%%%%%%%%%%%%%%%DELTA V CALCULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate orbital velocity
v_orbit = sqrt(mu_Earth / (r_Earth + spacecraft.orbit.altitude)) * 1000; % m/s

% Atmospheric drag calculation
D = 0.5 * Cd * rho * v_orbit^2 * A; % Drag force in N
delta_v_drag = (D / spacecraft.mass) * spacecraft.orbit.period; % Delta-v due to drag over one orbit in m/s

% Solar radiation pressure calculation
F_SRP = P_SRP * A / c; % N
delta_v_SRP = (F_SRP / spacecraft.mass) * spacecraft.orbit.period; % Delta-v due to solar radiation pressure over one orbit in m/s

% Total delta-v for orbit maintenance per orbit
delta_v_maintenance_per_orbit = delta_v_drag + delta_v_SRP; % m/s

% Calculate number of orbits in 5 years
total_orbits = (mission_duration_years * seconds_per_year) / spacecraft.orbit.period;

% Total delta-v for orbit maintenance over the mission duration
delta_v_maintenance_total = delta_v_maintenance_per_orbit * total_orbits; % m/s

% Delta-v for deorbiting (from SMAD)
delta_v_deorbit = v_orbit * (1 - sqrt(2 * (r_Earth + H_e) / (2 * r_Earth + H_e + H_i))); % m/s

% Total delta-v required
delta_v_total = delta_v_maintenance_total + delta_v_deorbit; % Total delta-v in m/s


%%%%%%%%%%%%%%%%%% PROPULSION SYSTEM COMPARISON %%%%%%%%%%%%%%%%%%%%%%%%%

% Propellant mass calculations using Tsiolkovsky rocket equation
m_prop_ion = spacecraft.mass * (1 - exp(-delta_v_total / (spacecraft.propulsion.ion.Isp * g0))); % Ion thruster
m_prop_cold_gas = spacecraft.mass * (1 - exp(-delta_v_total / (spacecraft.propulsion.cold_gas.Isp * g0))); % Cold gas thruster
m_prop_monopropellant = spacecraft.mass * (1 - exp(-delta_v_total / (spacecraft.propulsion.monopropellant.Isp * g0))); % Monopropellant thruster


%%%%%%%%%%%%%%% MONOPROPELLANT CALCULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Calculate volume of propellant for monopropellant
V_propellant = (m_prop_monopropellant / rho_hydrazine) * margin_factor; % Volume in m^3

% Hydrazine Tank Dimensions
r_tank_propellant = ((3 * V_propellant) / (4 * pi))^(1/3); % Radius in meters
t_tank_propellant = max(safety_factor * P_hydrazine_tank * r_tank_propellant / (2 * sigma_yield_tank_material), min_thickness); % Wall thickness in meters

% Pressurant Calculations using Polytropic Process
V_pressurant_initial = V_propellant * (P_pressurant_final / P_pressurant_initial)^(1/n); % Volume of pressurant gas at initial condition

% Pressurant Tank Dimensions
r_tank_pressurant = ((3 * V_pressurant_initial) / (4 * pi))^(1/3); % Radius in meters
t_tank_pressurant = max(safety_factor * P_pressurant_initial * r_tank_pressurant / (2 * sigma_yield_tank_material), min_thickness); % Wall thickness in meters

% Mass of Nitrogen Pressurant
n_N2 = (P_pressurant_final * V_propellant) / (R_N2 * T_pressurant_final); % moles
m_pressurant = n_N2 * M_N2; % kg

% Calculate tank masses
V_wall_propellant = (4/3) * pi * ((r_tank_propellant + t_tank_propellant)^3 - r_tank_propellant^3); % Volume of tank wall
V_wall_pressurant = (4/3) * pi * ((r_tank_pressurant + t_tank_pressurant)^3 - r_tank_pressurant^3); % Volume of tank wall

m_tank_propellant = V_wall_propellant * rho_tank_material; % Mass of the propellant tank
m_tank_pressurant = V_wall_pressurant * rho_tank_material; % Mass of the pressurant tank


% Total mass of the propulsion systems and propellant
total_mass_monopropellant = mass_monopropellant_thrusters + m_prop_monopropellant + m_tank_propellant + m_tank_pressurant;
total_mass_ion = mass_ion_thrusters + m_prop_ion;
total_mass_cold_gas = mass_cold_gas_thrusters + m_prop_cold_gas;

% Total propulsion system mass
total_propulsion_system_mass = m_tank_propellant + m_tank_pressurant + m_prop_monopropellant + m_pressurant + mass_monopropellant_thrusters;

% Print results in the command window
fprintf('Delta-v Requirements:\n');
fprintf('---------------------------------\n');
fprintf('Delta-v for orbit maintenance per orbit: %.2f m/s\n', delta_v_maintenance_per_orbit);
fprintf('Total delta-v for orbit maintenance over 5 years: %.2f m/s\n', delta_v_maintenance_total);
fprintf('Delta-v for deorbiting: %.2f m/s\n', delta_v_deorbit);
fprintf('Total Delta-v required: %.2f m/s\n\n', delta_v_total);

fprintf('Comparison of Propulsion Systems:\n');
fprintf('---------------------------------\n');
fprintf('Propulsion System: Monopropellant Thruster\n');
fprintf('Propellant Mass: %.2f kg\n', m_prop_monopropellant);
fprintf('Total System Mass: %.2f kg\n\n', total_mass_monopropellant);

fprintf('Propulsion System: Ion Thruster\n');
fprintf('Propellant Mass: %.2f kg\n', m_prop_ion);
fprintf('Total System Mass: %.2f kg\n\n', total_mass_ion);

fprintf('Propulsion System: Cold Gas Thruster\n');
fprintf('Propellant Mass: %.2f kg\n', m_prop_cold_gas);
fprintf('Total System Mass: %.2f kg\n\n', total_mass_cold_gas);

% Print detailed parameters of monopropellant system in a table format
fprintf('Detailed Parameters of Monopropellant System:\n');
fprintf('--------------------------------------------\n');
fprintf('%-30s %-15s %-15s\n', 'Parameter', 'Propellant', 'Pressurant');
fprintf('%-30s %-15.2f %-15.2f\n', 'Mass (kg)', m_prop_monopropellant, m_pressurant);
fprintf('%-30s %-15.2f %-15.2f\n', 'Mass Tank (kg)', m_tank_propellant, m_tank_pressurant);
fprintf('%-30s %-15.4f %-15.4f\n', 'Volume (m³)', V_propellant, V_pressurant_initial);
fprintf('%-30s %-15.2f %-15.2f\n', 'Wall Mass (kg)', m_tank_propellant, m_tank_pressurant);
fprintf('%-30s %-15.4f %-15.4f\n', 'Radius (m)', r_tank_propellant, r_tank_pressurant);
fprintf('%-30s %-15.4f %-15.4f\n', 'Wall Thickness (m)', t_tank_propellant, t_tank_pressurant);
fprintf('%-30s %-15.2f %-15.2f\n', 'Total Tank Mass (kg)', m_tank_propellant, m_tank_pressurant);

% Print total propulsion system mass
fprintf('\nTotal Propulsion System Mass: %.2f kg\n', total_propulsion_system_mass);
