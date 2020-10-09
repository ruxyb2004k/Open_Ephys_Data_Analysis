%%% create 3 new folders in the parent folder
%%% created by RB on 21.07.2020
% parentFolder = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2020-07-20_16-45-13';
% newDirF(parentFolder);

function newDir(parentFolder)

MyFolderInfo = dir(parentFolder); % list of files contained in the parentFolder

newsubfolderData = fullfile(parentFolder, 'data');
mkdir(newsubfolderData); % make data subfolder
newsubfolderMatlab = fullfile(parentFolder, 'matlab analysis');
mkdir(newsubfolderMatlab); % make Matlab subfolder
newsubfolderKlusta = fullfile(parentFolder, 'klusta analysis');
mkdir(newsubfolderKlusta); % make Klusta subfolder

for i = 3:size(MyFolderInfo,1)
    fileName = fullfile(parentFolder, MyFolderInfo(i).name);
    movefile(fileName, newsubfolderData); % move all files to the data subfolder
end

end