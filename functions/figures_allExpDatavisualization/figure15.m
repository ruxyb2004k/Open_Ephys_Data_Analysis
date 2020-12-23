%%% created by RB on 23.12.2020

% Fig 15 - waveform figures

titleFig15 = {'All waveforms', 'Normalized waveforms', 'Ratio vs time','Time vs peak asymmetry', '3D plot'};
saveFig15 = {'allWaveforms.fig', 'normAllWaveforms.fig', 'ratioVsTime.fig', 'timeVsPeakAsym.fig', '3Dplot.fig'};

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
figure; 
for unit = find(iUnitsFilt)
%     plot(cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', C_units(unit,:)); hold on
    plot(((0:size(cellMetricsAll.waveformFiltAvgNorm,2)-1)/20), cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', EIColor(classUnitsAll(unit))); hold on
end
xlabel('Time (ms)')
% ylim([-1,1.52])
ylim([-1,1.5])
title(titleFig15{2},'FontSize',18);
box off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{2}));
    saveas(gcf, strcat(savePath, saveFig15{2}(1:end-3), 'png'));
end


% 
% % Fig. 15c: plot ratio vs time
% figure;
% for unit = find(iUnitsFilt)
%     if classUnitsAll(unit) == 1
%         plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
%     elseif classUnitsAll(unit) == 2
%         plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
%     end
%     text(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
% end
% xlabel('peak : trough ratio'); 
% ylabel('trough to peak (ms)');
% title(titleFig15{3},'FontSize',18);
% if saveFigs == true
%     savefig(strcat(savePath, saveFig15{3}));
% end
% 

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
%     print('-painters', '-depsc')% save file as vector image
end

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
