%%% written by RB on 02.11.2020 %%%
function p_call(src, event, h, code, groupCodes, rM)

unitCode = groupCodes(code);
codeInd = find(groupCodes == unitCode);
s = inputname(6);
rM = evalin('base',s);

vals = get(h.c,'Value');
checked = find([vals{:}]);
if isempty(checked)
    checked = 'none';
end

switch s
    case 'respMat'
        updateRM(rM, codeInd, unitCode, checked)
    case 'respMatMua'
        updateRMMua(rM, codeInd, unitCode, checked)        
end
end
