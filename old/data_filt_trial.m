%% filter the selected data set - option 2
% this approach creates temporary files

tic
data_filt = zeros(1, numel(range1));
artefactCh = 7;
m = 0;
for j = 1:channelNo    
    clearvars data timestamps
    filename = ['100_CH', num2str(j+chOffset), '.continuous'];
    [data(1,:), timestamps(:,1), info(:,1)] = load_open_ephys_data_faster([basePathData, filesep, filename]);    
    data(1,:) = data(1,:)- med(j);
    deleteArtefact
    data_ch(1,:) = data(1, ismember(timestamps, ts));% in case a channel is missing data points, this command will align its data with the timestamps common for all channels
    disp(['Filtering channel ', num2str(j), '...'])
    data_filt(1,:) = highpass(data_ch(1,range1), 150, sessionInfo.rates.wideband); % highpass 150 Hz
    m = max([max(data_filt), abs(min(data_filt))]);
    gainCh(j)=suggestGain(m);
    data_filt(1,:) = data_filt(1,:)*gainCh(j);
    tmpName{j} = [tempname, '.dat'];
    fileID = fopen(tmpName{j},'w');
    fwrite(fileID,data_filt, 'int16');
    fclose(fileID);

end


disp(['Maximum value: ', num2str(round(m))]);
gain = suggestGain(m);
disp(['Suggested gain: ', num2str(gain)]);

%gain = 20
timeSeries.gain = gain;
toc

% open temporary files
tic
gain = min(gainCh);
data_filt = int16(zeros(1, numel(range1)));
artefactCh = 7;

for j = 1:channelNo    
    clearvars data timestamps
    fileID = fopen(tmpName{j});
    data_ch(1,:)= fread(fileID, '2*int16');
    fclose(fileID);
    delete(tmpName{j}); %%% this line was not checked - does it really work? recycle needed?
    data_filt(j,:) = data_ch(1,:)/(gainCh(j)/gain);
end
toc

