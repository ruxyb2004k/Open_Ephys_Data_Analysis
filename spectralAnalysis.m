
% make sure you are in this file's folder
clearvars -except experimentName sessionName 
global i x1 y1 y2 y3 recStartDataPoint z z_filt1 z_filt2 samplingRate

% experimentName = '2021-02-25_14-27-06'
% sessionName = 'V1_20210225_1'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKilosort = strjoin({basePath, 'kilosort analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);

% if SIexist
%     cfSI = checkFields(sessionInfo);
% end
% 
% if TSexist
%     cfTS = checkFields(timeSeries);
% end


%% Reverse variable atribution

% sessionInfo.session.path = basePath;
% sessionInfo.session.name = sessionName;
% sessionInfo.session.experimentName = experimentName;
channelNo = sessionInfo.nChannels;
recordingDepth = sessionInfo.recordingDepth ;
conditionNames = sessionInfo.conditionNames;
trialDuration = sessionInfo.trialDuration;
preTrialTime = sessionInfo.preTrialTime;
afterTrialTime = sessionInfo.afterTrialTime; 
visStim = sessionInfo.visStim;
optStimInterval = sessionInfo.optStimInterval;
probe = sessionInfo.probe;
animal = sessionInfo.animal;
recRegion = sessionInfo.recRegion;
chOffset = sessionInfo.chOffset;
samplingRate = sessionInfo.rates.wideband;
visStimDuration = sessionInfo.visStimDuration;

dataEv = timeSeries.events.dataEv ;
timestampsEv = timeSeries.events.timestampsEv;
infoEv = timeSeries.events.infoEv ;

condData = sessionInfo.condData;
recStartDataPoint = timeSeries.recStartDataPoint;    
dataPoints = timeSeries.dataPoints;
timestamps = timeSeries.timestamps;
% info = timeSeries.info;
med = timeSeries.medCh;
std_ch = timeSeries.stdCh;


timestamps1 = timestamps;

% load the data
data = nan(channelNo, numel(timeSeries.range1));

for i=(1:channelNo)
    clearvars data_ch data_1 timestamps
    filename = ['100_CH', num2str(i+chOffset), '.continuous'];
    [data_ch(1,:), timestamps(:,1), info(:,i)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
    data_1(1,:) = data_ch(1, ismember(timestamps, timeSeries.timestamps))-med(i);% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
    data(i,:) = data_1(:,[timeSeries.range1]); % select data based on the selected time range   
%     data(i,:) = data_1; % select all the data, regardless of the time range   
end

artefactCh = 7;
deleteArtefact

%% better use the next section


% totalEpochs = numel(condData.codes);
selCh = 20; % selected channel for figure and calculation 
z = data(selCh,:);
z_filt1(1,:) = lowpass(z(1,:), 150, 20000);
z_filt1_ds(1,:) = downsample(z_filt1,n); % keeps the 1st and then every nth sample
n=40;
for i = find(condData.codes(1:20) == 33)'%8%totalEpochs

%     x1 = (recStartDataPoint(i):recStartDataPoint(i+1)-1)/samplingRate;
    y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
    y1_filt1_ds = z_filt1_ds(1,ceil(recStartDataPoint(i)/n):floor((recStartDataPoint(i+1)-1)/n));
    figure;
    % spectrogram(x,window,noverlap,f,fs,'yaxis')
    % window must be larger than noverlap; large window -> large dots in
    % x direction, less data points
    % small f -> large dots in the y direction (multiplicative factor)
%     spectrogram(y1,128,120,128,samplingRate,'yaxis');
    subplot(2,1,1)
    spectrogram(y1,1024,960,1024,samplingRate,'yaxis'); 
    title(num2str(condData.codes(i)))
    
    subplot(2,1,2)
    [s,f,t] = spectrogram(y1_filt1_ds,128,120,128,samplingRate/n,'yaxis'); 
    % spectral values at t timepoint and f frequency
    %   f = all frequency datapoints
    %   t = all timepoints
    % If x is a signal of length Nx, then s has k columns, where
    %    k = ⌊(Nx – noverlap)/(window – noverlap)⌋ if window is a scalar.
    spectrogram(y1_filt1_ds,128,120,128,samplingRate/n,'yaxis'); 
%     ax = gca;
%     ax.YScale = 'log';
end

%%
clearvars P cP cWave F T

selCh = 19; % selected channel for figure and calculation 
z = data(selCh,:);
z_filt1(1,:) = lowpass(z(1,:), 150, 20000);
z_filt1_ds(1,:) = downsample(z_filt1,n); % keeps the 1st and then every nth sample


window  = 128;              % Window size for computing the spectrogram (FFT) [# samples]
overlap = 120;              % Overlap of the windows for computing the spectrogram [# samples]
nFFT    = 0:1:100;          % Vector defining the frequencies for computing the FFT
Fs      = 500;              % Signal sampling frequency.
j = 0;
cond = 32;
for i = find(condData.codes == cond)'%8%totalEpochs
    j = j+1;
    y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
    cWave = z_filt1_ds(1,ceil(recStartDataPoint(i)/n):floor((recStartDataPoint(i+1)-1)/n));
    [~,~,~,cP] = spectrogram(cWave,window,overlap,nFFT,Fs);
    if j == 1
        sz = size(cP);
    end    
    P(:,:,j) = cP(1:sz(1),1:sz(2));
end
P=mean(P,3);
[~,F,T,~] = spectrogram(cWave,window,overlap,nFFT,Fs);

% Plot spectrogram
figure
surf(T(1, 1:sz(2)),F,10*log10(abs(P)),'edgecolor','none');
title(num2str(cond))
line([5,13], [99 99], 'Color', 'w', 'LineWidth', 2);

%% calculate and plot avg over a frequency trhough time
PD = mean(10*log10(abs(P(1:4,:))),1);
sPD = smooth(PD, 29);
PT = mean(10*log10(abs(P(5:8,:))),1);
sPT = smooth(PT, 29);
PA = mean(10*log10(abs(P(9:12,:))),1);
sPAlpha = smooth(PA, 29);
PB = mean(10*log10(abs(P(13:30,:))),1);
sPB = smooth(PB, 29);
PG = mean(10*log10(abs(P(31:100,:))),1);
sPG = smooth(PG, 29);

%%
P10 = mean(10*log10(abs(P(1:10,:))),1);
sP10 = smooth(P10, 29);
P40 = mean(10*log10(abs(P(37:42,:))),1);
sP40 = smooth(P40, 29);
P50 = mean(10*log10(abs(P(48:53,:))),1);
sP50 = smooth(P50, 29);


figure
plot(T(1, 1:sz(2)), P10); hold on
plot(T(1, 1:sz(2)), sP10)
plot(T(1, 1:sz(2)), P40); hold on
plot(T(1, 1:sz(2)), sP40)
plot(T(1, 1:sz(2)), P50); hold on
plot(T(1, 1:sz(2)), sP50)
yl = ylim;
line([5 5], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
line([13 13], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);