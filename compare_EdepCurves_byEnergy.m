% combineEnergies.m
close all; clear all; clc;

% Simulation parameters
energy = [10,50,100,200]; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = [10,10,9,2]; % Number of simulations to process


% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);

% Histogram parameters
bin_width = 0.1; % keV
aboveE = 3; % keV, normalization should occur at the max after this value

% Reporting parameters
verbose = 1; % Plots generated if verbose==1
recombine = 1; % Trimmed raw files are combined and saved
saveFit = 0; % Save the fit parameters

for ii=1:length(energy)
    
    energy_str = [num2str(energy(ii),'%02.0f'),'MeV'];
    dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',energy_str];
    putfile = [dataDir,'/processed/',energy_str,'_',num2str(num_simulations(ii)),'runs.mat'];
    fitfile = [dataDir,'/processed/fitParams_',energy_str,'_',num2str(num_simulations(ii)),'.mat'];
    
    if ~exist(putfile,'file')||~exist(fitfile,'file')||recombine
        combineSims(energy(ii),num_simulations(ii))
        % Make histogram and normalize to 1
        % If there are no pixels with energy deposited, the script will exit
        [N, N_norm, ~,~,edges] = makeHistogram(bin_width,energy(ii),num_simulations(ii),num_particles,verbose);
        
        % Fit a curve to the histogram
%         [fitresult, gof] = createFit(edges, N_norm, energy(ii),1);
        ft = fittype('gauss2');
        [fitresult, gof] = fit(edges', N_norm', ft);
        preds = confint(fitresult);

        %         preds = predint(fitresult,edges,N_norm,0.95,'observation','on');
        
        if saveFit==1; save(fitfile,'fitresult','N','edges','gof'); end;
    end
    load(putfile)
    load(fitfile)
    edges = 0:0.1:2E5;
    E_tot_array_noZeros = simEnergyCombined.Edep_all_array(simEnergyCombined.Edep_all_array~=0);
    histresults(ii).E_tot_array_noZeros = E_tot_array_noZeros;
    histresults(ii).N = N;
    histresults(ii).N_norm = N_norm;
    histresults(ii).edges = edges;
    fitresults(ii).fit = fitresult(edges);
    fitresults(ii).edges = edges;
    fitresults(ii).gof = gof;
    fitresults(ii).pred = preds;
    
    min_edge_range(ii) = length(histresults(ii).N);

    % Normalization
%     histresults(ii).N_norm = N/max(N);
%     histresults(ii).N_norm_greater3keV = N/(max(N(aboveE/bin_width:end)));
%     histresults(ii).edges_greater3keV = histresults(ii).edges(aboveE/bin_width:end);
%     [fitresult_3keV,gof_3keV] = createFit(histresults(ii).edges(1+aboveE/bin_width:end),...
%         histresults(ii).N_norm_greater3keV(1+aboveE/bin_width:end),energy(ii),0);
%     fitresults(ii).fitresult_3keV = fitresult_3keV;
%     fitresults(ii).gof_3keV = gof_3keV;
%     fitresults(ii).fit_3keV = fitresult_3keV(histresults(ii).edges(1+aboveE/bin_width:end));
end

% Plot fitted curves -- normalized
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for jj=1:length(energy)
    displayName = strcat(num2str(num_simulations(jj)),' sims of ',num2str(energy(jj)),' MeV');
    plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName)
end
legend(axes1,'show');
xlim(axes1,[0 400])
xlabel(axes1,'Energy Deposited [keV]')
ylim(axes1,[0 1])
ylabel(axes1,'Normalized Number of Pixels')
title('Fitted Curves of Mono-energ. Sims')
axes1.FontSize = 18;
axes1.FontWeight = 'bold';
grid on; box on;

% Plot fitted curves -- normalized, zoomed in (<50 keV)
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for jj=1:length(energy)
    displayName = strcat(num2str(num_simulations(jj)),' sims of ',num2str(energy(jj)),' MeV');
    plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName,'LineWidth',1.0)
end
legend(axes1,'show');
xlim(axes1,[0 50])
xlabel(axes1,'Energy Deposited [keV]')
ylim(axes1,[0 1])
ylabel(axes1,'Normalized Number of Pixels')
title('Fitted Curves of Mono-energ. Sims -- Normalized to Peak')
axes1.FontSize = 18;
axes1.FontWeight = 'bold';
grid on; box on;


% % Plot fitted curves -- normalized, zoomed in (<50 keV), with 95% confint
% figure('Color',[1 1 1]); jj=1;
% plot(fitresults(jj).edges,histresults(jj).N_norm)
% hold on
% plot(fitresults(jj).edges,fitresults(jj).pred(1,:),'m--')

% figure1 = figure('Color',[1 1 1]);
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% for jj=1:length(energy)
%     displayName = strcat(num2str(num_simulations(jj)),' sims of ',num2str(energy(jj)),' MeV');
%     plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName,'LineWidth',1.0)
% end
% legend(axes1,'show');
% xlim(axes1,[0 50])
% xlabel(axes1,'Energy Deposited [keV]')
% ylim(axes1,[0 1])
% ylabel(axes1,'Normalized Number of Pixels')
% title('Fitted Curves of Mono-energ. Sims -- Normalized to Peak')
% axes1.FontSize = 18;
% axes1.FontWeight = 'bold';
% grid on; box on;


