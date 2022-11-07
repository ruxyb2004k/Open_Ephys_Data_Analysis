%%% load raw data and create session metadata %%%
%%% written by RB 09.07.2020 %%%

% make sure you are in this file's folder

global i x1 y1 y2 y3 recStartDataPoint z z_filt1 z_filt2 samplingRate

experimentName = '2020-05-19_16-30-24'
sessionName = 'V1_20200519_1'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKlusta = strjoin({basePath, 'klusta analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

% if ~exist(basePathData, 'dir')
%     newDir(basePath)
% end    

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
if SIexist && TSexist
    answer = questdlg('Load raw data?', 'Menu',...
        'Yes','No', 'No');
    % Handle response
    switch answer
        case 'Yes'
            disp([' Loading raw data ...'])
        case 'No'
            disp([' Proceed to the next section'])
            return
    end
end

%%%%%%% insert session-specific paramteres here %%%%%%%%%%

recordingDepth = -385; % !!! Modify for each experiment !!!
channelNo = 16;
probe = '1x16_P1';%'tetrode';
animal.name = '20200417_RV1';
animal.sex = 'm';
animal.strain = 'PvCre';
animal.virus = 'AAV9-mOp2A';
recRegion = 'RV1';

conditionNames= [];
conditionNames.c100visStim = 2; % 
conditionNames.c100optStim = 34; % 
% conditionNames.c50visStim = 3;
% conditionNames.c50optStim = 35;
% conditionNames.c25visStim = 5; % 
% conditionNames.c25optStim = 37; % 
% conditionNames.c12visStim = 7; % 
% conditionNames.c12optStim = 39; % 
% conditionNames.c6visStim = 9; % 
% conditionNames.c6optStim = 41; % 
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

trialDuration = 18;% Trial duration in seconds - a bit larger than end of the last rep
preTrialTime = 3; % time before 0 for display
visStim = (0.2:3:15.2);
optStimInterval = [2 10];

% trialDuration = 6;% Trial duration in seconds - a bit larger than end of the last rep
% preTrialTime = 2; % time before 0 for display
% visStim = (4);
% optStimInterval = [0.2 5.2];%[2 10];%

% trialDuration = 7;% Trial duration in seconds - a bit larger than end of the last rep
% preTrialTime = 2; % time before 0 for display
% visStim = (4);
% optStimInterval = [0.2 6];%[2 10];%

%%%%%%%%% experiment-specific parameters end here %%%%%%%%%%


conditionFieldnames = fieldnames(conditionNames); % extract conditionNames (c0visStim c100visStim etc)
totalConds = numel(conditionFieldnames);

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
% sessionInfo.evokedActInterval = evokedActInterval; 
% sessionInfo.spontActInterval = spontActInterval;
sessionInfo.optStimInterval = optStimInterval;
sessionInfo.probe = probe;
sessionInfo.animal = animal;
sessionInfo.recRegion = recRegion;


i=1;
filename = ['100_CH', num2str(i), '.continuous'];
[data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data([basePathData, filesep, filename]);
y(1,:) = bandpass(data(1,:),[600 6000], 20000); % bandpass filter 600-6000 Hz at a recording rate of 20 kHz

% find starting point of each trial
filename_events = ['all_channels', '.events'];
[dataEv, timestampsEv, infoEv] = load_open_ephys_data([basePathData, filesep, filename_events]);
samplingRate = info.header.sampleRate;
load([basePathData, filesep, 'order_all_cond.mat']) % load the sequence of all conditions
condData.codes = order_all_cond;
doubleTimes = timestampsEv(dataEv==1);% detect the events corresponding to beginning of all conditions
condData.times = doubleTimes(1:2:end); % remove the event corresponding to switch off of channel 1 in Master 8
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
%condData.times = condData.newTimes;

sessionInfo.rates.wideband = samplingRate;
sessionInfo.condData = condData;
timeSeries.recStartDataPoint = recStartDataPoint;
timeSeries.events.dataEv = dataEv;
timeSeries.events.timestampsEv = timestampsEv;
timeSeries.events.infoEv = infoEv;

% load the rest of the data
dataPoints = numel(data(1,:));
data= zeros(channelNo,dataPoints);
timestamps = zeros(dataPoints,1);
med = zeros(channelNo,1);
std_ch = zeros(channelNo,1);

for i=(1:channelNo)
    filename = ['100_CH', num2str(i), '.continuous'];
    [data(i,:), timestamps(:,1), info(:,i)] = load_open_ephys_data([basePathData, filesep, filename]);
    % calculate median over each channel and subtract from channel
    med(i) = median(data(i,:));
    std_ch(i) = std(data(i,:));
    data(i,:) = data(i,:) - med(i);
end

figure
plot(timestamps(:,1),y(1,:));

figure
subplot(2,1,1)
plot(1:channelNo,med);
% xlabel('no. channel');
ylabel('channel median');

subplot(2,1,2)
plot(1:channelNo,std_ch);
xlabel('no. channel');
ylabel('channel STD');

timeSeries.dataPoints= dataPoints;
timeSeries.timestamps = timestamps;
timeSeries.info = info;
timeSeries.medCh = med;
timeSeries.stdCh = std_ch;

%% Calculations for fig with epochs + plot figure
close all

selCh = 1;  % selected channel for figure and calculation 
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
    plot(xlim, [1 1]*327, '--k')
    plot(xlim, [1 1]*3276, '--r')
    ylabel('Max @150 Hz');    
    set(gca, 'YScale', 'log')
end
xlabel('channel no.');

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

% subTrialsForAnalysis = 1:numel(recStartDataPoint)-1; % default values
subTrialsForAnalysis = [1:16,21:44,49:80];

range2(1,1) = recStartDataPoint(subTrialsForAnalysis(1));

j=1;
for k = 1:(numel(subTrialsForAnalysis)-1)
    if subTrialsForAnalysis(k+1) ~= subTrialsForAnalysis(k)+1
        range2(j,2) = recStartDataPoint(subTrialsForAnalysis(k)+1)-1;
        range1 = [range1, range2(j,1):range2(j,2)];
        j = j+1;
        range2(j,1) = recStartDataPoint(subTrialsForAnalysis(k+1));
    end
end    
range2(j,2) = recStartDataPoint(subTrialsForAnalysis(end)+1)-1;
range1 = [range1, range2(j,1):range2(j,2)];

timeSeries.range1 = range1;
timeSeries.range2 = range2;
timeSeries.subTrialsForAnalysis = subTrialsForAnalysis;
timeSeries.timestampsRange  = timeSeries.timestamps(timeSeries.range1);
timeSeries.trialsForAnalysis = timeSeries.subTrialsForAnalysis(totalConds:totalConds:end)/totalConds

close all
clearvars -except range1 data channelNo dataPoints timeSeries sessionInfo filenameSessionInfo filenameTimeSeries experimentName sessionName basePathKlusta

%% filter the selected data set

data_filt = zeros(channelNo, numel(range1));

for j = 1:channelNo    
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(j,:) = highpass(data(j,range1), 150, 20000); % highpass 150 Hz
end

clearvars data

% flat subset of data 
gain = 100;
datavector = reshape(gain*data_filt, [1, numel(range1)*channelNo]);  % max ist 32000

%clearvars -except datavector sessionInfo timeSeries
max(datavector)
sum(datavector>32768) % should not be larger than 10 000
min(datavector)
sum(datavector<-32768) % should not be larger than 10 000

timeSeries.gain = gain;

%% best way to save the dat file:
datFilename = [basePathKlusta, filesep, sessionName, '.dat']
if exist(datFilename,'file')
    warning('.dat file already exists.')
else    
    f = fopen(datFilename, 'w');
    fwrite(f, datavector, 'int16');
    fclose(f);
end    


%% Save the meta data
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

%%
% save experiment details:
if exist('allExp_oldData.mat','file') %load structure containing all experiments if it already exists
    load('allExp_oldData.mat')   
    disp('Loading allExp_oldData.mat')
    entry = size(allExp, 2)+1
else
    disp('allExp_oldData has not been found, initializing allExp_oldData')
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
    % sort the entries by experimentName
    experimentNameValuesNew = extractfield(allExp,'experimentName');
    [x,idx]=sort([experimentNameValuesNew]);
    allExp=allExp(idx);
    % save the new file
    save('allExp_oldData.mat', 'allExp');
    disp('modifing and saving allExp_oldData.mat')
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

