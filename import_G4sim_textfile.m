function import_G4sim_textfile(inputfile,outputfile,energy_MeV,num_particles_sim)

% EXAMPLE:
%    import_G4sim_textfile('Data/Geant4_simulations/run_mono/50MeV/raw/50MeV_run01_trimmed.out','Data/Geant4_simulations/run_mono/50MeV/processed/50MeV_run01.mat',50)

currentDir = pwd;
% input_data_dir = '/Data/Geant4_simulations/raw/run_mono/';
% output_data_dir = '/Data/Geant4_simulations/processed/run_mono/';
[inputfile_dir,filename,ext] = fileparts(inputfile);
[outputfile_dir,~,~] = fileparts(outputfile);

fid = fopen([outputfile_dir,'/processing_summary.log'],'a+');
if fid == -1
    error('Author:Function:OpenFile', 'Cannot open file: %s', inputfile);
end
fprintf(fid,'\n===========================\n%s\n\n',datestr(now));
fprintf(fid,'Running import_G4sim_textfile.m\n');
fprintf(fid,'Loading %s .....',[filename,ext]);


%% Load and read information from textfile
formatSpec = '%d %d %s %d %f %f %f %f %f %f %f %f %f %s %d %d %d %s %[^\n\r]';
delimiter = ' ';
% Load in file
fileID = fopen(inputfile);
if fileID == -1
    error('Author:Function:OpenFile', 'Cannot open file: %s', inputfile);
end
G4_output = textscan(fileID,formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,'ReturnOnError', false);
fclose(fileID);
fprintf(fid,'done.\n');

simInfo.EventID = G4_output{:, 1};
simInfo.ParentID = G4_output{:, 2};
simInfo.ParticleName = G4_output{:, 3};
simInfo.StepNumber = G4_output{:, 4};
simInfo.xDetector = G4_output{:, 5}; %[mm]
simInfo.yDetector = G4_output{:, 6}; %[mm]
simInfo.zDetector = G4_output{:, 7}; %[mm]
simInfo.KineticEnergy = G4_output{:, 8}; %[keV]
simInfo.EnergyDeposited = G4_output{:, 9}; %[keV]
simInfo.StepLength = G4_output{:, 10}; %[um]
simInfo.ThetaSource = G4_output{:, 11}; %[deg]
simInfo.PhiSource = G4_output{:, 12}; %[deg]
simInfo.TrackLength = G4_output{:, 13}; %[um]
simInfo.PhysicsProcess = G4_output{:, 14};
simInfo.PixelRow = G4_output{:, 15};
simInfo.PixelColumn = G4_output{:, 16};
simInfo.ParentEnergy = G4_output{:, 17};
simInfo.Detector = G4_output{:, 18};

% For each of the tracks from the simulation, if the energy deposited
% isn't zero, record it as an energy_track and save the index of that
% line to an array (k_array)
fprintf(fid,'Calculating tracks with energy deposited.\n');
E_tot_sim = zeros(800,800);
energy_hits_counter = 0;
k_array = [];
fprintf(fid,'Calculating total energy deposited.\n\n');
for kk=1:length(simInfo.EnergyDeposited)
    if simInfo.EnergyDeposited(kk)~=0
        % fprintf('Energy deposited: %f keV at PixelRow %d and PixelColumn %d\n',EnergyDeposited{jj}(kk),PixelRow(kk)+1,PixelColumn(kk)+1);
        energy_hits_counter = energy_hits_counter+1;
        k_array = [k_array kk];
    end
    % Sum up counts and energy deposited in each pixel (pixel indexing is 0
    % to 799, so add one to each for storage in the matrix    
    E_tot_sim(simInfo.PixelRow(kk)+1,simInfo.PixelColumn(kk)+1) =  E_tot_sim(simInfo.PixelRow(kk)+1,simInfo.PixelColumn(kk)+1) + simInfo.EnergyDeposited(kk);
end
simStats.num_tracks = length(simInfo.EventID);
simStats.num_nonzero_tracks = length(k_array);
simStats.num_unique_parentIDs = length(unique(simInfo.ParentID));

fprintf(fid,'Total tracks in simulation: %d\n',simStats.num_tracks);
fprintf(fid,'Total non-zero tracks in simulation: %d\n',simStats.num_nonzero_tracks);
fprintf(fid,'Number of unique parent IDs: %d\n',simStats.num_unique_parentIDs);

fclose(fid);

% clear G4_output fileID formatSpec delimiter currentDir
save(outputfile,'simInfo','energy_MeV','simStats','E_tot_sim','num_particles_sim')

end