% % Plot fitted curves -- normalized to >3 keV, zoomed in (<50 keV)
% figure1 = figure('Color',[1 1 1]);
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% for jj=1:length(energy)
%     displayName = strcat(num2str(num_simulations(jj)),' sims of ',num2str(energy(jj)),' MeV');
%     plot(histresults(jj).edges(1+aboveE/bin_width:end),fitresults(jj).fit_3keV,...
%         'DisplayName',displayName,'LineWidth',1.0)
% end
% legend(axes1,'show');
% xlim(axes1,[0 50])
% xlabel(axes1,'Energy Deposited [keV]')
% ylim(axes1,[0 1])
% ylabel(axes1,'Normalized Number of Pixels')
% title('Fitted Curves of Mono-energ. Sims -- Normalized to Peak >3 keV')
% axes1.FontSize = 18;
% axes1.FontWeight = 'bold';
% grid on; box on;

% % Plot histograms -- not normalized
% figure('Color',[1 1 1])
% histogram(histresults(2).E_tot_array_noZeros,histresults(2).edges,'EdgeColor','none')
% hold on
% histogram(histresults(1).E_tot_array_noZeros,histresults(1).edges,'EdgeColor','none')
% xlabel('Energy Deposited [keV]')
% ylabel('Number of Pixels')
% legend('50 MeV', '10 MeV')
% title_str = sprintf('G4 simulation of Energy Deposited on Galileo SSI');
% title(title_str)
% set(gca,'FontSize',16,'FontWeight','bold')
% grid on; box on;
% xlim([0 50])

cmap = colormap('parula');
cmap_inds = 1:floor(length(cmap)/length(energy)):length(cmap);
% EDGES = histresults(kk).edges(1:min(min_edge_range));
figure1 = figure('Color',[1 1 1]);
% Plot histograms -- normalized
subplot(2,1,1)
hold on;
for kk = 1:length(energy)
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges(1:min(min_edge_range)),histresults(kk).N_norm(1:min(min_edge_range)),'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 50])
xlabel('Energy Deposited [keV]')
ylim([0 1])
ylabel('Number of Pixels')
title_str = sprintf('G4 simulation histograms - normalized to peak');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;

% Plot histograms -- normalized to peak greater than 3 keV
subplot(2,1,2)
hold on;
for kk = length(energy):-1:1
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges(1:min(min_edge_range)),histresults(kk).N_norm_greater3keV(1:min(min_edge_range)),'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 50])
xlabel('Energy Deposited [keV]')
ylim([0 1])
ylabel('Number of Pixels')
title_str = sprintf('G4 simulation histograms - normalized to peak >3 keV');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;


figure1 = figure('Color',[1 1 1]);
% Plot histograms -- normalized
subplot(2,1,1)
hold on;
for kk = length(energy):-1:1
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges(1:min(min_edge_range)),histresults(kk).N_norm(1:min(min_edge_range)),'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 20])
xlabel('Energy Deposited [keV]')
ylim([0 1])
ylabel('Number of Pixels')
title_str = sprintf('G4 simulation histograms - normalized to peak');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;

% Plot histograms -- normalized to peak greater than 3 keV
subplot(2,1,2)
hold on;
for kk = length(energy):-1:1
    displayName = strcat(num2str(num_simulations(kk)),' sims of ',num2str(energy(kk)),' MeV');
    bar(histresults(kk).edges(1:min(min_edge_range)),histresults(kk).N_norm_greater3keV(1:min(min_edge_range)),'FaceAlpha',0.75,...
        'FaceColor',cmap(cmap_inds(kk),:),'BarWidth',1,'EdgeColor','none','DisplayName',displayName)
end
legend(gca,'show');
xlim([0 20])
xlabel('Energy Deposited [keV]')
ylim([0 1])
ylabel('Number of Pixels')
title_str = sprintf('G4 simulation histograms - normalized to peak >3 keV');
title(title_str)
set(gca,'FontSize',18,'FontWeight','bold');
grid on; box on;

% minLen = length(fitresults(1).fit);
% for kk = 2:length(energies)
%     if length(fitresults(kk).fit)<minLen
%         minLen = length(fitresults(kk).fit);
%     end
% end
% for mm = 1:length(energies)
%     XX(mm,:) = fitresults(mm).fit(1:minLen);
% end
% resid1 = XX(end,:) - XX(end-1,:);
% resid2 = XX(end,:) - XX(end-2,:);
%
% figure1 = figure('Color',[1 1 1]);
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% % displayName = strcat(num2str(
% plot(fitresults(1).edges(1:minLen),resid1)%,'DisplayName',displayName)
% plot(fitresults(1).edges(1:minLen),resid2)%,'DisplayName',displayName)
% % legend(axes1,'show');
% % xlim(axes1,[0 50])
% % ylim(axes1,[0 1])
% axes1.FontSize = 18;
% grid on;
