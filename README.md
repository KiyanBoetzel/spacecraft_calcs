# Spacecraft Calculations

This repository contains code for various calculations related to spacecraft design. Each folder contains the corresponding code for the calculation of that subsystem or for the orbit.

## Repository Structure

- **ADCS/**
  - `ADCS.mlx`: MATLAB script for ADCS calculations.
  - `SpaceCraft_Parameters.m`: MATLAB script for spacecraft parameters related to ADCS.
- **Orbit/**
  - `Preliminary_Calculations.script`: GMAT script for preliminary orbit calculations.
- **Payload/**
  - `ARRAY.m`: MATLAB script for payload array calculations.
  - `CASSEGRAIN.m`: MATLAB script for Cassegrain calculations.
- **Propulsion/**
  - `Propulsion.m`: MATLAB script for propulsion calculations.
- **TTC_Power/**
  - `SpaceCraft_Parameters.m`: MATLAB script for spacecraft parameters related to TTC and power subsystems.
  - `components.xlsx`: Excel file with components data.
  - `satellite_power_subsystem_design.m`: MATLAB script for power subsystem design.
  - `satellite_ttc_subsystem_design.m`: MATLAB script for TTC subsystem design.
- **Thermal/**
  - `THERMAL_FINAL.m`: MATLAB script for thermal subsystem calculations.

## Instructions

For each subsystem, navigate to the corresponding folder and run the MATLAB scripts to perform the calculations. For orbit calculations, use the GMAT script in the `Orbit` folder.
