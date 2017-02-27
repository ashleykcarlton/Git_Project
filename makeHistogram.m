function [N, N_norm, myedge] = makeHistogram(binWidth,energy,numSims,numParticles,plot)

dataDir = ['Data/Geant4_simulations/run_mono/',num2str(energy),'MeV/processed/'];
load([dataDir,num2str(energy),'MeV_all.mat'])

bin_max = ceil(max(simEnergyCombined.Edep_all_aray));
EDGES = 0:binWidth:bin_max;
EDGES_midpoints = EDGES(1:end-1)+binWidth/2;

E_tot_array_noZeros = simEnergyCombined.Edep_all_aray(simEnergyCombined.Edep_all_aray~=0);
[N,myedge] = hist(E_tot_array_noZeros,EDGES);

if N(end)~=0
    error('Need to modify code! Last N bucket is not zero!!')
end

if plot==1
    figure('Color','white')
    histogram(E_tot_array_noZeros,EDGES,'EdgeColor','none')
    % histogram(E_tot_array_noZeros,EDGES(1:end),'EdgeColor','none')
    xlabel('Energy Deposited [keV]')
    ylabel('Number of Pixels')
    title_str = sprintf('G4 simulation of Energy Deposited from %d runs of \n%E %d MeV electrons on Galileo SSI',numSims,numParticles,energy);
    title(title_str)
    set(gca,'FontSize',16,'FontWeight','bold')
end

% Normalize the peak of the histogram to 1
N_norm = N/max(N);

end