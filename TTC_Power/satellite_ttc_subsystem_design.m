function spacecraft = satellite_ttc_subsystem_design(spacecraft)
    % Extract parameters from the input structure
    G_ant_dB = spacecraft.ttc.G_ant_dB; % Antenna gain in dBi
    T_sistema_K = spacecraft.ttc.T_sistema_K; % System noise temperature in Kelvin
    f_Hz = spacecraft.ttc.f_Hz; % Frequency in Hz
    c = 3e8; % Speed of light in m/s
    P_trans_dBm = spacecraft.ttc.P_trans_dBm; % Transmitter power in dBm
    Cable_atten_dB = spacecraft.ttc.Cable_atten_dB; % Cable attenuation in dB
    data_rate_bps = spacecraft.ttc.data_rate_bps; % Data rate in bits per second
    modulation_factor = spacecraft.ttc.modulation_factor; % Modulation factor
    FEC = spacecraft.ttc.FEC; % Forward Error Correction
    d_m = spacecraft.orbit.altitude; % Distance in meters
    G_tx_dB = spacecraft.ttc.G_ant_dB; % Gain of the transmitting antenna in dB
    G_rx_dB = spacecraft.ttc.G_ant_dB2; % Gain of the receiving antenna in dB (assuming same antenna for Rx)
    
    % Estimated specific attenuation (clear sky conditions)
    specific_atten_dB_per_km = 0.01; % dB/km

    % Calculate total attenuation for the given distance
    total_atten_dB = specific_atten_dB_per_km * (d_m / 1000); % Convert meters to km

    % Calculate G/T
    G_T_dB = G_ant_dB - 10 * log10(T_sistema_K);

    % Calculate Effective Antenna Aperture
    G_linear = 10^(G_ant_dB / 10); % Convert gain to linear value
    lambda_m = c / f_Hz; % Wavelength
    A_e_m2 = (lambda_m^2 / (4 * pi)) * G_linear;

    % Calculate EIRP
    EIRP_dBm = P_trans_dBm - Cable_atten_dB + G_ant_dB;

    % Calculate Free Space Path Loss (FSPL)
    FSPL_dB = 20 * log10(d_m) + 20 * log10(f_Hz) + 20 * log10(4 * pi / c) - G_tx_dB - G_rx_dB;

    % Total Path Loss includes FSPL and additional total attenuation
    Total_PL_dB = FSPL_dB + total_atten_dB;

    % Calculate Symbol Rate
    SR_symb_s = data_rate_bps / (modulation_factor * FEC);

    % Store results in the spacecraft structure
    spacecraft.ttc.G_T_dB = G_T_dB;
    spacecraft.ttc.A_e_m2 = A_e_m2;
    spacecraft.ttc.EIRP_dBm = EIRP_dBm;
    spacecraft.ttc.FSPL_dB = Total_PL_dB; % Updated to include total path loss
    spacecraft.ttc.SR_symb_s = SR_symb_s;

    






end
