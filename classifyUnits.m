%%% cluster units based on 3 properties

load('traceDataNexCre2aAll_long.mat')
X = [troughPeakTimeAll;peakTroughRatioAll;peakAsymmetryAll]';
k = 2;
[ix,Centroids] = kmeans(X,k);
sum(idx == 1) % excitatory
sum(idx == 2) % inhibitory


figure; 
% scatter3(troughPeakTimeAll,  peakTroughRatioAll, peakAsymmetryAll); hold on
scatter3(X(idx == 1,1),X(idx == 1,2),X(idx == 1,3), 'g'); hold on
scatter3(X(idx == 2,1),X(idx == 2,2),X(idx == 2,3), 'r'); hold on
% for unit = 1:totalUnits
%     text(troughPeakTimeAll(unit), peakTroughRatioAll(unit), peakAsymmetryAll(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',5, 'HorizontalAlignment','center'); hold on   
% end
xlabel('trough to peak (ms)'); 
ylabel('peak : trough ratio');
zlabel('peak asymmetry (P2-P1)/(P2+P1)');

classUnitsAll= idx;

%% cluster based on only two features 
Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
k = 2;
[idx1,Centroids1] = kmeans(Y,k);% same as [idx1,Centroids1] = kmedoids(Y,k);

% [idx1,Centroids1] = spectralcluster(Y,k);
% GMModel = fitgmdist(Y,k);
% idx1 = dbscan(Y,1,5);

sum(idx1 == 1)
sum(idx1 == 2)

figure; 
% scatter3(troughPeakTimeAll,  peakTroughRatioAll, peakAsymmetryAll); hold on
scatter(Y(idx1 == 1,1),Y(idx1 == 1,2), 'g'); hold on
scatter(Y(idx1 == 2,1),Y(idx1 == 2,2), 'r'); hold on
% for unit = 1:totalUnits
%     text(troughPeakTimeAll(unit), peakTroughRatioAll(unit), peakAsymmetryAll(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',5, 'HorizontalAlignment','center'); hold on   
% end
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');
