% setParams.m
% This is the only file that should be edited when processing
% mono-energetic Geant4 runs!!! It is called at the start of main.m.

% Simulation parameters
energy = 100; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = 9; % Number of simulations to process

% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);
dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',num2str(energy),'MeV/'];

% Histogram parameters
bin_width = 0.1; % keV

% Reporting parameters
verbose = 1; % Plots generated if verbose==1

