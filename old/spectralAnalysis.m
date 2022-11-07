
% make sure you are in this file's folder
clearvars -except experimentName sessionName 

% experimentName = '2019-02-26_16-07-29'
% sessionName = 'V1_20190226_2'


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

savePathFigs = fullfile(basePathMatlab, 'figs', 'spectral');
if ~exist(savePathFigs, 'dir')
     mkdir(savePathFigs);
end     


%% Reverse variable atribution

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
% timestamps = timeSeries.timestamps;
% info = timeSeries.info;
med = timeSeries.medCh;
std_ch = timeSeries.stdCh;

data = nan(channelNo, numel(timeSeries.timestamps));

for i=(1:channelNo)
    clearvars data_ch data_1 timestamps
    filename = ['100_CH', num2str(i+chOffset), '.continuous'];
    [data_ch(1,:), timestamps(:,1), info(:,i)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
    disp(['ch '  num2str(i),  ' , data points: ', num2str(numel(timestamps))]);
    data_1(1,:) = data_ch(1, ismember(timestamps, timeSeries.timestamps))-med(i);% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
%     data(i,:) = data_1(:,[timeSeries.range1]); % select data based on the selected time range   
    data(i,:) = data_1; % select all the data, regardless of the time range   
end

timestamps = timeSeries.timestamps;
if ~strcmp(sessionInfo.animal.strain, 'ePetCre')
    artefactCh = 7;
    deleteArtefact
end

% data = data(:,[timeSeries.range1]);% select data based on the selected time range

clearvars data_1 data_ch timestamps1
%% calculate lfp
lfp.data = data';
lfp.timestamps = timestamps;
lfp.samplingRate = samplingRate;
n = 40; % downsample factor
lfpdown = bz_DownsampleLFP(lfp, n);
clearvars data lfp
% lfpdown.data = lfpdown.data';

%% use only the selected trials
cond = 33;
indCond = find(condData.codes == cond);
indCondSel = indCond(ismember(indCond, timeSeries.subTrialsForAnalysis));%%
events = recStartDataPoint(indCondSel)/samplingRate; % events are time 0 of trials of a specific cond
eventsVisStim = events+0.2; % start of trial +0.2 s to get the first vis stim
eventsVisStim6 = repmat(events,1,numel(sessionInfo.visStim));
eventsVisStim6 = eventsVisStim6 + repmat(sessionInfo.visStim, size(events,1),1);
eventsVisStim6 = eventsVisStim6';
eventsVisStim6 = eventsVisStim6(:);
%% events are time 0 of a visual stimulus - not adjusted to missing data points!!! - don't use
% dataEv5 = find(dataEv == 5);
% visStimOn = dataEv5(1:2:end);
% visStimOnTimestamps = timestampsEv(visStimOn);
%% sort channels
if strcmp(sessionInfo.probe, '2x16_P1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_2x16_P1.mat')
elseif strcmp(sessionInfo.probe, '2x16_E1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_2x16_E1.mat') 
elseif strcmp(sessionInfo.probe, '1x16_E1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_1x16_E1.mat') 
end    
[sorted1, IndSorted1] = sort(ycoords(1:16), 'descend');

if strcmp(sessionInfo.probe, '2')
    [sorted2, IndSorted2] = sort(ycoords(17:32), 'descend');
    IndSorted2 = IndSorted2+16;
end    
%% calculate CSD
% [csd, lfpAvg] = bz_eventCSD(lfpdown, events)%, 'channels', [8]);
saveFigs = false;

