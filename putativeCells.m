%%% created by RB on 21.01.2022
%%% checks cells classified by their connections
%%% vs classified by TP time
disp('-----------');
indUnitConn = [];
iUnitsFiltExc = zeros(size(classUnitsAll));
iUnitsFiltInh = zeros(size(classUnitsAll));

countExc = 0;
countInh = 0;
for unit  = 1:totalUnits % remove units without inhibitory connections
    if ~isempty(putativeConnections(unit).excitatory) 
        iUnitsFiltExc(unit) = 1;
        if classUnitsAll(unit) == 1 
            countExc = countExc+1;
%         else    % rewrite the classification
%             classUnitsAll(unit) = 1;
        end    
    end
    if ~isempty(putativeConnections(unit).inhibitory) 
        iUnitsFiltInh(unit) = 1;
        if classUnitsAll(unit) == 2 
            countInh = countInh+1;
        else  % rewrite the classification
            classUnitsAll(unit) = 2;
%             unit
        end    
    end
end
countExc / sum(iUnitsFiltExc)

countInh / sum(iUnitsFiltInh)

