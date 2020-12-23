%%% written by RB on 02.11.2020 %%%
function p_call(src, event, h)

sCIN = evalin('base','selectedCodesIndNew');
sCISN = evalin('base','selectedCodesIndSpontNew');
tC = evalin('base','titleCode');

vals = get(h.c,'Value');
checked = find([vals{:}]);
if isempty(checked)
    checked = 'none';
end

n = get(gcf,'Number');

if checked == 1
    if ~ismember(n, sCIN)
        sCIN(end+1) = n;
        assignin('base','selectedCodesIndNew',sCIN);
        disp(['Unit in figure ', num2str(n), ' added in the group: visual evoked response']);
    end    
    if ismember(n, sCISN)
        sCISNtemp = sCISN(sCISN~=n);
        sCISN = sCISNtemp;
        assignin('base','selectedCodesIndSpontNew',sCISN);
    end   
    
elseif checked == 2
    if ~ismember(n, sCISN)
        sCISN(end+1) = n;
        assignin('base','selectedCodesIndSpontNew',sCISN);
        disp(['Unit in figure ', num2str(n), ' added in the group: spontaneous response to photostim.']);
    end    
    if ismember(n, sCIN)
        sCINtemp = sCIN(sCIN~=n);
        sCIN = sCINtemp;
        assignin('base','selectedCodesIndNew',sCIN);
    end   

elseif checked == 3
    if ismember(n, sCIN)
        sCINtemp = sCIN(sCIN~=n);
        sCIN = sCINtemp;
        assignin('base','selectedCodesIndNew',sCIN);
        disp(['Unit in figure ', num2str(n), ' removed from the group: visual evoked response']);
    elseif ismember(n, sCISN)
        sCISNtemp = sCISN(sCISN~=n);
        sCISN = sCISNtemp;
        assignin('base','selectedCodesIndSpontNew',sCISN);
        disp(['Unit in figure ', num2str(n), ' removed from the group: spontaneous response to photostim.']);    
           
    end   
end



sCI = [sCIN, sCISN];
sCIS = [zeros(1, numel(sCIN)), ones(1, numel(sCISN))];
[a,I] = sort(sCI);
assignin('base','selectedCodesInd',a);
assignin('base','selectedCodesIndSpont',sCIS(I));
% sCI = a;
% sCIS = sCIS(I);

end