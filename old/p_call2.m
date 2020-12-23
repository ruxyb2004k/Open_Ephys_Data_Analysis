%%% written by RB on 02.11.2020 %%%
function p_call(src, event, h, unitCode)
rM = evalin('base','respMat');
% sCI = evalin('base','selectedCodesInd');
% tC = evalin('base','titleCode');
gC = evalin('base','goodCodes');

vals = get(h.c,'Value');
checked = find([vals{:}]);
if isempty(checked)
    checked = 'none';
end

% figN = get(gcf,'Number');
% unitCode = tC(sCI(figN));
codeInd = find(gC == unitCode);

updateRM(rM, codeInd, unitCode, checked)
% 
% if checked == 1
%     if ~ismember(codeInd, sCIN)
%         sCIN(end+1) = codeInd;
%         sCIN = sort(sCIN);
%         assignin('base','selectedCodesIndNew',sCIN);
%         disp(['Unit ID ', num2str(unitCode), ' in fig. ', num2str(figN),' added in the group: visual evoked response']);
%     end    
%     if ismember(codeInd, sCISN)
%         sCISNtemp = sCISN(sCISN~=codeInd);
%         sCISN = sort(sCISNtemp);
%         assignin('base','selectedCodesIndSpontNew',sCISN);
%     end   
%     
% elseif checked == 2
%     if ismember(codeInd, sCISN)
%         sCISN(end+1) = codeInd;
%         sCISN = sort(sCISN);
%         assignin('base','selectedCodesIndSpontNew',sCISN);
%         disp(['Unit ID ', num2str(unitCode), ' in fig. ', num2str(figN), ' added in the group: spontaneous response to photostim.']);
%     end    
%     if ismember(codeInd, sCIN)
%         sCINtemp = sCIN(sCIN~=codeInd);
%         sCIN = sort(sCINtemp);
%         assignin('base','selectedCodesIndNew',sCIN);
%     end   
% 
% elseif checked == 3
%     if ismember(codeInd, sCIN)
%         sCINtemp = sCIN(sCIN~=codeInd);
%         sCIN = sort(sCINtemp);
%         assignin('base','selectedCodesIndNew',sCIN);
%         disp(['Unit ID ', num2str(unitCode), ' in fig. ', num2str(figN), ' removed from the group: visual evoked response']);
%     elseif ismember(codeInd, sCISN)
%         sCISNtemp = sCISN(sCISN~=codeInd);
%         sCISN = sort(sCISNtemp);
%         assignin('base','selectedCodesIndSpontNew',sCISN);
%         disp(['Unit ID ', num2str(unitCode), ' in fig. ', num2str(figN), ' removed from the group: spontaneous response to photostim.']);    
%            
%     end   
% end



% sCI = [sCIN, sCISN];
% sCIS = [zeros(1, numel(sCIN)), ones(1, numel(sCISN))];
% [a,I] = sort(sCI);
% assignin('base','selectedCodesInd',a);
% assignin('base','selectedCodesIndSpont',sCIS(I));
% sCI = a;
% sCIS = sCIS(I);

end