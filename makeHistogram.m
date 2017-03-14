function [N, N_norm, N_all, N_all_norm, EDGES] = makeHistogram(binWidth,energy,numSims,numParticles,plot)

energy_str = [num2str(energy,'%02.0f'),'MeV'];
dataDir = ['Data/Geant4_simulations/run_mono/',energy_str,'/processed/'];
load([dataDir,energy_str,'_',num2str(numSims),'runs.mat'])

bin_max = ceil(max(simEnergyCombined.Edep_all_array));
if bin_max==0
    error('No energy deposited for combined simulations. Exitting...')
end
EDGES = 0:binWidth:bin_max;
EDGES_midpoints = EDGES(1:end-1)+binWidth/2;

E_tot_array_noZeros = simEnergyCombined.Edep_all_array(simEnergyCombined.Edep_all_array~=0);
if isempty(E_tot_array_noZeros)
    error('No energy deposited in simulation!')
end

[N,myedge] = hist(E_tot_array_noZeros,EDGES);

if N(end)~=0
    disp('Last N bucket is not zero!! May need to modify code!')
end

Edep_noZeros = simEnergyCombined.Edep_noMatrix(simEnergyCombined.Edep_noMatrix~=0);
[N_all,myedge_all] = hist(Edep_noZeros,EDGES);

if plot==1
    figure('Color','white')
    histogram(E_tot_array_noZeros,EDGES,'EdgeColor','none')
    % histogram(E_tot_array_noZeros,EDGES(1:end),'EdgeColor','none')
    xlabel('Energy Deposited [keV]')
    ylabel('Number of Pixels')
    title_str = sprintf('G4 simulation of Energy Deposited from %d runs of \n%.2E %d MeV electrons on Galileo SSI',numSims,numParticles,energy);
    title(title_str)
    set(gca,'FontSize',16,'FontWeight','bold')
    
    figure('Color','white')
    histogram(Edep_noZeros,EDGES,'EdgeColor','none')
    xlabel('Energy Deposited [keV]')
    ylabel('Number of Particles')
    title_str = sprintf('G4 simulation of Energy Deposited from %d runs of \n%.2E %d MeV electrons on Galileo SSI',numSims,numParticles,energy);
    title(title_str)
    set(gca,'FontSize',16,'FontWeight','bold')
    
    figure('Color','white')
    hold on;
    bar(EDGES,N/max(N),'FaceAlpha',0.75,'BarWidth',1,'EdgeColor','none')
    bar(EDGES,N_all/max(N_all),'FaceAlpha',0.75,'BarWidth',1,'EdgeColor','none')
    xlim([0 20])
    xlabel('Energy Deposited [keV]')
    ylim([0 1])
    ylabel('Number of Pixels or Particles')
    title_str = sprintf('G4 simulation histograms - normalized');
    title(title_str)
    set(gca,'FontSize',18,'FontWeight','bold');
    grid on; box on;
end

% Normalize the peak of the histogram to 1
N_norm = N/max(N);
N_all_norm = N_all/max(N_all);

end