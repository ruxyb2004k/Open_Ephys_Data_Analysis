%%% created by RB on 23.12.2020

% Fig 15 - waveform figures

titleFig15 = {'All waveforms', 'Normalized waveforms', 'Ratio vs time',...
    'Time vs peak asymmetry', '3D plot', 'Differential of Normalized waveforms',...
    'Time vs Slope at 0.5 ms', 'Peak Assymetry vs Slope at 0.5 ms',...
    'Peak trough ratio vs Slope at 0.5 ms', 'Ratio vs peak assymetry'};
saveFig15 = {'allWaveforms.fig', 'normAllWaveforms.fig', 'ratioVsTime.fig',...
    'timeVsPeakAsym.fig', '3Dplot.fig', 'normAllWaveformsDiff.fig',...
    'timeVsSlope05.fig','peakAsymVsSlope05.fig','peakTroughRatioVsSlope05.fig',...
    'ratioVsPeakAsym'};

% Fig. 15a: plot all waveforms
% figure; 
% for unit = find(iUnitsFilt)
%     plot(cellMetricsAll.waveformFiltAvg(unit,:), 'Color', C_units(unit,:)); hold on
% end   
% title(titleFig15{1},'FontSize',18);
% if saveFigs == true
%     savefig(strcat(savePath, saveFig15{1}));
% end

% Fig. 15b: normalized waveforms to trough = -1

pos = find(iUnitsFilt);
randIdx = randperm(length(pos),150);
iUnitsFiltRand = zeros(size(iUnitsFilt));
iUnitsFiltRand(pos(randIdx)) = 1 & iUnitsFilt(pos(randIdx));
 
figure; 
for unit = find(iUnitsFiltRand)
%     plot(cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', C_units(unit,:)); hold on
%     plot(((-20:size(cellMetricsAll.waveformFiltAvgNorm,2)-21)/20), cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', EIColor(classUnitsAll(unit))); hold on
    plot(((-20:size(cellMetricsAll.waveformFiltAvgNorm,2)-21)/20), cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', EI_Color(classUnitsAll(unit),:)); hold on

end
meanExcWf = nanmean(cellMetricsAll.waveformFiltAvgNorm(classUnitsAll ==1,:));
meanInhWf = nanmean(cellMetricsAll.waveformFiltAvgNorm(classUnitsAll ==2,:));
plot(((-20:size(cellMetricsAll.waveformFiltAvgNorm,2)-21)/20), meanExcWf, 'Color', EIColor(1), 'LineWidth', 3); hold on
plot(((-20:size(cellMetricsAll.waveformFiltAvgNorm,2)-21)/20), meanInhWf, 'Color', EIColor(2), 'LineWidth', 3); hold on
xlabel('Time (ms)')
ylabel('Normalized voltage');
xticks([-1, -0.5, 0, 0.5, 1])
% ylim([-1,1.52])
ylim([-1,1.5])

% title(titleFig15{2},'FontSize',18);
set(gca, 'FontSize',fs)
box off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{2}));
    saveas(gcf, strcat(savePath, saveFig15{2}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig15{2}(1:end-4)), 'epsc');
end


%% 
% % Fig. 15c: plot ratio vs time
figure;
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end
%     text(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
end
xlabel('peak : trough ratio'); 
ylabel('trough to peak (ms)');
title(titleFig15{3},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{3}));
    saveas(gcf, strcat(savePath, saveFig15{3}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{3}(1:end-4)), 'epsc');% works, but file is not saved as vector
end

%%
% Fig. 15d: plot time vs peak asymmetry
figure; 
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1 % excitatory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2 % inhibitory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end    
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on   
end
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');
title(titleFig15{4},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{4}));
    saveas(gcf, strcat(savePath, saveFig15{4}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{4}(1:end-4)), 'epsc');% works, but file is not saved as vector
