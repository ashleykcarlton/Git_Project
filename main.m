clear all; close all; clc;

setParams;

% Import all simulation textfiles for a particular energy, save processed
% data
% (or skip because the .mat files that have already been made from a previous run)
processed_files = dir([dataDir,'processed/*run*.mat']);
if length(processed_files)>=num_simulations
    fprintf('%d processed mat files already exist for %d MeV.\nSkipping raw textfile import.\n',num_simulations,energy)
else
    trimmed_textfiles = dir([dataDir,'raw/*_trimmed.out']);
    if length(trimmed_textfiles) < num_simulations
        error('Number of simulations requested is greater than the number of textfiles available! Make sure the text files are trimmed.')
    end
    for ii = 1:length(trimmed_textfiles)
        getFilename = strsplit(trimmed_textfiles(ii).name,'_trimmed.out');
        import_G4sim_textfile([dataDir,'/raw/',trimmed_textfiles(ii).name],...
            [dataDir,'processed/',getFilename{1},'.mat'],...
            energy,num_particles);
    end
end

% Combine all simulations and save the total energy accumulated on the CCD,
% make histograms of energy deposition
% if length(processed_files)==num_simulations
%     outputfile = [dataDir,'processed/',energy_str,'_all.mat'];
% else
    outputfile = [dataDir,'processed/',energy_str,'_',num2str(num_simulations),'runs.mat'];
% end

if ~exist(outputfile,'file')||recombine
    combineSims(energy,num_simulations)
else
    fprintf('Combined file already exists. Skipping simulation combination script.\n')
end

% Make histogram and normalize to 1
% If there are no pixels with energy deposited, the script will exit
[N, N_norm, edges] = makeHistogram(bin_width,energy,num_simulations,num_particles,verbose);

% Fit a curve to the histogram
[fitresult, gof] = createFit(edges, N_norm, energy, verbose);
% save fitParams_100MeV_9sims.mat fitresult N edges gof