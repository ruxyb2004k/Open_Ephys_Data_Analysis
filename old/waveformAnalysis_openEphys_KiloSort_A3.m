%%% Waveform shape and clustering
%%% developed by RB on 17.05.2019
%%% uses spikeClusterData1.mat and traceFreqAndInfo1.mat (run SpikeDataLoading_openEphys.m and PlotPSTHandRaster_openEphys.m)

clearvars -except experimentName sessionName k expSetFilt
close all
% clearvars -except experimentName sessionName
% experimentName = '2020-06-19_12-56-47'
% sessionName = 'V1_20200619_1'

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

savePathFigs = strjoin({basePathMatlab, 'figs', 'metrics'}, filesep); 
if ~exist(savePathFigs, 'dir')
     mkdir(savePathFigs);
end     

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

if CMexist
    waveformFiltAvg = cellMetrics.waveformFiltAvg;
    waveformFiltAvgNorm = cellMetrics.waveformFiltAvgNorm;
    peakTroughRatio = cellMetrics.peakTroughRatio;
    troughPeakTime = cellMetrics.troughPeakTime;
    peakAsymmetry = cellMetrics.peakAsymmetry;
    return
end

% load the rest of the data
channelNo= sessionInfo.nChannels;
dataPoints = timeSeries.dataPoints;
% data = zeros(1,dataPoints);
% med = zeros(channelNo,1);
med = timeSeries.medCh;
samplingRate = sessionInfo.rates.wideband;
dataFilt = zeros(sessionInfo.nChannels, numel(timeSeries.range1));
% artefactCh = 7;

