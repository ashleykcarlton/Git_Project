% expectedParticles.m
% Last modified: 08 March 2017, A. Carlton
%
% flux_data Matlab array:
%       Column 1: RJ
%       Column 2: 1 MeV differential flux [(cm2-s-sr-keV)^-1]
%       Column 3: 5 MeV differential flux [(cm2-s-sr-keV)^-1]
%       Column 4: 10 MeV differential flux [(cm2-s-sr-keV)^-1]
%       Column 5: 20 MeV differential flux [(cm2-s-sr-keV)^-1]
%       Column 6: 40 MeV differential flux [(cm2-s-sr-keV)^-1]
%

clear all;
close all;
clc;

%% INPUT PARAMETERS
readoutTime = 6+2/3; % s
exposureTime = 45.83E-3; % s
Rj_selected = 6; % Rj
L_selected = 6; % L-shell
energies = 40:10:100; % MeV
numParticlesSimulated = 1E9;
simSphereRadius = 150; % cm
sensitiveArea = 1.219*1.219; % cm^2
sterCorrect = 4*pi; 
imageTime = readoutTime+exposureTime; % s

% Spectral fitting parameters from De Soria-Santacruz et al., 2016
fittingParams.Lshell = [8.75 11.75 14.75 17.75 20.75 23.75 26.75]; % VIP4
fittingParams.J_0 = [3.06E3 3.01E3 4.82E2 86.5 87.2 18.1 17.5]; % [cm2-s-sr-keV]^-1
fittingParams.A = [1.52 1.62 2.47 2.61 2.08 2.45 2.40];
fittingParams.B = [1.76 2.19 3.51 9.1 2.85 1.14 6.79];
fittingParams.E_0 = [10.3 3.67 25.9 118 7.58 150 77.2]; % MeV

%% LOAD DATA
codeDirectory = '/Users/acarlton/Dropbox (MIT)/NASA JPL/Galileo SSI/MatLab/';
path2Data = '/Users/acarlton/Dropbox (MIT)/NASA JPL/Galileo SSI/Data/';

load([path2Data,'GIRE2_diff_vs_Rj.mat']);
Rj = flux_diff(:,1);
Diff_Flux = flux_diff(:,2:6);
Energy_Labels = {'1 MeV','5 MeV','10 MeV','20 MeV','40 MeV'};

%% ANALYZE
% Find closest index to the Rj_selected
[~,ind] = min(abs(Rj_selected-Rj));
diffEnergies_GIRE2 = [1,5,10,20,40];
diffFluxes_GIRE2 = Diff_Flux(ind,:);

% Interpolate and calculate the integral flux at the requested energy
f = 10.^interp1(log10(diffEnergies_GIRE2),log10(diffFluxes_GIRE2),log10(energies),'pchip','extrap');
% [(cm2-s-sr-keV)^-1]

binSize = [diff(energies) 0];
fprintf('Energy [MeV],Elec. Diff. Flux [(cm2-s-sr-MeV)^-1]\n');
for ii=1:length(energies)
    fprintf('%s,%.6f\n',[num2str(energies(ii)),' MeV'],f(ii)*1000);
    bin_estimate(ii) = f(ii)*1000*binSize(ii); % e-/cm2-sr-s
end
numParticles_rough = sum(bin_estimate)*4*pi*simSphereRadius^2*sterCorrect; % e-/s
scaleFactor_rough = numParticles_rough/numParticlesSimulated;

% Rough estimate of particles from integrating the differential spectrum
%numParticlespersec_rough = 

% Integrate to find number of particles expected. Determine scale factor
% for how much the 1e9 particle simulations need to be scaled up.
% Find closest index to the L_selected
[~,ind_L] = min(abs(L_selected-fittingParams.Lshell));
E_0 = fittingParams.E_0(ind_L); % MeV
A = fittingParams.A(ind_L);
B = fittingParams.B(ind_L);
J_0 = fittingParams.J_0(ind_L); % (cm2-s-sr-keV)^-1
fprintf('\nIntegrating the differential spectra function...\n'); % From Hank
fprintf('Evaluating at L-shell: %.2f... found fitting parameters.\n',fittingParams.Lshell(ind_L));

diffFunc = @(ENG) J_0*(ENG.^(-A)).*(1+(ENG/E_0)).^(-B);  
numParticles = integral(diffFunc,energies(1),energies(end))*4*pi*simSphereRadius^2*4*pi*1000; % #/s

%% PLOT
scrsz = get(groot,'ScreenSize');
figure('Color','white','NumberTitle','off','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
scatter(log10(diffEnergies_GIRE2),log10(diffFluxes_GIRE2),'*','LineWidth',2)
hold on
scatter(log10(energies),log10(f),'LineWidth',2)
xlabel('Log10 Energy Channel [MeV]')
ylabel('Log10 Differential Flux [(cm2-s-keV)^-1]')
legend('GIRE-2 values','Interpolated values')
grid on
box on
set(gca,'FontSize',16,'FontWeight','bold')