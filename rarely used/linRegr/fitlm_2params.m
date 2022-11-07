%% base quantification

cond = 3;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 3;
stimPost = 4;
norm = 1; % 0 to not normalized, 1 to normalize
unitsLR = find(baseSelect);%find(OIposUnits);%
x = allStimBase(cond+1, unitsLR, 1)'; % photostim cond, pre photostim
y = allStimBase(cond+1, unitsLR, stimPost)'; % photostim cond, post photostim

%% magn quantification
cond = 1;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 1;
stimPost = 2:4;
norm = 1;
unitsLR = find(baseSelect);%find(OInegUnits);%
x = allStimMagn(cond+1, unitsLR, 1)'; % photostim cond, pre photostim
y = mean(allStimMagn(cond+1, unitsLR, stimPost),3)'; % photostim cond, post photostim


%% linear model with 4 parameters - all units
norm = 1;
exclude0 = 1;
excludeOutliers = 1;
thOut = 0.23;

if exclude0  % exclude trials with 0 in pre or post stim
    warning('exclude0 activated')
    ind12 = (x~= 0 & y~= 0);
    x = x(ind12);
    y = y(ind12); 
end
if norm % normalize data to the max value in the data set
    maxData = max(x) 
    x = x/maxData; 
    y = y/maxData;
end

if excludeOutliers  % exclude trials with 0 in pre or post stim
    warning('excludeOutliers activated')
    ind1Out = (x<= thOut);

    x = x(ind1Out);
    y = y(ind1Out);
    if norm % normalize data to the max value in the data set
        maxData = max(x)
        x = x/maxData;
        y = y/maxData;
    end
end


mdl = fitlm(x,y)
coeffsLM = table2array(mdl.Coefficients); % 4 params, 4 properties of coeffs
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % slope, intercept


% figure16f
% figure16fx

%%

y2 = y-x;
mdl_diff = fitlm(x,y2)

coeffsLM_diff = table2array(mdl_diff.Coefficients); % 4 params, 4 properties of coeffs
coeffsLM1_diff = [coeffsLM_diff(2,1), coeffsLM_diff(1,1)]; % slope, intercept
figure; scatter(x,y2)