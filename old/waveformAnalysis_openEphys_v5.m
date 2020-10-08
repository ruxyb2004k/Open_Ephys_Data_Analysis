%%% Waveform shape and clustering
%%% developed by RB on 17.05.2019
%%% uses spikeClusterData1.mat and traceFreqAndInfo1.mat (run SpikeDataLoading_openEphys.m and PlotPSTHandRaster_openEphys.m)

clear

% load traceFreqAndInfo1 to get selectedCodes
load('traceFreqAndInfo1.mat')
% load('range'); % modify datasub accordingly

% data path
path = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-06-18_15-39-40/data/';
% path = 'P:\Ruxi\2020-05-23_14-29-08\data\';
channelNo = 16;

% load 1st channel of the data as example
i = 1;
filename = ['100_CH', num2str(i), '.continuous'];
[data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data([path, filename]); % load 1st channel of the data as example
samplingRate = info.header.sampleRate;

% load the rest of the data
dataPoints = numel(data(1,:));
data= zeros(channelNo,dataPoints);
timestamps = zeros(dataPoints,1);
med = zeros(channelNo,1);

for i=(1:channelNo)
    filename = ['100_CH', num2str(i), '.continuous'];
    [data(i,:), timestamps(:,1), info(:,i)] = load_open_ephys_data([path, filename]);
    med(i) = median(data(i,:));
    data(i,:) = data(i,:) - med(i);
end
%%
% select range and filter data - modify range accordingly for every exp or
% comment out the next four lines if there is no range

load('range.mat');
datasub = data(:,[rangeBeg1:rangeEnd1, rangeBeg2:rangeEnd2]);% rangeBeg3:rangeEnd3]);
data = datasub;
clearvars datasub

