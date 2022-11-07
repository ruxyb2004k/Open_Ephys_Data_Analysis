%%  plot figure for Berlin presentation - exp 17.02.2021_1
% before running this section, load all .mat files from the respective
% experiment

plotBeg=-sessionInfo.preTrialTime;
plotEnd=sessionInfo.trialDuration + sessionInfo.afterTrialTime;

conditionFieldnames = fieldnames(spikeClusterData.spikeTimes); % extract condition names

spikeTimes = spikeClusterData.spikeTimes;
totalConds = numel(conditionFieldnames);
totalTrials = numel(spikeClusterData.trialsForAnalysisSelected);
optStimInterval = sessionInfo.optStimInterval;

if sessionInfo.trialDuration == 18 % protocol 7
    stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[17 32 47 62 77 92];
    baseTime = round((sessionInfo.visStim+sessionInfo.preTrialTime-1)/bin+1);%[12, 27, 42, 57, 72, 87];
elseif sessionInfo.trialDuration == 9 % protocol 3
    stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[46];
    baseTime = round(([-1,0.2,sessionInfo.visStim(1)-1]+sessionInfo.preTrialTime)/bin+1);%[6, 12, 41];
elseif sessionInfo.trialDuration == 6 % protocol 2
    stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[31];
    baseTime = round(([-1,0.2,sessionInfo.visStim(1)-1]+sessionInfo.preTrialTime)/bin+1);%[6, 12, 26];
elseif sessionInfo.trialDuration == 7 % protocol 1
    stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[31];
    baseTime = round(([-1,0.2,sessionInfo.visStim(1)-1]+sessionInfo.preTrialTime)/bin+1);%[6, 12, 26];
end

clusterTimeSeries.stimTime = stimTime; 
clusterTimeSeries.baseTime = baseTime;

unclCodes = spikeClusterData.unclCodes;
goodCodes = spikeClusterData.goodCodes;
muaCodes = spikeClusterData.muaCodes;
noiseCodes = spikeClusterData.noiseCodes;
titleCode = goodCodes';
respMat = ones(1, numel(goodCodes))*3; % by default 3 (='none')
respMatMua = ones(1, numel(muaCodes))*1; % by default 1 (='visEv')

if sum(spikeClusterData.uniqueCodes(:,2)) == 0
%     goodCodes = spikeClusterData.uniqueCodes(:,1);
    warning('Channel numbers not updated')
    saveFigs = false;
end    
    
spikeInTrials = clusterTimeSeries.spikeInTrials;

%% for statistics, traceByTrial is needed


traceByTrial = clusterTimeSeries.traceByTrial;%(cond, code, trialInt, :)
traceByTrialDiff = nan(size(traceByTrial)); % V - S and Vph - Sph
for cond = 1:totalConds-2
    for unit = 1: numel(goodCodes)
        for trial = 1: size(traceByTrial,3)
            traceByTrialDiff(cond, unit, trial, :) = traceByTrial(cond, unit, trial, :)-traceByTrial(totalConds-mod(cond,2), unit, trial,:);
        end    
    end
end

trace = clusterTimeSeries.traceFreqGood;
traceDiff = nan(size(trace));% V - S and Vph - Sph
for cond = 1:totalConds-2
    for unit = 1: numel(goodCodes)
        traceDiff(cond, unit, :) = trace(cond, unit,:)-trace(totalConds-mod(cond,2), unit,:);
    end
end    

stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[17 32 47 62 77 92]; % long exp
for code = (1:numel(goodCodes)) 
    for stim = 1:numel(stimTime) % quantify max for each trial
        searchMaxInt = 0.4/bin;%stimTime(1):stimTime(1)+0.4/bin;%(17:19);
        for cond = 1:totalConds
            [M(cond,code, stim),I(cond,code, stim)] = max(traceDiff (cond,code,stimTime(stim):stimTime(stim)+ searchMaxInt));
            I(cond,code, stim) = I(cond,code,stim)+stimTime(stim)-1;
            
            if cond < totalConds-1 % conds with visual stim
                maxTraceByTrialDiff(cond, code, :,stim) = squeeze(mean(traceByTrialDiff(cond, code, :, I(cond, code, stim):I(cond, code, stim)+round(0.2/bin)),4));
            else % conds without visual stim
                maxTraceByTrialDiff(cond, code, :, stim) = squeeze(mean(traceByTrialDiff(cond, code,:,stimTime(stim):stimTime(stim)+round(0.4/bin)),4));
            end
        end
    end    
