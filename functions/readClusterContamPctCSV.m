%%% script created by RB, 19.10.2020
function [cids, ccp] = readClusterContamPctCSV(filename)
% cids is length nClusters, the cluster ID numbers
% cch is length nClusters, the "best channel":

fid = fopen(filename);
C = textscan(fid, '%s%s');
fclose(fid);

cids = cellfun(@str2num, (C{1,1}(2:end)));
ccp = cellfun(@str2num, (C{1,2}(2:end)));
