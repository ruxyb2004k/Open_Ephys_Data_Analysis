%% cluster based on only two features 
% Y = [cellMetricsAll.troughPeakTime(iUnitsFilt);cellMetricsAll.peakAsymmetry(iUnitsFilt)]';
Y = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry]';
k = 2;
[idx1,Centroids1] = kmeans(Y,k);% same as [idx1,Centroids1] = kmedoids(Y,k);

% [idx1,Centroids1] = spectralcluster(Y,k);
% GMModel = fitgmdist(Y,k);
% idx1 = dbscan(Y,1,5);
if Centroids1(1,1)< Centroids1(2,1) % exchange the units' label if attributed completely opposite
    Centroids1 = flipud(Centroids1);
    idx1 = abs(idx1-3); % 1 becomes 2 and 2 becomes 1
end    
sum(idx1 == 1)
sum(idx1 == 2)

figure; 

scatter(Y(idx1 == 1,1),Y(idx1 == 1,2), 'g'); hold on
scatter(Y(idx1 == 2,1),Y(idx1 == 2,2), 'r'); hold on

xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');

classUnitsAll= idx1';