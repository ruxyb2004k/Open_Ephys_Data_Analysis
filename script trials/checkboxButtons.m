%     h.c(1) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[10,30,50,15],'string','EvokedVis');
%     h.c(2) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[90,30,50,15],'string','SpontPh');   
%     h.c(3) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[170,30,50,15],'string','none');    
%     h.p = uicontrol('style','pushbutton','units','pixels',...
%                 'position',[40,5,70,20],'string','OK');
%     set(h.p, 'callback', @(src, event) p_call(src, event, h, selectedCodesIndNew, selectedCodesIndSpontNew));   
%     bg = uibuttongroup




% selectedCodesInd = [selectedCodesIndNew, selectedCodesIndSpontNew];
% selectedCodesIndSpont = [zeros(1, numel(selectedCodesIndNew)), ones(1, numel(selectedCodesIndSpontNew))];
% [a,I] = sort(selectedCodesInd);
% selectedCodesInd = a;
% selectedCodesIndSpont = selectedCodesIndSpont(I);
