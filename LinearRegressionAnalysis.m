%%% Created by RB 04.02.2021


%% baseline quantification OR
cond = 3;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 3;
stimPost = 4;
norm = 1; % 0 to not normalized, 1 to normalize
unitsLR = find(baseSelect);%find(OIposUnits);%
x1 = allStimBase(cond, unitsLR ,1)'; % no photostim cond, pre photostim
x2 = allStimBase(cond+1, unitsLR ,1)'; % photostim cond, pre photostim
y1 = allStimBase(cond, unitsLR ,stimPost)'; % no photostim cond, post photostim
y2 = allStimBase(cond+1, unitsLR ,stimPost)'; % photostim cond, post photostim
%% OR amplitude quantification OR
cond = 3;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 1;
stimPost = 4;
norm = 1;
x1 = allStimAmpl(cond, iUnitsFilt, 1)'; % no photostim cond, pre photostim
x2 = allStimAmpl(cond+1, iUnitsFilt, 1)'; % photostim cond, pre photostim
y1 = allStimAmpl(cond, iUnitsFilt, stimPost)'; % no photostim cond, post photostim
y2 = allStimAmpl(cond+1, iUnitsFilt, stimPost)'; % photostim cond, post photostim

%%  OR amplitude of normalized traces between baseline and amplitude - doesn't make sense

% cond = 1;
% stimPost = 4;
% norm = 1;
% x1 = allStimAmplNormTracesBaseSubtr(cond, iUnitsFilt,1)';
% x2 = allStimAmplNormTracesBaseSubtr(cond+1, iUnitsFilt,1)';
% y1 = allStimAmplNormTracesBaseSubtr(cond, iUnitsFilt,stimPost)';
% y2 = allStimAmplNormTracesBaseSubtr(cond+1, iUnitsFilt,stimPost)';

%% OR magnitude quantification
cond = 1;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 1;
stimPost = 2:4;
norm = 1;
unitsLR = find(baseSelect);%find(OInegUnits);%
x1 = allStimMagn(cond, unitsLR, 1)'; % no photostim cond, pre photostim
x2 = allStimMagn(cond+1, unitsLR, 1)'; % photostim cond, pre photostim
y1 = mean(allStimMagn(cond, unitsLR, stimPost),3)'; % no photostim cond, post photostim
y2 = mean(allStimMagn(cond+1, unitsLR, stimPost),3)'; % photostim cond, post photostim


%% OR magnitude quantification from normalized traces
% not informative
cond = 1;
% baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
cond = 1;
stimPost = 3:4;
norm = 1;
unitsLR = find(baseSelect);%find(OInegUnits);%
x1 = allStimMagnNormTracesBaseSubtr100(cond, unitsLR, 1)'; % no photostim cond, pre photostim
x2 = allStimMagnNormTracesBaseSubtr100(cond+1, unitsLR, 1)'; % photostim cond, pre photostim
y1 = mean(allStimMagnNormTracesBaseSubtr100(cond, unitsLR, stimPost),3)'; % no photostim cond, post photostim
y2 = mean(allStimMagnNormTracesBaseSubtr100(cond+1, unitsLR, stimPost),3)'; % photostim cond, post photostim


%% OR COMBINED baseline quantification  (totalStim = 1)
cond = 1;
baseSelect = allStimBaseComb(cond,:,1) >= thresholdFreq ;
stimPost = 4;
norm = 1; % 0 to not normalized, 1 to normalize
unitsLR = find(baseSelect)%find(OIposUnits);%
% use only units with baseline freq above threshold (= baseSelect)
x1 = allStimBaseComb(cond, unitsLR ,1)'; % no photostim cond, pre photostim
x2 = allStimBaseComb(cond+1,unitsLR ,1)'; % photostim cond, pre photostim
y1 = allStimBaseComb(cond, unitsLR ,stimPost)'; % no photostim cond, post photostim
y2 = allStimBaseComb(cond+1, unitsLR ,stimPost)'; % photostim cond, post photostim

