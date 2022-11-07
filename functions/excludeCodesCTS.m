%% trial 1

% excludeSelCodes = [28,36,64,104,110];
% 
% sC = clusterTimeSeries.selectedCodes;
% sc = excludeCodes(clusterTimeSeries.selectedCodes, excludeSelCodes);
% 
% sCI = clusterTimeSeries.selectedCodesInd;
% sCI = find(spikeClusterData.goodCodes, sC);
% 
% function [sC] = excludeCodes(sC,excludeSelCodes)
%     if ~isempty(excludeSelCodes)
%         excludeSelCodes = sort(excludeSelCodes,'descend');
% 
%         for i = 1:numel(excludeSelCodes)
%             if any(sC(:) == excludeSelCodes(i)) %check whether the given number is still present
% %                    delthisCode = find(sC(:) == excludeSelCodes(i));
% %                    sC(delthisCode)=[]; 
%                    sC(sC == excludeSelCodes(i))=[]; 
%             end
%         end
%     end
% end

%% trial 2

codesToModify = [28,36,64,104,110];

sC = clusterTimeSeries.selectedCodes;

respMat = ones(1, numel(spikeClusterData.goodCodes))*3; 
respMat(clusterTimeSeries.selectedCodesInd) = 1;
respMat(find(clusterTimeSeries.selectedCodesIndSpont)) = 2;
respMat = modifyCodes(clusterTimeSeries.selectedCodes, codesToModify, 'toNone');

function [rMfin] = modifyCodes(rM, codesToModify, modifType) % 'toEv', 'toSpont', 'toNone'
    switch strcmp(modifType)
        case 'toEv'
            n = 1;
        case 'toSpont'
            n = 2;
        case 'toNone'
            n =3;
    end        
    if ~isempty(codesToModify)
        codesToModify = sort(codesToModify,'descend');
        
        for i = 1:numel(codesToModify)
            if any(sC(:) == codesToModify(i)) %check whether the given number is still present
                rMfin(sC == codesToModify(i))=n; 
            end
        end
    end
end
