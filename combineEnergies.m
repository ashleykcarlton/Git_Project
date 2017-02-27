% combineEnergies.m

codeDir = 'Users/acarlton/Dropbox (MIT)/Git_Project';
energies = [10,50,100,200];
num_sims = [20,20,9,2];

for ii=1:length(energies)
    %     load(['fitParams_',num2str(energies(ii)),'MeV_',num2str(num_sims(ii)),'sims.mat'])
    load(['Data/Geant4_simulations/run_mono/',num2str(energies(ii)),'MeV/processed/fitParams_',num2str(energies(ii)),'MeV_',num2str(num_sims(ii)),'sims.mat'])
    fitresults(ii).fit = fitresult(edges);
    fitresults(ii).edges = edges;
    fitresults(ii).gof = gof;
end

figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for jj=1:length(energies)
    displayName = strcat(num2str(num_sims(jj)),' sims of ',num2str(energies(jj)),' MeV');
    plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName)
end
legend(axes1,'show');
xlim(axes1,[0 400])
ylim(axes1,[0 1])
axes1.FontSize = 18;
grid on;

figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for jj=1:length(energies)
    displayName = strcat(num2str(num_sims(jj)),' sims of ',num2str(energies(jj)),' MeV');
    plot(fitresults(jj).edges,fitresults(jj).fit,'DisplayName',displayName)
end
legend(axes1,'show');
xlim(axes1,[0 50])
ylim(axes1,[0 1])
axes1.FontSize = 18;
grid on;

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
