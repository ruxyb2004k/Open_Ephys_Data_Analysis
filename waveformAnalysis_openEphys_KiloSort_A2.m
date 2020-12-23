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
filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data

[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
[cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);


% load the rest of the data
channelNo= sessionInfo.nChannels;
dataPoints = timeSeries.dataPoints;
data = zeros(1,dataPoints);
% med = zeros(channelNo,1);
med = timeSeries.medCh;
samplingRate = sessionInfo.rates.wideband;
dataFilt = zeros(sessionInfo.nChannels, numel(timeSeries.range1));
% artefactCh = 7;

for i=(1:channelNo)
    data = zeros(1,dataPoints);
    filename = ['100_CH', num2str(i+sessionInfo.chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
%     deleteArtefact
%     med(i) = median(data(1,:));
    data(1,:) = data(1,:) - med(i);
    datasub = data(:,[timeSeries.range1]); % select data based on the selected time range
    data = datasub;
    clearvars datasub
    disp(['Filtering channel ', num2str(i), '...'])
    dataFilt(i,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz
end

% main calculation part
% change if necessary
codes = spikeClusterData.goodCodes;
timeWindow = 3; % ms

dataPointsWindow = timeWindow * samplingRate / 1000; % data points in timeWindow
timeWaveform = (-dataPointsWindow/2:dataPointsWindow/2)/samplingRate*1000; % time in ms, with 0 the time of spike

% initialize variables 
waveformFiltAvg = nan(numel(codes), dataPointsWindow+1);
waveformTrough = nan(1,numel(codes));
datapointTrough = nan(1,numel(codes));
waveformFiltAvgNorm = nan(numel(codes),41);
visitedCh = nan(channelNo,numel(codes));
minCh = nan(channelNo, numel(codes));
normMinCh = nan(channelNo, numel(codes));
iMinCh = nan(channelNo, numel(codes));
waveformCodeChannelNew = nan(1,numel(codes));
waveformFiltAvgCh = nan(numel(codes),dataPointsWindow+1,channelNo);

for ind = (1:numel(codes)) % for each selected code
    waveformCode = codes(ind) 
    waveformCodeInd = find(spikeClusterData.uniqueCodes(:,1) == waveformCode); % index of the selected waveform
    waveformCodeChannel = spikeClusterData.uniqueCodesChannel(waveformCodeInd); % most representative channel of the selected waveform
 
    % isolate spikes
    clear waveformData waveformDataFilt;
    
    iWaveform = spikeClusterData.codes == waveformCode; % index of times at which spikes of the selected waveform occur
    waveformTimes = spikeClusterData.times(iWaveform);  % times at which spikes of the selected waveform occur
    waveformDataPoints{ind} = round(waveformTimes * samplingRate); %  times in data points at which spikes of the selected waveform occur
    
%     waveformData = zeros(numel(waveformDataPoints{ind}),dataPointsWindow+1, channelNo);
    waveformDataFilt = zeros(numel(waveformDataPoints{ind}),dataPointsWindow+1, channelNo);    
    for j = (1:channelNo)
        for i = (1:numel(waveformDataPoints{ind}))
            waveformInt = (waveformDataPoints{ind}(i)-dataPointsWindow/2:waveformDataPoints{ind}(i)+dataPointsWindow/2); % waveform interval in data points for each occurance of the waveform
%             waveformData(i,:,j) = data(j,waveformInt); % waveform in data
            waveformDataFilt(i,:,j) = dataFilt(j,waveformInt); % waveform in filtered data
        end
        waveformFiltAvgCh(ind,:,j) = squeeze(mean(waveformDataFilt(:,:,j),1)); % average waveform for the selected code (single unit), all channels                           
    end
    waveformFiltAvg(ind,:) = squeeze(waveformFiltAvgCh(ind,:,waveformCodeChannel+1)); % average waveform for the selected code (single unit) and channel suggested by phy
    
%     figure; % plot all waveforms of this unit, unfiltered
%     randWf = sort(randi(size(waveformData,1),1,100));
%     for i = (1:numel(randWf))
%         plot(squeeze(waveformData(randWf(i),:,waveformCodeChannel+1))); hold on%
%     end
%     title(codes(ind)) 
  
%     figure; % plot all waveforms of this unit, filtered
%     randWf = sort(randi(size(waveformDataFilt,1),1,100));
%     for i = (1:numel(randWf))
%         plot(squeeze(waveformDataFilt(randWf(i),:,waveformCodeChannel+1))); hold on%
%     end 
%     title(codes(ind)) 
    
    % cellMetrics.waveformData{ind} = waveformData;
    cellMetrics.waveformDataFilt{ind} = waveformDataFilt;
end

% Waveform feature calculations
waveforms.timeWaveform{1} = timeWaveform;
waveforms.filtWaveform = mat2cell(waveformFiltAvg, ones(size(waveformFiltAvg,1),1));
cellMetrics_part = calcWaveformMetrics(waveforms, samplingRate);

peakTroughTime = cellMetrics_part.peaktoTrough;
troughPeakTime = cellMetrics_part.troughtoPeak;
peakAsymmetry = cellMetrics_part.ab_ratio ;
peakTroughRatio = cellMetrics_part.peakTroughRatio ;
cellMetrics.polarity = cellMetrics_part.polarity ;
cellMetrics.derivative_TroughtoPeak = cellMetrics_part.derivative_TroughtoPeak ;
cellMetrics.peakA = cellMetrics_part.peakA ;
cellMetrics.peakB = cellMetrics_part.peakB ;
cellMetrics.trough = cellMetrics_part.trough ;

for ind = (1:numel(codes))
    if cellMetrics.polarity(ind) >0
        waveformFiltAvgCh(ind,:,:) = -waveformFiltAvgCh(ind,:,:);
        waveformFiltAvg(ind,:) = -waveformFiltAvg(ind,:);
        cellMetrics.waveformDataFilt{ind} = -cellMetrics.waveformDataFilt{ind};
    end    
    minCh(:,ind) = min(waveformFiltAvgCh(ind,dataPointsWindow/2-5:dataPointsWindow/2+5,:));
    [~,waveformCodeChannelNew(ind)] = min(minCh(:, ind));
    waveformCodeChannelNew(ind) = waveformCodeChannelNew(ind) - 1;
    normMinCh(:,ind) = minCh(:,ind)/minCh(waveformCodeChannelNew(ind)+1,ind);
    iMinCh(:,ind)=normMinCh(:,ind)>0.12; 
    visitedCh(:,ind) = iMinCh(:,ind);  % simplified in comparison to klusta
    
    % waveformFiltAvg(ind,:) = waveformFiltAvgCh(:,waveformCodeChannelNew(ind)+1); % average waveform for the selected code (single unit) and best channel
        
    [waveformTrough(ind), datapointTrough(ind)] = min(waveformFiltAvg(ind,dataPointsWindow/2-5:dataPointsWindow/2+5)); % find min (trough) and its datapoint (timepoint)
    datapointTrough(ind) =  datapointTrough(ind) + dataPointsWindow/2-6;
    waveformFiltAvgNorm(ind,:) = waveformFiltAvg(ind,datapointTrough(ind)-20:datapointTrough(ind)+20)/abs(waveformTrough(ind)); % normalize to -1 and adjust time to trough
    
    % calculate the trough of each single spike
    indivTrough = nan(numel(waveformDataPoints{ind}),1);
    for i = (1:numel(waveformDataPoints{ind})) % store amplitude of each spike - scatter plot with time between consecutive spikes
        indivTrough(i) = min(cellMetrics.waveformDataFilt{ind}(i, datapointTrough(ind)-3:datapointTrough(ind)+3, waveformCodeChannelNew(ind)+1));
    end
    
    % figure of average waveform for a specific selected code (single unit)
    figure;
    subplot(2,1,1)
    plot(timeWaveform, waveformFiltAvg(ind,:)); hold on
    xlabel('Time (ms)');
    ylabel('Spike amplitude (uV)');
    title(codes(ind))    
    % histogram of all troughs
    subplot(2,1,2)
    histogram(indivTrough,50);
    xlabel('Spike amplitude (uV)');
    ylabel('Spike count');    
    
    cellMetrics.indivTrough{ind} = indivTrough;
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

% non-selected codes = red; ev-codes = blue; spont=codes = green
codesColor = repmat([1 0 0], numel(codes),1);% red
codesColor(clusterTimeSeries.selectedCodesInd,:) = repmat([0 0 1], numel(clusterTimeSeries.selectedCodesInd),1); %blue
codesColor(clusterTimeSeries.selectedCodesInd(:,clusterTimeSeries.selectedCodesIndSpont==1),:) = repmat([0 1 0], sum(clusterTimeSeries.selectedCodesIndSpont),1); % green

% plot time vs ratio
figure;
scatter(peakTroughRatio, troughPeakTime);
for i =1:numel(codes)
    text(peakTroughRatio(i),troughPeakTime(i), num2str(codes(i)), 'Color', codesColor(i,:));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('peak : trough height ratio'); 
ylabel('trough to peak (ms)') ;

% plot ratio vs peak asymmetry
figure;
scatter( troughPeakTime, peakAsymmetry);
for i =1:numel(codes)
    text(troughPeakTime(i),peakAsymmetry(i),num2str(codes(i)), 'Color', codesColor(i,:));
end
% xlim([0.2 0.6]);
% ylim([0.2 0.8]);
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)') ;

%% save waveform characteristics

close all
cellMetrics.waveformCodes = codes;
cellMetrics.waveformFiltAvgNorm = waveformFiltAvgNorm;
cellMetrics.waveformFiltAvg = waveformFiltAvg;
cellMetrics.peakTroughRatio = peakTroughRatio;
cellMetrics.troughPeakTime = troughPeakTime;
cellMetrics.peakAsymmetry = peakAsymmetry;
cellMetrics.waveformCodeChannelNew = waveformCodeChannelNew ;
% cellMetrics.invWf = invWf;

cellMetrics.minCh = minCh;
cellMetrics.normMinCh = normMinCh;
cellMetrics.iMinCh = iMinCh;
cellMetrics.visitedCh = visitedCh;

% if file too large:
% cellMetrics.waveformDataFilt = [];

cellMetrics
cfCM = checkFields(cellMetrics);
if ~cfCM         
    disp(['Saving ', experimentName, ' / ' , sessionName, ' .cellMetrics.mat file'])
    save(filenameCellMetrics, 'cellMetrics')
else
    disp('.cellMetrics.mat file was not saved')
end
    