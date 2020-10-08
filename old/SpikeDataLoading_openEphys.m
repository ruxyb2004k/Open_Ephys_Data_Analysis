%%% Load matlab data from open ephys kwik files. 
%%% modified 25.02.2019 by Ruxandra %%%

recordingDepth = -425; % !!! Modify for each experiment !!!

conditionNames= [];

conditionNames.c100visStim = 1; % 
conditionNames.c100optStim = 33; % 
% conditionNames.c50visStim = 4;
% conditionNames.c50optStim = 36;
% conditionNames.c25visStim = 6; % 
% conditionNames.c25optStim = 38; % 
% conditionNames.c12visStim = 8; % 
% conditionNames.c12optStim = 40; % 
% conditionNames.c6visStim = 9; % 
% conditionNames.c6optStim = 41; % 
conditionNames.c0visStim = 0; 
conditionNames.c0optStim = 32;

%%
path = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-06-19_12-56-47/data/';
% path = 'P:\Ruxi\2020-05-23_14-29-08\data\';
% path = 'Z:\Ruxandra\Open Ephys\Open Ephys Data\2020-05-23_14-29-08\data\';

i=1;
filename = ['100_CH', num2str(i), '.continuous'];
[data, timestamps, info] = load_open_ephys_data([path, filename]);

filename_events = ['all_channels', '.events'];
[dataEv, timestampsEv, infoEv] = load_open_ephys_data([path, filename_events]);
samplingRate = info.header.sampleRate;

ld = 0;
if ld
   load('spikeClusterData1.mat') 
end    
%% if ld = 0, run this section

filename_kwik = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-06-19_12-56-47/klusta analysis/V1_20200619_1.kwik';
% filename_kwik = 'P:\Ruxi\2020-05-23_14-29-08\klusta analysis\V1_20200523_2.kwik';
spikeClusterData.times = double(hdf5read(filename_kwik, '/channel_groups/0/spikes/time_samples'))/samplingRate; % all spike times

spikeClusterData.adjGraph = double(h5readatt(filename_kwik,'/channel_groups/0', 'adjacency_graph'));

for i = (0:15) % number channels
    % in spikeClusterData.channelPosition, column 2 is the depth, where 0 is the tip of the
    % electrode and all other channels have positive depths    
    spikeClusterData.channelPosition(i+1,1:2) = double(h5readatt(filename_kwik, ['/channel_groups/0/channels/',num2str(i)],'position'));
end

spikeClusterData.codes = double(hdf5read(filename_kwik, '/channel_groups/0/spikes/clusters/main')); % all spike codes
spikeClusterData.uniqueCodes(:,1) = unique(spikeClusterData.codes); % ordered list of all codes

for i = (1:numel(spikeClusterData.uniqueCodes(:,1))) % reads 0(noise), 1(mua) or 2(good)
    % spikeClusterData.uniqueCodesLabel is 0(noise), 1(mua) or 2(good) 
    spikeClusterData.uniqueCodesLabel(i,1) = double(h5readatt(filename_kwik,['/channel_groups/0/clusters/main/', num2str(spikeClusterData.uniqueCodes(i,1))],'cluster_group'));
end

%% if ld = 0, verify first in Klusta if the channels fit the cluster codes and insert manually the channel number...
% ...for each cluster code in 2nd column of spikeClusterData.uniqueCodes, then run the next command
spikeClusterData.uniqueCodesChannel(:,1) = spikeClusterData.uniqueCodes(:,2);

% calculate the depth of each cluster based on the channel position
spikeClusterData.uniqueCodesDepth(:,1) = spikeClusterData.channelPosition(spikeClusterData.uniqueCodesChannel(:,1)+1,2);

% calculate the depth of each channel based on the recording depth
spikeClusterData.uniqueCodesRealDepth(:,1) = recordingDepth + spikeClusterData.uniqueCodesDepth(:,1); 
%% calculate the starting time of each condition and adjust the spike times from klusta to the real recording times

load([path, 'order_all_cond.mat']) % load the sequence of all conditions
condData.codes = order_all_cond;
doubleTimes = timestampsEv(dataEv==1); % detect the events corresponding to beginning of all conditions
condData.times = doubleTimes(1:2:end); % remove the event corresponding to switch off of channel 1 in Master 8
%% if ld = 0
% just for this experiment, because of missing trials:
load('range.mat');
timestampsNew = timestamps([rangeBeg1: rangeEnd1, rangeBeg2: rangeEnd2]);%, rangeBeg3: rangeEnd3]); 
timestamps = timestampsNew;

klustaTime = (0:1:numel(timestamps)-1)./samplingRate;
spikeClusterData.newTimes = zeros([numel(spikeClusterData.times),1]);

%adjust the spike times from klusta to the real recording times
j=1;
for i=(1:numel(spikeClusterData.times))
    while spikeClusterData.times(i) > klustaTime(j) % search for each spike time in the the klustaTime, then take the time index and match it to timestamp index. 
        j = j+1;
    end    
    spikeClusterData.newTimes(i) = timestamps(j); % The matched timestamp will be the adjusted spike time
end 

spikeClusterData.times = spikeClusterData.newTimes;
spikeClusterData = rmfield(spikeClusterData, 'newTimes');
%%

pathDigital = condData;
pathWaveMark = spikeClusterData;

trialDuration = 18;% Trial duration in seconds - a bit larger than end of the last rep
preTrialTime = 3; % time before 0 for display
afterTrialTime = 0; % time after trial for display
trialsForAnalysis = [1,14:20]; %[2, 4:9, 11, 12, 14, 16:18]; % trials to be analyzed
visStim = (0.2:3:15.2);
evokedActInterval = [0 0.5]; 
%spontActInterval = [2 3];
optStimInterval = [2 10];%[0.2 5.2];%
evokedOrSpontOrOpt = 3; % 1 for evoked, 2 for spont, 3 for optic
narrow = false; % select true to consider only short time intervals

