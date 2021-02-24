% orientation experiment analysis
clearvars -except experimentName sessionName


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data

% try to load structures if they don't already exist in the workspace
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
[cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);


savePath = basePathMatlab;
savePathFigs = fullfile(basePathMatlab, 'figs');
savePathGood = fullfile(savePathFigs, 'good');

saveFigs = false;
%%
% use amplByTrial % conds, codes, trials
% meanAmplByTrial = squeeze(nanmean(clusterTimeSeries.amplByTrial, 3));
meanAmplByTrial = squeeze(nanmean(amplByTrial, 3));
% % totalCodes = size(clusterTimeSeries.selectedCodes, 1);

totalConds = size(meanAmplByTrial, 1); % all good codes

totalCodes = size(meanAmplByTrial, 2);
m = ceil(sqrt(totalCodes));

titleColor = 'gr';
if exist('cellMetrics') 
    EItype = (cellMetrics.troughPeakTime<0.5) + 1;
else    
    EItype = ones(totalCodes, 1);
end    

%%
figure
for code = 1: totalCodes
    subplot(m,m,code, 'align');
    
%     plot((1:totalConds/2), meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), 'Color', 'k'); hold on
%     plot((1:totalConds/2), meanAmplByTrial(2:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), 'Color', 'b');  
    plot((1:totalConds/2), meanAmplByTrial(1:2:totalConds, code), 'Color', 'k'); hold on
    plot((1:totalConds/2), meanAmplByTrial(2:2:totalConds, code), 'Color', 'b');  
%     title(spikeClusterData.uniqueCodes(code,1));  
%     title(clusterTimeSeries.selectedCodes(code), 'Color', titleColor(EItype(clusterTimeSeries.selectedCodesInd(code)))); 
    title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code))); 
%     ylim([0 max(max(meanAmplByTrial))]);
%     xlabel('orientation (°)')
    xticks([(3:3:12)]);
    xticklabels({ '90', '180', '270', '360°'});
    ylabel('FR (Hz)')
end    
if saveFigs == true
    savefig(strcat(savePathGood,  filesep, 'tuningCurve_all.fig'));
end

%%
figure
for code = 1: totalCodes
    subplot(m,m,code, 'align');
    %     scatter(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), meanAmplByTrial(2:2:totalConds, clusterTimeSeries.selectedCodesInd(code))); hold on
    scatter(meanAmplByTrial(1:2:totalConds, code), meanAmplByTrial(2:2:totalConds, code)); hold on

%     fitline = fit(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), meanAmplByTrial(2:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), 'poly1');
    fitline = fit(meanAmplByTrial(1:2:totalConds, code), meanAmplByTrial(2:2:totalConds, code), 'poly1');

    plot(fitline);
    coeffs(code,:) = coeffvalues(fitline);
%     title(spikeClusterData.uniqueCodes(code,1));
%     title(clusterTimeSeries.selectedCodes(code), 'Color', titleColor(EItype(clusterTimeSeries.selectedCodesInd(code))));  
    title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code)));  
    legend off
    lim = max(max(meanAmplByTrial));
    text(lim*0.3, lim*0.95, [num2str(round(coeffs(code,1),2)),'*x + ',num2str(round(coeffs(code,2),2)) ] ,'FontSize',8, 'HorizontalAlignment','center');
    h1 = line([0 lim],[0 lim]); % diagonal line
    set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
    xlabel('');
    ylabel('');
end    
xlabel('FR no photostim. (Hz)');
ylabel('FR with photostim. (Hz)');
if saveFigs == true
    savefig(strcat(savePathGood,  filesep, 'fitTuningCurve_all.fig'));
end
%%
normMeanAmplByTrial = nan(totalConds, totalCodes);
for code = 1: totalCodes % normalize by the most selective orientation in non-ph conds
%     normMeanAmplByTrial(:,code) = meanAmplByTrial(:, clusterTimeSeries.selectedCodesInd(code)) / max(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)));
    normMeanAmplByTrial(:,code) = meanAmplByTrial(:, code) / max(meanAmplByTrial(1:2:totalConds, code));
end  

figure
for code = 1: totalCodes
    subplot(m,m,code, 'align');
    scatter(normMeanAmplByTrial(1:2:totalConds, code), normMeanAmplByTrial(2:2:totalConds, code)); hold on
    fitline = fit(normMeanAmplByTrial(1:2:totalConds, code), normMeanAmplByTrial(2:2:totalConds, code), 'poly1');
    plot(fitline);
    coeffs(code,:) = coeffvalues(fitline);
%     title(spikeClusterData.uniqueCodes(code,1));
    title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code)));  
    legend off
    lim = max(normMeanAmplByTrial(:, code));
    text(lim*0.3, lim*0.95, [num2str(round(coeffs(code,1),2)),'*x + ',num2str(round(coeffs(code,2),2)) ] ,'FontSize',8, 'HorizontalAlignment','center');
    h1 = line([0 lim],[0 lim]); % diagonal line
    set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
    xlabel('');
    ylabel('');
end   
xlabel('Norm. FR no photostim.');
ylabel('Norm. FR with photostim.');

if saveFigs == true
    savefig(strcat(savePathGood,  filesep, 'fitNormTuningCurve_all.fig'));
end