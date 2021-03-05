function [signaltonoise] = snr(Data)
%SNR Summary of this function goes here
%   Detailed explanation goes here

responseData = squeeze(Data);

% rows are degrees, columns are trials

responseAverageAllTrial = mean(responseData,2);
responseAverageAllOri = mean(responseAverageAllTrial);
responseVar = var(responseData,0,2);

%SNR = sum((firing rate at ° averaged across all trials - mean firing rate
%across all orientations)^2) / sum(variance of the response at ° across trials)

signaltonoise = sum((responseAverageAllTrial - responseAverageAllOri).^2)/sum(responseVar);
end

