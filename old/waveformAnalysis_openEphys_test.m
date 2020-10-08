%%% Waveform shape and clustering
%%% developed by RB on 17.05.2019
%%% uses spikeClusterData1.mat, no other script needs to be run before this

clear all

% select waveform code for analysis
waveformCode = 61

% data path
path = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-01-15_12-25-26/data/';

% load 1st channel of the data as example
i = 1;
filename = ['100_CH', num2str(i), '.continuous'];
[data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data([path, filename]); % load the most representative channel for the selected waveform

% load sampling rate
filename_events = ['all_channels', '.events'];
[dataEv, timestampsEv, infoEv] = load_open_ephys_data([path, filename_events]);
samplingRate = info(1).header.sampleRate;

%load spikeClusterData1
load('spikeClusterData1.mat');

%load times
filename_kwik = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-01-15_12-25-26/klusta analysis/V1_20200115_1.kwik';
spikeClusterData.klustaTimes = double(hdf5read(filename_kwik, '/channel_groups/0/spikes/time_samples'))/samplingRate; % all spike times

waveformCodeInd = find(spikeClusterData.uniqueCodes(:,1) == waveformCode); % index of the selected waveform
waveformCodeChannel = spikeClusterData.uniqueCodesChannel(waveformCodeInd); % most representative channel of the selected waveform

% load data
i = waveformCodeChannel+1;
% i= 1;
filename = ['100_CH', num2str(i), '.continuous'];
[data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data([path, filename]); % load the most representative channel for the selected waveform
dataFilt(1,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz

%% isolate spikes

clear waveformData waveformDataFilt;

timeWindow = 3; % ms
dataPointsWindow = timeWindow * samplingRate /1000; % data points in timeWindow

iWaveform = spikeClusterData.codes == waveformCode; % index of times at which spikes of the selected waveform occur
waveformTimes = spikeClusterData.klustaTimes(iWaveform);  % times at which spikes of the selected waveform occur
waveformDataPoints = round(waveformTimes * samplingRate); %  times in data points at which spikes of the selected waveform occur

for i = (1:numel(waveformDataPoints))
    waveformInt = (waveformDataPoints(i)-dataPointsWindow/2:waveformDataPoints(i)+dataPointsWindow/2); % waveform interval in data points for each occurance of the waveform
    waveformData(i,:) = data(1,waveformInt); % waveform in data
    waveformDataFilt(i,:) = dataFilt(1,waveformInt); % waveform in filtered data
end

waveformFiltAvg = mean(waveformDataFilt(:,:),1);

%% figures

figure;
for i = (1:numel(waveformData(:,1)))
    plot(waveformData(i,:)); hold on
end

figure;
for i = (1:numel(waveformData(:,1)))
    plot(waveformDataFilt(i,:)); hold on
end

figure;
plot(waveformFiltAvg); hold on
title(waveformCode)
% plot(mean(waveformData(:,:),1));

%% Waveform feature calculations

[waveformTrough, datapointTrough] = min(waveformFiltAvg);
[waveformPeak, datapointPeak] = max(waveformFiltAvg(dataPointsWindow/2:1:end));
datapointPeak = datapointPeak + dataPointsWindow/2-1;

peakTroughRatio = abs(waveformPeak/waveformTrough);
troughPeakTime = (datapointPeak - datapointTrough)/samplingRate*1000; % time in ms

%% plot time vs ratio

ratioAll= [0.333 0.3196 0.395 0.3554 0.401 0.3731 0.3417 0.3052 0.3675];
timeAll = [0.7 0.65 0.4 0.65 0.3 0.6 0.6 0.7 0.6];
figure;
scatter(ratioAll, timeAll);
xlim([0.2 0.6]);
ylim([0.2 0.8]);
xlabel('peak : trough height ratio'); 
ylabel('trough to peak (ms)') ;

