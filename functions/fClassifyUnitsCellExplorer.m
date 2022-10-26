%% classification based on cell explorer (Peter Petersen) 

% consider interneurons and wide_interneurons as one group
classUnitsAll = [strcmp(cellMetricsAll.putativeCellType, 'pyramidal') + strcmp(cellMetricsAll.putativeCellType, 'interneuron')*2 + ...
    strcmp(cellMetricsAll.putativeCellType, 'wide_interneuron')*2]';


% consider interneurons and wide_interneurons as 2 groups
% classUnitsAll = [strcmp(cellMetricsAll.putativeCellType, 'pyramidal') + strcmp(cellMetricsAll.putativeCellType, 'interneuron')*2 + ...
%     strcmp(cellMetricsAll.putativeCellType, 'wide_interneuron')*3]';


Y = [cellMetricsAll.troughPeakTime;cellMetricsAll.peakAsymmetry]';

figure; 

scatter(Y(classUnitsAll == 1,1),Y(classUnitsAll == 1,2), 'g'); hold on
scatter(Y(classUnitsAll == 2,1),Y(classUnitsAll == 2,2), 'r'); hold on
scatter(Y(classUnitsAll == 3,1),Y(classUnitsAll == 3,2), 'b'); hold on

xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');