%%% written by RB on 04.11.2020 %%%
function updateRMMua(rM, codeInd, unitCode, catVal)

rMNew = rM;
rMNew(codeInd) = catVal;
if rM(codeInd)~=rMNew(codeInd) 
    if catVal == 1
        disp(['Unit ID ', num2str(unitCode), ' added to the group: visual evoked response']);
    elseif catVal == 2
        if rM(codeInd) == 1
            disp(['Unit ID ', num2str(unitCode), ' removed from the group: visual evoked response']);
        end
    end
    
    rM = rMNew;    
    sCIM = find(rM == 1);
    
    assignin('base','respMatMua',rM);
    assignin('base','selectedCodesIndMua',sCIM);
end
end