conditionFieldnames = fieldnames(conditionNames); % extract conditionNames (c0visStim c100visStim etc)
spikeTimes = [];
spikeTypeCount = [];
alltempMean =[];
totalTrials = numel(trialsForAnalysis);

tempSpikes = pathWaveMark.times; % times at which spikes occur
tempCodes = pathWaveMark.codes(:,1); % array with all codes for waveforms
%tempCodes = tempCodes + 1; % increase all codes with 1 in order to include code "0" as well
totalCodes = numel(unique(tempCodes)); % total codes number
totalConds = numel(conditionFieldnames);

if evokedOrSpontOrOpt == 1
    repStart = visStim + evokedActInterval(1); % (2); visual stim. pulses start time or (2) spont act. start time
    repEnd = visStim + evokedActInterval(2); %visually-evoked activity end time
elseif evokedOrSpontOrOpt == 2
    repStart = visStim + spontActInterval(1); % (2); visual stim. pulses start time or (2) spont act. start time
    repEnd = visStim + spontActInterval(2); %visually-evoked activity end time
elseif evokedOrSpontOrOpt == 3
    repStart = optStimInterval(1); % (2); visual stim. pulses start time or (2) spont act. start time
    repEnd = optStimInterval(2); %visually-evoked activity end time
end

totalRep = numel(repStart); 
   
for condInt = 1:totalConds % for all conditions
    currentConName = conditionFieldnames{condInt}; % extract current condition name
    currentConDataID = conditionNames.(currentConName); % extract ID number for this specific condition
    temp = pathDigital.codes; % array containing all condition codes - only first column out of 4 produced by Spike2 (numel = trials*conditions)
    temp = (temp == currentConDataID); % keep only the entries for the current condition, everything else is 0 
    
    temptimes = pathDigital.times;% load condition starting times
    temptimes = temptimes(temp);% keep only the starting times of the current condition
    temptimes = temptimes(trialsForAnalysis);
    
    tempTotalTrials = numel(temptimes);
    
    tempMean = nan(tempTotalTrials, totalRep, totalCodes); % no trials, pulses, codes
    tempAll = nan(tempTotalTrials, totalRep, totalCodes);% get all with single trial
    
    for trialInt=1:tempTotalTrials % for every trial
        refTime = temptimes(trialInt); % real start of the condition in this trial
        startTime= refTime-preTrialTime; % startTime could be seconds before the real condition start
        endTime = temptimes(trialInt)+ trialDuration + afterTrialTime; % end is the end of the recorded trial 
        iTrialTimeFrame = tempSpikes >= startTime & tempSpikes <= endTime; % array with numel = total spike number, 1 for each spike in this trial and cond, 0 for all others
        trialTime = tempSpikes(iTrialTimeFrame); % time at which the spikes occur in this trial and cond
        trialTime =  trialTime - refTime; % time at which the spikes occur in this trial and cond relative to the start of the condition
        trialCodes = tempCodes(iTrialTimeFrame); % extract codes that occur only in this condition an trial
        if narrow; % consider only spikes in evokedActInterval
            for rep=1:numel(repStart) % for all repetitions = visual pulses
                iConfinedTimeFrame = trialTime>repStart(rep) & trialTime<repEnd(rep); % logical for all spikes occuring in the evokedActInterval or spontActInterval in this condition and trial
                realtime = trialTime(iConfinedTimeFrame); % times for spikes occuring in evokedActInterval
                codes = trialCodes(iConfinedTimeFrame); % codes for spikes occuring in evokedActInterval
                spikeTimes.(currentConName){trialInt,rep} = realtime; % matrix containing evoked spike times for each condition, trial and repetition
                for collect = 1:totalCodes % for each code number
                    iCodes = codes == collect; % only for one code type
                    tempMean(trialInt,rep,collect) = sum(iCodes); % matrix contains the total occurances of a certain waveform type in a specific trial and repetition 
                end
            end
        else
            iConfinedTimeFrame = trialTime>(-preTrialTime) & trialTime<(trialDuration+afterTrialTime); % logical for all spikes occuring in the evokedActInterval or spontActInterval in this condition and trial
            realtime = trialTime(iConfinedTimeFrame);
            codes = trialCodes(iConfinedTimeFrame);
            spikeTimes.(currentConName){trialInt} = [realtime,codes]; % matrix containing evoked spike times for each condition and entire trial
        end        
    end
    tempAll = tempMean; % dim: trials, repetitions, codes
    tempMean = sum(tempMean,1); % sum across all trials, reduce first dimension from trial no. to 1
    spikeTypeCount.(currentConName) = permute(tempMean,[3 2 1]); %  dim: codes, repetitions
    allSpikeTypeCount.(currentConName) = permute(tempAll,[3 2 1]); % dim: codes, repetitions, trials
end
% arryCount=nan(totalCodes,totalRep,totalConds); % array with sum over trials. dim: codes, repetitions, conds
% arryCount(:,:,1)=spikeTypeCount.c100visStim;
%arryCount(:,:,2)=spikeTypeCount.c100optStim;
%arryCount(:,:,1)=spikeTypeCount.c25visStim;
%arryCount(:,:,2)=spikeTypeCount.c25optStim;
% arryCount(:,:,3)=spikeTypeCount.c0visStim;
%arryCount(:,:,4)=spikeTypeCount.c0optStim;           
% arryCount(:,:,5)=spikeTypeCount.c50visStim;
% arryCount(:,:,6)=spikeTypeCount.c50optStim;%%% modified 01.08.2017 by Ruxandra %%%
