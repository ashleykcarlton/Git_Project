% combineEnergies.m Combine the information from the simulations of the
% Kinetic Energy when the particles reach the detector
close all; clear all; clc;

% Simulation parameters
energy = [10,50,100,200]; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = [1,1,1,1]; % Number of simulations to process

% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);

% Histogram parameters
binWidth = 1; % keV
binMax = 2*10^5; % keV (100 MeV)
EDGES = 0:binWidth:binMax;

% Reporting parameters
verbose = 1; % Plots generated if verbose==1
recombine = 1; % Trimmed raw files are combined and saved
% saveFit = 1; % Save the fit parameters

for ii=1:length(energy)
    
    energy_str = [num2str(energy(ii),'%02.0f'),'MeV'];
    dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',energy_str];
    putfile = [dataDir,'/processed/',energy_str,'_',num2str(num_simulations(ii)),'runs.mat'];
    %     fitfile = [dataDir,'/processed/fitParams_',energy_str,'_',num2str(num_simulations(ii)),'.mat'];
    
    %     if ~exist(putfile,'file')||~exist(fitfile,'file')||recombine
    if ~exist(putfile,'file')||recombine
        combineSims(energy(ii),num_simulations(ii))
    end
    
    if num_simulations(ii)>1
        load(putfile)
        KE_dep = simEnergyCombined.KE(simEnergyCombined.Edep_noMatrix~=0);
    else
        load([dataDir,'/processed/',energy_str,'_run01.mat'])
        einds = find(simInfo.EnergyDeposited~=0);
        eeinds = find(strcmp(simInfo.ParticleName,'e-'));
        KE_dep = simInfo.KineticEnergy(intersect(einds,eeinds));
    end
    
    [N,myedge] = hist(KE_dep,EDGES);
    
    histresults(ii).KE_dep = KE_dep;
    histresults(ii).N = N;
    histresults(ii).N_norm = N/max(N);
    histresults(ii).edges = myedge;
    %     fitresults(ii).fit = fitresult(edges);
    %     fitresults(ii).edges = edges;
    %     fitresults(ii).gof = gof;
    %     fitresults(ii).pred = preds;
    
    if verbose==1
        figure('Color','white')
        hold on;
        histogram(KE_dep,EDGES,'EdgeColor','none')
        xlabel('Kinetic Energy of Particles when they reach the Detector [keV]')
        ylabel('Number of Particles')
        title_str = sprintf('G4 simulation of Kinetic Energy from %d runs of \n%.2E %d MeV electrons on Galileo SSI',...
            num_simulations(ii),num_particles,energy(ii));
        title(title_str)
        set(gca,'FontSize',16,'FontWeight','bold')
        grid on; box on;
        
        %         % Normalized
        %         figure('Color','white')
        %         hold on;
        %         bar(myedge,N/max(N),'FaceAlpha',0.75,'BarWidth',1,'EdgeColor','none')
        %         xlabel('Normalized Kinetic Energy of Particles when they reach the Detector [keV]')
        %         ylabel('Number of Particles')
        %         title_str = sprintf('G4 simulation of Normalized Kinetic Energy from %d runs of \n%.2E %d MeV electrons on Galileo SSI',...
        %             num_simulations(ii),num_particles,energy(ii));
        %         title(title_str)
        %         xlim([0 myedge(end)])
        %         set(gca,'FontSize',16,'FontWeight','bold')
        %         grid on; box on;
    end
end


cmap = colormap('parula');
cmap_inds = 1:floor(length(cmap)/length(energy)):length(cmap);

% Plot histograms -- NOT normalized
figure1 = figure('Color',[1 1 1]);
hold on;
for kk = length(energy):-1:1
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges,histresults(kk).N,'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 binMax])
xlabel('Kinetic Energy of Particles that Reach the Detector and Deposit Energy [keV]')
ylim([0 max(histresults(end).N)])
ylabel('Number of Particles')
title_str = sprintf('G4 simulation histograms');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;

% Plot histograms -- normalized
figure1 = figure('Color',[1 1 1]);
hold on;
for kk = 1:length(energy)
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges,histresults(kk).N_norm,'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 binMax])
xlabel('Kinetic Energy of Particles that Reach the Detector and Deposit Energy [keV]')
ylim([0 1])
ylabel('Number of Particles')
title_str = sprintf('G4 simulation histograms - normalized to peak');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;

STe = load([codeHome,'Data/StoppingPower_electrons.mat']);
figure1 = figure('Color',[1 1 1]);
hold on;
plot(STe.KineticEnergyMeV,STe.TotalStoppingPower,'DisplayName','Total Stopping Power','LineWidth',1)
plot(STe.KineticEnergyMeV,STe.CollStoppingPower,'--','DisplayName','Collision Stopping Power','LineWidth',1)
plot(STe.KineticEnergyMeV,STe.RadStoppingPower,'--','DisplayName','Radiative Stopping Power','LineWidth',1)
legend(gca,'show','Location','southeast');
xlabel('Kinetic Energy [MeV]')
ylabel('Stopping Power [MeV cm2/g]')
title_str = sprintf('Stopping Power: Electrons in Aluminum');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold','yscale','log','xscale','log');
grid on; box on;

% Plot histograms -- normalized
figure('Color',[1 1 1]);
[ax, h1, h2] =plotyy(histresults(end).edges,histresults(end).N_norm,...
    STe.KineticEnergyMeV*1000,STe.CollStoppingPower,'bar','plot');
hold on
set(h1,'FaceColor',cmap(cmap_inds(4),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
for kk = length(energy)-1:-1:1
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges,histresults(kk).N_norm,'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
set(ax(1),'xlim',[0 1E4])
set(ax(2),'xlim',[0 1E4])
set(h2, 'Marker','none','Color',[0 0 0],'LineStyle','.-','LineWidth',3);
% legend([h1,h2],'Histogram','Total Stopping Power')
legend(gca,'show')
xlabel('Kinetic Energy [keV]','FontWeight','bold','FontSize',16)
y_str1 = sprintf('Number of Particles');
set(get(ax(1), 'Ylabel'), 'String', y_str1,'FontWeight','bold','FontSize',16);
y_str = sprintf('Collison Stopping Power [MeV cm2/g]');
set(get(ax(2), 'Ylabel'), 'String', y_str,'FontWeight','bold','FontSize',16,'Color', [0.6 0 .95]);
title_str = sprintf('G4 simulation histograms\n normalized to peak, with stopping power');
title(title_str)
set(ax(1),'FontSize',16,'FontWeight','bold','xscale','log')
set(ax(2),'FontSize',16,'FontWeight','bold','xscale','log','YColor',[0 0 0])
box on; grid on;