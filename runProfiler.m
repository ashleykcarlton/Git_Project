close all; clear all;

% Simulation parameters
energy = 10; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = 1; % Number of simulations to process

energy_str = [num2str(energy,'%02.0f'),'MeV'];

% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);
dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',energy_str,filesep];

load([dataDir,'processed',filesep,energy_str,'_run01.mat'])

energy
numOrigSourceParticles = num_particles*num_simulations
numSourceParticlesCCDHit = length(unique(simInfo.EventID))
numPrimariesCCDHit = length(find(simInfo.ParentID==0))
numParticlesEDep = nnz(simInfo.EnergyDeposited)


primaryInds = find(simInfo.ParentID==0);
primKE = simInfo.KineticEnergy(primaryInds);
secondaryInds = find(simInfo.ParentID==1);
secKE = simInfo.KineticEnergy(secondaryInds);

figure
hold on
histogram(simInfo.KineticEnergy,'BinWidth',10,'EdgeColor','none')% 1 keV
histogram(primKE,'BinWidth',10,'EdgeColor','none')