%% baseline 4 vs amplitude 4 quantification OR
% cond = 3;
% baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
% cond = 1;
% stimPost = 4;
% norm = 1; % 0 to not normalized, 1 to normalize
% % use only units with baseline freq above threshold (= baseSelect)
% x1 = allStimBase(cond, find(baseSelect),stimPost)'; % no photostim cond, pre photostim
% x2 = allStimBase(cond+1, find(baseSelect),stimPost)'; % photostim cond, pre photostim
% y1 = allStimAmpl(cond, find(baseSelect), stimPost)'; % no photostim cond, post photostim
% y2 = allStimAmpl(cond+1, find(baseSelect), stimPost)'; % photostim cond, post photostim

%% OR amplitude quantification OR
% cond = 3;
% baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
% cond = 1;
% stimPost = 4;
% norm = 1;
% x1 = allStimAmpl(totalConds-1, find(baseSelect), stimPost)'; % no photostim cond, pre photostim
% x2 = allStimAmpl(totalConds, find(baseSelect), stimPost)'; % photostim cond, pre photostim
% y1 = allStimAmpl(cond, find(baseSelect), stimPost)'; % no photostim cond, post photostim
% y2 = allStimAmpl(cond+1, find(baseSelect), stimPost)'; % photostim cond, post photostim

%% linear model with 4 parameters - all units
norm = 1;
exclude0 = 1;
excludeOutliers = 0;
thOut = 0.23;
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
    ind12 = (x1~= 0 & y1 ~= 0 & x2~= 0 & y2 ~= 0);
    x1 = x1(ind12);
    y1 = y1(ind12);
    x2 = x2(ind12);
    y2 = y2(ind12);    
end
if norm % normalize data to the max value in the data set
    maxData = max([x1;x2]) 
    x1 = x1/maxData; 
    y1 = y1/maxData;
    x2 = x2/maxData;
    y2 = y2/maxData;
end

if excludeOutliers  % exclude trials with 0 in pre or post stim
    warning('excludeOutliers activated')
    ind1Out = (x1<= thOut);
    ind2Out = (x2<= thOut);
    x1 = x1(ind1Out);
    y1 = y1(ind1Out);
    x2 = x2(ind2Out);
    y2 = y2(ind2Out);
    if norm % normalize data to the max value in the data set
        maxData = max([x1;x2])
        x1 = x1/maxData;
        y1 = y1/maxData;
        x2 = x2/maxData;
        y2 = y2/maxData;
    end
end


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
%% linear model with 4 parameters - combined baseline of 1 stim protocols - single unit
thresholdFreq = 0.5;
cond = 3;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
stimPost = 3;
norm = 1; % 0 to not normalized, 1 to normalize
exclude0 = 1; % exclude (x,y) pairs if one of them is 0
n = ceil(sqrt(sum(baseSelect)));
totalCoeffs = 4;
coeffsLM = nan(totalUnits, totalCoeffs,4); % units, params, properties of params


saveFig16j = {'LMbasePreBasePost1eachSUA.fig'}; 
figure;
% use only units with baseline freq above threshold (= baseSelect)
i=1;

for unit = find(baseSelect) 
    % method 1
%     x1 = [];
%     y1 = [];
%     x2 = [];
%     y2 = [];
%     for cond = 1:2:totalConds
%         x1 = [x1; squeeze(allStimBaseByTrial(cond, unit,:, 1))]; % no photostim cond, pre photostim
%         x2 = [x2; squeeze(allStimBaseByTrial(cond+1, unit,:, 1))]; % photostim cond, pre photostim       
%         y1 = [y1; squeeze(allStimBaseByTrial(cond, unit,:,stimPost))]; % no photostim cond, post photostim
%         y2 = [y2; squeeze(allStimBaseByTrial(cond+1, unit,:,stimPost))]; % photostim cond, post photostim
%     end
    % method 2
    x1 = squeeze(allStimBaseByTrial(cond:2:totalConds, unit,:, 1)); % no photostim cond, pre photostim
    x2 = squeeze(allStimBaseByTrial(cond+1:2:totalConds, unit,:, 1)); % photostim cond, pre photostim
    y1 = squeeze(allStimBaseByTrial(cond:2:totalConds, unit,:,stimPost)); % no photostim cond, post photostim
    y2 = squeeze(allStimBaseByTrial(cond+1:2:totalConds, unit,:,stimPost)); % photostim cond, post photostim
    
    x1= x1(:);
    x2= x2(:);
    y1= y1(:);
    y2= y2(:);
