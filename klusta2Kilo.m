%% modify the saved binary file and save it for Kilosort2 analysis

experimentName = '2020-09-29_11-14-44'
sessionName = 'V1_20200929_1'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKlusta = strjoin({basePath, 'klusta analysis_all'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);

% best way to open the file
datFilename = [basePathKlusta, filesep, sessionName, '.dat']
fileID = fopen(datFilename, 'r');
a = fread(fileID,'*int16');
fclose(fileID);
datamatrix = reshape(a, [sessionInfo.nChannels, numel(a)/sessionInfo.nChannels]);

newsubfolderKilosort2 = fullfile(basePath, 'kilosort2 analysis');
mkdir(newsubfolderKilosort2); % make Kilosort subfolder
basePathKilosort2 = strjoin({basePath, 'kilosort2 analysis'}, filesep);
datFilenameKS = [basePathKilosort2, filesep, sessionName, '.dat']

if exist(datFilenameKS,'file')
    warning('.dat file already exists.')
else    
    f2 = fopen(datFilenameKS, 'w');
    fwrite(f2, datamatrix, 'int16');
    fclose(f2);
end    