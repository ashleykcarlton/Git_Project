function combineSims(energy_MeV,num_sims)
 
dataDir = ['Data/Geant4_simulations/run_mono/',num2str(energy_MeV),'MeV/processed/'];
outputfile = [dataDir,num2str(energy_MeV),'MeV_all.mat'];

getFilenames = dir([dataDir,'*run*']);

for jj=1:num_sims
   load([dataDir,getFilenames(jj).name])
   total_tracks(jj) = simStats.num_tracks;
   total_nonzero_tracks(jj) = simStats.num_nonzero_tracks;
   total_unique_PIDs(jj) = simStats.num_unique_parentIDs;
   
   E_tot(:,:,jj) = E_tot_sim;
end

simStatsCombined.total_tracks = total_tracks;
simStatsCombined.total_nonzero_tracks = total_nonzero_tracks;
simStatsCombined.total_unique_parentIDs = total_unique_PIDs;

simEnergyCombined.Edep_eachSim = E_tot;
simEnergyCombined.Edep_all = sum(E_tot,3);
simEnergyCombined.Edep_all_aray = reshape(simEnergyCombined.Edep_all,length(simEnergyCombined.Edep_all)^2,1);

save(outputfile,'simStatsCombined','simEnergyCombined','num_sims','energy_MeV','num_sims')

end