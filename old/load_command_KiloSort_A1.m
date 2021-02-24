%%% load raw data and create session metadata %%%
%%% written by RB 09.07.2020 %%%

% make sure you are in this file's folder

global i x1 y1 y2 y3 recStartDataPoint z z_filt1 z_filt2 samplingRate

experimentName = '2021-01-28_11-51-43'
sessionName = 'V1_20210128_1'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKilosort = strjoin({basePath, 'kilosort analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

if ~exist(basePathData, 'dir')
    newDirKS(basePath)
end    

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);

if SIexist
    cfSI = checkFields(sessionInfo);
end

if TSexist
    cfTS = checkFields(timeSeries);
end
% if SIexist && TSexist % deactivated for now, as a break between sections
% has been introduced
%     answer = questdlg('Load raw data?', 'Menu',...
%         'Yes','No', 'No');
%     % Handle response
%     switch answer
%         case 'Yes'
%             disp([' Please run the next section'])
% %         case 'No'
% %             disp([' Proceed to the next section'])
% %             return
%     end
% end

%%
%%%%%%% insert session-specific paramteres here %%%%%%%%%%

recordingDepth = [-440 -400]'; % !!! Modify for each experiment !!!
channelNo = 32;
probe = '2x16_E1';% '1x16_P1' '2x16_E1'
animal.name = '20210122_LV1';
animal.sex = 'm';
animal.strain = 'PvCre';
animal.virus = 'AAV9-mOp2A';
recRegion = 'LV1';
chOffset = 16; % 0 for 16-channel probes; 16 for 32-channel probe

conditionNames= [];
conditionNames.c100visStim = 2; % 
conditionNames.c100optStim = 34; % 
% conditionNames.c50visStim = 4;
% conditionNames.c50optStim = 36;
% conditionNames.c25visStim = 6; % 
% conditionNames.c25optStim = 38; % 
% conditionNames.c12visStim = 8; % 
% conditionNames.c12optStim = 40; % 
conditionNames.c0visStim = 0; 
conditionNames.c0optStim = 32;

% conditionNames.or0visStim = 1;
% conditionNames.or0optStim = 33;
% conditionNames.or30visStim = 2;
% conditionNames.or30optStim = 34;
% conditionNames.or60visStim = 3;
% conditionNames.or60optStim = 35;
% conditionNames.or90visStim = 4;
% conditionNames.or90optStim = 36;
% conditionNames.or120visStim = 5;
% conditionNames.or120optStim = 37;
% conditionNames.or150visStim = 6;
% conditionNames.or150optStim = 38;
% conditionNames.or180visStim = 7;
% conditionNames.or180optStim = 39;
% conditionNames.or210visStim = 8;
% conditionNames.or210optStim = 40;
% conditionNames.or240visStim = 9;
% conditionNames.or240optStim = 41;
% conditionNames.or270visStim = 10;
% conditionNames.or270optStim = 42;
% conditionNames.or300visStim = 11;
% conditionNames.or300optStim = 43;
% conditionNames.or330visStim = 12;
% conditionNames.or330optStim = 44;

afterTrialTime = 0; % time after trial for display

trialDuration = 18;% Long stimulation protocol (7)
preTrialTime = 3; % time before 0 for display
visStim = (0.2:3:15.2);
optStimInterval = [2 10];
visStimDuration = 0.2;

% trialDuration = 9;% Contrast protocol (3)
% preTrialTime = 2; % time before 0 for display
% visStim = (7);
% optStimInterval = [0.2 8.2];
% visStimDuration = 0.2;

% trialDuration = 6;% Contrast protocol (2)
% preTrialTime = 2; % time before 0 for display
% visStim = (4);
% optStimInterval = [0.2 5.2];
% visStimDuration = 0.2;

% trialDuration = 7;% Orientation protocol (1)
% preTrialTime = 2; % time before 0 for display
% visStim = (4);
% optStimInterval = [0.2 6];%[2 10];%
% visStimDuration = 1;


%%%%%%%%% experiment-specific parameters end here %%%%%%%%%%

conditionFieldnames = fieldnames(conditionNames); % extract conditionNames (c0visStim c100visStim etc)
totalConds = numel(conditionFieldnames);
condDataIDs = [];

for condInt = 1:totalConds % for all conditions
    currentConName = conditionFieldnames{condInt}; % extract current condition name
    condDataIDs = [condDataIDs; conditionNames.(currentConName)];
end
    

i=1;
filename = ['100_CH', num2str(i+chOffset), '.continuous'];
[data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);%
y(1,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz

% find starting point of each trial
filename_events = ['all_channels', '.events'];
[dataEv, timestampsEv, infoEv] = load_open_ephys_data_faster([basePathData, filesep, filename_events]);
samplingRate = info.header.sampleRate;
load([basePathData, filesep, 'order_all_cond.mat']) % load the sequence of all conditions
condData.codes = order_all_cond;
doubleTimes = timestampsEv(dataEv==1);% detect the events corresponding to beginning of all conditions
condData.times = doubleTimes(1:2:end); % remove the event corresponding to switch off of channel 1 in Master 8



if ~isequal(sort(condDataIDs),sort(unique(condData.codes)))
    warning('Wrong conditions, please check again');
end    

sessionInfo.session.path = basePath;
sessionInfo.session.name = sessionName;
sessionInfo.session.experimentName = experimentName;
sessionInfo.nChannels = channelNo;
sessionInfo.recordingDepth = recordingDepth;
sessionInfo.conditionNames = conditionNames;
sessionInfo.trialDuration = trialDuration;
sessionInfo.preTrialTime = preTrialTime;
sessionInfo.afterTrialTime = afterTrialTime; 
sessionInfo.visStim = visStim;
sessionInfo.optStimInterval = optStimInterval;
sessionInfo.probe = probe;
sessionInfo.animal = animal;
sessionInfo.recRegion = recRegion;
sessionInfo.nShanks = str2num(sessionInfo.probe(1));
sessionInfo.chOffset = chOffset;
sessionInfo.rates.wideband = samplingRate;
sessionInfo.visStimDuration = visStimDuration;

timeSeries.events.dataEv = dataEv;
timeSeries.events.timestampsEv = timestampsEv;
timeSeries.events.infoEv = infoEv;
timestamps1 = timestamps;

% load the rest of the data
dataPoints = numel(data(1,:));
data= nan(channelNo,dataPoints);
timestamps = zeros(dataPoints,1);
med = zeros(channelNo,1);
std_ch = zeros(channelNo,1);

for i=(1:channelNo)
    clearvars data_ch timestamps
    filename = ['100_CH', num2str(i+chOffset), '.continuous'];
    [data_ch, timestamps(:,1), info(:,i)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
    data(i,ismember(timestamps1, timestamps)) = data_ch(ismember(timestamps, timestamps1))';% in case a channel is missing data points, this command will align its data with the first loaded channel
    % calculate median over each channel and subtract from channel
    med(i) = nanmedian(data(i,:));
    std_ch(i) = nanstd(data(i,:));
    data(i,:) = data(i,:) - med(i);
end
disp(['Missing / shifted data points: ', num2str(sum(isnan(sum(data,1))))]);
indx =  ~isnan(sum(data,1));
ts = timestamps1(indx);
timestamps = ts;
% data = data(:, indx);

% subtract non-recorded time from total time
condData.newTimes = zeros(numel(condData.times),1); % new shifted times for condition begin
timeDiff = zeros(numel(condData.times),1);
timeDiff(1) =  timestamps(1);
condData.newTimes(1) = condData.times(1)-timeDiff(1);
recStartDataPoint = zeros(numel(condData.times),1);
recStartDataPoint(1) = 1;
i=2;
for timePoint=(1:numel(timestamps)-1)
    if timestamps(timePoint+1)>timestamps(timePoint)+1 % i more than 1 sec difference
        recStartDataPoint(i) = timePoint+1;
        timeDiff(i) = timeDiff(i-1) + timestamps(timePoint+1)-timestamps(timePoint);% add up the pause times
        condData.newTimes(i) = condData.times(i)-timeDiff(i); %shift time to ignore the break
        i=i+1;
    end
end  
recStartDataPoint(end+1) = numel(timestamps)+1; %% new


artefactCh = 7;
deleteArtefact

figure
plot(timestamps1(:,1),y(1,:));

figure
subplot(2,1,1)
plot(1:channelNo,med);
% xlabel('no. channel');
ylabel('channel median');

subplot(2,1,2)
plot(1:channelNo,std_ch);
xlabel('no. channel');
ylabel('channel STD');

if numel(recordingDepth)>1
    if (recordingDepth(1) > recordingDepth(2) && recRegion(1) == 'L') || (recordingDepth(1) < recordingDepth(2) && recRegion(1) == 'R')
        warning('Are you sure the electrode depths and the recorded region are correct?')
    end
end    
    
sessionInfo.condData = condData;
timeSeries.recStartDataPoint = recStartDataPoint;    
timeSeries.dataPoints= dataPoints;
timeSeries.timestamps = timestamps;
timeSeries.info = info;
timeSeries.medCh = med;
timeSeries.stdCh = std_ch;

%% Calculations for fig with epochs + plot figure
close all

selCh = 17; % selected channel for figure and calculation 
totalEpochs = numel(condData.codes);

std_z = zeros(totalEpochs,1);
std_z_filt1 = zeros(totalEpochs,1);
std_z_filt2 = zeros(totalEpochs,1);
max_z_filt1 = zeros(totalEpochs,1);

z = data(selCh,:);
z_filt1(1,:) = highpass(z(1,:), 150, 20000);
z_filt2(1,:) = bandpass(z(1,:),[600 6000], 20000);
for i = 1:totalEpochs
    std_z(i) = std(z(recStartDataPoint(i):recStartDataPoint(i+1)-1)); 
    std_z_filt1(i) = std(z_filt1(recStartDataPoint(i):recStartDataPoint(i+1)-1)); 
    std_z_filt2(i) = std(z_filt2(recStartDataPoint(i):recStartDataPoint(i+1)-1)); 
    max_z_filt1(i) = max(abs(z_filt1(recStartDataPoint(i):recStartDataPoint(i+1)-1)));
end

% Figure with epochs
fig = figure;
totalSubplots = 7;

i=1;
updateXY;

subplot(totalSubplots,1,1)
plot1_h = plot(x1,y1);
ylabel('Potential (uV)');

subplot(totalSubplots,1,2)
plot2_h = plot(x1,y2);
ylabel('@150 Hz');

subplot(totalSubplots,1,3)
plot3_h = plot(x1,y3);
xlabel('time (s)');
ylabel('@0.6-6kHz');

if exist('std_z', 'var') == 1
    subplot(totalSubplots,1,4)
    plot(std_z)
    ylabel('STD');    
    set(gca, 'YScale', 'log')
end

if exist('std_z_filt1', 'var') == 1
    subplot(totalSubplots,1,5)
    plot(std_z_filt1)
    ylabel('@150 Hz');    
    set(gca, 'YScale', 'log')
end

if exist('std_z_filt2', 'var') == 1
    subplot(totalSubplots,1,6)
    plot(std_z_filt2)
    ylabel('@0.6-6kHz');    
    set(gca, 'YScale', 'log')
end

if exist('max_z_filt1', 'var') == 1
    subplot(totalSubplots,1,7)
    plot(max_z_filt1); hold on
    plot(xlim, [1 1]*327, '--k') % gain 1002020-12-01_15-18-49
    plot(xlim, [1 1]*655, '--g') % gain 50
    plot(xlim, [1 1]*1638, '--b') % gain 20
    plot(xlim, [1 1]*3276, '--r') % gain 10
    ylabel('Max @150 Hz');    
    set(gca, 'YScale', 'log')
end
xlabel('subtrial no.');

edit_box_h = uicontrol('style', 'edit',...
                        'units', 'normalized',...
                        'position', [0.15 0.92 0.05 0.05]);%'callback', {@eg_fun, edit_box_h

but_h = uicontrol('style', 'pushbutton',...
                    'string', 'Return',...
                    'units', 'normalized',...
                    'position', [0.2 0.92 0.1 0.05],...
                    'callback', {@eg_fun, edit_box_h});
                
but_h_next = uicontrol('style', 'pushbutton',...
                    'string', 'Next',...
                    'units', 'normalized',...
                    'position', [0.3 0.92 0.05 0.05],...
                    'callback', {@eg_fun_next, edit_box_h});
                
but_h_prev = uicontrol('style', 'pushbutton',...
                    'string', 'Prev.',...
                    'units', 'normalized',...
                    'position', [0.35 0.92 0.05 0.05],...
                    'callback', {@eg_fun_prev, edit_box_h});
                                 
linkdata(fig, 'on');                 

%% determine range

range1 = [];
range2 = [];

% no need to comment out anything here from now on. Just fill 'exclude', or
% leave it empty
subTrialsForAnalysis = 1:numel(recStartDataPoint)-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exclude = []; %state here what trials you want to exclude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subTrialsForAnalysis = countformepls(subTrialsForAnalysis,totalConds,exclude);

range2(1,1) = recStartDataPoint(subTrialsForAnalysis(1));

j=1;
for k = 1:(numel(subTrialsForAnalysis)-1)
    if subTrialsForAnalysis(k+1) ~= subTrialsForAnalysis(k)+1
        range2(j,2) = recStartDataPoint(subTrialsForAnalysis(k)+1)-1;
%         range_part = range2(j,1):range2(j,2);
%         range1 = [range1, range_part(ismember(range_part, indx))];
    range1 = [range1, range2(j,1):range2(j,2)];
        j = j+1;
        range2(j,1) = recStartDataPoint(subTrialsForAnalysis(k+1));
    end
end    
range2(j,2) = recStartDataPoint(subTrialsForAnalysis(end)+1)-1;
% range_part = range2(j,1):range2(j,2);
% range1 = [range1, range_part(ismember(range_part, indx))];
range1 = [range1, range2(j,1):range2(j,2)];

timeSeries.range1 = range1;
timeSeries.range2 = range2;
timeSeries.subTrialsForAnalysis = subTrialsForAnalysis;
timeSeries.timestampsRange  = timeSeries.timestamps(timeSeries.range1);
timeSeries.trialsForAnalysis = timeSeries.subTrialsForAnalysis(totalConds:totalConds:end)/totalConds

close all
% clearvars z z_filt1 z_filt2 x1 y1 y2 y3 % possibly redundant if the next line also deletes global variables
clearvars -except range1 channelNo dataPoints timeSeries sessionInfo filenameSessionInfo filenameTimeSeries experimentName sessionName basePathKilosort basePathData chOffset dataEv timestampsEv

%% filter the selected data set
data_filt = zeros(channelNo, numel(range1));
artefactCh = 7;

for j = 1:channelNo    
    clearvars data timestamps
    filename = ['100_CH', num2str(j+chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
%     data(i,ismember(timestamps1, timestamps)) = data_ch(ismember(timestamps, timestamps1))';% in case a channel is missing data points, this command will align its data with the first loaded channel

    deleteArtefact
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(j,:) = highpass(data(1,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz
end

m = max(max(max(data_filt)), -min(min(data_filt)));
disp(['Maximum value: ', num2str(round(m))]);
gain = suggestGain(m);
disp(['Suggested gain: ', num2str(gain)]);

% flat subset of data 
%gain = 20
data_filt = gain * data_filt; 

disp(['Maximum Value: ',num2str(round(max(max(data_filt))))])
disp(['data points above maximum threshold: ',num2str(sum(sum(data_filt>32768)))]) % should not be larger than 1 000 x channelNo
disp(['Minimum Value: ',num2str(round(min(min(data_filt))))])
disp(['data points below minimum threshold: ',num2str(sum(sum(data_filt<-32768)))]) % should not be larger than 1 000 x channelNo

timeSeries.gain = gain;

%% save the dat file, metadata structures and metadata .mat file
% save the dat file
datFilename = [basePathKilosort, filesep, sessionName, '.dat']
if exist(datFilename,'file')
    warning('.dat file already exists.')
else    
    f = fopen(datFilename, 'w');
    fwrite(f, data_filt, 'int16');
    fclose(f);
end    


% Save the metadata structures
if exist(filenameSessionInfo,'file')
    warning('.sessionInfo.mat file already exists.')
else
     cfSI = checkFields(sessionInfo);
     if ~cfSI
         sessionInfo         
         disp(['Saving ', experimentName, ' / ' , sessionName, ' .sessionInfo.mat file'])
         save(filenameSessionInfo, 'sessionInfo')
     end   
end    

if exist(filenameTimeSeries,'file')
    warning('.timeSeries.mat file already exists.')
else    
    cfTS = checkFields(timeSeries);
    if ~cfTS
        timeSeries
        disp(['Saving ', experimentName, ' / ' , sessionName, ' .timeSeries.mat file'])
        save(filenameTimeSeries, 'timeSeries')
    end    
end


% save experiment details in a metadata .mat file:
if exist('allExp.mat','file') %load structure containing all experiments if it already exists
    load('allExp.mat')   
    disp('Loading allExp.mat')
    entry = size(allExp, 2)+1
else
    disp('allExp has not been found, initializing allExp')
    allExp = struct([]);
    entry = 1    
end

% check if the experiment already exists
experimentNameValues = extractfield(allExp,'experimentName');
a = ismember(experimentName, experimentNameValues );

if ~a % if the experiment doesn't already exist, add it and save allExp.mat
    allExp(entry).experimentName = experimentName;
    allExp(entry).sessionName = sessionName;
    allExp(entry).animalName = sessionInfo.animal.name;
    allExp(entry).animalStrain = sessionInfo.animal.strain;
    allExp(entry).animalVirus = sessionInfo.animal.virus;
    allExp(entry).trialDuration = sessionInfo.trialDuration;
    allExp(entry).expSel1 = 2;
    allExp(entry).expSel2 = 2;
    % sort the entries by experimentName
    experimentNameValuesNew = extractfield(allExp,'experimentName');
    [x,idx]=sort([experimentNameValuesNew]);
    allExp=allExp(idx);
    % save the new file
    save('allExp.mat', 'allExp');
    disp('modifing and saving allExp.mat')
end

%% button and update functions

function eg_fun( ~, ~, edit_handle)
    global i 
    editBoxContents = get(edit_handle,'String');
    i = str2double(char(editBoxContents));
    updateXY;
end

function eg_fun_next(~, ~, edit_handle)
    global i 
    i= i+1;
    updateXY;
    set(edit_handle, "String", i);
end    

function eg_fun_prev(~, ~, edit_handle)
    global i 
    i= i-1;
    updateXY;
    set(edit_handle, "String", i);
end    

function updateXY
    global i x1 y1 y2 y3 z z_filt1 z_filt2 recStartDataPoint samplingRate
    x1 = (recStartDataPoint(i):recStartDataPoint(i+1)-1)/samplingRate;
    y1 = z(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
    y2 = z_filt1(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
    y3 = z_filt2(1,recStartDataPoint(i):recStartDataPoint(i+1)-1);
    refreshdata
    drawnow
end    