end

hSua = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
pSua = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
pSuaW = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
hSuaW = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
keepTrials = false(totalTrials,numel(statsCodesInd));

for code = (1:numel(goodCodes))
    keepTrials(:,code) = squeeze(nanmean(nanmean(traceByTrialDiff(:, code,:,:)),4))>0; % keep only trials with at least one spike
end   

for cond = (1:totalConds/2) % for all conds
    for code = (1:numel(goodCodes)) % for all selected good codes         
        for time = (1:numel(stimTime))
            meanMaxTraceByTrialDiff(cond, code,time) = nanmean(maxTraceByTrialDiff(cond, code, keepTrials(:,code),time),3);
            STEMmaxTraceByTrialDiff(cond,code, time) = nanstd(maxTraceByTrialDiff(cond,code, keepTrials(:,code),time))/sqrt(sum(~isnan(maxTraceByTrialDiff(cond,code,keepTrials(:,code),time))));
        end
    end
end

for cond = (1:2:totalConds-2) % for all conds
    for code = (1:numel(goodCodes)) % for all selected good codes         
        for time = (1:numel(stimTime))
            [hSua((cond+1)/2, code, time),pSua((cond+1)/2, code, time)] = ttest( maxTraceByTrialDiff(cond, code, keepTrials(:,code), time), maxTraceByTrialDiff(cond+1, code, keepTrials(:,code), time));
            [pSuaW((cond+1)/2,code, time),hSuaW((cond+1)/2,code, time)] = signrank(squeeze(maxTraceByTrialDiff(cond, code, keepTrials(:,code), time)), squeeze(maxTraceByTrialDiff(cond+1, code, keepTrials(:,code), time)));
        end
    end
end



%% Figure of an excitatory neuron and an inhibitory neurons with a secondary effect
savePath = '/data/oidata/Ruxandra/Open Ephys/Open Ephys Data/2021-02-17_11-41-03/matlab analysis/figs/BerlinFig';

% selCodes = [0, 77 107, 25,19,11,43,124,97,83];% decr in ev
% selCodes = [18, 26,27,32,53,68,80]; % incr in spont

selCodes = [107, 25]; % 53- initial effect; 107 - exc; 25 - inh
saveFigs =0;    
figure;
codeAll = [];
for i = 1:numel(selCodes)
    codeU = selCodes(i);
    code = find(spikeClusterData.goodCodes == codeU)
    codeAll = [codeAll, code];
%     subplot(code,1);
    c = [139, 203, 235]/255;
%     C = repmat([0, 0, 0; 0,0,1; 0.7,0.7,0.7; 0.2,0,1; 0.5,0.5,1; 0,0,1; 1,1,0.5; 1,1,0; 1,0.5,1; 1,0,1; 0.5,0.5,0.5; 0,0,0],[2,1]);
    C = [[0 1 0]; [1 0 0]];
    x = [sessionInfo.visStim; sessionInfo.visStim + sessionInfo.visStimDuration]';
   
    subplot(3,1,i, 'align');
    plot((plotBeg+bin:bin:plotEnd), squeeze(traceDiff(2, code,:)), 'Color', C(i,:),'LineWidth', 3); hold on
    plot((plotBeg+bin:bin:plotEnd), squeeze(traceDiff(1, code,:)), 'Color', 'k','LineWidth', 3); hold on