dataFilt = zeros(size(data));
for i=(1:channelNo)
    dataFilt(i,:) = bandpass(data(i,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz
end 
%% load spikeClusterData1, klustaTimes and intialize variables

%load spikeClusterData1
load('spikeClusterData1.mat');

%load times
filename_kwik = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-06-18_15-39-40/klusta analysis/V1_20200618_1.kwik';
% filename_kwik = 'P:\Ruxi\2020-05-23_14-29-08\klusta analysis\V1_20200523_2.kwik';
spikeClusterData.klustaTimes = double(hdf5read(filename_kwik, '/channel_groups/0/spikes/time_samples'))/samplingRate; % all spike times

timeWindow = 3; % ms
dataPointsWindow = timeWindow * samplingRate / 1000; % data points in timeWindow

waveformFiltAvg = nan(numel(selectedCodes), dataPointsWindow+1);
waveformTrough = nan(1,numel(selectedCodes));
datapointTrough = nan(1,numel(selectedCodes));
waveformPeak1 = nan(1,numel(selectedCodes));
datapointPeak1 = nan(1,numel(selectedCodes));
waveformPeak2 = nan(1,numel(selectedCodes));
datapointPeak2 = nan(1,numel(selectedCodes));
peakAsymmetry = nan(1,numel(selectedCodes));
peakTroughRatio = nan(1,numel(selectedCodes));
troughPeakTime = nan(1,numel(selectedCodes));
waveformFiltAvgNorm = nan(numel(selectedCodes),41);
visitedCh = nan(16,numel(selectedCodes));
minCh = nan(16, numel(selectedCodes));
normMinCh = nan(16, numel(selectedCodes));
iMinCh = nan(16, numel(selectedCodes));
%%
for ind = 1:numel(selectedCodes) % for each selected code
    waveformCode = selectedCodes(ind) 
    waveformCodeInd = find(spikeClusterData.uniqueCodes(:,1) == waveformCode); % index of the selected waveform
    waveformCodeChannel = spikeClusterData.uniqueCodesChannel(waveformCodeInd); % most representative channel of the selected waveform
 
    % isolate spikes
    clear waveformData waveformDataFilt;
    
    iWaveform = spikeClusterData.codes == waveformCode; % index of times at which spikes of the selected waveform occur
    waveformTimes = spikeClusterData.klustaTimes(iWaveform);  % times at which spikes of the selected waveform occur
    waveformDataPoints = round(waveformTimes * samplingRate); %  times in data points at which spikes of the selected waveform occur
    
    waveformData = zeros(numel(waveformDataPoints),dataPointsWindow+1, channelNo);
    waveformDataFilt = zeros(numel(waveformDataPoints),dataPointsWindow+1, channelNo);    
    for j = (1:channelNo)
        for i = (1:numel(waveformDataPoints))
            waveformInt = (waveformDataPoints(i)-dataPointsWindow/2:waveformDataPoints(i)+dataPointsWindow/2); % waveform interval in data points for each occurance of the waveform
            waveformData(i,:,j) = data(j,waveformInt); % waveform in data
            waveformDataFilt(i,:,j) = dataFilt(j,waveformInt); % waveform in filtered data
        end
    
        %     figure; % plot all waveforms of this unit, unfiltered
        %     for i = (1:numel(waveformData(:,1)))
        %         plot(waveformData(i,:)); hold on
        %     end
        %
        %     figure; % plot all waveforms of this unit, filtered
        %     for i = (1:numel(waveformData(:,1)))
        %         plot(waveformDataFilt(i,:)); hold on
        %     end
    
        waveformFiltAvgCh(:,j) = squeeze(mean(waveformDataFilt(:,:,j),1)); % average waveform for the selected code (single unit), al channels            
    end 
    
    minCh(:,ind) = min(waveformFiltAvgCh(dataPointsWindow/2-5:dataPointsWindow/2+5,:));
    normMinCh(:,ind) = minCh(:,ind)/minCh(waveformCodeChannel+1,ind);
    iMinCh(:,ind)=normMinCh(:,ind)>0.12; 

    ord = [];
    visitedCha= nan(16,1); 
    
    [visitedCha, ord] = findAdjNodes(waveformCodeChannel, spikeClusterData.adjGraph, iMinCh(:,ind), visitedCha, ord);
    visitedCh(:,ind) = visitedCha;
    
    waveformFiltAvg(ind,:) = mean(waveformDataFilt(:,:,waveformCodeChannel+1),1); % average waveform for the selected code (single unit)

    % figure of average waveform for a specific selected code (single unit)
    figure;
    plot(waveformFiltAvg(ind,:)); hold on
    title(waveformCode)

    % Waveform feature calculations
    [waveformTrough(ind), datapointTrough(ind)] = min(waveformFiltAvg(ind,:)); % find min (trough) and its datapoint (timepoint)
    [waveformPeak1(ind), datapointPeak1(ind)] = max(waveformFiltAvg(ind,1:1:dataPointsWindow/2)); % find max (peak) in the first part of the waveform and its datapoint (timepoint)
    
    [waveformPeak2(ind), datapointPeak2(ind)] = max(waveformFiltAvg(ind,datapointTrough(ind):1:end)); % find max (peak) in the second part of the waveform and its datapoint (timepoint)
    datapointPeak2(ind) = datapointPeak2(ind) + datapointTrough(ind)-1; % adjust datapoint of peak
    
    peakAsymmetry(ind) = (waveformPeak2(ind) - waveformPeak1(ind))/(waveformPeak2(ind) + waveformPeak1(ind)); % ratio of peaks
    peakTroughRatio(ind) = abs(waveformPeak2(ind)/waveformTrough(ind)); % peak height / trough height
    troughPeakTime(ind) = (datapointPeak2(ind) - datapointTrough(ind))/samplingRate*1000; % time difference between trough and peak in ms
    
    waveformFiltAvgNorm(ind,:) = waveformFiltAvg(ind,datapointTrough(ind)-20:datapointTrough(ind)+20)/abs(waveformTrough(ind)); % normalize to -1 and adjust time to trough

    % analysis and 1st figure commented out just for testing    
    indivTrough = nan(numel(waveformDataPoints),1);
    for i = (1:numel(waveformDataPoints)) % store amplitude of each spike - scatter plot with time between consecutive spikes 
        indivTrough(i) = min(waveformDataFilt(i,datapointTrough(ind)-3:datapointTrough(ind)+3));
%         indivTrough1(i) = min(waveformDataFilt(i,datapointTrough(ind)-3:datapointTrough(ind)+3))-waveformDataFilt(i,1);% subtract baseline
    end
    
    figure;
    histogram(indivTrough,50);
    xlabel('Spike amplitude (uV)');
    ylabel('Spike count');
    title(waveformCode)
    
%     figure;
%     histogram(indivTrough1,50);
%     xlabel('Spike amplitude - baseline (uV)');
%     ylabel('Spike count');
%     title(waveformCode)
end

%% plot all waveforms

figure;
for i =1:numel(waveformFiltAvg(:,1))
    plot(waveformFiltAvg(i,:)); hold on
end    

figure; % normalized waveforms to -1
for i =1:numel(waveformFiltAvgNorm(:,1))
    plot(waveformFiltAvgNorm(i,:)); hold on
end


%% plot time vs ratio
figure;
scatter(peakTroughRatio, troughPeakTime);
for i =1:numel(selectedCodes)
    text(peakTroughRatio(i),troughPeakTime(i),num2str(selectedCodes(i)));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('peak : trough height ratio'); 
ylabel('trough to peak (ms)') ;

% plot ratio vs peak asymmetry
figure;
scatter( troughPeakTime, peakAsymmetry);
for i =1:numel(selectedCodes)
    text(troughPeakTime(i),peakAsymmetry(i),num2str(selectedCodes(i)));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)') ;

%% save waveform characteristics
save('waveformAndInfo_spont.mat', 'waveformFiltAvgNorm', 'waveformFiltAvg', 'peakTroughRatio', 'troughPeakTime', 'peakAsymmetry', 'selectedCodes', 'selectedCodesInd')

save('unitSpread_spont.mat', 'minCh', 'normMinCh', 'iMinCh', 'visitedCh', 'selectedCodes')

%% preorder traversal through channels based on adjacency

function [visitedChn, ord]  = findAdjNodes(chIn, adjGr, k, visitedChn, ord)

if isnan(visitedChn(chIn+1))|| visitedChn(chIn+1) == 2 % not visited or in memory
    if k(chIn+1)==1
        visitedChn(chIn+1) = 1; % node was visited and value is large
        ord(end+1) = chIn;
        chAdj = [adjGr(2,adjGr(1,:)==chIn),adjGr(1,adjGr(2,:)==chIn)];
        chAdj = chAdj(isnan(visitedChn(chAdj+1))); 
        for ch = chAdj
            if isnan(visitedChn(ch+1))
                visitedChn(ch+1)=2;
            elseif visitedChn(ch+1)==2
                chAdj1 = chAdj(chAdj~=ch);
                chAdj = chAdj1;
            end
        end    
        for ch = chAdj    
            if isnan(visitedChn(ch+1))|| visitedChn(ch+1) == 2 % not visited or in memory
                [visitedChn, ord] = findAdjNodes(ch, adjGr, k, visitedChn, ord);
            end    
        end    
    else
        visitedChn(chIn+1) = 0; % node was visited and the value is small
        ord(end+1) = chIn;
    end
end
end