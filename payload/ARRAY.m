clear
clc

% Definition of Optics parameters
Object_Distance = 41000; % Distance in meters
GSD = 0.082; % Ground Sampling Distance in meters
wave_length = 0.0000007; % Visual Wavelength in meters
pixel_arrange = 360; % Pixel array based on Samsung EVT3
Pixel_Radius = 0.00000486;
% Sizing calculations

Focal_length = Pixel_Radius*Object_Distance/GSD; % SMAD Table Formula
Diameter = (2.44*(Object_Distance)*(wave_length))/((Focal_length)*(GSD)); % SMAD Table Formula
Sensor_Radius = Pixel_Radius*pixel_arrange; % Pixel radius multiplied by half of array's height
Observed_S = GSD*pixel_arrange; % Radius
Area = ((Observed_S)^2)*(pi); % Observed Area
FOV = 2*(atan(Observed_S/Object_Distance));

% Results

fprintf('Diameter Required (Diameter): %.4f m', Diameter);
fprintf('\n');
fprintf('Focal Length Required (Focal_length): %.7f m', Focal_length);
fprintf('\n');
fprintf('Pixel Radius Required (Pixel_Radius): %.7f m', Pixel_Radius);
fprintf('\n');
fprintf('Sensor Required (Sensor_Radius): %.2f m', Sensor_Radius);
fprintf('\n');
fprintf('Observed Length (S): %.2f m', Observed_S);
fprintf('\n');
fprintf('Observed Area (A): %.2f m^2', Area);
fprintf('\n');
fprintf('Field of View (FOV): %.9f', FOV);
