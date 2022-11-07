excludeSelCodes = [];
sC = clusterTimeSeries.selectedCodes;
sc = excludeCodes(clusterTimeSeries.selectedCodes, excludeSelCodes)



function [sc_new] = excludeCodes(sC,excludeSelCodes)
    if ~isempty(excludeSelCodes)
        excludeSelCodes = sort(excludeSelCodes,'descend');

        for i = 1:numel(excludeSelCodes)
            if any(sC(:) == excludeSelCodes(i)) %check whether the given number is still present
                   delthisCode = find(sC(:) == excludeSelCodes(i));
                   sC(delthisCode)=[]; 
            end
        end
    end
end