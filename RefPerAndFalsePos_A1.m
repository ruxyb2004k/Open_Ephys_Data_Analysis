%%% Refractory period ratio based on trialsForAnalysisSelected for all selected
%%% units
% created by RB on 20.04.2020 
% run after SpikeDataLoading_openEphys.m and loads traceFreqAndInfo1


% experimentName = '2020-07-20_16-45-13'
% sessionName = 'V1_20200720_2'

histoHalfWidth = 0.025; % in sec
histoBin = 0.0005; % in sec
ref_per = 0.002; % refractory period
cens_per = 0.0005;% censored period

% uncomment the next lines only if this script is run separately from another script (like SpikeDataLoading)
% path = strsplit(pwd,filesep);
% basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
% basePathData = strjoin({basePath, 'data'}, filesep);
% basePathKlusta = strjoin({basePath, 'klusta analysis'}, filesep);
% basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);
% 
% filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
% filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
% filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
% 
% [sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
% [timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
% [spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);

totalConds = numel(fieldnames(sessionInfo.conditionNames));

totalCodes = size(spikeClusterData.uniqueCodes,1);
totalTrials = numel(spikeClusterData.trialsForAnalysisSelected);
falsePos = nan(totalCodes,1);
refrPeriodRatio = nan(totalCodes,1);
presence = nan(totalCodes,1);

for ind = 1:totalCodes
    trialPresence = nan(20,1);%nan(numel(condData.times)/totalConds,1);
    clusterCode = spikeClusterData.uniqueCodes(ind,1);
    x=spikeClusterData.rangeTimes(spikeClusterData.codes==clusterCode);

    lastPoint = max(x(end), sessionInfo.condData.times(end))+sessionInfo.preTrialTime; % buffer preTrialTime s
    histocIntAll = [sessionInfo.condData.times(1:totalConds:end); lastPoint];
    
    x_part = [];

    for trial = spikeClusterData.trialsForAnalysisSelected
        x_curr_trial = x(x > histocIntAll(trial)-sessionInfo.preTrialTime & x < histocIntAll(trial+1)-sessionInfo.preTrialTime);
        x_part = [x_part; x_curr_trial];  
        trialPresence(trial) = numel(x_curr_trial)>0; 
    end
    
    presence(ind) = sum(trialPresence==1)/totalTrials;
    
    if numel(x_part)<40000 % otherwise the matrices will be too large
        
        x = x_part;
        
        y = zeros(numel(x));
        z = zeros([numel(x)-1,1]);
        
        for i = (1:numel(x))
            for j= (1:numel(x))
                y(i,j) = x(i)-x(j);
            end
            y(i,i) = NaN;
            if i< numel(x)
                z(i) = x(i+1) - x(i); % difference between two consecutive spikes
            end
        end
        
%         figure;histogram(y, (-histoHalfWidth:0.0005:histoHalfWidth));
%         xlabel('ms');
%         ylabel('spike count');
%         title(clusterCode);
        
        [histoc_correl,edges] = histcounts(y,(-histoHalfWidth:histoBin:histoHalfWidth));
        refrPeriodRatio(ind) = mean(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1))/max(histoc_correl(1:(round((histoHalfWidth-0.0025)/histoBin))));
        
        ind1 = z<=0.002;
        a = x(ind1); % spikes with intervals below 2 ms
        
%         figure;histogram(a,histocIntAll); % histogram of spikes with interval below 2 ms - ploted by trial
%         xlabel('trial time');
%         ylabel('ISI < 2 ms count');
%         [histoc_tc_fast,edges_tc_fast] = histcounts(a,histocIntAll);
%         title(clusterCode);
        
%         figure;histogram(x,histocIntAll); % histogram of all spikes - ploted by trial
%         [histoc_tc_all,edges_tc_all] = histcounts(x,histocIntAll);
%         xlabel('trial time');
%         ylabel('spike count');
%         title(clusterCode);
        
        %     figure; % ratio between number of spikes with interval below 2 ms and all spikes - ploted by trial
        %     plot(1:numel(histocIntAll)-1, histoc_tc_fast./histoc_tc_all);
        %     xlabel('trial');
        %     ylabel('(ISI < 2 ms) / (all ISI in trial) ');
        %     title(clusterCode);
        
        % Calculate false positives based on refractory period violations
        % ref_v = (ref_per ? cens_per)* N^2*(1 ? fals_pos)*false_pos/T
        
        num_spikes = numel(x_part);
        
        ref_v = sum(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1));%refractory period violations
        total_rec_time = (sessionInfo.trialDuration+sessionInfo.preTrialTime)*numel(spikeClusterData.trialsForAnalysisSelected)*totalConds;% total recording time
        
        c = (ref_v*total_rec_time)/((ref_per - cens_per)*num_spikes^2); % remove the factor of 2
        if c <= 0.25
            p = [-1 1 -c];
            roots(p);
            falsePos(ind) = min(roots(p));
        end
    end
    spikeClusterData.ACC25(ind,:) = histoc_correl;
    
%     disp(['cluster ', num2str(clusterCode), ', refractory period ratio ', num2str(refrPeriodRatio(ind)), ', min ISI ' , num2str(min(z(ind1))), ', presence % ', num2str(presence(ind)*100), ', False positives ', num2str(falsePos(ind))]); % check if there is any ISI smaller thn 0.5 ms
end

disp(['Total possible SUAs: ', num2str(sum(refrPeriodRatio<=0.125 | isnan(refrPeriodRatio)))]);
disp(['Possible SUAs: ', num2str(spikeClusterData.uniqueCodes(refrPeriodRatio<=0.125 | isnan(refrPeriodRatio))')]);

spikeClusterData.refrPeriodRatio = refrPeriodRatio;
spikeClusterData.presence = presence;
spikeClusterData.falsePos = falsePos;

%%

% save(filenameSpikeClusterData, 'spikeClusterData')
% disp(['Saving ', experimentName, ' / ' , sessionName, ' .spikeClusterData.mat file'])
% end    
