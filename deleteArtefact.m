%%% Script by RB / 13.10.2020 %%%
%%% rewrites the data matrix with the same value during the opto-electrical
%%% artefact

numDp = round(sessionInfo.rates.wideband*0.001); % number of data points to average out (1 ms)
artefactTimes = timestampsEv(dataEv == artefactCh);
for timeInd = 1: numel(artefactTimes) % for each artefact
    exclInd = find(timestamps == artefactTimes(timeInd)); % find its index in timestamps and data    
    data(:,exclInd: exclInd+numDp) = repmat(data(:, exclInd-1), [1,numDp+1]); % remove artefact
end    