%%% created by RB on 24.01.2022
%%% analysis of LFP signal in all experiments
%%% run after th 2 first sections in allExpDataVisualization_A3 (comment out
%%% everything with cellMetrics, uncomment everything with lfp)

saveFigs = false;
saveStats = false;
savePath = [strjoin({path{1:end}, 'figs','2024-01',  'PvCre', 'long','lfp'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

% provisional time line
T = (lfp.SpectrParams.window/ 2 /lfp.SpectrParams.Fs:...
    (lfp.SpectrParams.window-lfp.SpectrParams.overlap)/lfp.SpectrParams.Fs:...
    (sessionInfo.trialDuration+sessionInfo.preTrialTime - lfp.SpectrParams.window/ 2 /lfp.SpectrParams.Fs));
F = lfp.SpectrParams.nFFT; % frequency values spectrogram

conds = struct2array(sessionInfo.conditionNames);

% can be removed after integrating this exp with the entire analysis
if sessionInfoAll.trialDuration == 18
    C = [[0 0 0]; [0 0 1];  [0.7 0.7 0.7]; [0 0.4470 0.7410]; [0 0 0]; [0.5 0.5 0.5]]; % black, navy-blue, grey, light blue, black, dark grey - traces
elseif sessionInfoAll.trialDuration == 6 || sessionInfoAll.trialDuration == 9 
    C = [repmat([0 0 0; 0 0 1],4,1); [0.7 0.7 0.7]; [0 0.4470 0.7410]; repmat([0 0 0; 0.5 0.5 0.5], 4,1)]; % (black, navy-blue)*4, grey, light blue, (black, dark grey)*4 - traces

    for i= 1:(totalConds/2-1)
        contrasts(i)= floor(100/2^(i-1));
    end
    contrasts0 = [contrasts, 0];
end
fs = 24; %font size

%% select for each experiment the channel with the highest STD or the deepest ch

%%%%%
chooseCh = 'all';%'all'; % choose between {'maxStd', 'deepest', 'all', 'oneChID'};
selCh = 1; % only works if chooseCh = 'oneChID'
normFFT = 2; % [2, 1, 0]; 2- normalize to each exp, to each non-ph stim cond; 1 means normalize to the 100% non-photostim condition; 0 - no norm
bin = 1;
% choose one set of the next lines
P1_shortMean = lfpAll.FFT.P1_shortMean;    % entire photostim period
f = lfpAll.FFT.f; % frequency values FFT
% P1_shortMean = lfpAll.FFT.P1_shortLast3Mean;   % last 3 sec
% f = lfpAll.FFT.fLast3; % frequency values FFT
% P1_shortMean = lfpAll.FFT.P1_shortVisOptStimMean; % 1 sec following vis stim during photostim
% f = lfpAll.FFT.fVisOptStim; % frequency values FFT

%%%%%

% binning
newLen = ceil(size(P1_shortMean, 3) / bin);
sz_nan = size(P1_shortMean);
sz_nan(3) = newLen*bin - size(P1_shortMean, 3);
P1_shortMean_temp = cat(3, P1_shortMean, nan(sz_nan));
size_new = [size(P1_shortMean, 1), size(P1_shortMean, 2), bin, size(P1_shortMean, 3)];
size_new(4) = newLen;
P1_shortMean_temp2 = squeeze(nanmean(reshape(P1_shortMean_temp, size_new), 3));
P1_shortMean = P1_shortMean_temp2;
f_temp = f(1:bin:end);
f = f_temp;

% numChPerExp: array containing the total number of channels analyzed for lfp
count = 1;
numChPerExp = [];
for i = 2 :numel(lfpAll.channelsToLoad)
    if lfpAll.channelsToLoad(i-1) > lfpAll.channelsToLoad(i) % if theprevious channel ID is larger than the current, it means there is a new exp
        numChPerExp(end+1) = count;%i - sum(chPerExp);
        count = 1;
    else
        count = count + 1;
    end
end    
numChPerExp(end+1) = count;

% chInExp: cell array containing the chIds for each experiment
for exp = 1:numel(numChPerExp)
    if exp == 1
         chInExp{exp} = lfpAll.channelsToLoad(1:numChPerExp(exp));
    else
        chInExp{exp} = lfpAll.channelsToLoad((1:numChPerExp(exp))+sum(numChPerExp(1:exp-1)));
    end    
end

% the selCh can only be applied to lfpAll, not to sessionInfoAll or timeSeriesAll
selChExp = nan(size(chInExp));

switch chooseCh
    case 'oneChID'
        % selected channel only
        selChExp = find(lfpAll.channelsToLoad == selCh);
    case {'maxStd', 'deepest'}
        I = nan(size(chInExp));
        count = 1;
        figure;
        for exp = 1:numel(numChPerExp)
            switch chooseCh
                case 'maxStd'
                    % select the channel with the smallest std 
                    stdChCurrExp = timeSeriesAll.stdCh(count:sum(sessionInfoAll.nChannels(1:exp)));
                    [M, I(exp)] = max(stdChCurrExp(chInExp{exp})) ;
                    plot(1+sum(numChPerExp(1:exp-1)):sum(numChPerExp(1:exp)), stdChCurrExp(chInExp{exp})); hold on                   
                case 'deepest'
                    % OR select the deepest channel
                    chDepthCurrExp = realDepthChannelAll(count:sum(sessionInfoAll.nChannels(1:exp)));
                    [M, I(exp)] = min(chDepthCurrExp(chInExp{exp})) ;
                    plot(1+sum(numChPerExp(1:exp-1)):sum(numChPerExp(1:exp)), chDepthCurrExp(chInExp{exp})); hold on                    
            end
            selChExp(exp) =  I(exp) + sum(numChPerExp(1:exp-1)); % chInExp{exp}(I(exp))
            scatter(selChExp(exp), M, 'ob')
            count = count + sessionInfoAll.nChannels(exp);                        
        end        
end     

smooth_param = 9;
count = 1;
P1_shortMeanAll = nan(numel(numChPerExp), totalConds, size(P1_shortMean,3));
for exp = 1:size(P1_shortMeanAll,1)
    for cond = 1: totalConds
        switch chooseCh
            case 'all'
                P1_shortMeanCurr = smooth(squeeze(mean(P1_shortMean(count:sum(numChPerExp(1:exp)),cond,:),1)), smooth_param);
            otherwise
                P1_shortMeanCurr = smooth(squeeze(P1_shortMean(selChExp(exp),cond,:)), smooth_param);
        end
        if normFFT
            if normFFT == 2 % normalize to each exp, to each non-ph stim cond
                condNorm = floor((cond+1)/2)*2-1; 
            elseif normFFT == 1   % normalize to each exp, tothe 100% non-photostim cond
                condNorm = 1; 
            end
            if cond == condNorm
                u(exp, condNorm) = max(P1_shortMeanCurr);
            end
            P1_shortMeanAll(exp, cond, :) = P1_shortMeanCurr/ u(exp, condNorm); % channels, conds, freq
        else
            P1_shortMeanAll(exp, cond, :) = P1_shortMeanCurr; % channels, conds, freq
        end
    end    
    count = count + numChPerExp(exp);   
end


n = ceil(sqrt(size(P1_shortMeanAll,1)));
figure % each subplot is an experiment
for exp = 1:size(P1_shortMeanAll,1)
    subplot(n,n, exp);
    for cond = 1: totalConds
        plot(f(1:500), squeeze(P1_shortMeanAll(exp, cond, 1:500)), 'Color', C(cond,:)); hold on
    end
end

% for cond = 1:totalConds
%     figure; % one trace for each exp
%     for i = 1: size(P1_shortMeanAll,1)
%         plot(f(1:500),smooth(squeeze(P1_shortMeanAll(i, cond, 1:500)),1)); hold on %
%     end
%     title('Single-Sided Amplitude Spectrum of X(t)')
%     xlabel('f (Hz)')
%     ylabel('|P1(f)|')
% end


%% fft of freq in the selected time range 


P1_shortMeanAllMean = squeeze(mean(P1_shortMeanAll,1));
STEM_P1_shortMeanAll = nan(size(P1_shortMeanAllMean));

for cond = 1 : totalConds
    for datapoint = 1:size(P1_shortMeanAllMean,2)
        STEM_P1_shortMeanAll(cond, datapoint) = nanstd(P1_shortMeanAll(:, cond, datapoint))/sqrt(sum(~isnan(P1_shortMeanAll(:, cond, datapoint))));
    end 
end

% slowW, delta, theta, alpha, beta, gamma
waveFreq = [0 1; 1 4; 4 8; 8 12; 12 30; 30 70];

for freq = 1:size(waveFreq,1)
    waveFreqInd_P1{freq} = find(f == waveFreq(freq,1)):find(f == waveFreq(freq,2));
    P1_shortMeanAllWave(:,:,freq) = mean(P1_shortMeanAll(:,:,waveFreqInd_P1{freq}),3);
end    

P1_shortMeanAllWaveMean = squeeze(mean(P1_shortMeanAllWave,1));
STEM_P1_shortMeanAllWave = nan(size(P1_shortMeanAllWaveMean));

for cond = 1 : totalConds
    for freq = 1:size(P1_shortMeanAllWaveMean,2)
        STEM_P1_shortMeanAllWave(cond, freq) = nanstd(P1_shortMeanAllWave(:, cond, freq))/sqrt(sum(~isnan(P1_shortMeanAllWave(:, cond, freq))));
    end 
end

for cond = 1:2:totalConds
    for freq = 1:size(waveFreq,1)
        [hP1_shortMeanAllWave((cond+1)/2,freq), pP1_shortMeanAllWave((cond+1)/2,freq)] = ttest(squeeze(P1_shortMeanAllWave(:, cond,freq)),squeeze(P1_shortMeanAllWave(:, cond+1,freq))); % param: stim in photostim cond vs stim in non-photostim cond
    end    
end
applyBonfCorr = 1;

figure60a
figure60b

%% surface figure of a selected channel
optStimCoords = sessionInfo.preTrialTime + sessionInfo.optStimInterval; 

switch chooseCh
    case 'all'
        % perform avg across all ch in each exp
        sz  = size(lfpAll.Spectr.P);
        sz(1) = numel(chInExp); % num exps
        P_all = nan(sz); % channels x exp, conds, freq, time
        count = 1;
        for exp = 1:numel(chInExp)
            for cond = 1: size(P1_shortMeanAll, 2)
                P_all(exp,:,:,:) = mean(lfpAll.Spectr.P(count:sum(numChPerExp(1:exp)),:,:,:),1);
            end
            count = count + numChPerExp(exp);
        end        
    otherwise % selChExp should have already been calculated above, otherwise error
        P_all = lfpAll.Spectr.P(selChExp,:,:,:); % channels x exp, conds, freq, time        
end

smooth_param = 1;
P_all_mean = smoothdata(squeeze(mean(P_all, 1)), 3, 'movmean', smooth_param);

figure61a % Plot spectrogram of each condition
figure61b % Plot spectrogram difference between conditions
%% Isolate spectrograms of particular bands

for freq = 1:size(waveFreq,1)
    waveFreqInd_P{freq} = find(F == waveFreq(freq,1)):find(F == waveFreq(freq,2));
end    

% figure62a % spectrogram of lfp of single bands; one fig for each band, all conds in the same fig
% figure62b % spectrogram of lfp of single bands; one fig for each band, 2 conds in the same fig
% figure62c % Difference (vis - (vis+opt)) of lfp of a single band spectrogram 
figure62d %  Spectrogram of lfp  of a single band of two conds + their diff
%% calculate and plot avg over a frequency band through time

smooth_param = 19;
P_allWave = nan(size(P_all,1), size(P_all,2), numel(freqs), size(P_all,4)); % exps, cons, freqs, time data points
for freq = freqs 
    for cond = 1:totalConds-2
        P_allWave(:,cond,freq, :) = smoothdata(mean(10*log10(abs(P_all(:,cond,waveFreqInd_P{freq}(1:end-1),:))),3), 4, 'movmean', smooth_param);
    end
    for cond = totalConds-1: totalConds % higher smoothing for spont conds
        P_allWave(:,cond,freq, :) = smoothdata(mean(10*log10(abs(P_all(:,cond,waveFreqInd_P{freq}(1:end-1),:))),3), 4, 'movmean', smooth_param*2);
    end
end    

P_allWaveMean = squeeze(mean(P_allWave,1)); 

STEM_P_allWave = nan(size(P_allWaveMean));

for cond = 1 : totalConds
    for freq = freqs
        for datapoint = 1:numel(T)
            STEM_P_allWave(cond, freq, datapoint) = nanstd(P_allWave(:, cond, freq, datapoint))/sqrt(sum(~isnan(P_allWave(:, cond, freq, datapoint))));
        end
    end
end

figure63 % Trace depicting average spectrogram of lfp  of a single band
