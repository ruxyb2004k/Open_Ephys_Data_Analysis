%%
clear all
load('allExp.mat');
expSet = allExp; % select experiment set
numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 

%%%%%%% add filter here %%%%%%%

filt(1,:) = [expSet.trialDuration] == 18; % Protocol type
filt(2,:) = strcmp({expSet.animalStrain}, 'NexCre'); % mouse line
% filt(3,:) = strcmp({expSet.experimentName}, '2020-08-11_15-44-59');
% filt(4,:) = ~(contains({expSet.experimentName}, '2020-11-12_14-20-47') | contains({expSet.experimentName}, '2020-12-01_13-58-50') | contains({expSet.experimentName},'2020-12-03_14-41-44'));
% filt(5,:) = contains({expSet.animalName}, '20200730') | contains({expSet.animalName}, '20200805');
% filt(6,:) = datetime({expSet.experimentName}, 'InputFormat','yyyy-MM-dd_HH-mm-ss')>datetime(2020,09,28); % exclude experiments before a certain date (yyyy, MM, dd)
filt(7,:) = [expSet.expSel1] == 1; % first experiment selection
filt(8,:) = [expSet.expSel2] == 1; % 2nd experiment selection
filt(9,:) = [expSet.expSel3] == 1; % 3rd experiment selection


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combinedFilter = sum(filt,1) == numFilt;
expSetFilt = expSet(combinedFilter); % apply filters to the experiment set



%%
for k =1:(size(expSetFilt,2))
    clearvars sessionInfo timeSeries spikeClusterData clusterTimeSeries cellMetrics orientationMetrics lfp
    
    disp('');
    disp(['Loading experiment ', num2str(k)]);
    experimentName = expSetFilt(k).experimentName
    sessionName = expSetFilt(k).sessionName;
    
    spectralAnalysis_A1
end    