[csd2, lfpAvg2] = bz_eventCSD(lfpdown, eventsVisStim6, 'channels', IndSorted2);
if saveFigs == true
    savefig(strcat(savePathFigs, ['/sh1_cond',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/sh1_cond',  num2str(cond)], '.png'));
end

[csd1, lfpAvg1] = bz_eventCSD(lfpdown, eventsVisStim6, 'channels', IndSorted1);
if saveFigs == true
    savefig(strcat(savePathFigs, ['/sh2_cond',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/sh2_cond',  num2str(cond)], '.png'));
end
%%
clearvars P cP cWave F T

saveFigs = false;

selCh = 17; % selected channel for figure and calculation 
n=40;
z = data(selCh,:);
z_filt1(1,:) = lowpass(z(1,:), 150, 20000);
z_filt1_ds(1,:) = downsample(z_filt1,n); % keeps the 1st and then every nth sample
optStimCoords = sessionInfo.preTrialTime + sessionInfo.optStimInterval; 

window  = 128;              % Window size for computing the spectrogram (FFT) [# samples]
overlap = 120;              % Overlap of the windows for computing the spectrogram [# samples]
nFFT    = 0:1:100;          % Vector defining the frequencies for computing the FFT
Fs      = 500;              % Signal sampling frequency.
j = 0;

cond = 1;

for i = find(condData.codes == cond)'%8%totalEpochs
    if ismember(i, timeSeries.subTrialsForAnalysis)
        j = j+1;
        y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
        cWave = z_filt1_ds(1,ceil(recStartDataPoint(i)/n):floor((recStartDataPoint(i+1)-1)/n));
        [~,~,~,cP] = spectrogram(cWave,window,overlap,nFFT,Fs);
        if j == 1
            sz = size(cP);
        end
        P(:,:,j) = cP(1:sz(1),1:sz(2));
    end    
end
P=mean(P,3);
[~,F,T,~] = spectrogram(cWave,window,overlap,nFFT,Fs);


% Plot spectrogram
figure
surf(T(1, 1:sz(2)),F,10*log10(abs(P)),'edgecolor','none');
title(num2str(cond))
if cond >= 32
    line(optStimCoords, [99 99],[10 10], 'Color', 'w', 'LineWidth', 2);
end
xlabel('Time (s)')
ylabel('Frequency (Hz)')
zlabel('Frequency power')
grid off
if saveFigs == true
    savefig(strcat(savePathFigs, ['/surf_',  num2str(cond)]));
%     saveas(gcf, strcat(savePathFigs, ['/surf_',  num2str(cond)], '.png'));
end
%%
P10 = mean(10*log10(abs(P(1:10,:))),1);
sP10 = smooth(P10, 29);
P40 = mean(10*log10(abs(P(37:44,:))),1);
sP40 = smooth(P40, 29);
P50 = mean(10*log10(abs(P(48:53,:))),1);
sP50 = smooth(P50, 29);
P60 = mean(10*log10(abs(P(57:63,:))),1);
sP60 = smooth(P60, 29);
Pall = mean(10*log10(abs(P)),1);
sPall = smooth(Pall, 29);

figure
% plot(T(1, 1:sz(2)), P10); hold on
plot(T(1, 1:sz(2)), sP10, 'LineWidth', 2); hold on
% plot(T(1, 1:sz(2)), P40); hold on
plot(T(1, 1:sz(2)), sP40, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), P50); hold on
plot(T(1, 1:sz(2)), sP50, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), P60); hold on
plot(T(1, 1:sz(2)), sP60, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), Pall); hold on
plot(T(1, 1:sz(2)), sPall, 'LineWidth', 2);

title(num2str(cond))
yl = ylim;
if cond >= 32
    line([optStimCoords(1) optStimCoords(1)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
    line([optStimCoords(2) optStimCoords(2)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
end
visStimLine(:,1) = sessionInfo.preTrialTime +sessionInfo.visStim;
visStimLine(:,2) = sessionInfo.preTrialTime +sessionInfo.visStim + sessionInfo.visStimDuration;
if cond ~= 0 && cond ~= 32
    for i = (1:numel(sessionInfo.visStim))
        h2 = line([visStimLine(i,1) visStimLine(i,2)], [yl(2) yl(2)]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
end
legend('P10', 'P40', 'P50', 'P60', 'Pall');
box off
xlabel('Time (s)')
ylabel('Frequency power')
if saveFigs == true
    savefig(strcat(savePathFigs, ['/freq1_',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/freq1_',  num2str(cond)], '.png'));
end
%% calculate and plot avg over a frequency trhough time
PD = mean(10*log10(abs(P(1:4,:))),1);
sPD = smooth(PD, 29);
PT = mean(10*log10(abs(P(5:8,:))),1);
sPT = smooth(PT, 29);
PA = mean(10*log10(abs(P(9:12,:))),1);
sPA = smooth(PA, 29);
PB = mean(10*log10(abs(P(13:30,:))),1);
sPB = smooth(PB, 29);
PG = mean(10*log10(abs(P(31:100,:))),1);
sPG = smooth(PG, 29);

figure
% plot(T(1, 1:sz(2)), PD); hold on
plot(T(1, 1:sz(2)), sPD, 'LineWidth', 2); hold on
% plot(T(1, 1:sz(2)), PT); hold on
plot(T(1, 1:sz(2)), sPT, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), PA); hold on
plot(T(1, 1:sz(2)), sPA, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), PB); hold on
plot(T(1, 1:sz(2)), sPB, 'LineWidth', 2);
% plot(T(1, 1:sz(2)), PG); hold on
plot(T(1, 1:sz(2)), sPG, 'LineWidth', 2);

title(num2str(cond))

yl = ylim;
yl(1) = 0;
clearvars ylim
ylim(yl);

if cond >= 32
    line([optStimCoords(1) optStimCoords(1)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
    line([optStimCoords(2) optStimCoords(2)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
end
visStimLine(:,1) = sessionInfo.preTrialTime +sessionInfo.visStim;
visStimLine(:,2) = sessionInfo.preTrialTime +sessionInfo.visStim + sessionInfo.visStimDuration;
if cond ~= 0 && cond ~= 32
    for i = (1:numel(sessionInfo.visStim))
        h2 = line([visStimLine(i,1) visStimLine(i,2)], [yl(2) yl(2)]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
end
legend('delta(1-4)', 'theta(5-8)', 'alpha(9-12)', 'beta(13-30)', 'gamma(31-100)');
box off
xlabel('Time (s)')
ylabel('Frequency power')
if saveFigs == true
    savefig(strcat(savePathFigs, ['/freq2_',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/freq2_',  num2str(cond)], '.png'));
end


%%  must be updated

% 
% % totalEpochs = numel(condData.codes);
% selCh = 20; % selected channel for figure and calculation 
% z = data(selCh,:);
% z_filt1(1,:) = lowpass(z(1,:), 150, 20000);
% z_filt1_ds(1,:) = downsample(z_filt1,n); % keeps the 1st and then every nth sample
% n=40;
% for i = find(condData.codes(1:20) == 33)'%8%totalEpochs
% 
% %     x1 = (recStartDataPoint(i):recStartDataPoint(i+1)-1)/samplingRate;
%     y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
%     y1_filt1_ds = z_filt1_ds(1,ceil(recStartDataPoint(i)/n):floor((recStartDataPoint(i+1)-1)/n));
%     figure;
%     % spectrogram(x,window,noverlap,f,fs,'yaxis')
%     % window must be larger than noverlap; large window -> large dots in
%     % x direction, less data points
%     % small f -> large dots in the y direction (multiplicative factor)
% %     spectrogram(y1,128,120,128,samplingRate,'yaxis');
%     subplot(2,1,1)
%     spectrogram(y1,1024,960,1024,samplingRate,'yaxis'); 
%     title(num2str(condData.codes(i)))
%     
%     subplot(2,1,2)
%     [s,f,t] = spectrogram(y1_filt1_ds,128,120,128,samplingRate/n,'yaxis'); 
%     % spectral values at t timepoint and f frequency
%     %   f = all frequency datapoints
%     %   t = all timepoints
%     % If x is a signal of length Nx, then s has k columns, where
%     %    k = ⌊(Nx – noverlap)/(window – noverlap)⌋ if window is a scalar.
%     spectrogram(y1_filt1_ds,128,120,128,samplingRate/n,'yaxis'); 
% %     ax = gca;
% %     ax.YScale = 'log';
% end