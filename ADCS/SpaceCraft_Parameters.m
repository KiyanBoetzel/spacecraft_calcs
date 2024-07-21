 
clc
spacecraft = struct();
spacecraft.Orbit = struct();
spacecraft.Payload = struct();
spacecraft.Power = struct();
spacecraft.Thermal = struct();
spacecraft.Propulsion = struct();
spacecraft.Structure = struct();
spacecraft.ADCS = struct();
spacecraft.TTC = struct();

spacecraft.Orbit.period = 6036.1; % [sec]
spacecraft.Orbit.SMA = 7165.2 * 10^3; % [m]
spacecraft.Orbit.inclination = 98.9; % [deg]

spacecraft.Structure.length = 1.9; % [m]
spacecraft.Structure.width = 0.9; % [m]
spacecraft.Structure.height = 0.95; % [m]
spacecraft.Structure.mass = 300; % [m]

spacecraft.Structure.Ixx = (1/12) * spacecraft.Structure.mass * (spacecraft.Structure.width^2 + spacecraft.Structure.height^2); % [Kg m2]
spacecraft.Structure.Iyy = (1/12) * spacecraft.Structure.mass * (spacecraft.Structure.length^2 + spacecraft.Structure.height^2); % [Kg m2]
spacecraft.Structure.Izz = (1/12) * spacecraft.Structure.mass * (spacecraft.Structure.width^2 + spacecraft.Structure.length^2); % [Kg m2]

spacecraft.ADCS.slew_angularVelocity = 0.1; % [deg/sec]
spacecraft.ADCS.accuracy = 1; % [deg]
spacecraft.ADCS.slew_angle = 30; % [deg]
spacecraft.ADCS.slew_time = 300; % [sec]