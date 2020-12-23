data_filt = zeros(channelNo, numel(range1));

for j = 1:channelNo    
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(j,:) = highpass(data(j,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz
end

clearvars data

m = max(max(max(data_filt)), -min(min(data_filt)));
disp(['Maximum value: ', num2str(round(m))]);
gain = suggestGain(m);
disp(['Suggested gain: ', num2str(gain)]);


% flat subset of data 
%gain = 20
% datavector = reshape(gain*data_filt, [1, numel(range1)*channelNo]);  % max ist 32000
datavector = gain * data_filt; % not really vector
%clearvars -except datavector sessionInfo timeSeries
disp(['Maximum Value: ',num2str(round(max(max(datavector))))])
disp(['data points above maximum threshold: ',num2str(sum(sum(datavector>32768)))]) % should not be larger than 1 000 x channelNo
disp(['Minimum Value: ',num2str(round(min(min(datavector))))])
disp(['data points below minimum threshold: ',num2str(sum(sum(datavector<-32768)))]) % should not be larger than 1 000 x channelNo

timeSeries.gain = gain;