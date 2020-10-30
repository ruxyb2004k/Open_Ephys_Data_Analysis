%%% script created by RB, 16.10.2020
function [cids, cch] = readClusterInfoCSV(filename)
% cids is length nClusters, the cluster ID numbers
% cch is length nClusters, the "best channel":

fid = fopen(filename);
C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s');
fclose(fid);

cids = cellfun(@str2num, (C{1,1}(2:end)));
cch = cellfun(@str2num, (C{1,6}(2:end)));
