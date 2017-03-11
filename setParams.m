% setParams.m
% This is the only file that should be edited when processing
% mono-energetic Geant4 runs!!! It is called at the start of main.m.

% Simulation parameters
energy = 50; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = 10; % Number of simulations to process

energy_str = [num2str(energy,'%02.0f'),'MeV'];

% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);
dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',energy_str,filesep];

% Histogram parameters
bin_width = 0.1; % keV
norm2 = 3; % Normalize the histograms to the peak after 3 keV

% Reporting parameters
verbose = 1; % Plots generated if verbose==1
recombine = 0; % Trimmed raw files are comined into an _all file

