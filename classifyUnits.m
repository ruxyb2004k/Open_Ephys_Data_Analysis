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

% classUnitsAll= idx;

%%% cluster units based on 3 properties
%%
% load('traceDataNexCre2aAll_long.mat')
% X = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry;cellMetricsAll.peakTroughRatio]';
X = [cellMetricsAll.waveformFiltAvgNormDiff05';cellMetricsAll.peakAsymmetry;cellMetricsAll.peakTroughRatio]';
k = 2;
[idx,Centroids] = kmeans(X,k);
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
ylabel('peak asymmetry');
zlabel('peak trough ratio');

% classUnitsAll= idx;

%% cluster based on only two features 
% similar to fig 15g
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.waveformFiltAvgNormDiff05(iUnitsFilt)']';

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
ylabel('slope');
% classUnitsAll= idx1';


%% cluster based on only two features 
% similar to fig 15h
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.peakAsymmetry(iUnitsFilt);cellMetricsAll.waveformFiltAvgNormDiff05(iUnitsFilt)']';

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
xlabel('peak asymmetry'); 
ylabel('slope');
% classUnitsAll= idx1';

%% cluster based on only two features 
% similar to fig 15i
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.peakTroughRatio(iUnitsFilt);cellMetricsAll.waveformFiltAvgNormDiff05(iUnitsFilt)']';

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
xlabel('peak trough ratio'); 
ylabel('slope');
% classUnitsAll= idx1';

%% cluster based on only two features 
% similar to fig 15d
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry]';

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
% classUnitsAll= idx1';
%% cluster based on only two features using the Birch algo
% similar to fig 15d
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry]';

k =2; % cluster no.
branching_factor=20;
threshold=0.01;
brc = Birch( threshold,branching_factor, k);
brc=brc.fit(Y);
idx1=brc.predict(Y);

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
% classUnitsAll= idx1';

%% cluster after PCA

Y = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry]';
[coeff,score,latent, ~, explained] = pca(Y);

k = 2;
[idx1,Centroids1] = kmeans(score,k);% same as [idx1,Centroids1] = kmedoids(Y,k);


sum(idx1 == 1)
sum(idx1 == 2)

figure; 
%scatter(score(:,1), score(:,2))
scatter(score(idx1 == 1,1),score(idx1 == 1,2), 'g'); hold on
scatter(score(idx1 == 2,1),score(idx1 == 2,2), 'r'); hold on
%scatter(Y(idx1 == 1,1),Y(idx1 == 1,2), 'g'); hold on
%scatter(Y(idx1 == 2,1),Y(idx1 == 2,2), 'r'); hold on

xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');
% classUnitsAll= idx1';

%% cluster based on only two features 
% similar to fig 15j
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.peakTroughRatio;cellMetricsAll.peakAsymmetry]';

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
xlabel('peak trough ratio'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');
% classUnitsAll= idx1';