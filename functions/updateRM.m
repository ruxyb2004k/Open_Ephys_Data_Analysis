%%% written by RB on 04.11.2020 %%%
function updateRM(rM, codeInd, unitCode, catVal)

rMNew = rM;
rMNew(codeInd) = catVal;
if rM(codeInd)~=rMNew(codeInd) 
    if catVal == 1
        disp(['Unit ID ', num2str(unitCode), ' added to the group: visual evoked response']);
    elseif catVal == 2
        disp(['Unit ID ', num2str(unitCode), ' added to the group: spontaneous response to photostim.']);
    elseif catVal == 3
        if rM(codeInd) == 1
            disp(['Unit ID ', num2str(unitCode), ' removed from the group: visual evoked response']);
        elseif rM(codeInd) == 2
            disp(['Unit ID ', num2str(unitCode), ' removed from the group: spontaneous response to photostim.']);
        end
    end
    
    rM = rMNew;
    
    sCISN = sort(find(rM == 2));
    sCI = sort([find(rM == 1), find(rM == 2)]);
    if numel(sCISN)
        sCIS = double(ismember(sCI, sCISN));
    else
        sCIS = zeros(1, numel(sCI));
    end
    assignin('base','respMat',rM);
    assignin('base','selectedCodesInd',sCI);
    assignin('base','selectedCodesIndSpont',sCIS);
    assignin('base','selectedCodesIndSpontNew',sCISN);

end
end