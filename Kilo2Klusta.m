%% modify the Kilosort saved binary file and save it for Klusta analysis

experimentName = '2020-09-22_12-37-59_trial14'
sessionName = 'V1_20200922_1'


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);

basePathData = strjoin({basePath, 'data'}, filesep);
basePathKilosort = strjoin({basePath, 'kilosort analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);

% best way to open the file
datFilename = [basePathKilosort, filesep, sessionName, '.dat']
fileID = fopen(datFilename, 'r');
a = fread(fileID,'*int16');
fclose(fileID);
datavector = reshape(a, [1 numel(a)]);

newsubfolderKlusta = fullfile(basePath, 'klusta analysis');
mkdir(newsubfolderKlusta); % make Kilosort subfolder
basePathKlusta = strjoin({basePath, 'klusta analysis'}, filesep);
datFilenameK = [basePathKlusta, filesep, sessionName, '.dat']

if exist(datFilenameK,'file')
    warning('.dat file already exists.')
else    
    f2 = fopen(datFilenameK, 'w');
    fwrite(f2, datavector, 'int16');
    fclose(f2);
end    