%     print('-painters', '-depsc')% save file as vector image
end
%%
% Fig. 15e: 3D plot time vs ratio vs peak asymmetry
figure; 
scatter3(cellMetricsAll.troughPeakTime(classUnitsAll ==1),  cellMetricsAll.peakTroughRatio(classUnitsAll ==1), cellMetricsAll.peakAsymmetry(classUnitsAll ==1), '^'); hold on
scatter3(cellMetricsAll.troughPeakTime(classUnitsAll ==2),  cellMetricsAll.peakTroughRatio(classUnitsAll ==2), cellMetricsAll.peakAsymmetry(classUnitsAll ==2), 'o'); hold on
% for unit = 1:totalUnits
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',10, 'HorizontalAlignment','center'); hold on   
% end
xlabel('trough to peak (ms)'); 
ylabel('peak : trough ratio');
zlabel('peak asymmetry (P2-P1)/(P2+P1)');
title(titleFig15{5},'FontSize',18);
grid off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{5}));
end
%%
% Fig. 15f: differentials of the normalized waveforms to trough = -1

pos = find(iUnitsFilt);
randIdx = randperm(length(pos),150);
iUnitsFiltRand = zeros(size(iUnitsFilt));
iUnitsFiltRand(pos(randIdx)) = 1 & iUnitsFilt(pos(randIdx));
 
figure; 
for unit = find(iUnitsFiltRand)
    plot(((-20:size(cellMetricsAll.waveformFiltAvgNormDiff,2)-21)/20), cellMetricsAll.waveformFiltAvgNormDiff(unit,:), 'Color', EI_Color(classUnitsAll(unit),:)); hold on
end
meanExcWfDiff = nanmean(cellMetricsAll.waveformFiltAvgNormDiff(classUnitsAll ==1,:));
meanInhWfDiff = nanmean(cellMetricsAll.waveformFiltAvgNormDiff(classUnitsAll ==2,:));
plot(((-20:size(cellMetricsAll.waveformFiltAvgNormDiff,2)-21)/20), meanExcWfDiff, 'Color', EIColor(1), 'LineWidth', 3); hold on
plot(((-20:size(cellMetricsAll.waveformFiltAvgNormDiff,2)-21)/20), meanInhWfDiff, 'Color', EIColor(2), 'LineWidth', 3); hold on
xlabel('Time (ms)')
ylabel('DIff Normalized voltage');
xticks([-1, -0.5, 0, 0.5, 1])
% ylim([-1,1.52])
ylim([-1,1.5])

% title(titleFig15{2},'FontSize',18);
set(gca, 'FontSize',fs)
box off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{6}));
    saveas(gcf, strcat(savePath, saveFig15{6}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig15{6}(1:end-4)), 'epsc');
end

%%

% Fig. 15g: plot time vs slope 
figure; 
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1 % excitatory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2 % inhibitory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end    
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on   
end
xlabel('trough to peak (ms)'); 
ylabel('slope');
title(titleFig15{7},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{7}));
    saveas(gcf, strcat(savePath, saveFig15{7}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{7}(1:end-4)), 'epsc');% works, but file is not saved as vector
end

%%

% Fig. 15h: plot peak asymmetry vs slope 
figure; 
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1 % excitatory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.peakAsymmetry(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2 % inhibitory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.peakAsymmetry(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end    
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on   
end
xlabel('Peak Assymetry'); 
ylabel('Slope');
title(titleFig15{8},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{8}));
    saveas(gcf, strcat(savePath, saveFig15{8}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{8}(1:end-4)), 'epsc');% works, but file is not saved as vector
end

%%

% Fig. 15i: peak trough ratio vs slope 
figure; 
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1 % excitatory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2 % inhibitory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.waveformFiltAvgNormDiff05(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end    
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on   
end
xlabel('Peak trough ratio'); 
ylabel('Slope');
title(titleFig15{9},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{9}));
    saveas(gcf, strcat(savePath, saveFig15{9}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{9}(1:end-4)), 'epsc');% works, but file is not saved as vector
end

%%
% % Fig. 15j: plot ratio vs peak asymm
figure;
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2
        plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end
%     text(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
end
xlabel('peak : trough ratio'); 
ylabel('trough to peak (ms)');
title(titleFig15{10},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{10}));
    saveas(gcf, strcat(savePath, saveFig15{10}(1:end-3), 'png'));% works, but file is not saved as vector
    saveas(gcf, strcat(savePath, saveFig15{10}(1:end-4)), 'epsc');% works, but file is not saved as vector
end