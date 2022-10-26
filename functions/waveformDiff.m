%%% Created by RB on 20.01.2022
%%% calculates the differential of each waveform and its value at 0.5 ms
%%% after the through


for unit = 1:size(cellMetricsAll.waveformFiltAvgNorm,1)
    % differential of the waveform
    cellMetricsAll.waveformFiltAvgNormDiff(unit,:) = diff(cellMetricsAll.waveformFiltAvgNorm(unit,:));
    % slope value at 0.5 ms after the trough
    cellMetricsAll.waveformFiltAvgNormDiff05(unit,:) = cellMetricsAll.waveformFiltAvgNormDiff(unit,30);% or 31 ?
end    

    