%     title(num2str(codeU));
    box off

    ax = gca;
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',24);
    
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',(0:5:floor(plotEnd))); % set major ticks [floor(plotBeg):5:floor(plotEnd)]
    set(gca,'XMinorTick','on');% set(gca,'XTick',[]);
    if i ==1
        set(gca, 'XColor', 'w');
    else    
         xlabel('Time (s)');
        ylabel('Firing rate (Hz)');
    end    
    yl = ylim;
    maxGraph = yl(2)*1.2;
    minGraph = yl(1)*0.99;
    h1 = line([optStimInterval(1) optStimInterval(1)],[minGraph max(max(traceDiff(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[minGraph max(max(traceDiff(:, code,:)))]);
    set([h1 h2],'Color',c,'LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[minGraph minGraph maxGraph maxGraph],c, 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    
    
    for i = 1:size(x,1)
        h3 = line('XData',x(i,:),'YData', [maxGraph maxGraph]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h3,'Color',[0 0 0] ,'LineWidth',4);% Set properties of lines
    end
    if saveFigs == true
        savefig(strcat(savePath,  filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)),'.fig'));
        saveas(gcf, strcat(savePath, filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)), '.png'));
    end
    hold off
end
%% Statistics for the two units above

C = [0 0 0 ; 0 1 0 ; 0 0 0 ;1 0 0];
stim= 3;
figure
xdata = [meanMaxTraceByTrialDiff(1, codeAll(1),stim), meanMaxTraceByTrialDiff(2, codeAll(1),stim), meanMaxTraceByTrialDiff(1, codeAll(2),stim), meanMaxTraceByTrialDiff(2, codeAll(2),stim)].*1/bin;
ydata = [STEMmaxTraceByTrialDiff(1,codeAll(1),stim ), STEMmaxTraceByTrialDiff(2,codeAll(1),stim ),STEMmaxTraceByTrialDiff(1,codeAll(2),stim ), STEMmaxTraceByTrialDiff(2,codeAll(2),stim )].*1/bin;
b=bar((1:4),xdata); hold on
b.FaceColor = 'flat';
for j = 1:4
    b.CData(j,:) = C(j,:); hold on
    errorbar(j,xdata(j), ydata(j), 'Color', C(j,:), 'LineWidth', 2); hold on
end    
% b.CData(2,:) = [0 1 0 ];
% b.CData(3,:) = [0 0 0 ];
% b.CData(4,:) = [1 0 0 ];
ax= gca;
set(ax,'FontSize',24);
ylabel('Firing rate (Hz)');
box off
xticklabels({''; ''; ''; ''})
set(ax,'YLim',[0 12]);
text(1.5, (xdata(1)+ydata(1))*1.1,'*','FontSize',16, 'HorizontalAlignment','center');
text(3.5, (xdata(3)+ydata(3))*1.1,'**','FontSize',16, 'HorizontalAlignment','center');
line([1,2],[(xdata(1)+ydata(1))*1.05, (xdata(1)+ydata(1))*1.05], 'Color', 'k', 'LineWidth', 1)
line([3,4],[(xdata(3)+ydata(3))*1.05, (xdata(3)+ydata(3))*1.05], 'Color', 'k', 'LineWidth', 1)
if saveFigs == true
    savefig(strcat(savePath,  filesep, 'Stats','.fig'));
    saveas(gcf, strcat(savePath, filesep, 'Stats', '.png'));
end
%% Figure of an inhibitory neuron with a primary effect

trace = clusterTimeSeries.traceFreqGood;

selCodes = [53]; % 53- initial effect; 107 - exc; 25 - inh
saveFigs =1;    
figure;

for i = 1:numel(selCodes)
    codeU = selCodes(i);
    code = find(spikeClusterData.goodCodes == codeU);
%     subplot(code,1);
    c = [139, 203, 235]/255;
%     C = repmat([0, 0, 0; 0,0,1; 0.7,0.7,0.7; 0.2,0,1; 0.5,0.5,1; 0,0,1; 1,1,0.5; 1,1,0; 1,0.5,1; 1,0,1; 0.5,0.5,0.5; 0,0,0],[2,1]);
    C = [[0 0 0]; [1 0 0];[0.8 0.8 0.8];[1 0.6 0.6]];
    x = [sessionInfo.visStim; sessionInfo.visStim + sessionInfo.visStimDuration]';
   

%     figure;
    subplot(3,1,i, 'align');
    for j =4:-1:1
        plot((plotBeg+bin:bin:plotEnd), squeeze(trace(j, code,:)), 'Color', C(j,:),'LineWidth', 3); hold on
    end    

%     title(num2str(codeU));
    box off

    ax = gca;
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',24);
    
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',(0:5:floor(plotEnd))); % set major ticks [floor(plotBeg):5:floor(plotEnd)]
    set(gca,'XMinorTick','on');% set(gca,'XTick',[]);
    
    xlabel('Time (s)');
    ylabel('Firing rate (Hz)');
 
    yl = ylim;
    maxGraph = yl(2)*1.2;
    minGraph = yl(1)*0.99;
    h1 = line([optStimInterval(1) optStimInterval(1)],[minGraph max(max(trace(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[minGraph max(max(trace(:, code,:)))]);
    set([h1 h2],'Color',c,'LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[minGraph minGraph maxGraph maxGraph],c, 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    
    
    for i = 1:size(x,1)
        h3 = line('XData',x(i,:),'YData', [maxGraph maxGraph]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h3,'Color',[0 0 0] ,'LineWidth',4);% Set properties of lines
    end
    
    if saveFigs == true
        savefig(strcat(savePath,  filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)),'.fig'));
        saveas(gcf, strcat(savePath, filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)), '.png'));
    end
    hold off

end
%% check out several codes with increase in spont act
trace = clusterTimeSeries.traceFreqGood;

% selCodes = [0, 77 107, 25,19,11,43,124,97,83];
selCodes = [18, 26,27,32,53,68,80];

% selCodes = [107, 25]; %68
saveFigs =0;    
% figure;

for i = 1:numel(selCodes)
    codeU = selCodes(i);
    code = find(spikeClusterData.goodCodes == codeU);
%     subplot(code,1);
    c = [139, 203, 235]/255;
%     C = repmat([0, 0, 0; 0,0,1; 0.7,0.7,0.7; 0.2,0,1; 0.5,0.5,1; 0,0,1; 1,1,0.5; 1,1,0; 1,0.5,1; 1,0,1; 0.5,0.5,0.5; 0,0,0],[2,1]);
    C = [[0 1 0]; [1 0 0]];
    x = [sessionInfo.visStim; sessionInfo.visStim + sessionInfo.visStimDuration]';
   

    figure;
    subplot(3,1,2, 'align')
    plot((plotBeg+bin:bin:plotEnd), squeeze(trace(4, code,:)), 'Color', 'r','LineWidth', 3); hold on
    plot((plotBeg+bin:bin:plotEnd), squeeze(trace(3, code,:)), 'Color', 'k','LineWidth', 3); hold on
%     title(num2str(codeU));
    box off

    ax = gca;
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',24);
    
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',(0:5:floor(plotEnd))); % set major ticks [floor(plotBeg):5:floor(plotEnd)]
    set(gca,'XMinorTick','on');% set(gca,'XTick',[]);


    xlabel('Time (s)');
    ylabel('Firing rate (Hz)');
 
    yl = ylim;
    maxGraph = yl(2)*1.2;
    minGraph = yl(1)*0.99;
    h1 = line([optStimInterval(1) optStimInterval(1)],[minGraph maxGraph]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[minGraph maxGraph]);
    set([h1 h2],'Color',c,'LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[minGraph minGraph maxGraph maxGraph],c, 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    
    
%     for i = 1:size(x,1)
%         h3 = line('XData',x(i,:),'YData', [maxGraph maxGraph]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
%         set(h3,'Color',[0 0 0] ,'LineWidth',4);% Set properties of lines
%     end
    
    if saveFigs == true
        savefig(strcat(savePath,  filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)),'sp.fig'));
        saveas(gcf, strcat(savePath, filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)), 'sp.png'));
    end
    hold off

end