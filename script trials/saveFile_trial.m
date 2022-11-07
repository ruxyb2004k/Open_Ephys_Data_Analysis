datFilename = [basePathKilosort, filesep, sessionName, '.dat']
if exist(datFilename,'file')
    warning('.dat file already exists.')
else   
    clearvars data_filt
%     data_filt = zeros(1, numel(range1));
%     artefactCh = 7;
%     m = 0;
    for j = 1:3%channelNo
%         clearvars data timestamps
%         filename = ['100_CH', num2str(j+chOffset), '.continuous'];
%         [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
%         deleteArtefact
%         data_ch(1,:) = data(1, ismember(timestamps, ts));% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
%         disp(['Filtering channel ', num2str(j), '...'])
%         data_filt(1,:) = highpass(data_ch(1,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz    
%         data_filt = gain * data_filt;
        data_filt = [(1:10)*j];%; (11:20)*j];
        
        if j == 1
            f = fopen(datFilename, 'w');
        else 
            f = fopen(datFilename, 'a');
        end
        fwrite(f, data_filt, 'int16');
        fclose(f);

    end
    
end

fileID = fopen(datFilename);
A = fread(fileID, [10 3],'2*int16');
fclose(fileID);
B= A.';


%% filter the selected data set
data_filt = int16(zeros(channelNo, numel(range1)));
artefactCh = 7;

for j = 1:channelNo    
    clearvars data timestamps
    filename = ['100_CH', num2str(j+chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);    
    deleteArtefact
    data_ch(1,:) = data(1, ismember(timestamps, ts));% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(j,:) = highpass(data_ch(1,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz
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
%%

data_filt = int16(zeros(channelNo, numel(range1)));
artefactCh = 7;

for j = 1:channelNo    
    clearvars data data_ch timestamps
    filename = ['100_CH', num2str(j+chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);    
    deleteArtefact
    data_ch(1,:) = data(1, ismember(timestamps, ts));% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(j,:) = highpass(data_ch(1,range1), 150, sessionInfo.rates.wideband)*gain; % highpass 150 Hz
end







%%


a = int16(zeros(3, 10));
a(1) = 1;
a(2)= 1.5;
a(3)=10.4;


%%
%% save the dat file, metadata structures and metadata .mat file
% save the dat file
tic
datFilename = [basePathKilosort, filesep, sessionName, '.dat']
if exist(datFilename,'file')
    warning('.dat file already exists.')
else    
    data_filt = zeros(1, numel(range1));
    artefactCh = 7;
    m = 0;
    for j = 1:channelNo
        clearvars data timestamps
        filename = ['100_CH', num2str(j+chOffset), '.continuous'];
        [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);
        deleteArtefact
        data_ch(1,:) = data(1, ismember(timestamps, ts));% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
        disp(['Filtering channel ', num2str(j), '...'])
        data_filt(1,:) = highpass(data_ch(1,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz    
        data_filt = gain * data_filt;
        if j == 1
            f = fopen(datFilename, 'w');
        else 
            f = fopen(datFilename, 'a');
        end
        fwrite(f, data_filt, 'int16');
        fclose(f);  
    end    
end 
toc
%% trial 1
fileID = fopen(datFilename);
A = fread(fileID, [numel(range1) channelNo],'2*int16');
fclose(fileID);
%%
B= A.';
fileID = fopen([datFilename(1:end-4), '-a', '.dat'], 'w');
fwrite(f, B, 'int16');
fclose(fileID);

%% trial 2
fileID = fopen(datFilename);
A = fread(fileID, '2*int16');
fclose(fileID);
%%
tic
dP = numel(range1);
B= nan(channelNp, dP);
parfor j =1:channelNo
    B(j,:) = A(dp*(j-1)+1:dp*j);
end    
toc
fileID = fopen([datFilename(1:end-4), '-a', '.dat'], 'w');
fwrite(f, B, 'int16');
fclose(fileID);

