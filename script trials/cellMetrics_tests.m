%%% created by RB on 04.03.2021
%%% checks correlation between cell type and thetaModulation Indes and
%%% burst Index

figure;
scatter(cellMetrics.troughPeakTime, cellMetrics.peakAsymmetry)
figure;
scatter(cellMetrics.troughPeakTime, cellMetrics.acg_metrics.thetaModulationIndex)
figure;
scatter(cellMetrics.troughPeakTime, cellMetrics.acg_metrics.burstIndex_Royer2012)
figure;
scatter(cellMetrics.troughPeakTime, cellMetrics.acg_metrics.burstIndex_Doublets)

%%
codes = spikeClusterData.goodCodes;
putativeCellType = cellMetrics.putativeCellType;
inh = strcmp(putativeCellType, 'interneuron'); % interneuron codes index
winh = strcmp(putativeCellType, 'wide_interneuron'); % wide interneuron codes index
pyr = strcmp(putativeCellType, 'pyramidal'); % wide interneuron codes index

codesColor_pCT = repmat([1 0 0], numel(codes),1);% red
codesColor_pCT(winh,:) = repmat([0 0 1], sum(winh),1); % blue
codesColor_pCT(pyr,:) = repmat([0 1 0], sum(pyr),1); % green

figure;
scatter(cellMetrics.troughPeakTime(inh), cellMetrics.acg_metrics.thetaModulationIndex(inh), 'r'); hold on
scatter(cellMetrics.troughPeakTime(winh), cellMetrics.acg_metrics.thetaModulationIndex(winh),'b');
scatter(cellMetrics.troughPeakTime(pyr), cellMetrics.acg_metrics.thetaModulationIndex(pyr), 'g');

figure;
scatter(cellMetrics.troughPeakTime(inh), cellMetrics.acg_metrics.burstIndex_Royer2012(inh), 'r'); hold on
scatter(cellMetrics.troughPeakTime(winh), cellMetrics.acg_metrics.burstIndex_Royer2012(winh),'b');
scatter(cellMetrics.troughPeakTime(pyr), cellMetrics.acg_metrics.burstIndex_Royer2012(pyr), 'g');

figure;
scatter(cellMetrics.troughPeakTime(inh), cellMetrics.acg_metrics.burstIndex_Doublets(inh), 'r'); hold on
scatter(cellMetrics.troughPeakTime(winh), cellMetrics.acg_metrics.burstIndex_Doublets(winh),'b');
scatter(cellMetrics.troughPeakTime(pyr), cellMetrics.acg_metrics.burstIndex_Doublets(pyr), 'g');