%     
    x1 = x1(~isnan(x1)); % exclude Nans - do x1 and y1 have exactly the same nans?
    y1 = y1(~isnan(y1));
    x2 = x2(~isnan(x2));
    y2 = y2(~isnan(y2));

    
    if exclude0  % exclude trials with 0 in pre or post stim
        warning('exclude0 activated')
        ind1 = (x1~= 0 & y1 ~= 0);
        ind2 = (x2~= 0 & y2 ~= 0);
        x1 = x1(ind1);
        y1 = y1(ind1);
        x2 = x2(ind2);
        y2 = y2(ind2);
    end    
    
    if norm % normalize data to the max value in the data set
        maxData = max([x1;x2])
        x1 = x1/maxData;%
        y1 = y1/maxData;
        x2 = x2/maxData;
        y2 = y2/maxData;
    end
    
    x_all = [x1;x2];
    y_all = [y1;y2];
    
    ph = [zeros(size(x1)); ones(size(x2))];
    X = [x_all, ph, x_all.*ph];
    mdl = fitlm(X,y_all) % returns parameters and p-values
    
    subplot(n,n,i)
    ax=gca;   

    scatter(x1', y1', [], C(totalConds-1,:), 'LineWidth', 2); hold on
    scatter(x2', y2', [], C(totalConds,:), 'LineWidth', 2);

    lims = max(xlim, ylim);
    xlim(lims)
    ylim(lims)
    
    % calculate coefficients from the linear regression model
    coeffsLM(unit,:,:) = table2array(mdl.Coefficients);
    coeffsLM1 = [coeffsLM(unit,2,1), coeffsLM(unit,1,1)]; % coefficients for x1,y1
    coeffsLM2 = [coeffsLM(unit,2,1)+coeffsLM(unit,4,1), coeffsLM(unit,1,1)+coeffsLM(unit,3,1)]; % coefficients for x2,y2
   
    f1 = polyval(coeffsLM1, lims);
    f2 = polyval(coeffsLM2, lims);

    plot(lims, f1, 'Color', C(totalConds-1,:));
    plot(lims, f2, 'Color', C(totalConds,:));
    
    lim= max(max(xlim, ylim));
    % text(lim*0.2, lim*0.90, [num2str(round(coeffs1(1),2)),'*x + ',num2str(round(coeffs1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
    % text(lim*0.2, lim*0.97, [num2str(round(coeffs2(1),2)),'*x + ',num2str(round(coeffs2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));
%     text(lim*0.8, lim*0.37, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
%     text(lim*0.8, lim*0.30, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));

    legend off
    
    h1 = line([0 lim],[0 lim]); % diagonal line
    set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
    
%     set(ax,'FontSize',fs)
    title([num2str(unit), ', ', num2str(spikeClusterDataAll.goodCodes(unit))], 'Color', EIColor(classUnitsAll(unit)), 'Fontsize', 8);
    i = i+1

end

if norm
    xlabel('Pre (norm. spike freq.)');
    ylabel('Post (norm. spike freq.)');
else     
    xlabel('Pre spike freq (Hz)');
    ylabel('Post spike freq (Hz)');
end    

if saveFigs == true
    savefig(strcat(savePath, saveFig16j{1}));
    saveas(gcf, strcat(savePath, saveFig16j{1}(1:end-3), 'png'));
end

meanCoeffsLM = nanmean(coeffsLM(:,:,1),1)';

STEMcoeffsLM = nan(totalCoeffs,1);
for coeff = 1:totalCoeffs
    STEMcoeffsLM(coeff) = nanstd(coeffsLM(:,coeff,1))/sqrt(sum(~isnan(coeffsLM(:,coeff,1))));  
end

for coeff = 1:totalCoeffs
    [hCoeffsLM(coeff), pCoeffsLM(coeff)] = ttest(squeeze(coeffsLM(:,coeff,1))); % param: all stims vs first stim in photostim conditions
    [pCoeffsLMW(coeff), hCoeffsLMW(coeff)] = signrank(squeeze(coeffsLM(:,coeff,1))); % nonparam: all stims vs first stim in photostim conditions
end

%% coefficients figure
saveFig16jx = {'LMbasePreBasePost1eachSUACoeffs.fig'}; 
figure
ax=gca;
bar(1:totalCoeffs,meanCoeffsLM, 'FaceColor', 'k', 'EdgeColor', 'none', 'BarWidth', 0.8); hold on
errorbar(1:totalCoeffs,meanCoeffsLM ,STEMcoeffsLM, 'LineStyle','none', 'LineWidth', 2,'Color', C(1,:));

for coeff = 1:totalCoeffs % add stars in case of significance
    yp = (meanCoeffsLM(coeff)+sign(meanCoeffsLM(coeff))*STEMcoeffsLM(coeff))*1.15;
    if pCoeffsLM(coeff) <= 0.001
        %             pStars = '***';
        text(coeff, yp, '***','FontSize',10,  'HorizontalAlignment','center')
    elseif pCoeffsLM(coeff) <= 0.01
        %             pStars = '**';
        text(coeff, yp, '**','FontSize',10, 'HorizontalAlignment','center')
    elseif pCoeffsLM(coeff) <= 0.05
        %             pStars = '*';
        text(coeff, yp, '*','FontSize',10, 'HorizontalAlignment','center')
    end
end
ylim([min(meanCoeffsLM -STEMcoeffsLM), max(meanCoeffsLM + STEMcoeffsLM)]*1.3) 
xticklabels({'\beta_0', '\beta_1', '\beta_2', '\beta_3'})
box off
set(ax,'FontSize',fs)
text(2,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1*r_p_r_e + \beta_2*s + \beta_3*r_p_r_e*s','FontSize',10)
if saveFigs == true
    savefig(strcat(savePath, saveFig16jx{1}));
    saveas(gcf, strcat(savePath, saveFig16jx{1}(1:end-3), 'png'));
end

%% simulated fits based on the average coefficients

saveFig16jxx = {'LMbasePrebasePost0CoeffSim.fig'}; %modify here if needed
    
figure;
ax = gca;

lims = [0, 1.5];
xlim(lims)
ylim(lims)

% calculate coefficients from the linear regression model

coeffsLM1 = [meanCoeffsLM(2), meanCoeffsLM(1)]; % coefficients for x1,y1
coeffsLM2 = [meanCoeffsLM(2)+meanCoeffsLM(4), meanCoeffsLM(1)+meanCoeffsLM(3)]; % coefficients for x2,y2
 
f1 = polyval(coeffsLM1, lims); hold on
f2 = polyval(coeffsLM2, lims);

plot(lims, f1, 'Color', C(totalConds-1,:));
plot(lims, f2, 'Color', C(totalConds,:));


lim= max(max(xlim, ylim));
text(lim*0.25, lim*0.90, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds-1,:));
text(lim*0.25, lim*0.97, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds,:));

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
if totalStim == 6
    xlabel('Norm. base pre','FontSize',24); % modify here if needed
    ylabel('Norm. base post','FontSize',24); % modify here if needed
else
    xlabel('Norm. comb. base pre','FontSize',24); % modify here if needed
    ylabel('Norm. comb. base post','FontSize',24); % modify here if needed
end    
% xlim([0 1])
% ylim([0 1])
set(ax,'FontSize',fs)
if saveFigs == true
    savefig(strcat(savePath, saveFig16jxx{1}));
    saveas(gcf, strcat(savePath, saveFig16jxx{1}(1:end-3), 'png'));
end


%% linear model with 7/8 parameters - for contrast protocols, all units
norm = 1;
cond = 3;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
stimPost = 4;
exclude0 = 1;
norm = 1; % 0 to not normalized, 1 to normalize
cond =1;
totalCoeffs = 7;
excludeOutliers = 0;
thOut = 0.23; 
% use only units with baseline freq above threshold (= baseSelect)
x1 = allStimBase(cond, find(baseSelect),1)'; % no photostim cond, pre photostim
x2 = allStimBase(cond+1, find(baseSelect),1)'; % photostim cond, pre photostim
x3 = allStimBase(totalConds-1, find(baseSelect),1)'; % no photostim cond, pre photostim
x4 = allStimBase(totalConds, find(baseSelect),1)'; % photostim cond, pre photostim

y1 = allStimAmpl(cond, find(baseSelect),stimPost)'; % no photostim cond, post photostim
y2 = allStimAmpl(cond+1, find(baseSelect),stimPost)'; % photostim cond, post photostim
y3 = allStimAmpl(totalConds-1, find(baseSelect),stimPost)'; % no photostim cond, post photostim
y4 = allStimAmpl(totalConds, find(baseSelect),stimPost)'; % photostim cond, post photostim

if exclude0  % exclude cells with 0 in pre or post stim
    warning('exclude0 activated')
    ind1 = (x1~= 0 & y1 ~= 0);
    ind2 = (x2~= 0 & y2 ~= 0);
    ind3 = (x3~= 0 & y3 ~= 0);
    ind4 = (x4~= 0 & y4 ~= 0);
    x1 = x1(ind1);
    y1 = y1(ind1);
    x2 = x2(ind2);
    y2 = y2(ind2);
    x3 = x3(ind3);
    y3 = y3(ind3);
    x4 = x4(ind4);
    y4 = y4(ind4);
end

if norm % normalize data to the max value in the data set
    maxData = max([x1;x2;x3;x4]); 
    x1 = x1/maxData; 
    y1 = y1/maxData;
    x2 = x2/maxData;
    y2 = y2/maxData;
    x3 = x3/maxData;
    y3 = y3/maxData;
    x4 = x4/maxData;
    y4 = y4/maxData;
end   
if excludeOutliers  % exclude trials with 0 in pre or post stim
    warning('excludeOutliers activated')
    ind1Out = (x1<= thOut);
    ind2Out = (x2<= thOut);
    ind3Out = (x3<= thOut);
    ind4Out = (x4<= thOut);
    x1 = x1(ind1Out);
    y1 = y1(ind1Out);
    x2 = x2(ind2Out);
    y2 = y2(ind2Out);
    x3 = x3(ind3Out);
    y3 = y3(ind3Out);
    x4 = x4(ind4Out);
    y4 = y4(ind4Out);
    if norm % normalize data to the max value in the data set
        maxData = max([x1;x2])
        x1 = x1/maxData;
        y1 = y1/maxData;
        x2 = x2/maxData;
        y2 = y2/maxData;
        x3 = x3/maxData;
        y3 = y3/maxData;
        x4 = x4/maxData;
        y4 = y4/maxData;
    end
end

x_all = [x1;x2;x3;x4];
y_all = [y1;y2;y3;y4];

ev = [ones(size([x1;x2])); zeros(size([x3;x4]))];
ph = [zeros(size(x1)); ones(size(x2)); zeros(size(x3)); ones(size(x4))];
if totalCoeffs == 7
    X = [x_all, ev, x_all.*ph, x_all.*ev, ph.*ev, x_all.*ph.*ev];  % 7 params (Lottem, 2016)
elseif totalCoeffs == 8
    X = [x_all, ev, x_all.*ph, x_all.*ev, ph.*ev, x_all.*ph.*ev, ph]; % 8 params 
end    
mdl = fitlm(X,y_all) % returns parameters and p-values
% also useful: regress function from matlab


figure16h
figure16hx

%%%%% Tip 1: include only significantly inhibited / excited units %%%%%
%%%%% Tip 2: include 8 params instead of 7, or drop one based on the effect
%%%%% on the spontaneous activity - DONE %%%%%
%%%%% Tip 3: try on single units, as well as on avg - DONE %%%%%
%%%%% Tip 4: Report the value of average regression coefficients (Fig. 4D) - DONE %%%
%%%%% Tip 5: Discard data points with post firing rate = 0  - DONE %%%%%
%%% Task: store all coeffs - DONE
%%% update figures
%% linear model with 7/8 parameters - for contrast protocols - single unit

cond = 1;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
stimPost = 1;
norm = 0; % 0 to not normalized, 1 to normalize
exclude0 = 1; % exclude (x,y) pairs if one of them is 0
n = ceil(sqrt(sum(baseSelect)));
coeffsLM = nan(totalUnits, 8,4);

saveFig16i = {'LMbase1Ampl1eachSUA.fig'}; 
figure;
% use only units with baseline freq above threshold (= baseSelect)
i=1;
for unit = find(baseSelect)
    x1 = squeeze(allStimBaseByTrial(cond, unit,:, 1)); % no photostim cond, pre photostim
    x2 = squeeze(allStimBaseByTrial(cond+1, unit,:, 1)); % photostim cond, pre photostim
    x3 = squeeze(allStimBaseByTrial(totalConds-1, unit, :, 1)); % no photostim cond, no vis stim, pre photostim
    x4 = squeeze(allStimBaseByTrial(totalConds, unit, :, 1)); % photostim cond, no vis stim, pre photostim
    
    y1 = squeeze(allStimAmplByTrial(cond, unit,:,1)); % no photostim cond, post photostim
    y2 = squeeze(allStimAmplByTrial(cond+1, unit,:,1)); % photostim cond, post photostim
    y3 = squeeze(allStimAmplByTrial(totalConds-1, unit,:,1)); % no photostim cond, no vis stim, post photostim
    y4 = squeeze(allStimAmplByTrial(totalConds, unit,:,1)); % photostim cond, no vis stim, post photostim
    
    x1 = x1(~isnan(x1)); % exclude Nans
    y1 = y1(~isnan(x1));
    x2 = x2(~isnan(x2));
    y2 = y2(~isnan(x2));
    x3 = x3(~isnan(x3));
    y3 = y3(~isnan(x3));
    x4 = x4(~isnan(x4));
    y4 = y4(~isnan(x4));
    
    if exclude0  % exclude trials with 0 in pre or post stim
        ind1 = (x1~= 0 & y1 ~= 0);
        ind2 = (x2~= 0 & y2 ~= 0);
        ind3 = (x3~= 0 & y3 ~= 0);
        ind4 = (x4~= 0 & y4 ~= 0);
        x1 = x1(ind1);
        y1 = y1(ind1);
        x2 = x2(ind2);
        y2 = y2(ind2);
        x3 = x3(ind3);
        y3 = y3(ind3);
        x4 = x4(ind4);
        y4 = y4(ind4);
    end    
    
    if norm % normalize data to the max value in the data set
        maxData = max([x1;x2;x3;x4])
        x1 = x1/maxData;%
        y1 = y1/maxData;
        x2 = x2/maxData;
        y2 = y2/maxData;
        x3 = x3/maxData;
        y3 = y3/maxData;
        x4 = x4/maxData;
        y4 = y4/maxData;
    end
    
    x_all = [x1;x2;x3;x4];
    y_all = [y1;y2;y3;y4];
    
    ev = [ones(size([x1;x2])); zeros(size([x3;x4]))];
    ph = [zeros(size(x1)); ones(size(x2)); zeros(size(x3)); ones(size(x4))];
    
    X = [x_all, ev, x_all.*ph, x_all.*ev, ph.*ev, x_all.*ph.*ev, ph]; % 8 params
%     X = [x_all, ev, x_all.*s, x_all.*ev, s.*ev, x_all.*s.*ev];  % 7 params (Lottem, 2016)
    mdl = fitlm(X,y_all) % returns parameters and p-values
    % also useful: regress function from matlab
    
    subplot(n,n,i)
    ax=gca;
    
    scatter(x1', y1', [], C(1,:), 'LineWidth', 2); hold on
    scatter(x2', y2', [], C(2,:), 'LineWidth', 2);
    scatter(x3', y3', [], C(totalConds-1,:), 'LineWidth', 2); hold on
    scatter(x4', y4', [], C(totalConds,:), 'LineWidth', 2);

    

    lims = max(xlim, ylim);
    xlim(lims)
    ylim(lims)
    
    % calculate coefficients by simple linear fit
%     fitline1 = fit(x1, y1, 'poly1');
%     fitline2 = fit(x2, y2, 'poly1');
%     fitline3 = fit(x3, y3, 'poly1');
%     fitline4 = fit(x4, y4, 'poly1');
%     coeffs1 = coeffvalues(fitline1);
%     coeffs2 = coeffvalues(fitline2);
%     coeffs3 = coeffvalues(fitline3);
%     coeffs4 = coeffvalues(fitline4);
        
%     f1 = polyval(coeffs1, lims);
%     f2 = polyval(coeffs2, lims);
%     f3 = polyval(coeffs3, lims);
%     f4 = polyval(coeffs4, lims);
    
    
    % calculate coefficients from the linear regression model
    coeffsLM(unit,:,:) = table2array(mdl.Coefficients);
    coeffsLM1 = [coeffsLM(unit,2,1)+coeffsLM(unit,5,1), coeffsLM(unit,1,1)+coeffsLM(unit,3,1)]; % coefficients for x1,y1
    coeffsLM2 = [coeffsLM(unit,2,1)+coeffsLM(unit,4,1)+coeffsLM(unit,5,1)+coeffsLM(unit,7,1), coeffsLM(unit,1,1)+coeffsLM(unit,3,1)+coeffsLM(unit,6,1)+ coeffsLM(unit,8,1)]; % coefficients for x2,y2
    coeffsLM3 = [coeffsLM(unit,2,1), coeffsLM(unit,1,1)]; % coefficients for x3,y3
    coeffsLM4 = [coeffsLM(unit,2,1)+coeffsLM(unit,4,1), coeffsLM(unit,1,1)+ coeffsLM(unit,8,1)]; % coefficients for x4,y4
        
    f1 = polyval(coeffsLM1, lims);
    f2 = polyval(coeffsLM2, lims);
    f3 = polyval(coeffsLM3, lims);
    f4 = polyval(coeffsLM4, lims);
    
    plot(lims, f1, 'Color', C(1,:));    
    plot(lims, f2, 'Color', C(2,:));
    plot(lims, f3, 'Color', C(totalConds-1,:));
    plot(lims, f4, 'Color', C(totalConds,:));
    
    lim= max(max(xlim, ylim));
    % text(lim*0.2, lim*0.90, [num2str(round(coeffs1(1),2)),'*x + ',num2str(round(coeffs1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
    % text(lim*0.2, lim*0.97, [num2str(round(coeffs2(1),2)),'*x + ',num2str(round(coeffs2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));
    % text(lim*0.2, lim*0.75, [num2str(round(coeffs3(1),2)),'*x + ',num2str(round(coeffs3(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
    % text(lim*0.2, lim*0.82, [num2str(round(coeffs4(1),2)),'*x + ',num2str(round(coeffs4(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', 'b');
%     text(lim*0.8, lim*0.37, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
%     text(lim*0.8, lim*0.30, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));
%     text(lim*0.8, lim*0.22, [num2str(round(coeffsLM3(1),2)),'*x + ',num2str(round(coeffsLM3(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds-1,:));
%     text(lim*0.8, lim*0.15, [num2str(round(coeffsLM4(1),2)),'*x + ',num2str(round(coeffsLM4(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds,:));
    
    legend off
    
    h1 = line([0 lim],[0 lim]); % diagonal line
    set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
    
    set(ax,'FontSize',fs)
    title([num2str(unit), ', ', num2str(spikeClusterDataAll.goodCodes(unit))], 'Color', EIColor(classUnitsAll(unit)), 'Fontsize', 8);
    i = i+1

end

if norm
    xlabel('Pre (norm. spike freq.)','FontSize',24);
    ylabel('Post (norm. spike freq.)','FontSize',24);
else     
    xlabel('Pre spike freq (Hz)','FontSize',24);
    ylabel('Post spike freq (Hz)','FontSize',24);
end    

if saveFigs == true
    savefig(strcat(savePath, saveFig16i{1}));
    saveas(gcf, strcat(savePath, saveFig16i{1}(1:end-3), 'png'));
end
% figure16i
