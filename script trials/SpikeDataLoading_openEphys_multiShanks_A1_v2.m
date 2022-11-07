%%% Load matlab data from open ephys kwik files. 
%%% modified 13.07.2020 by Ruxandra %%%

experimentName = '2020-07-20_15-06-54'
sessionName = 'V1_20200720_1'

clearvars -except experimentName sessionName

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathKlusta = strjoin({basePath, 'klusta analysis', '1'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % general info about the session

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);


if ~SCDexist
    
    spikeClusterData.clusterSoftware = 'klusta';
    spikeClusterData.trialsForAnalysisSelected = timeSeries.trialsForAnalysis;
    
    filename_kwik = fullfile(basePathKlusta,[sessionName,'.kwik']); % general info about the session
    spikeClusterData.times = [];
    spikeClusterData.adjGraph = [];
    spikeClusterData.codes = [];
    for i = (0:sessionInfo.nShanks-1)
        spikeClusterData.times = [spikeClusterData.times; double(hdf5read(filename_kwik, ['/channel_groups/', num2str(i), '/spikes/time_samples']))/sessionInfo.rates.wideband]; % all spike times
        spikeClusterData.adjGraph = [spikeClusterData.adjGraph, double(h5readatt(filename_kwik,'/channel_groups/0', 'adjacency_graph'))];
        spikeClusterData.codes = [spikeClusterData.codes; 100*i + double(hdf5read(filename_kwik, ['/channel_groups/', num2str(i), '/spikes/clusters/main']))]; % all spike codes
    end
    
    if sessionInfo.nShanks > 1
        [spikeClusterData.timesSorted, indSort] = sort(spikeClusterData.times);
        spikeClusterData.times = spikeClusterData.timesSorted;
        spikeClusterData.codesSorted = spikeClusterData.codes(indSort);
        spikeClusterData.codes = spikeClusterData.codesSorted;
        spikeClusterData = rmfield(spikeClusterData, 'timesSorted');
        spikeClusterData = rmfield(spikeClusterData, 'codesSorted');
    end    
        
    if sessionInfo.nChannels <= 16
        for i = (0:sessionInfo.nChannels-1) % number channels
            % in spikeClusterData.channelPosition, column 2 is the depth, where 0 is the tip of the
            % electrode and all other channels have positive depths
            spikeClusterData.channelPosition(i+1,1:2) = double(h5readatt(filename_kwik, ['/channel_groups/0/channels/',num2str(i)],'position'));
        end
    elseif sessionInfo.nChannels == 32
        for i = (0:15)% number channels
            % in spikeClusterData.channelPosition, column 2 is the depth, where 0 is the tip of the
            % electrode and all other channels have positive depths
            spikeClusterData.channelPosition(i+1,1:2) = double(h5readatt(filename_kwik, ['/channel_groups/1/channels/',num2str(i)],'position'));
        end
        for i = (16:31)% number channels
            spikeClusterData.channelPosition(i+1,1:2) = double(h5readatt(filename_kwik, ['/channel_groups/0/channels/',num2str(i)],'position'));
        end
    end    
        
    spikeClusterData.uniqueCodes(:,1) = unique(spikeClusterData.codes); % ordered list of all codes
    
    for i = (1:numel(spikeClusterData.uniqueCodes(:,1))) % reads 0(noise), 1(mua) or 2(good)
        code = spikeClusterData.uniqueCodes(i,1);
        shank = floor(code/100);
        % spikeClusterData.uniqueCodesLabel is 0(noise), 1(mua) or 2(good)
        spikeClusterData.uniqueCodesLabel(i,1) = double(h5readatt(filename_kwik,['/channel_groups/',num2str(shank),'/clusters/main/', num2str(code-100*shank)],'cluster_group'));
    end
    
    spikeClusterData.uniqueCodes(:,2) = 0;
end
warning('Please insert the channel numbers and double-check them');
%% verify first in Klusta if the channels fit the cluster codes and insert manually the channel number...

if ~SCDexist
    % ...for each cluster code in 2nd column of spikeClusterData.uniqueCodes, then run the next command
    spikeClusterData.uniqueCodesChannel(:,1) = spikeClusterData.uniqueCodes(:,2);

    % calculate the depth of each cluster based on the channel position
    spikeClusterData.uniqueCodesDepth(:,1) = spikeClusterData.channelPosition(spikeClusterData.uniqueCodesChannel(:,1)+1,2);

    % calculate the depth of each channel based on the recording depth
    spikeClusterData.uniqueCodesRealDepth(:,1) = sessionInfo.recordingDepth + spikeClusterData.uniqueCodesDepth(:,1); 
    
    unclCodes = []; % unclassified codes
    goodCodes = [];
    muaCodes = [];
    noiseCodes = [];

    for i =(1:numel(spikeClusterData.uniqueCodes(:,1)))
        if spikeClusterData.uniqueCodesLabel(i,1) == 3 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            unclCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 2 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            goodCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 1 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            muaCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 0 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            noiseCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        end
    end    
    
    timestampsRange = timeSeries.timestampsRange;
    
    klustaTime = (0:1:numel(timestampsRange)-1)./sessionInfo.rates.wideband;
    spikeClusterData.rangeTimes = zeros([numel(spikeClusterData.times),1]);
    spikeClusterData.klustaTime = klustaTime;
    spikeClusterData.unclCodes = unclCodes;
    spikeClusterData.goodCodes = goodCodes;
    spikeClusterData.muaCodes = muaCodes;
    spikeClusterData.noiseCodes = noiseCodes;
    
    %adjust the spike times from klusta to the real recording times
    j=1;
    for i=(1:numel(spikeClusterData.times))
        while spikeClusterData.times(i) > klustaTime(j) % search for each spike time in the the klustaTime, then take the time index and match it to timestamp index.
            j = j+1;
        end
        spikeClusterData.rangeTimes(i) = timeSeries.timestampsRange(j); % The matched timestamp will be the adjusted spike time
    end
    
    % spikeClusterData.times = spikeClusterData.newTimes;
    % spikeClusterData = rmfield(spikeClusterData, 'newTimes');
end
%%
% modify when selecting different trials than already selected in load_command
% spikeClusterData.trialsForAnalysisSelected = timeSeries.trialsForAnalysis([1:13,15]);

conditionFieldnames = fieldnames(sessionInfo.conditionNames); % extract conditionNames (c0visStim c100visStim etc)
totalConds = numel(conditionFieldnames);

spikeTimes = [];
spikeTypeCount = [];
alltempMean =[];
totalTrials = numel(spikeClusterData.trialsForAnalysisSelected);

tempSpikes = spikeClusterData.rangeTimes; % times at which spikes occur
tempCodes = spikeClusterData.codes(:,1); % array with all codes for waveforms
totalCodes = numel(unique(tempCodes)); % total codes number
   
for condInt = 1:totalConds % for all conditions
    currentConName = conditionFieldnames{condInt}; % extract current condition name
    currentConDataID = sessionInfo.conditionNames.(currentConName); % extract ID number for this specific condition
    temp = sessionInfo.condData.codes; % array containing all condition codes - only first column out of 4 produced by Spike2 (numel = trials*conditions)
    temp = (temp == currentConDataID); % keep only the entries for the current condition, everything else is 0 
    
    temptimes = sessionInfo.condData.times;% load condition starting times
    temptimes = temptimes(temp);% keep only the starting times of the current condition
    temptimes = temptimes(spikeClusterData.trialsForAnalysisSelected);
    
    tempTotalTrials = numel(temptimes);
    
    for trialInt=1:tempTotalTrials % for every trial
        refTime = temptimes(trialInt); % real start of the condition in this trial
        startTime= refTime-sessionInfo.preTrialTime; % startTime could be seconds before the real condition start
        endTime = refTime+ sessionInfo.trialDuration + sessionInfo.preTrialTime; % end is the end of the recorded trial 
        iTrialTimeFrame = tempSpikes >= startTime & tempSpikes <= endTime; % array with numel = total spike number, 1 for each spike in this trial and cond, 0 for all others
        trialTime = tempSpikes(iTrialTimeFrame); % time at which the spikes occur in this trial and cond
        trialTime =  trialTime - refTime; % time at which the spikes occur in this trial and cond relative to the start of the condition
        trialCodes = tempCodes(iTrialTimeFrame); % extract codes that occur only in this condition an trial
        iConfinedTimeFrame = trialTime>(-sessionInfo.preTrialTime) & trialTime<(sessionInfo.trialDuration+sessionInfo.preTrialTime); % logical for all spikes occuring in the evokedActInterval or spontActInterval in this condition and trial
        realtime = trialTime(iConfinedTimeFrame);
        codes = trialCodes(iConfinedTimeFrame);
        spikeTimes.(currentConName){trialInt} = [realtime,codes]; % matrix containing evoked spike times for each condition and entire trial
                
    end
end
spikeClusterData.spikeTimes = spikeTimes

RefPerAndFalsePos_A1

%%
if exist(filenameSpikeClusterData,'file')
    warning('.spikeClusterData.mat file already exists.')
else
    spikeClusterData
    cfSCD = checkFields(spikeClusterData);
    if ~cfSCD            
         disp(['Saving ', experimentName, ' / ' , sessionName, ' .spikeClusterData.mat file'])
         save(filenameSpikeClusterData, 'spikeClusterData')
    end     
end   

