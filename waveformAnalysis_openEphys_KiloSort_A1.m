%%% Waveform shape and clustering
%%% developed by RB on 17.05.2019
%%% uses spikeClusterData1.mat and traceFreqAndInfo1.mat (run SpikeDataLoading_openEphys.m and PlotPSTHandRaster_openEphys.m)

clearvars -except experimentName sessionName
close all
% clearvars -except experimentName sessionName
% experimentName = '2020-06-19_12-56-47'
% sessionName = 'V1_20200619_1'

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data

[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);


% load the rest of the data
channelNo= sessionInfo.nChannels;
dataPoints = timeSeries.dataPoints;
data = zeros(channelNo,dataPoints);
% timestamps = zeros(dataPoints,1);
med = zeros(channelNo,1);
samplingRate = sessionInfo.rates.wideband;

for i=(1:channelNo)
    filename = ['100_CH', num2str(i), '.continuous'];
    [data(i,:), timestamps(:,1), info(:,i)] = load_open_ephys_data([basePathData, filesep, filename]);
    med(i) = median(data(i,:));
    data(i,:) = data(i,:) - med(i);
end

% select range and filter data - modify range accordingly for every exp or

datasub = data(:,[timeSeries.range1]);% rangeBeg3:rangeEnd3]);
data = datasub;
clearvars datasub

dataFilt = zeros(size(data));
for i=(1:channelNo)
    disp(['Filtering channel ', num2str(i), '...'])
    dataFilt(i,:) = bandpass(data(i,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz
end

% main calculation part

% change if necessary
codes = spikeClusterData.goodCodes;

timeWindow = 3; % ms
dataPointsWindow = timeWindow * samplingRate / 1000; % data points in timeWindow

% initialize variables 
waveformFiltAvg = nan(numel(codes), dataPointsWindow+1);
waveformTrough = nan(1,numel(codes));
datapointTrough = nan(1,numel(codes));
waveformPeak1 = nan(1,numel(codes));
datapointPeak1 = nan(1,numel(codes));
waveformPeak2 = nan(1,numel(codes));
datapointPeak2 = nan(1,numel(codes));
peakAsymmetry = nan(1,numel(codes));
peakTroughRatio = nan(1,numel(codes));
troughPeakTime = nan(1,numel(codes));
waveformFiltAvgNorm = nan(numel(codes),41);
visitedCh = nan(channelNo,numel(codes));
minCh = nan(channelNo, numel(codes));
normMinCh = nan(channelNo, numel(codes));
iMinCh = nan(channelNo, numel(codes));

for ind = 1:numel(codes) % for each selected code
    waveformCode = codes(ind) 
    waveformCodeInd = find(spikeClusterData.uniqueCodes(:,1) == waveformCode); % index of the selected waveform
    waveformCodeChannel = spikeClusterData.uniqueCodesChannel(waveformCodeInd); % most representative channel of the selected waveform
 
    % isolate spikes
    clear waveformData waveformDataFilt;
    
    iWaveform = spikeClusterData.codes == waveformCode; % index of times at which spikes of the selected waveform occur
    waveformTimes = spikeClusterData.times(iWaveform);  % times at which spikes of the selected waveform occur
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
%             figure; % plot all waveforms of this unit, filtered
%             for i = (1:numel(waveformData(:,1)))
%                 plot(waveformDataFilt(i,:)); hold on
%             end
    
        waveformFiltAvgCh(:,j) = squeeze(mean(waveformDataFilt(:,:,j),1)); % average waveform for the selected code (single unit), all channels            
    end 
    
    minCh(:,ind) = min(waveformFiltAvgCh(dataPointsWindow/2-5:dataPointsWindow/2+5,:));
    normMinCh(:,ind) = minCh(:,ind)/minCh(waveformCodeChannel+1,ind);
    iMinCh(:,ind)=normMinCh(:,ind)>0.12; 
    
    visitedCh(:,ind) = iMinCh(:,ind);  % simplified in comparison to klusta
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
        indivTrough(i) = min(waveformDataFilt(i, datapointTrough(ind)-3:datapointTrough(ind)+3, waveformCodeChannel+1));
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

% cellMetrics.waveformData{ind} = waveformData;
cellMetrics.waveformDataFilt{ind} = waveformDataFilt;
cellMetrics.indivTrough{ind} = indivTrough;
end

%% plot figures
% plot all waveforms

figure;
for i =1:numel(waveformFiltAvg(:,1))
    plot(waveformFiltAvg(i,:)); hold on
end    

figure; % normalized waveforms to -1
for i =1:numel(waveformFiltAvgNorm(:,1))
    plot(waveformFiltAvgNorm(i,:)); hold on
end


% plot time vs ratio

figure;
scatter(peakTroughRatio, troughPeakTime);
for i =1:numel(codes)
    text(peakTroughRatio(i),troughPeakTime(i),num2str(codes(i)));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('peak : trough height ratio'); 
ylabel('trough to peak (ms)') ;

% plot ratio vs peak asymmetry
figure;
scatter( troughPeakTime, peakAsymmetry);
for i =1:numel(codes)
    text(troughPeakTime(i),peakAsymmetry(i),num2str(codes(i)));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)') ;

%% save waveform characteristics

cellMetrics.waveformCodes = codes;
cellMetrics.waveformFiltAvgNorm = waveformFiltAvgNorm;
cellMetrics.waveformFiltAvg = waveformFiltAvg;
cellMetrics.peakTroughRatio = peakTroughRatio;
cellMetrics.troughPeakTime = troughPeakTime;
cellMetrics.peakAsymmetry = peakAsymmetry;

cellMetrics.minCh = minCh;
cellMetrics.normMinCh = normMinCh;
cellMetrics.iMinCh = iMinCh;
cellMetrics.visitedCh = visitedCh;

cellMetrics
cfCM = checkFields(cellMetrics);
if ~cfCM         
    disp(['Saving ', experimentName, ' / ' , sessionName, ' .cellMetrics.mat file'])
    save(filenameCellMetrics, 'cellMetrics')
else
    disp('.cellMetrics.mat file was not saved')
end
    