for i=(1:channelNo)
    
    clearvars data timestamps
    filename = ['100_CH', num2str(i+sessionInfo.chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);    
%     deleteArtefact
%     med(i) = median(data(1,:));
    data_ch(1,:) = data(1, ismember(timestamps, timeSeries.timestamps))-med(i);% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
    datasub = data_ch(:,[timeSeries.range1]); % select data based on the selected time range
    data = datasub;
    clearvars datasub
    disp(['Filtering channel ', num2str(i), '...'])
    dataFilt(i,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz
    
%     clearvars timestamps
%     data = zeros(1,dataPoints);
%     filename = ['100_CH', num2str(i+sessionInfo.chOffset), '.continuous'];
%     [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
% %     deleteArtefact
% %     med(i) = median(data(1,:));
%     data(1,:) = data(1,:) - med(i);
%     datasub = data(:,[timeSeries.range1]); % select data based on the selected time range
%     data = datasub;
%     clearvars datasub
%     disp(['Filtering channel ', num2str(i), '...'])
%     dataFilt(i,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz
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
shiftCodes = [];
shiftCodes = [28, 60];

for ind = (1:numel(codes)) % for each selected code
    waveformCode = codes(ind); 
    waveformCodeInd = find(spikeClusterData.uniqueCodes(:,1) == waveformCode); % index of the selected waveform
    waveformCodeChannel = spikeClusterData.uniqueCodesChannel(waveformCodeInd); % most representative channel of the selected waveform
 
    % isolate spikes
    clear waveformData waveformDataFilt;
    
    iWaveform = spikeClusterData.codes == waveformCode; % index of times at which spikes of the selected waveform occur
    waveformTimes = spikeClusterData.times(iWaveform);  % times at which spikes of the selected waveform occur
    if ismember(waveformCode, shiftCodes) % exception just for this experiment to shift a bit the data of this unit
        waveformTimes = waveformTimes + 4/samplingRate;
        warning(['Shifting data for code: ', num2str(waveformCode)])
    end    
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
clearvars dataFilt

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

cellMetrics.waveformCodes = codes;
cellMetrics.waveformFiltAvgNorm = waveformFiltAvgNorm;
cellMetrics.waveformFiltAvg = waveformFiltAvg;
cellMetrics.peakTroughRatio = peakTroughRatio;
cellMetrics.troughPeakTime = troughPeakTime;
cellMetrics.peakAsymmetry = peakAsymmetry;
cellMetrics.waveformCodeChannelNew = waveformCodeChannelNew ;
% cellMetrics.invWf = invWf;
clearvars data data_ch datasub timestamps timeSeries waveformDataPoints waveformTimes
%%
%calculate ACG fit, putative cell type and putative connections
close all
spikes.numcells = numel(spikeClusterData.goodCodes);
for i = 1: spikes.numcells
    clusterCode = spikeClusterData.goodCodes(i);
    spikes.times{i} = spikeClusterData.rangeTimes(spikeClusterData.codes==clusterCode);
    spikes.total(i) = numel(spikes.times{i});
end   

init_acg_metrics;
if spikes.numcells
    acg_metrics = calcACGmetrics(spikes,sessionInfo.rates.wideband); % calculate ACG
    fit_params = fitACG(acg_metrics.acg_narrow, spikeClusterData.goodCodes); % fit the ACG
    for fn = fieldnames(fit_params)'
        acg_metrics.(fn{1}) = fit_params.(fn{1});
    end
end

fft_metrics = fftMetrics(acg_metrics.acg_wide, spikeClusterData.goodCodes); % calculate FFT for each ACG

% determine the putative cell - subject to change
for i = 1:numel(spikeClusterData.goodCodes)
    if cellMetrics.troughPeakTime(i)<= 0.425 % criterion subject to change
        putativeCellType(i,:) = {'interneuron'};
    else
        putativeCellType(i,:) = {'pyramidal'};
        if acg_metrics.acg_tau_rise(i) > 6  % criterion subject to change
            putativeCellType(i,:) = {'wide_interneuron'};
        end    
    end
end
% openvar('putativeCellType')

% detect putative connections
[~,idGC ] = ismember(spikeClusterData.goodCodes,spikeClusterData.uniqueCodes(:,1));
spikes.shankID = spikeClusterData.channelShank(spikeClusterData.uniqueCodesChannel(idGC)+1)'; % determines the electrode shank for each good code
spikes.cluID = 1:numel(spikeClusterData.goodCodes); % cluster Id from 1 till numel(goodCodes)
[ids, idGoodCodes] = ismember(spikeClusterData.codes, spikeClusterData.goodCodes); % extract only the spikes belonging to the good codes
spikes.spindices = [spikeClusterData.times(ids), idGoodCodes(ids)]; % Nx2 matrix of spike times and cluster IDs (1...N)

if spikes.numcells
    detectInh = true; % true if inhibitory connection detection is wanted, false otherwise
    mono_res = ce_MonoSynConvClick(spikes,'includeInhibitoryConnections',detectInh); % detects the monosynaptic connections
    mono_res = gui_MonoSyn(mono_res); % Shows the GUI for manual curation
    
    putativeConnections.excitatory = mono_res.sig_con_excitatory; % copy this field into the putativeConnections structure
    putativeConnections.inhibitory = [];
    if isfield(mono_res, 'sig_con_inhibitory')
        putativeConnections.inhibitory = mono_res.sig_con_inhibitory; % if inhibitory connections were detected, copy this field into the putativeConnections structure
    end
end

% fill cellMetrics 

cellMetrics.acg_metrics = acg_metrics;
cellMetrics.putativeCellType = putativeCellType;
cellMetrics.mono_res = mono_res;
cellMetrics.putativeConnections = putativeConnections;
cellMetrics.fft_metrics = fft_metrics;

spikeClusterData.goodCodes(cellMetrics.mono_res.sig_con_excitatory_all)
spikeClusterData.goodCodes(cellMetrics.mono_res.sig_con_inhibitory_all)
spikeClusterData.goodCodes(cellMetrics.putativeConnections.excitatory)
spikeClusterData.goodCodes(cellMetrics.putativeConnections.inhibitory)
%% plot more figures all waveforms

codes = spikeClusterData.goodCodes;
figure; % all waveforms
for i =1:numel(waveformFiltAvg(:,1))
    plot(waveformFiltAvg(i,:)); hold on
end    

figure; % normalized waveforms to -1
for i =1:numel(waveformFiltAvgNorm(:,1))
    plot(waveformFiltAvgNorm(i,:)); hold on
end

% non-selected codes = red; ev-codes = blue; spont=codes = green
nonSel = ~ismember(1:numel(spikeClusterData.goodCodes), clusterTimeSeries.selectedCodesInd);
nonSpont = clusterTimeSeries.selectedCodesInd(:,clusterTimeSeries.selectedCodesIndSpont==0);
spont = clusterTimeSeries.selectedCodesInd(:,clusterTimeSeries.selectedCodesIndSpont==1);

codesColor = repmat([1 0 0], numel(codes),1);% non selected codes : red
codesColor(clusterTimeSeries.selectedCodesInd,:) = repmat([0 1 0], numel(clusterTimeSeries.selectedCodesInd),1); %selected codes : green
codesColor(clusterTimeSeries.selectedCodesInd(:,clusterTimeSeries.selectedCodesIndSpont==1),:) = repmat([0 0 1], sum(clusterTimeSeries.selectedCodesIndSpont),1); % spontaneous codes: blue

% plot time vs ratio
figure;
scatter(peakTroughRatio(nonSel), troughPeakTime(nonSel), 'r'); hold on % plot non-selected codes
scatter(peakTroughRatio(nonSpont), troughPeakTime(nonSpont), 'g'); % plot evoked codes
scatter(peakTroughRatio(spont), troughPeakTime(spont), 'b'); % plot spontaneous codes
for i =1:numel(codes)
    text(peakTroughRatio(i),troughPeakTime(i), num2str(codes(i)), 'Color', codesColor(i,:));
end
legend({'non selected', 'evoked', 'spontaneous'})
xlabel('peak : trough height ratio'); 
ylabel('trough to peak (ms)') ;

% plot ratio vs peak asymmetry
figure;
scatter( troughPeakTime(nonSel), peakAsymmetry(nonSel), 'r'); hold on % plot non-selected codes
scatter( troughPeakTime(nonSpont), peakAsymmetry(nonSpont), 'g'); % plot evoked codes
scatter( troughPeakTime(spont), peakAsymmetry(spont), 'b'); % plot spontaneous codes
for i =1:numel(codes)
    text(troughPeakTime(i),peakAsymmetry(i),num2str(codes(i)), 'Color', codesColor(i,:));
end
legend({'non selected', 'evoked', 'spontaneous'})
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)') ;
saveas(gcf, strcat(savePathFigs, filesep, 'troughPeakTimeVsPeakAsym.fig'));

% plot ratio vs peak asymmetry with putativeCellType color codes

codes = spikeClusterData.goodCodes;
inh = strcmp(putativeCellType, 'interneuron'); % interneuron codes index
winh = strcmp(putativeCellType, 'wide_interneuron'); % wide interneuron codes index
pyr = strcmp(putativeCellType, 'pyramidal'); % wide interneuron codes index

codesColor_pCT = repmat([1 0 0], numel(codes),1);% red
codesColor_pCT(winh,:) = repmat([0 0 1], sum(winh),1); % blue
codesColor_pCT(pyr,:) = repmat([0 1 0], sum(pyr),1); % green

figure;
scatter(cellMetrics.troughPeakTime(inh), cellMetrics.peakAsymmetry(inh), 'r'); hold on
scatter(cellMetrics.troughPeakTime(winh), cellMetrics.peakAsymmetry(winh),'b');
scatter(cellMetrics.troughPeakTime(pyr), cellMetrics.peakAsymmetry(pyr), 'g');
for i =1:numel(codes)
    txtCon = [];
    if ~isempty(putativeConnections.excitatory)
        txtCon = [txtCon, repmat('+', 1, sum(putativeConnections.excitatory(:,1)==i))];
    end
    if ~isempty(putativeConnections.inhibitory)
        txtCon = [txtCon, repmat('-', 1, sum(putativeConnections.inhibitory(:,1)==i))];
    end    
    text(cellMetrics.troughPeakTime(i),cellMetrics.peakAsymmetry(i), [num2str(codes(i)), txtCon], ...
        'HorizontalAlignment', 'left', 'Color', codesColor_pCT(i,:));   
    
end
legend({'Inhibitory', 'Wide Inhibitory', 'Pyramidal'});
xlabel('trough to peak (ms)');
ylabel('peak asymmetry (P2-P1)/(P2+P1)') ;
saveas(gcf, strcat(savePathFigs, filesep, 'troughPeakTimeVsPeakAsymConnections.fig'));

%% modify if needed
% [mono_res, putativeConnections] = removeConnections([], 'exc', mono_res, putativeConnections)
% [mono_res, putativeConnections] = removeConnections([], 'inh', mono_res, putativeConnections)

cellMetrics.mono_res = mono_res;
cellMetrics.putativeConnections = putativeConnections;

spikeClusterData.goodCodes(cellMetrics.putativeConnections.excitatory)
spikeClusterData.goodCodes(cellMetrics.putativeConnections.inhibitory)
%% save waveform characteristics

close all


cellMetrics.minCh = minCh;
cellMetrics.normMinCh = normMinCh;
cellMetrics.iMinCh = iMinCh;
cellMetrics.visitedCh = visitedCh;

% if file too large:
s = whos('cellMetrics');
if s.bytes >= 3*10^9
    cellMetrics.waveformDataFilt = [];
    warning('waveformDataFilt was emptied')
end    

% cellMetrics
cfCM = checkFields(cellMetrics);
if ~cfCM         
    disp(['Saving ', experimentName, ' / ' , sessionName, ' .cellMetrics.mat file'])
    save(filenameCellMetrics, 'cellMetrics')
else
    disp('.cellMetrics.mat file was not saved')
end
    