%%% created by RB on 13.07.2021
%%% allows reclassification of a good code to ev, spont or none
%%% first make a copy of clusterTimeSeries.m outside the matlab analysis folder
%%% Script to be executed after SpikeDataLoading_openEphys_KiloSort_A1.m and the
%%% first section of PlotPSTHandRaster_openEphys_KiloSort_A3.m; 
%%% After modifiying 'codesToModify', continue
%%% with running the next sections of PlotPSTHandRaster_openEphys_KiloSort_A3.m 
%%% for good codes and update the excel table

% trial 2 - working fine
% still need to check if it really works for spont codes


%%%%%% modify here %%%%%%
codesToModify = [58,63,233];
modifType = 'toNone'; % 'toEv', 'toSpont', 'toNone'
%%%%%%%%%%%%%%%%%%%%%%%%%

gC = spikeClusterData.goodCodes;
respMat(clusterTimeSeries.selectedCodesInd) = 1;
respMat(clusterTimeSeries.selectedCodesInd(logical(clusterTimeSeries.selectedCodesIndSpont))) = 2; % does it really work when there are selected spont codes?

switch modifType
    case 'toEv'
        catVal = 1;
    case 'toSpont'
        catVal = 2;
    case 'toNone'
        catVal = 3;
end

if ~isempty(codesToModify)
    codesToModify = sort(codesToModify,'descend');
    for i = 1:numel(codesToModify)
        if any(gC(:) == codesToModify(i)) % check whether the given number is still present
            unitCode = codesToModify(i);
            codeInd = find(gC == unitCode);
            updateRM(respMat, codeInd, unitCode, catVal)
        end
    end
end
%% still needs to be modified in order to include or exclude Muas
% 
% respMatMua = ones(1, numel(spikeClusterData.muaCodes))*2; 
% respMatMua(clusterTimeSeries.selectedCodesIndMua) = 1;



%% trial 1 of the 1st section - not needed, kept just in case

% gC = spikeClusterData.goodCodes;
% respMat(clusterTimeSeries.selectedCodesInd) = 1;
% respMat(clusterTimeSeries.selectedCodesInd(logical(clusterTimeSeries.selectedCodesIndSpont))) = 2; % does it really work when there are selected spont codes?
% 
% %%%%%% modify here %%%%%%
% codesToModify = [28,36,64,104,110];
% respMat = modifyCodes(respMat, gC, codesToModify, 'toNone');
% %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function [rMfin] = modifyCodes(rM, gC, codesToModify, modifType) % 'toEv', 'toSpont', 'toNone'
% rMfin = rM;
% 
% switch modifType
%     case 'toEv'
%         catVal = 1;
%     case 'toSpont'
%         catVal = 2;
%     case 'toNone'
%         catVal = 3;
% end
% if ~isempty(codesToModify)
%     codesToModify = sort(codesToModify,'descend');
%     
%     for i = 1:numel(codesToModify)
%         if any(gC(:) == codesToModify(i)) % check whether the given number is still present
%             rMfin(gC == codesToModify(i))=catVal;
% %             codeInd = 
% %             updateRM(rM, codeInd, unitCode, catVal)
%         end
%     end
% end
% end

%% For klusta data - removed codes manually:
%%% Script to be executed after SpikeDataLoading_openEphys_KiloSort_A1.m and the
%%% first section of PlotPSTHandRaster_openEphys_KiloSort_A3.m; 
%%% after running this section, save clusterTimeSeries
newSelCodes = [1];

traceFreqGoodSel = clusterTimeSeries.traceFreqGoodSel(:,newSelCodes,:);
selectedCodes= clusterTimeSeries.selectedCodes(newSelCodes);
selectedCodesDepth= clusterTimeSeries.selectedCodesDepth(newSelCodes);
selectedCodesInd= clusterTimeSeries.selectedCodesInd(newSelCodes);
selectedCodesIndSpont= clusterTimeSeries.selectedCodesIndSpont(newSelCodes);

statsSuaSel = clusterTimeSeries.statsSuaSel;
statsSuaSel.keepTrials = statsSuaSel.keepTrials(:,newSelCodes);
statsSuaSel.keepTrialsBase = statsSuaSel.keepTrialsBase(:,newSelCodes,:);
statsSuaSel.statsCodesInd = statsSuaSel.statsCodesInd(newSelCodes);                              
statsSuaSel.hSua = statsSuaSel.hSua(:,newSelCodes,:);
statsSuaSel.pSua = statsSuaSel.pSua(:,newSelCodes,:);
statsSuaSel.hSuaW = statsSuaSel.hSuaW(:,newSelCodes,:);
statsSuaSel.pSuaW = statsSuaSel.pSuaW(:,newSelCodes,:);
statsSuaSel.hSuaBase = statsSuaSel.hSuaBase(:,newSelCodes,:);
statsSuaSel.pSuaBase = statsSuaSel.pSuaBase(:,newSelCodes,:);
statsSuaSel.hSuaBaseW = statsSuaSel.hSuaBaseW(:,newSelCodes,:);
statsSuaSel.pSuaBaseW = statsSuaSel.pSuaBaseW(:,newSelCodes,:);
statsSuaSel.hSuaBaseSameCond = statsSuaSel.hSuaBaseSameCond(:,newSelCodes,:);
statsSuaSel.pSuaBaseSameCond = statsSuaSel.pSuaBaseSameCond(:,newSelCodes,:);
statsSuaSel.hSuaBaseSameCondW = statsSuaSel.hSuaBaseSameCondW(:,newSelCodes,:);
statsSuaSel.pSuaBaseSameCondW = statsSuaSel.pSuaBaseSameCondW(:,newSelCodes,:);
statsSuaSel.hSuaBaseComb = statsSuaSel.hSuaBaseComb(newSelCodes,:);
statsSuaSel.pSuaBaseComb = statsSuaSel.pSuaBaseComb(newSelCodes,:);
statsSuaSel.hSuaBaseCombW = statsSuaSel.hSuaBaseCombW(newSelCodes,:);
statsSuaSel.pSuaBaseCombW = statsSuaSel.pSuaBaseCombW(newSelCodes,:);

clusterTimeSeries.traceFreqGoodSel = traceFreqGoodSel;
clusterTimeSeries.selectedCodes= selectedCodes;
clusterTimeSeries.selectedCodesDepth= selectedCodesDepth;
clusterTimeSeries.selectedCodesInd= selectedCodesInd;
clusterTimeSeries.selectedCodesIndSpont= selectedCodesIndSpont;
clusterTimeSeries.statsSuaSel = statsSuaSel;