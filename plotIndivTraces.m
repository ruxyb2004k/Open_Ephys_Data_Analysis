cond = 3;
figure;
for unit = find(baseSelect)
%     plot((plotBeg:bin:plotEnd), normTraceFreqAllAdj(cond,unit,:),'LineWidth', 1, 'Color', C(cond,:)); hold on
    plot((plotBeg:bin:plotEnd), squeeze(normTraceFreqAllAdj(cond+1,unit,:)),'LineWidth', 1, 'Color', C(cond+1,:)); hold on
end    

%%

cond = 3;
totalUnitsBaseSelect = sum(baseSelect);
n= ceil(sqrt(totalUnitsBaseSelect));
i=1;
figure;
for unit = find(baseSelect)
    subplot(n,n,i)
    %     plot((plotBeg:bin:plotEnd), normTraceFreqAllAdj(cond,unit,:),'LineWidth', 1, 'Color', C(cond,:)); hold on
    plot((plotBeg:bin:plotEnd), squeeze(normTraceFreqAllAdj(cond+1,unit,:)),'LineWidth', 1, 'Color', C(cond+1,:)); hold on
    max_hist1 = max(ylim);
    
    title(num2str(unit))
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    i = i+1;
end    


%%

cond = 1;
totalUnitsBaseSelect = sum(baseSelect);
n= ceil(sqrt(totalUnitsBaseSelect));
i=1;
figure;
for unit = find(baseSelect)
    subplot(n,n,i)
    plot((plotBeg:bin:plotEnd), squeeze(normTracesBaseSubtr100(cond,unit,:)),'LineWidth', 1, 'Color', C(cond,:)); hold on
    plot((plotBeg:bin:plotEnd), squeeze(normTracesBaseSubtr100(cond+1,unit,:)),'LineWidth', 1, 'Color', C(cond+1,:)); hold on
    max_hist1 = max(ylim);
    
    title([num2str(unit), ', ',num2str(spikeClusterDataAll.goodCodes(unit))])
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    i = i+1;
end    

%%
cond = 1;
figure
scatter(1:totalUnits,allStimMagnNormTracesBaseSubtr100(cond,:,1));hold on
scatter(1:totalUnits,allStimMagnNormTracesBaseSubtr100(cond+1,:,1));hold on
%%
stim = 1;
% m = squeeze(mean(tracesBaseSubtr(:,:, baseStim(stim):baseStim(stim)+baseDuration),3));
m = squeeze(mean(normTracesBaseSubtr100(:,:, baseStim(stim):baseStim(stim)+baseDuration),3));
