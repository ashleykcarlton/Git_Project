% combineEnergies.m
close all; clear all; clc;

% Simulation parameters
energy = [10,50];%,100,200]; % Simulation energy in MeV
num_particles = 1E9; % Number of electrons in each simulation
num_simulations = [10,10];%,9,2]; % Number of simulations to process


% File locations
codeHome = '/Users/acarlton/Dropbox (MIT)/Git_Project/';
cd(codeHome);

% Histogram parameters
bin_width = 0.1; % keV
aboveE = 3; % keV, normalization should occur at the max after this value

% Reporting parameters
verbose = 1; % Plots generated if verbose==1
recombine = 0; % Trimmed raw files are combined and saved
% saveFit = 0; % Save the fit parameters

for ii=1:length(energy)
    
    energy_str = [num2str(energy(ii),'%02.0f'),'MeV'];
    dataDir = [codeHome,'Data/Geant4_simulations/run_mono/',energy_str];
    putfile = [dataDir,'/processed/',energy_str,'_',num2str(num_simulations(ii)),'runs.mat'];
    fitfile = [dataDir,'/processed/fitParams_',energy_str,'_',num2str(num_simulations(ii)),'.mat'];
    
    if ~exist(putfile,'file')||~exist(fitfile,'file')||recombine
        combineSims(energy(ii),num_simulations(ii))
        % Make histogram and normalize to 1
        % If there are no pixels with energy deposited, the script will exit
        [N, N_norm, edges] = makeHistogram(bin_width,energy(ii),num_simulations(ii),num_particles,verbose);
        
        % Fit a curve to the histogram
        [fitresult, gof] = createFit(edges, N_norm, energy(ii), verbose);
        save(fitfile,'fitresult','N','edges','gof')
    else
        load(putfile)
        load(fitfile)
    end
    E_tot_array_noZeros = simEnergyCombined.Edep_all_array(simEnergyCombined.Edep_all_array~=0);
    histresults(ii).E_tot_array_noZeros = E_tot_array_noZeros;
    histresults(ii).N = N;
    histresults(ii).edges = edges;
    fitresults(ii).fit = fitresult(edges);
    fitresults(ii).edges = edges;
    fitresults(ii).gof = gof;
end

% Plot fitted curves
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
axes1.FontSize = 18;
grid on; box on;

% Plot fitted curves -- zoomed in (<50 keV)
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for jj=1:length(energy)
    displayName = strcat(num2str(num_simulations(jj)),' sims of ',num2str(energy(jj)),' MeV');
    plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName)
end
legend(axes1,'show');
xlim(axes1,[0 50])
xlabel(axes1,'Energy Deposited [keV]')
ylim(axes1,[0 1])
ylabel(axes1,'Normalized Number of Pixels')
axes1.FontSize = 18;
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