%%% Refractory period ratio based on trialsForAnalysis for all selected
%%% units
% created by RB on 20.04.2020 
% run after SpikeDataLoading_openEphys.m and loads traceFreqAndInfo1

%load('traceFreqAndInfo1.mat');
histoHalfWidth = 0.025; % in sec
histoBin = 0.0005; % in sec
ref_per = 0.002; % refractory period
cens_per = 0.0005;% censored period

falsePos = nan(numel(selectedCodes),1);
refrPeriodRatio = nan(numel(selectedCodes),1);
presence = nan(numel(selectedCodes),1);

for ind = 1:numel(selectedCodes)
    trialPresence = nan(20,1);%nan(numel(condData.times)/totalConds,1);
    clusterCode = selectedCodes(ind);
    x=spikeClusterData.times(spikeClusterData.codes==clusterCode);

    lastPoint = max(x(end), condData.times(end))+preTrialTime; % buffer preTrialTime s
    histocIntAll = [condData.times(1:totalConds:end); lastPoint];
    
    x_part = [];

    for trial = trialsForAnalysis
        x_curr_trial = x(x > histocIntAll(trial)-preTrialTime & x < histocIntAll(trial+1)-preTrialTime);
        x_part = [x_part; x_curr_trial];  
        trialPresence(trial) = numel(x_curr_trial)>0; 
    end
    
    presence(ind) = sum(trialPresence==1)/totalTrials;
    
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

%     figure;histogram(y, (-histoHalfWidth:0.0005:histoHalfWidth));
%     xlabel('ms');
%     ylabel('spike count');
    
    [histoc_correl,edges] = histcounts(y,(-histoHalfWidth:histoBin:histoHalfWidth));
    refrPeriodRatio(ind) = mean(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1))/max(histoc_correl(1:(round((histoHalfWidth-0.0025)/histoBin))));
    
    ind1 = z<=0.002;
    disp(['cluster ', num2str(selectedCodes(ind)), ', min ISI ' , num2str(min(z(ind1)))]); % check if there is any ISI smaller thn 0.5 ms
    a = x(ind1); % spikes with intervals below 2 ms

%     figure;histogram(a,histocIntAll); % histogram of spikes with interval below 2 ms - ploted by trial
%     xlabel('trial time');
%     ylabel('ISI < 2 ms count');
%     [histoc_tc_fast,edges_tc_fast] = histcounts(a,histocIntAll);
    
%     figure;histogram(x,histocIntAll); % histogram of all spikes - ploted by trial
%     [histoc_tc_all,edges_tc_all] = histcounts(x,histocIntAll);
%     xlabel('trial time');
%     ylabel('spike count');
    
%     figure; % ratio between number of spikes with interval below 2 ms and all spikes - ploted by trial
%     plot(1:numel(histocIntAll)-1, histoc_tc_fast./histoc_tc_all);
%     xlabel('trial');
%     ylabel('(ISI < 2 ms) / (all ISI in trial) ');
    
    % Calculate false positives based on refractory period violations
    % ref_v = (ref_per ? cens_per)* N^2*(1 ? fals_pos)*false_pos/T
    
    num_spikes = numel(x_part);

    ref_v = sum(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1));%refractory period violations
    total_rec_time = (trialDuration+preTrialTime)*numel(trialsForAnalysis)*totalConds;% total recording time
    
    c = (ref_v*total_rec_time)/((ref_per - cens_per)*num_spikes^2) % remove the factor of 2
    if c <= 0.25
        p = [-1 1 -c];
        roots(p);
        falsePos(ind) = min(roots(p));
    end
end
disp('False positives'), disp(falsePos);
disp('Presence percentage'), disp(presence*100);
%%
save('refPerAndFalsePos_spont.mat', 'falsePos', 'refrPeriodRatio', 'presence', 'selectedCodes')
