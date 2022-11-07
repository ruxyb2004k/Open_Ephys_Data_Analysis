filename1 = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2021-07-01_14-53-08/data/100_CH1.continuous';
filename2 = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2021-07-01_16-55-37/data/100_CH1.continuous';
filenamef = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2021-07-01_16-55-37/100_CH1.continuous';

NUM_HEADER_BYTES = 1024;
fid1 = fopen(filename1, 'r');
hdr1 = fread(fid1, NUM_HEADER_BYTES, 'char*1'); % RB: not working
samples1 = fread(fid1, 'int16');
timestamps1 = fread(fid1, 1, 'int64',0,'l');

% load data from file 2
fid2 = fopen(filename2, 'r');
hdr2 = fread(fid2, NUM_HEADER_BYTES, 'char1');
samples2 = fread(fid2, 'int16');
% write data into new file
fid_final=fopen(sprintf('100_CH%d.continuous',i), 'w');
fwrite(fid_final, hdr1, 'char*1'); %I just put the first header in there, since Kilosort expects it.
fwrite(fid_final, samples1, 'int16');
fwrite(fid_final, samples2, 'int16');
fclose(fid1);
fclose(fid2);
fclose(fid_final);

% not getting the timestamps