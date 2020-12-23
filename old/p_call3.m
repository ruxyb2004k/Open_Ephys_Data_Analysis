%%% written by RB on 04.11.2020 %%%
function p_call(src, event, h, unitCode)
rM = evalin('base','respMat');
gC = evalin('base','goodCodes');

vals = get(h.c,'Value');
checked = find([vals{:}]);
if isempty(checked)
    checked = 'none';
end

codeInd = find(gC == unitCode);

updateRM2(rM, codeInd, unitCode, checked)

end