%%% Created by RB 04.02.2021


%% baseline quantification OR
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 3;
stimPost = 4;
norm = 1; % 0 to not normalized, 1 to normalize
% use only units with baseline freq above threshold (= baseSelect)
x1 = allStimBase(cond, find(baseSelect),1)'; % no photostim cond, pre photostim
x2 = allStimBase(cond+1, find(baseSelect),1)'; % photostim cond, pre photostim
y1 = allStimBase(cond, find(baseSelect),stimPost)'; % no photostim cond, post photostim
y2 = allStimBase(cond+1, find(baseSelect),stimPost)'; % photostim cond, post photostim
%% OR amplitude quantification OR
cond = 1;
stimPost = 4;
norm = 1;
x1 = allStimAmpl(cond, iUnitsFilt, 1)'; % no photostim cond, pre photostim
x2 = allStimAmpl(cond+1, iUnitsFilt, 1)'; % photostim cond, pre photostim
y1 = allStimAmpl(cond, iUnitsFilt, stimPost)'; % no photostim cond, post photostim
y2 = allStimAmpl(cond+1, iUnitsFilt, stimPost)'; % photostim cond, post photostim


%% OR magnitude quantification
cond = 1;
stimPost = 4;
norm = 1;
x1 = allStimMagn(cond, iUnitsFilt, 1)'; % no photostim cond, pre photostim
x2 = allStimMagn(cond+1, iUnitsFilt, 1)'; % photostim cond, pre photostim
y1 = allStimMagn(cond, iUnitsFilt, stimPost)'; % no photostim cond, post photostim
y2 = allStimMagn(cond+1, iUnitsFilt, stimPost)'; % photostim cond, post photostim

%%

if norm % normalize data to the max value in the data set
    maxData = max([x_all;y_all]) 
    x1 = x1/maxData; 
    y1 = y1/maxData;
    x2 = x2/maxData;
    y2 = y2/maxData;
end    

x_all = [x1;x2];
y_all = [y1;y2];

% size (X) = [2*numUnits 4]
% Columns: 1st: 1; 2nd: 0 for no ph stim, 1 for ph stim conds (s); 3rd: x_all (rpre);
% 4th: 0 for the non stim cond, x2 for the ph stim cond (rpre*s)
X = [ones(size(x_all)), [zeros(size(x1)); ones(size(x2))], x_all, x_all.*[zeros(size(x1)); ones(size(x2))]]; 

mdl = fitlm(X,y_all) % returns parameters and p-values
% also useful: regress function from matlab
