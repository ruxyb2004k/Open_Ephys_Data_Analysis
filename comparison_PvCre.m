%% comparison PV-Cre vs PV-Cre with 2 viruses
load("comparison_PvCre.mat")
allStimMagnNormTracesBaseSubtr100Subtr_1 = allStimMagnNormTracesBaseSubtr100Subtr;
x3 = x2;
y3 = y2;
load("comparison_PvCre_2viruses.mat")
allStimMagnNormTracesBaseSubtr100Subtr_2 = allStimMagnNormTracesBaseSubtr100Subtr;

x1 = x3;
y1 = y3;
clear("allStimMagnNormTracesBaseSubtr100Subtr", "x3", "y3")
%%
totalConds = 4;
totalStim = 6;
for cond = 1:totalConds/2
    for stim = 1:totalStim
        [hAllStimMagnNormTracesBaseSubtr100Subtr(cond,stim), pAllStimMagnNormTracesBaseSubtr100Subtr(cond,stim)] = ttest2(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1(cond,:,stim)), squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2(cond,:,stim)));%,'Vartype', 'unequal'); 
        [pAllStimMagnNormTracesBaseSubtr100SubtrW(cond,stim), hAllStimMagnNormTracesBaseSubtr100SubtrW(cond,stim)] = ranksum(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1(cond,:,stim)), squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2(cond,:,stim))); 
    end    
end
% only significant for stim 4, both tests

[h1,p1]=jbtest(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1(1,:,4)))
[h2,p2]=jbtest(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2(1,:,4)))

[h1,p1]=lillietest(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1(1,:,4)))
[h2,p2]=lillietest(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2(1,:,4)))
nanvar(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1(1,:,4)))
nanvar(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2(1,:,4)))


%%
allStimMagnNormTracesBaseSubtr100Subtr_1_avg(:,:,1) = allStimMagnNormTracesBaseSubtr100Subtr_1(:,:,1);
allStimMagnNormTracesBaseSubtr100Subtr_1_avg(:,:,2) = nanmean(allStimMagnNormTracesBaseSubtr100Subtr_1(:,:,2:4),3);

allStimMagnNormTracesBaseSubtr100Subtr_2_avg(:,:,1) = allStimMagnNormTracesBaseSubtr100Subtr_2(:,:,1);
allStimMagnNormTracesBaseSubtr100Subtr_2_avg(:,:,2) = nanmean(allStimMagnNormTracesBaseSubtr100Subtr_2(:,:,2:4),3);


for cond = 1:totalConds/2
    for stim = 1:2
        [hAllStimMagnNormTracesBaseSubtr100Subtr_avg(cond,stim), pAllStimMagnNormTracesBaseSubtr100Subtr_avg(cond,stim)] = ttest2(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1_avg(cond,:,stim)), squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2_avg(cond,:,stim))); 
        [pAllStimMagnNormTracesBaseSubtr100Subtr_avgW(cond,stim), hAllStimMagnNormTracesBaseSubtr100Subtr_avgW(cond,stim)] = ranksum(squeeze(allStimMagnNormTracesBaseSubtr100Subtr_1_avg(cond,:,stim)), squeeze(allStimMagnNormTracesBaseSubtr100Subtr_2_avg(cond,:,stim))); 
    end    
end
% none is significant

%% linear model with 4 parameters - all units
% must be run when some experiments are loaded and analyzed
norm = 1;
exclude0 = 1;
excludeOutliers = 0;
thOut = 0.5;
totalCoeffs = 4;
dataLM = 'magn';% 'base', 'ampl', 'magn' 

if exclude0  % exclude trials with 0 in pre or post stim
    warning('exclude0 activated')
    % Method 1
%     ind1 = (x1~= 0 & y1 ~= 0);
%     ind2 = (x2~= 0 & y2 ~= 0);
%     x1 = x1(ind1);
%     y1 = y1(ind1);
%     x2 = x2(ind2);
%     y2 = y2(ind2);
    % Method 2
    ind1 = (x1 ~= 0 & y1 ~= 0);
    ind2 = (x2 ~= 0 & y2 ~= 0);
    x1 = x1(ind1);
    y1 = y1(ind1);
    x2 = x2(ind2);
    y2 = y2(ind2);    
end
if norm % normalize data to the max value in the data set
    y1 = y1/max(x1);
    x1 = x1/max(x1); 
    y2 = y2/max(x2);
    x2 = x2/max(x2);
end

% if excludeOutliers  % exclude trials with 0 in pre or post stim
%     warning('excludeOutliers activated')
%     ind1Out = (x1<= thOut);
%     ind2Out = (x2<= thOut);
%     x1 = x1(ind1Out);
%     y1 = y1(ind1Out);
%     x2 = x2(ind2Out);
%     y2 = y2(ind2Out);
%     if norm % normalize data to the max value in the data set
%         maxData = max([x1;x2])
%         x1 = x1/maxData;
%         y1 = y1/maxData;
%         x2 = x2/maxData;
%         y2 = y2/maxData;
%     end
% end


x_all = [x1;x2];
y_all = [y1;y2];

% size (X) = [2*numUnits 4]
% Columns: 1st: 1; 2nd: 0 for no ph stim, 1 for ph stim conds (s); 3rd: x_all (rpre);
% 4th: 0 for the non stim cond, x2 for the ph stim cond (rpre*s)
ph = [zeros(size(x1)); ones(size(x2))];
X = [x_all, ph, x_all.*ph]; 
mdl = fitlm(X,y_all) % returns parameters and p-values
% also useful: regress function from matlab
coeffsLM = table2array(mdl.Coefficients); % 4 params, 4 properties of coeffs
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1
coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)+coeffsLM(3,1)]; % coefficients for x2,y2



figure16f
figure16fx

