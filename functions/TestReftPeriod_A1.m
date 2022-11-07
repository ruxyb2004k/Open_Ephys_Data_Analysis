%%% Refractory period ratio based on trialsForAnalysis
% created by RB on 06.03.2019, modified on the 28.07.2020 
% run after SpikeDataLoading_openEphys.m

clusterCode = 4; % cluster code to be teste
histoHalfWidth = 0.025; % in sec
histoBin = 0.0005; % in sec
trialPresence = nan(20,1);%nan(numel(condData.times)/totalConds,1);
x=spikeClusterData.rangeTimes(spikeClusterData.codes==clusterCode);

lastPoint = max(x(end), sessionInfo.condData.times(end))+sessionInfo.preTrialTime; % buffer preTrialTime s
histocIntAll = [sessionInfo.condData.times(1:totalConds:end); lastPoint];
x_part = [];

for trial = spikeClusterData.trialsForAnalysisSelected
    x_curr_trial = x(x > histocIntAll(trial)-sessionInfo.preTrialTime & x < histocIntAll(trial+1)-sessionInfo.preTrialTime);
    x_part = [x_part; x_curr_trial];  
    trialPresence(trial) = numel(x_curr_trial)>0;
end

presence = sum(trialPresence==1)/totalTrials

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

figure;histogram(y, (-histoHalfWidth:0.0005:histoHalfWidth));
xlabel('ms');
ylabel('spike count');

[histoc_correl,edges] = histcounts(y,(-histoHalfWidth:histoBin:histoHalfWidth));
refrPeriodRatio = mean(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1))/max(histoc_correl(1:(round((histoHalfWidth-0.0025)/histoBin))))

ind1 = z<=0.002;
disp(['min ISI ', num2str(min(z(ind1)))]); % check if there is any ISI smaller thn 0.5 ms
a = x(ind1); % spikes with intervals below 2 ms

figure;histogram(a,histocIntAll-sessionInfo.preTrialTime); % histogram of spikes with interval below 2 ms - ploted by trial
xlabel('trial time');
ylabel('ISI < 2 ms count');
[histoc_tc_fast,edges_tc_fast] = histcounts(a,histocIntAll-sessionInfo.preTrialTime);

figure;histogram(x,histocIntAll-sessionInfo.preTrialTime); % histogram of all spikes - ploted by trial
[histoc_tc_all,edges_tc_all] = histcounts(x,histocIntAll-sessionInfo.preTrialTime);
xlabel('trial time');
ylabel('spike count');

figure; % ratio between number of spikes with interval below 2 ms and all spikes - ploted by trial
plot(1:numel(histocIntAll)-1, histoc_tc_fast./histoc_tc_all);
xlabel('trial');
ylabel('(ISI < 2 ms) / (all ISI in trial) ');

% figure; % time between two consecutive spikes vs amplitude of the 2nd spike
% scatter(z,indivTrough(2:end));
% xlabel('trial time');
% ylabel('ISI < 2 ms count');

%% Calculate false positives based on refractory period violations
% ref_v = (ref_per - cens_per)* N^2*(1 - fals_pos)*false_pos/T
% example data set below
% num_spikes = 10000; ref_per = 0.003; cens_per = 0.001; ref_v = 20; total_rec_time = 1000;

num_spikes = numel(x_part);
ref_per = 0.002; % refractory period
cens_per = 0.0005;% 0.0005;% censored period
ref_v = sum(histoc_correl(histoHalfWidth/histoBin-3:histoHalfWidth/histoBin-1));%refractory period violations
total_rec_time = (sessionInfo.trialDuration+sessionInfo.preTrialTime)*numel(spikeClusterData.trialsForAnalysisSelected)*totalConds;% total recording time

c = (ref_v*total_rec_time)/((ref_per - cens_per)*num_spikes^2); % remove the factor of 2?
if c <= 0.25
    p = [-1 1 -c];
    roots(p)
    falsePos = min(roots(p))
else
    falsePos = NaN
end

%% calculate GoTo times for refr period violation spikes
% only works for trials before removing other trials
k= nan(numel(a),1);
for j=(1:numel(a))
    k(j) = find(timestamps==a(j));   
end 
k=k/samplingRate;

