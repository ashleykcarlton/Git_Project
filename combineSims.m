function combineSims(energy_MeV,num_sims)

energy_str = [num2str(energy_MeV,'%02.0f'),'MeV'];
dataDir = ['Data/Geant4_simulations/run_mono/',energy_str,'/processed/'];

fid = fopen([dataDir,'/processing_summary.log'],'a+');
if fid == -1
    error('Author:Function:OpenFile', 'Cannot open file: %s', inputfile);
end
fprintf(fid,'\n===========================\n%s\n\n',datestr(now));
fprintf(fid,'Running combineSims.m\n');

getFilenames = dir([dataDir,'*_run*']);
% if length(getFilenames)==num_sims
%     outputfile = [dataDir,energy_str,'_all.mat'];
% else
    outputfile = [dataDir,energy_str,'_',num2str(num_sims),'runs.mat'];
% end
hitEnergy = [];
total_KE = [];
for jj=1:num_sims
   load([dataDir,getFilenames(jj).name])
   total_tracks(jj) = simStats.num_tracks;
   total_nonzero_tracks(jj) = simStats.num_nonzero_tracks;
   total_primaries(jj) = simStats.num_primaries;
   
   total_KE = [total_KE,simInfo.KineticEnergy'];
   hitEnergy = [hitEnergy,simInfo.EnergyDeposited'];
   E_tot(:,:,jj) = E_tot_sim;
end

simStatsCombined.total_tracks = sum(total_tracks);
simStatsCombined.total_nonzero_tracks = sum(total_nonzero_tracks);
simStatsCombined.total_primaries = sum(total_primaries);

simEnergyCombined.KE = total_KE;
simEnergyCombined.Edep_noMatrix = hitEnergy;
simEnergyCombined.Edep_eachSim = E_tot;
simEnergyCombined.Edep_all = sum(E_tot,3);
simEnergyCombined.Edep_all_array = reshape(simEnergyCombined.Edep_all,length(simEnergyCombined.Edep_all)^2,1);

fprintf(fid,'Total number of pixels with energy deposited: %d\n',...
    nnz(simEnergyCombined.Edep_all_array));
fclose(fid);

save(outputfile,'simStatsCombined','simEnergyCombined','num_sims','energy_MeV')

end