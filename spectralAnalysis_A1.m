%%% Created by RB on 24.01.2022

clearvars -except experimentName sessionName expSetFilt k a b

% experimentName = '2019-02-26_16-07-29'
% sessionName = 'V1_20190226_2'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKilosort = strjoin({basePath, 'kilosort analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
filenameLFP = fullfile(basePathMatlab,[sessionName,'.lfp4.mat']); % lfp

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[lfp, LFPexist] = tryLoad('lfp', filenameLFP);

savePathFigs = fullfile(basePathMatlab, 'figs', 'spectral');

if ~exist(savePathFigs, 'dir')
     mkdir(savePathFigs);
end     


%% Reverse variable atribution

loadSessionInfo
loadTimeSeries  

%%% Deniz
% designSpecs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',0.01,1,300,1000,60,1,20,samplingRate);
% designmethods(designSpecs,'SystemObject',true)
% designoptions(designSpecs,'cheby1','SystemObject',true)
% BP = design(designSpecs,'cheby1','FilterStructure','df1sos','SystemObject',true)
% % fvtool(BP)
% samplingRate = 20000;

% data_2(:,1) = BP(data_1(:,1));
%%%%%%%%%%

% notch filter
q = 180;% quality factor 300
w=50/(20000/2);
bw=w/q;  
[num,den]=iirnotch(w,bw); % notch filter implementation 
% fvtool(num,den)


clearvars timestamps info range1 range2 subTrialsForAnalysis ts 

if LFPexist
    loadLFP
else    

    % select a few channels to load
    % select 32 channels or all the channels if less then 32 have been recorded
    % avoid channels 16 and 35 for 2x32_H6, as they might be broken
    
    channelsToLoad = round(linspace(1, channelNo, min(32, channelNo)));
    fltrFreq = 300;
    fltrFreqInt = [1 300];
    

    try       
       data = nan(numel(timeSeries.timestamps), numel(channelsToLoad)); 
       for j = 1:numel(channelsToLoad) %(1:channelNo)
            i = channelsToLoad(j);
            clearvars data_ch data_1 timestamps data_2
            filename = ['100_CH', num2str(i+chOffset), '.continuous'];
            [data_ch(1,:), timestamps(:,1), info(:,i)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
            disp(['ch '  num2str(i),  ' , data points: ', num2str(numel(timestamps))]);
            data_1(:,1) = data_ch(1, ismember(timestamps, timeSeries.timestamps))-med(i);% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
            data_2(:,1) = lowpass(data_1(:,1), fltrFreq, samplingRate); % use this one
            data(:,j) = filter(num,den,data_2(:,1)); % notch filt
        end
    catch ME
        warning('avoided timestamps error')
        data = nan(numel(timeSeries.timestamps), numel(channelsToLoad)); 
        for j = 1:numel(channelsToLoad) %(1:channelNo)
            i = channelsToLoad(j);
            clearvars data_ch data_1 timestamps data_2
            filename = ['100_CH', num2str(i+chOffset), '.continuous'];
            [data_ch(1,:), timestamps(:,1), info(:,i)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
            disp(['ch '  num2str(i),  ' , data points: ', num2str(numel(timestamps))]);
            data_1(:,1) = data_ch(1, ismember(timestamps, timeSeries.timestamps))-med(i);% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
            data_2(:,1) = lowpass(data_ch(1,:), fltrFreq, samplingRate); % use in case of error
            data(:,j) = filter(num,den,data_2(:,1)); % notch filt
        end    
    end

    timestamps = timeSeries.timestamps;
   
    clearvars data_1 data_ch timestamps1
end
%% calculate lfp
if ~LFPexist

    lfp1.data = data;
    lfp1.timestamps = timestamps;
    lfp1.samplingRate = samplingRate;
    downSampleF = 20; % downsample factor
    
    lfp = bz_DownsampleLFP(lfp1, downSampleF);
    lfp.fltrFreq = fltrFreq;
    lfp.channelsToLoad = channelsToLoad; % implement something like this
    
    clearvars data lfp1
    
%     if exist(filenameLFP,'file')
%         warning('.lfp.mat file already exists.')
%     else
%         %      cfLFP = checkFields(lfp); % must be implemented
%         %      if ~cfLFP
%         lfp
%         disp(['Saving ', experimentName, ' / ' , sessionName, ' .lfp.mat file'])
%         save(filenameLFP, 'lfp')
%         %      end
%     end

end

%%

clearvars P P1_short P_temp P1_shortLast3 P1_shortLast3_temp P1_shortVisOptStim P1_shortVisOptStim_temp

saveFigs = false;

optStimCoords = sessionInfo.preTrialTime + sessionInfo.optStimInterval; 

downSampleF = 20;
window  = 128;              % Window size for computing the spectrogram (FFT) [# samples]
overlap = 120;              % Overlap of the windows for computing the spectrogram [# samples]
nFFT    = 0:1:100;          % Vector defining the frequencies for computing the FFT
Fs      = samplingRate/downSampleF;              % Signal sampling frequency.

conds = struct2array(conditionNames);
totalConds = numel(conds); 
disp('Calculating the spectrum...');
for chInd = 1:numel(channelsToLoad) %(1:channelNo)
    ch = channelsToLoad(chInd);
    disp(['channel '  num2str(ch)]);
    lfp_ch = lfp.data(:,chInd)';
    
    for condInd = 1:totalConds % for all conditions
        cond = conds(condInd);
        trialInd = 0;       
        for i = find(condData.codes == cond)'
            if ismember(i, timeSeries.subTrialsForAnalysis)
                trialInd = trialInd+1;
                % analyze the entire trial for spectrogarm
                timeInt = ceil(recStartDataPoint(i)/downSampleF) : (ceil(recStartDataPoint(i)/downSampleF) + ...
                    (preTrialTime+trialDuration)*samplingRate/downSampleF);
                cWave = lfp_ch(1,timeInt);
                
                [~,F,T,cP] = spectrogram(cWave,window,overlap,nFFT,Fs);
                
                if  ~exist('P_temp','var') % initialize P_temp
                    P_temp = nan(numel(trialsForAnalysis), numel(nFFT), size(cP,2));
                end
                
                P_temp(trialInd,:,:) = cP;
                
                % analyze the opto-stimulated part of the trial for fft
                timeInt_short = ceil(recStartDataPoint(i)/downSampleF) + preTrialTime*samplingRate/downSampleF +...
                    (optStimInterval(1)*samplingRate/downSampleF:1:(optStimInterval(2)-1/samplingRate/downSampleF)*samplingRate/downSampleF);
                cWave_short = lfp_ch(1,timeInt_short);
                
                [P1_short_temp, f] = fftRB(cWave_short, Fs);

                if  ~exist('P1_short','var')% initialize P1_short
                    P1_short = nan(numel(channelsToLoad), totalConds, numel(trialsForAnalysis), numel(P1_short_temp));
                end
                P1_short(chInd, condInd, trialInd, :) = P1_short_temp;
                
                                
                % last 3 s of the photostim time
                timeInt_shortLast3 = ceil(recStartDataPoint(i)/downSampleF) + preTrialTime*samplingRate/downSampleF +...
                    ((optStimInterval(1)+5)*samplingRate/downSampleF:1:(optStimInterval(2)-1/samplingRate/downSampleF)*samplingRate/downSampleF);
                
                cWave_shortLast3 = lfp_ch(1,timeInt_shortLast3);
                
                [P1_shortLast3_temp, fLast3] = fftRB(cWave_shortLast3, Fs);

                if  ~exist('P1_shortLast3','var')% initialize P1_short
                    P1_shortLast3 = nan(numel(channelsToLoad), totalConds, numel(trialsForAnalysis), numel(P1_shortLast3_temp));
                end
                P1_shortLast3(chInd, condInd, trialInd, :) = P1_shortLast3_temp;
                
                % one sec after the vis stim during photostim
                timeInt_short_visOptStim = ceil(recStartDataPoint(i)/downSampleF) + preTrialTime*samplingRate/downSampleF +...
                    [sessionInfo.visStim(2)*samplingRate/downSampleF:1:((sessionInfo.visStim(2)+1)-1/samplingRate/downSampleF)*samplingRate/downSampleF,...
                    sessionInfo.visStim(3)*samplingRate/downSampleF:1:((sessionInfo.visStim(3)+1)-1/samplingRate/downSampleF)*samplingRate/downSampleF,...
                    sessionInfo.visStim(4)*samplingRate/downSampleF:1:((sessionInfo.visStim(4)+1)-1/samplingRate/downSampleF)*samplingRate/downSampleF];
                
                cWave_shortVisOptStim = lfp_ch(1,timeInt_short_visOptStim);
                
                [P1_shortVisOptStim_temp, fVisOptStim] = fftRB(cWave_shortVisOptStim, Fs);

                if  ~exist('P1_shortLast3','var')% initialize P1_short
                    P1_shortVisOptStim = nan(numel(channelsToLoad), totalConds, numel(trialsForAnalysis), numel(P1_shortVisOptStim_temp));
                end
                P1_shortVisOptStim(chInd, condInd, trialInd, :) = P1_shortVisOptStim_temp; 
                                
            end
        end
        
        if  ~exist('P','var')
            P = nan(numel(channelsToLoad), totalConds, numel(nFFT), size(cP,2));
        end
        P(chInd, condInd, :, :) = squeeze(mean(P_temp,1));
        clearvars P_temp
    end
end
P1_shortMean = squeeze(mean(P1_short, 3)); % dimentions: channel, cond, trials, freq
P1_shortLast3Mean = squeeze(mean(P1_shortLast3, 3)); % dimentions: channel, cond, trials, freq
P1_shortVisOptStimMean = squeeze(mean(P1_shortVisOptStim, 3)); % dimentions: channel, cond, trials, freq
P_mean = squeeze(mean(P,3)); % Makes no sense to avg!! dimentions: channel, cond, freq, time

Spectr.P = P;
Spectr.P_mean = P_mean;

SpectrParams.window  = window;             % Window size for computing the spectrogram (FFT) [# samples]
SpectrParams.overlap = overlap;             % Overlap of the windows for computing the spectrogram [# samples]
SpectrParams.nFFT    = nFFT;          % Vector defining the frequencies for computing the FFT
SpectrParams.F    = F;          % should replace nFFT
SpectrParams.T    = T;          % NEW!!!
SpectrParams.Fs      = Fs;              % Signal sampling frequency.

FFT.P1_shortMean = P1_shortMean;
FFT.f = f;
FFT.P1_shortLast3Mean = P1_shortLast3Mean;
FFT.fLast3 = fLast3;
FFT.P1_shortVisOptStimMean = P1_shortVisOptStimMean;
FFT.fVisOptStim = fVisOptStim;

lfp.SpectrParams = SpectrParams;
lfp.Spectr = Spectr;
lfp.FFT = FFT;

if exist(filenameLFP,'file')
    warning('.lfp.mat file already exists.')
else
    %      cfLFP = checkFields(lfp); % must be implemented
    %      if ~cfLFP
    lfp
    disp(['Saving ', experimentName, ' / ' , sessionName, ' .lfp4.mat file'])
    save(filenameLFP, 'lfp')
%          end
end

%% spectrum of freq in the selected time range - selected channel only
% % 
% selCh = 1;
% condInd = 1;% 1 or 3
% cond = conds(condInd);
% 
% figure;
% % plot(f(1:400),smooth(P1_shortMean(selCh, condInd, 1:400),1)); hold on
% % plot(f(1:400),smooth(P1_shortMean(selCh, condInd+1, 1:400),1)); hold on
% plot(f(1:500),smooth(lfp.FFT.P1_shortMean(selCh, condInd, 1:500),1));hold on
% plot(f(1:500),a);hold on
% % plot(f(1:500),smooth(lfp.FFT.P1_shortMean(selCh, condInd+1, 1:500),1)); hold on
% % plot(f(1:500),b);hold on
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

%% spectrum of freq in the selected time range - average of all channels

% P1_shortMeanMean = squeeze(mean(P1_shortMean,1));
% condInd = 3;% 1 or 3
% cond = conds(condInd);
% 
% figure;
% plot(f(1:400),smooth(P1_shortMeanMean(condInd, 1:400),1)); hold on
% plot(f(1:400),smooth(P1_shortMeanMean(condInd+1, 1:400),1))
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

%% surface figure of a selected channel

% selCh = 1;
% P_sel = squeeze(P(selCh, condInd, :, :));
% 
% % Plot spectrogram
% figure
% surf(T,F,10*log10(abs(P_sel)),'edgecolor','none');
% title(num2str(cond))
% if cond >= 32
%     line(optStimCoords, [99 99],[10 10], 'Color', 'w', 'LineWidth', 2);
% end
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% zlabel('Frequency power')
% grid off
% if saveFigs == true
%     savefig(strcat(savePathFigs, ['/surf_',  num2str(cond)]));
% %     saveas(gcf, strcat(savePathFigs, ['/surf_',  num2str(cond)], '.png'));
% end

%%
% P = ;
% sz = size(P_sel);
% P10 = mean(10*log10(abs(P_sel(1:10,:))),1);
% sP10 = smooth(P10, 29);
% P40 = mean(10*log10(abs(P_sel(37:44,:))),1);
% sP40 = smooth(P40, 29);
% P50 = mean(10*log10(abs(P_sel(48:53,:))),1);
% sP50 = smooth(P50, 29);
% P60 = mean(10*log10(abs(P_sel(57:63,:))),1);
% sP60 = smooth(P60, 29);
% Pall = mean(10*log10(abs(P_sel)),1);
% sPall = smooth(Pall, 29);
% 
% figure
% % plot(T(1, 1:sz(2)), P10); hold on
% plot(T(1, 1:sz(2)), sP10, 'LineWidth', 2); hold on
% % plot(T(1, 1:sz(2)), P40); hold on
% plot(T(1, 1:sz(2)), sP40, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), P50); hold on
% plot(T(1, 1:sz(2)), sP50, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), P60); hold on
% plot(T(1, 1:sz(2)), sP60, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), Pall); hold on
% plot(T(1, 1:sz(2)), sPall, 'LineWidth', 2);
% 
% title(num2str(cond))
% yl = ylim;
% if cond >= 32
%     line([optStimCoords(1) optStimCoords(1)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
%     line([optStimCoords(2) optStimCoords(2)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
% end
% visStimLine(:,1) = sessionInfo.preTrialTime +sessionInfo.visStim;
% visStimLine(:,2) = sessionInfo.preTrialTime +sessionInfo.visStim + sessionInfo.visStimDuration;
% if cond ~= 0 && cond ~= 32
%     for i = (1:numel(sessionInfo.visStim))
%         h2 = line([visStimLine(i,1) visStimLine(i,2)], [yl(2) yl(2)]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
%         set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
%     end
% end
% legend('P10', 'P40', 'P50', 'P60', 'Pall');
% box off
% xlabel('Time (s)')
% ylabel('Frequency power')
% if saveFigs == true
%     savefig(strcat(savePathFigs, ['/freq1_',  num2str(cond)]));
%     saveas(gcf, strcat(savePathFigs, ['/freq1_',  num2str(cond)], '.png'));
% end

%% calculate and plot avg over a frequency trhough time
% PD = mean(10*log10(abs(P_sel(1:4,:))),1);
% sPD = smooth(PD, 29);
% PT = mean(10*log10(abs(P_sel(5:8,:))),1);
% sPT = smooth(PT, 29);
% PA = mean(10*log10(abs(P_sel(9:12,:))),1);
% sPA = smooth(PA, 29);
% PB = mean(10*log10(abs(P_sel(13:30,:))),1);
% sPB = smooth(PB, 29);
% PG = mean(10*log10(abs(P_sel(31:100,:))),1);
% sPG = smooth(PG, 29);
% 
% figure
% % plot(T(1, 1:sz(2)), PD); hold on
% plot(T(1, 1:sz(2)), sPD, 'LineWidth', 2); hold on
% % plot(T(1, 1:sz(2)), PT); hold on
% plot(T(1, 1:sz(2)), sPT, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), PA); hold on
% plot(T(1, 1:sz(2)), sPA, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), PB); hold on
% plot(T(1, 1:sz(2)), sPB, 'LineWidth', 2);
% % plot(T(1, 1:sz(2)), PG); hold on
% plot(T(1, 1:sz(2)), sPG, 'LineWidth', 2);
% 
% title(num2str(cond))
% 
% yl = ylim;
% % yl(1) = 0;
% clearvars ylim
% ylim(yl);
% 
% if cond >= 32
%     line([optStimCoords(1) optStimCoords(1)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
%     line([optStimCoords(2) optStimCoords(2)], [yl(1) yl(2)], 'Color', 'b', 'LineWidth', 2);
% end
% visStimLine(:,1) = sessionInfo.preTrialTime +sessionInfo.visStim;
% visStimLine(:,2) = sessionInfo.preTrialTime +sessionInfo.visStim + sessionInfo.visStimDuration;
% if cond ~= 0 && cond ~= 32
%     for i = (1:numel(sessionInfo.visStim))
%         h2 = line([visStimLine(i,1) visStimLine(i,2)], [yl(2) yl(2)]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
%         set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
%     end
% end
% legend('delta(1-4)', 'theta(5-8)', 'alpha(9-12)', 'beta(13-30)', 'gamma(31-100)');
% box off
% xlabel('Time (s)')
% ylabel('Frequency power')
% if saveFigs == true
%     savefig(strcat(savePathFigs, ['/freq2_',  num2str(cond)]));
%     saveas(gcf, strcat(savePathFigs, ['/freq2_',  num2str(cond)], '.png'));
% end


%%  not necessary
% 
% 
% % totalEpochs = numel(condData.codes);
% selCh = 20; % selected channel for figure and calculation 
% z = data(selCh,:);
% z_filt1(1,:) = lowpass(z(1,:), 150, 20000);
% z_filt1_ds(1,:) = downsample(z_filt1,downSampleF); % keeps the 1st and then every nth sample
% n=40;
% for i = find(condData.codes(1:20) == 33)'%8%totalEpochs
% 
% %     x1 = (recStartDataPoint(i):recStartDataPoint(i+1)-1)/samplingRate;
%     y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
%     y1_filt1_ds = z_filt1_ds(1,ceil(recStartDataPoint(i)/downSampleF):floor((recStartDataPoint(i+1)-1)/downSampleF));
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
%     [s,f,t] = spectrogram(y1_filt1_ds,128,120,128,samplingRate/downSampleF,'yaxis'); 
%     % spectral values at t timepoint and f frequency
%     %   f = all frequency datapoints
%     %   t = all timepoints
%     % If x is a signal of length Nx, then s has k columns, where
%     %    k = ⌊(Nx – noverlap)/(window – noverlap)⌋ if window is a scalar.
%     spectrogram(y1_filt1_ds,128,120,128,samplingRate/downSampleF,'yaxis'); 
% %     ax = gca;
% %     ax.YScale = 'log';
% end