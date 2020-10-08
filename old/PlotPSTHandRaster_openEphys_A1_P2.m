%%% plot PSTH and Raster plot of spikes for all conditions %%%
%%% It can be executed after spikedataloading.m %%%
%%% modified 25.02.2019 by Ruxandra %%%


% experimentName = '2020-07-21_17-54-30'
% sessionName = 'V1_20200721_3'

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathKlusta = strjoin({basePath, 'klusta analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);

%%
bin = 0.2;

savePath = basePathMatlab;
saveFigs = false;
plotBeg=-sessionInfo.preTrialTime;
plotEnd=sessionInfo.trialDuration + sessionInfo.afterTrialTime;

conditionFieldnames = fieldnames(spikeClusterData.spikeTimes); % extract condition names

spikeTimes = spikeClusterData.spikeTimes;
totalConds = numel(conditionFieldnames);
totalTrials = numel(spikeClusterData.trialsForAnalysisSelected);
optStimInterval = sessionInfo.optStimInterval;

stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1);%[31];
baseTime = round(([-1,0.2,sessionInfo.visStim(1)-1]+sessionInfo.preTrialTime)/bin+1);%[6, 12, 26];
timeCourses.stimTime = stimTime; 
timeCourses.baseTime = baseTime;

unclCodes = spikeClusterData.unclCodes;
goodCodes = spikeClusterData.goodCodes;
muaCodes = spikeClusterData.muaCodes;
noiseCodes = spikeClusterData.noiseCodes;


%%
spikeInTrials = cell(totalConds,numel(goodCodes));
spikeInTrialsMua = cell(totalConds,numel(muaCodes));
spikeInTrialsNoise = cell(totalConds,numel(noiseCodes));
spikeScatter = [];
spikeScatterMua = [];
spikeScatterNoise = [];

for cond = (1:totalConds)
    currentConName = conditionFieldnames{cond};
    for code = (1:numel(goodCodes))
        for trialInt= 1:totalTrials
            iConfinedSpikes1 = spikeTimes.(currentConName){trialInt}(:,2) == goodCodes(code);
            spikeInTrials{cond,code}=[spikeInTrials{cond,code}; (spikeTimes.(currentConName){trialInt}(iConfinedSpikes1,1))]; % for first cond
            spikeByTrial{cond,code,trialInt}=spikeTimes.(currentConName){trialInt}(iConfinedSpikes1,1);
            spikeScatter.(currentConName){code, trialInt} = spikeTimes.(currentConName){trialInt}(iConfinedSpikes1,1)';
        end
    end
    for code = (1:numel(muaCodes))
        for trialInt= 1:totalTrials
            iConfinedSpikesMua = spikeTimes.(currentConName){trialInt}(:,2) == muaCodes(code);
            spikeInTrialsMua{cond,code}=[spikeInTrialsMua{cond,code}; (spikeTimes.(currentConName){trialInt}(iConfinedSpikesMua,1))]; % for first cond
            spikeByTrialMua{cond,code,trialInt}= spikeTimes.(currentConName){trialInt}(iConfinedSpikesMua,1);
            spikeScatterMua.(currentConName){code, trialInt} = spikeTimes.(currentConName){trialInt}(iConfinedSpikesMua,1)';
            
        end
    end
    for code = (1:numel(noiseCodes))
        for trialInt= 1:totalTrials
            iConfinedSpikesNoise = spikeTimes.(currentConName){trialInt}(:,2) == noiseCodes(code);
            spikeInTrialsNoise{cond,code}=[spikeInTrialsNoise{cond,code}; (spikeTimes.(currentConName){trialInt}(iConfinedSpikesNoise,1))]; % for first cond
            spikeScatterNoise.(currentConName){code, trialInt} = spikeTimes.(currentConName){trialInt}(iConfinedSpikesNoise,1)';
        end
    end
end
%% plot NEW figures - good codes

C = ['r', 'g', 'b', 'y', 'm', 'k'];
trace=zeros(totalConds, numel(goodCodes), (trialDuration+afterTrialTime+preTrialTime)/bin);
edges = [];
meanTrace = zeros(totalConds, (trialDuration+afterTrialTime+preTrialTime)/bin);
selectedCodesInd = [1,3,4];%(1:numel(goodCodes));% selected codes indices
selectedCodesIndSpont = [1,0,0];
selectedCodes = goodCodes(selectedCodesInd); % selected codes 
selectedCodesDepth = spikeClusterData.uniqueCodesRealDepth(selectedCodesInd);
for cond = (1:totalConds) % for all conds
    for code = (1:numel(goodCodes)) % for all good codes      
        [trace(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrials{cond,code},(-preTrialTime:bin:trialDuration+afterTrialTime)); % calculate the histocount
    end
    meanTrace(cond,:) = mean(trace(cond,selectedCodesInd,:),2);% compute mean over codes (good or selected)
end

for code = selectedCodesInd%(1:numel(goodCodes))%(20:22) % plot figures for good or selected codes
    figure
    for cond = (1:totalConds)
        if cond == 2
            title(goodCodes(code))
        end
        currentConName = conditionFieldnames{cond};
        subplot(totalConds+4,1,cond, 'align');
        plotSpikeRaster(spikeScatter.(currentConName)(code,:),'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
        set(gca,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin]);
        set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 tempTotalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 tempTotalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 tempTotalTrials + 1 tempTotalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
            set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
        end
    end
    
    subplot(totalConds+4,1,[totalConds+1 totalConds+2], 'align');
    for cond = (1:totalConds)
          ls = '-';
%         C1 = 'k';
%         if mod(cond,2) == 0
%             ls = '--';
%             C1 = 'b';
%         end
        plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime), squeeze(trace(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    

    box off
    ylabel('Count');
    ax = gca;
    set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
    set(gca,'XTick',[]);
    set(gca, 'XColor', 'w');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(trace(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(trace(:, code,:)))]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(trace(:, code,:))) max(max(trace(:, code,:)))],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.

    
    subplot(totalConds+4,1,[totalConds+3 totalConds+4], 'align');
    plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime),squeeze(sum(trace(1:2:end,code,:),1)),'Color', 'k','LineWidth',2);
    hold on
    plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime),squeeze(sum(trace(2:2:end,code,:),1)),'Color', 'b','LineWidth',2);
    
    y1=ylim;
    box off
    ylabel('Count');
    xlabel('Time [sec]');

%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(-preTrialTime):1:floor(trialDuration+afterTrialTime)]); % set major ticks
%     set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    set(ax,'FontSize',24);
    background = get(gcf, 'color');
    set(gcf,'color','white');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 y1(2)]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 y1(2)]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 y1(2) y1(2)],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    if saveFigs == true
        savefig(strcat(savePath, '/AllCondRasterAndTrace_',num2str(goodCodes(code)),'.fig'));
    end
    hold off

% quantifications of max and baselines
    normby = repelem(1:2:totalConds,2);%[1:totalConds];
    searchMaxInt = round(0.4/bin);%stimTime(1):stimTime(1)+0.4/bin;%(17:19);
    for cond = 1:totalConds
        for stim = 1:numel(stimTime)
            [M(cond,code, stim),I(cond,code, stim)] = max(trace (cond,code,stimTime(stim):stimTime(stim)+ searchMaxInt));
            %normtrace(cond,code,:) = trace(cond,code,:)/M(cond,code);
            %normtrace(cond,code,:) = trace(cond,code,:)/(trace(cond,code,I(cond,code)-1:I(cond,code)+1));
            I(cond,code, stim) = I(cond,code,stim)+stimTime(stim)-1;

        end    
        
        normtrace(cond,code,:) = trace(cond,code,:)/M(normby(cond),code,1); % normalize by the control cond
        for trialInt = 1:totalTrials % histocounts by cond, code, trial and timepoint
            [traceByTrial(cond, code, trialInt, :), edgesByTrial(cond, code, trialInt, :)] = histcounts(spikeByTrial{cond, code, trialInt},(-preTrialTime:bin:trialDuration+afterTrialTime));
        end
        for stim = 1:numel(stimTime) % quantify max for each trial
            if cond < totalConds-1 % conds with visual stim
                maxTraceByTrial(cond, code, :,stim) = squeeze(mean(traceByTrial(cond, code, :, I(cond, code, stim):I(cond, code, stim)+round(0.2/bin)),4));
            else % conds without visual stim
                maxTraceByTrial(cond, code, :, stim) = squeeze(mean(traceByTrial(cond, code,:,stimTime(stim):stimTime(stim)+round(0.4/bin)),4));
            end
        end
        
        for time =(1:numel(baseTime)) % quantify base for each trial
            baselineByTrial(cond, code, :, time) = squeeze(mean(traceByTrial(cond, code,:,baseTime(time):baseTime(time)+1/bin-1),4));
        end    
    end
 
end
%% Stats
% Stats max 
hSua = nan(totalConds/2,numel(selectedCodesInd),numel(stimTime));
pSua = nan(totalConds/2,numel(selectedCodesInd),numel(stimTime));
pSuaW = nan(totalConds/2,numel(selectedCodesInd),numel(stimTime));
hSuaW = nan(totalConds/2,numel(selectedCodesInd),numel(stimTime));
keepTrials = false(totalTrials,numel(selectedCodesInd));

for code = (1:numel(selectedCodesInd))
    keepTrials(:,code) = squeeze(mean(mean(traceByTrial(:, selectedCodesInd(code),:,:)),4))>0;
end   

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(selectedCodesInd)) % for all selected good codes         
        for time = (1:numel(stimTime))
            [hSua((cond+1)/2, code, time),pSua((cond+1)/2, code, time)] = ttest( maxTraceByTrial(cond, selectedCodesInd(code), keepTrials(:,code), time), maxTraceByTrial(cond+1, selectedCodesInd(code), keepTrials(:,code), time));
%             [pSuaW((cond+1)/2,code, time),hSuaW((cond+1)/2,code, time)] = signrank( squeeze(maxTraceByTrial(cond, selectedCodesInd(code), keepTrials(:,code), time)), squeeze(maxTraceByTrial(cond+1, selectedCodesInd(code), keepTrials(:,code), time)));
        end
    end
end

% Stats baseline compared to same time in control cond
hSuaBase = nan(totalConds/2,numel(selectedCodesInd),numel(baseTime));
pSuaBase = nan(totalConds/2,numel(selectedCodesInd),numel(baseTime));
pSuaBaseW = nan(totalConds/2,numel(selectedCodesInd),numel(baseTime));
hSuaBaseW = nan(totalConds/2,numel(selectedCodesInd),numel(baseTime));

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(selectedCodesInd)) % for all selected good codes 
        for time = (1:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hSuaBase((cond+1)/2, code, time),pSuaBase((cond+1)/2, code, time)] = ttest( baselineByTrial(cond, selectedCodesInd(code), keepTrials(:,code),time), baselineByTrial(cond+1, selectedCodesInd(code), keepTrials(:,code),time));
%             [pSuaBaseW((cond+1)/2,code, time),hSuaBaseW((cond+1)/2,code, time)] = signrank( squeeze(baselineByTrial(cond, selectedCodesInd(code), keepTrials(:,code),time)), squeeze(baselineByTrial(cond+1, selectedCodesInd(code), keepTrials(:,code),time)));
                        
        end       
    end    
end

% Stats baseline compared to first baseline, same cond
hSuaBaseSameCond = nan(totalConds,numel(selectedCodesInd),numel(baseTime));
pSuaBaseSameCond = nan(totalConds,numel(selectedCodesInd),numel(baseTime));
pSuaBaseSameCondW = nan(totalConds,numel(selectedCodesInd),numel(baseTime));
hSuaBaseSameCondW = nan(totalConds,numel(selectedCodesInd),numel(baseTime));
keepTrialsBase = false(totalConds,numel(selectedCodesInd),totalTrials);

for cond = (1:totalConds) % for all conds
    for code = (1:numel(selectedCodesInd)) % for all selected good codes 
        keepTrialsBase(cond,code,:) = squeeze(mean(traceByTrial(cond, selectedCodesInd(code),:,:),4))>0;
        for time = (2:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            if sum( keepTrialsBase(cond,code,:)) ~= 0
                [hSuaBaseSameCond(cond, code, time),pSuaBaseSameCond(cond, code, time)] = ttest( baselineByTrial(cond, selectedCodesInd(code), keepTrialsBase(cond,code,:),1), baselineByTrial(cond, selectedCodesInd(code), keepTrialsBase(cond,code,:),time));
%                 [pSuaBaseSameCondW(cond,code, time),hSuaBaseSameCondW(cond,code, time)] = signrank( squeeze(baselineByTrial(cond, selectedCodesInd(code), keepTrialsBase(cond,code,:),1)), squeeze(baselineByTrial(cond, selectedCodesInd(code), keepTrialsBase(cond,code,:),time)));                       
            end         
        end     
    end
end

% Stats baseline compared to first baseline in photostim combined conds 
hSuaBaseComb = nan(numel(selectedCodesInd),numel(baseTime));
pSuaBaseComb = nan(numel(selectedCodesInd),numel(baseTime));
pSuaBaseCombW = nan(numel(selectedCodesInd),numel(baseTime));
hSuaBaseCombW = nan(numel(selectedCodesInd),numel(baseTime));

for code = (1:numel(selectedCodesInd)) % for all selected good codes
    for time = (2:numel(baseTime))
        % compare combined condition to first baseline in photostim combined cond 
        keepTrialsComb = squeeze(mean(traceByTrial(2:2:totalConds, selectedCodesInd(code),:,:),4)>0)';
        keepTrialsComb = keepTrialsComb(:);
        tr1 = squeeze(baselineByTrial(2:2:totalConds, selectedCodesInd(code), :,1))';
        tr2 = squeeze(baselineByTrial(2:2:totalConds, selectedCodesInd(code), :,time))';
        tr1 = tr1(:);
        tr2 = tr2(:);    
        tr1 = tr1(keepTrialsComb);
        tr2 = tr2(keepTrialsComb);  
        [hSuaBaseComb(code, time),pSuaBaseComb(code, time)] = ttest(tr1, tr2);
%         [pSuaBaseCombW(code, time),hSuaBaseCombW(code, time)] = signrank(tr1, tr2);
    end
end

if saveFigs == true
    save('statsSua.mat', 'hSua', 'pSua', 'hSuaW', 'pSuaW', 'hSuaBase', 'pSuaBase', 'hSuaBaseW', 'pSuaBaseW', ...
        'hSuaBaseSameCond', 'pSuaBaseSameCond', 'pSuaBaseSameCondW', 'hSuaBaseSameCondW', ...
        'hSuaBaseComb', 'pSuaBaseComb', 'pSuaBaseCombW','hSuaBaseCombW');
end    


traceFreqGood = trace(:, 1:numel(goodCodes), :)/bin/totalTrials;
traceFreqGoodSel = trace(:, selectedCodesInd, :)/bin/totalTrials;

%traceFreqbyTrial(cond, code, unit, dataPoint)

%% plot NEW figures - mua codes

C = ['r', 'g', 'b', 'y', 'm', 'k'];
traceMua=zeros(totalConds, numel(muaCodes), (trialDuration+afterTrialTime+preTrialTime)/bin);
edges =[];
meanTraceMua = zeros(totalConds, (trialDuration+afterTrialTime+preTrialTime)/bin);
selectedCodesIndMua = [2,3,5:7,9:14,16];%(1:numel(muaCodes)); % selected codes indices
selectedCodesMua = muaCodes(selectedCodesIndMua); % selected codes 
selectedCodesDepthMua = spikeClusterData.uniqueCodesRealDepth(selectedCodesIndMua);
for cond = (1:totalConds)
    for code = (1:numel(muaCodes))    
        [traceMua(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrialsMua{cond,code},(-preTrialTime:bin:trialDuration+afterTrialTime));
    end
    meanTraceMua(cond,:) = mean(traceMua(cond,:,:),2);%mean(trace(cond,selectedCodes,:),2);
end

for code = selectedCodesIndMua%(1:numel(muaCodes))%(20:22)%
    figure
    for cond = (1:totalConds)
        if cond == 2
            title(muaCodes(code))
        end
        currentConName = conditionFieldnames{cond};
        subplot(totalConds+4,1,cond, 'align');
%         title('100 % visual Stimulus');
        plotSpikeRaster(spikeScatterMua.(currentConName)(code,:),'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
        set(gca,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin]);
        set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 tempTotalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 tempTotalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 tempTotalTrials + 1 tempTotalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
            set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
        end
    end
    
    subplot(totalConds+4,1,[totalConds+1 totalConds+2], 'align');  
    for cond = (1:totalConds)
        ls = '-';
%         C1 = 'k';
%         if mod(cond,2) == 0
%             ls = '--';
%             C1 = 'b';
%         end
        plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime), squeeze(traceMua(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    
    box off
    ylabel('Count');
    ax = gca;
    set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
    set(gca,'XTick',[]);
    set(gca, 'XColor', 'w');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(traceMua(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(traceMua(:, code,:)))]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(traceMua(:, code,:))) max(max(traceMua(:, code,:)))],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.

    
    
    subplot(totalConds+4,1,[totalConds+3 totalConds+4], 'align');
    plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime),squeeze(sum(traceMua(1:2:end,code,:),1)),'Color', 'k','LineWidth',2);
    hold on
    plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime),squeeze(sum(traceMua(2:2:end,code,:),1)),'Color', 'b','LineWidth',2);

    y1= ylim;
    box off
    xlabel('Time [sec]');
    ylabel('Count');
%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(-preTrialTime):1:floor(trialDuration+afterTrialTime)]); % set major ticks
%     set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    set(ax,'FontSize',24);
    background = get(gcf, 'color');
    set(gcf,'color','white');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 y1(2)]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 y1(2)]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 y1(2) y1(2)],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    if saveFigs == true
        savefig(strcat(savePath, '/AllCondRasterAndTrace_',num2str(muaCodes(code)),'.fig'));
    end
    hold off

 % quantifications of max and baselines
    normby = repelem(1:2:totalConds,2);%[1:totalConds];
    searchMaxInt = 0.4/bin;%stimTime(1):stimTime(1)+0.4/bin;%(17:19);
    for cond = 1:totalConds
        for stim = 1:numel(stimTime)
            [MMua(cond,code, stim),IMua(cond,code, stim)] = max(traceMua (cond,code,stimTime(stim):stimTime(stim)+ searchMaxInt));
            %normtrace(cond,code,:) = trace(cond,code,:)/M(cond,code);
            %normtrace(cond,code,:) = trace(cond,code,:)/(trace(cond,code,I(cond,code)-1:I(cond,code)+1));
            IMua(cond,code, stim) = IMua(cond,code,stim)+stimTime(stim)-1;

        end    
        
        normtraceMua(cond,code,:) = traceMua(cond,code,:)/MMua(normby(cond),code,1); % normalize by the control cond
        for trialInt = 1:totalTrials % histocounts by cond, code, trial and timepoint
            [traceByTrialMua(cond, code, trialInt, :), edgesByTrialMua(cond, code, trialInt, :)] = histcounts(spikeByTrialMua{cond, code, trialInt},(-preTrialTime:bin:trialDuration+afterTrialTime));
        end
        for stim = 1:numel(stimTime) % quantify max for each trial
            if cond < totalConds-1 % conds with visual stim
                maxTraceByTrialMua(cond, code, :,stim) = squeeze(mean(traceByTrialMua(cond, code, :, IMua(cond, code, stim):IMua(cond, code, stim)+round(0.2/bin)),4));
            else % conds without visual stim
                maxTraceByTrialMua(cond, code, :, stim) = squeeze(mean(traceByTrialMua(cond, code,:,stimTime(stim):stimTime(stim)+round(0.4/bin)),4));
            end
        end
        
        for time =(1:numel(baseTime)) % quantify base for each trial
            baselineByTrialMua(cond, code, :, time) = squeeze(mean(traceByTrialMua(cond, code,:,baseTime(time):baseTime(time)+1/bin-1),4));
        end    
    end
 
end

%% Stats
% Stats max 
hMua = nan(totalConds/2,numel(selectedCodesIndMua),numel(stimTime));
pMua = nan(totalConds/2,numel(selectedCodesIndMua),numel(stimTime));
pMuaW = nan(totalConds/2,numel(selectedCodesIndMua),numel(stimTime));
hMuaW = nan(totalConds/2,numel(selectedCodesIndMua),numel(stimTime));
keepTrialsMua = false(totalTrials,numel(selectedCodesIndMua));

for code = (1:numel(selectedCodesIndMua))
    keepTrialsMua(:,code) = squeeze(mean(mean(traceByTrialMua(:, selectedCodesIndMua(code),:,:)),4))>0;
end   

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(selectedCodesIndMua)) % for all selected good codes         
        for time = (1:numel(stimTime))
            [hMua((cond+1)/2, code, time),pMua((cond+1)/2, code, time)] = ttest( maxTraceByTrialMua(cond, selectedCodesIndMua(code), keepTrialsMua(:,code), time), maxTraceByTrialMua(cond+1, selectedCodesIndMua(code), keepTrialsMua(:,code), time));
            [pMuaW((cond+1)/2,code, time),hMuaW((cond+1)/2,code, time)] = signrank( squeeze(maxTraceByTrialMua(cond, selectedCodesIndMua(code), keepTrialsMua(:,code), time)), squeeze(maxTraceByTrialMua(cond+1, selectedCodesIndMua(code), keepTrialsMua(:,code), time)));
        end
    end
end

% Stats baseline compared to same time in control cond
hMuaBase = nan(totalConds/2,numel(selectedCodesIndMua),numel(baseTime));
pMuaBase = nan(totalConds/2,numel(selectedCodesIndMua),numel(baseTime));
pMuaBaseW = nan(totalConds/2,numel(selectedCodesIndMua),numel(baseTime));
hMuaBaseW = nan(totalConds/2,numel(selectedCodesIndMua),numel(baseTime));

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(selectedCodesIndMua)) % for all selected good codes 
        for time = (1:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hMuaBase((cond+1)/2, code, time),pMuaBase((cond+1)/2, code, time)] = ttest( baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsMua(:,code),time), baselineByTrialMua(cond+1, selectedCodesIndMua(code), keepTrialsMua(:,code),time));
            [pMuaBaseW((cond+1)/2,code, time),hMuaBaseW((cond+1)/2,code, time)] = signrank( squeeze(baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsMua(:,code),time)), squeeze(baselineByTrialMua(cond+1, selectedCodesIndMua(code), keepTrialsMua(:,code),time)));                        
        end       
    end    
end

% Stats baseline compared to first baseline, same cond
hMuaBaseSameCond = nan(totalConds,numel(selectedCodesIndMua),numel(baseTime));
pMuaBaseSameCond = nan(totalConds,numel(selectedCodesIndMua),numel(baseTime));
pMuaBaseSameCondW = nan(totalConds,numel(selectedCodesIndMua),numel(baseTime));
hMuaBaseSameCondW = nan(totalConds,numel(selectedCodesIndMua),numel(baseTime));
keepTrialsBaseMua = false(totalConds,numel(selectedCodesIndMua),totalTrials);

for cond = (1:totalConds) % for all conds
    for code = (1:numel(selectedCodesIndMua)) % for all selected good codes 
        keepTrialsBaseMua(cond,code,:) = squeeze(mean(traceByTrialMua(cond, selectedCodesIndMua(code),:,:),4))>0;
        for time = (2:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hMuaBaseSameCond(cond, code, time),pMuaBaseSameCond(cond, code, time)] = ttest( baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsBaseMua(cond,code,:),1), baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsBaseMua(cond,code,:),time));
            [pMuaBaseSameCondW(cond,code, time),hMuaBaseSameCondW(cond,code, time)] = signrank( squeeze(baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsBaseMua(cond,code,:),1)), squeeze(baselineByTrialMua(cond, selectedCodesIndMua(code), keepTrialsBaseMua(cond,code,:),time)));                       
        end       
    end    
end

% Stats baseline compared to first baseline in photostim combined conds 
hMuaBaseComb = nan(numel(selectedCodesIndMua),numel(baseTime));
pMuaBaseComb = nan(numel(selectedCodesIndMua),numel(baseTime));
pMuaBaseCombW = nan(numel(selectedCodesIndMua),numel(baseTime));
hMuaBaseCombW = nan(numel(selectedCodesIndMua),numel(baseTime));


for code = (1:numel(selectedCodesIndMua)) % for all selected good codes
    for time = (2:numel(baseTime))
        % compare combined condition to first baseline in photostim combined cond 
        keepTrialsCombMua = squeeze(mean(traceByTrialMua(2:2:totalConds, selectedCodesIndMua(code),:,:),4)>0)';
        keepTrialsCombMua = keepTrialsCombMua(:);
        tr1 = squeeze(baselineByTrialMua(2:2:totalConds, selectedCodesIndMua(code), :,1))';
        tr2 = squeeze(baselineByTrialMua(2:2:totalConds, selectedCodesIndMua(code), :,time))';
        tr1 = tr1(:);
        tr2 = tr2(:);    
        tr1 = tr1(keepTrialsCombMua);
        tr2 = tr2(keepTrialsCombMua);  
        [hMuaBaseComb(code, time),pMuaBaseComb(code, time)] = ttest(tr1, tr2);
        [pMuaBaseCombW(code, time),hMuaBaseCombW(code, time)] = signrank(tr1, tr2);
    end
end

if saveFigs == true
    save('statsMua.mat', 'hMua', 'pMua', 'hMuaW', 'pMuaW', 'hMuaBase', 'pMuaBase', 'hMuaBaseW', 'pMuaBaseW', ...
        'hMuaBaseSameCond', 'pMuaBaseSameCond', 'pMuaBaseSameCondW', 'hMuaBaseSameCondW', ...
        'hMuaBaseComb', 'pMuaBaseComb', 'pMuaBaseCombW','hMuaBaseCombW');
end  


traceFreqMuaSel = traceMua(:, selectedCodesIndMua, :)/bin/totalTrials;
traceFreqMua = traceMua(:, 1:numel(muaCodes), :)/bin/totalTrials;
%% plot NEW figures - noise codes

C = ['r', 'g', 'b', 'y', 'm', 'k'];
traceNoise=zeros(totalConds, numel(noiseCodes), (trialDuration+afterTrialTime+preTrialTime)/bin);
meanTraceNoise = zeros(totalConds, (trialDuration+afterTrialTime+preTrialTime)/bin);
edges =[];
meanTrace = zeros(totalConds, (trialDuration+afterTrialTime+preTrialTime)/bin);
selectedCodesIndNoise = (1:numel(noiseCodes)); % selected codes indices
selectedCodesNoise = noiseCodes(selectedCodesIndNoise); % selected codes 
selectedCodesDepthNoise = spikeClusterData.uniqueCodesRealDepth(selectedCodesIndNoise);
for cond = (1:totalConds)
    for code = (1:numel(noiseCodes))    
        [traceNoise(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrialsNoise{cond,code},(-preTrialTime:bin:trialDuration+afterTrialTime));
    end
    meanTraceNoise(cond,:) = mean(traceNoise(cond,selectedCodesIndNoise,:),2);
end

for code = selectedCodesIndNoise%(20:22)%
    figure
    for cond = (1:totalConds)
        if cond == 2
            title(noiseCodes(code))
        end
        currentConName = conditionFieldnames{cond};
        subplot(totalConds+2,1,cond, 'align');
%         title('100 % visual Stimulus');
        plotSpikeRaster(spikeScatterNoise.(currentConName)(code,:),'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
        set(gca,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin]);
        set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 tempTotalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 tempTotalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 tempTotalTrials + 1 tempTotalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
            set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
        end
    end
    
    subplot(totalConds+2,1,[totalConds+1 totalConds+2], 'align');  
    for cond = (1:totalConds)
        ls = '-';
%         C1 = 'k';
%         if mod(cond,2) == 0
%             ls = '--';
%             C1 = 'b';
%         end
        plot((-preTrialTime+bin:bin:trialDuration+afterTrialTime), squeeze(traceNoise(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    box off
    xlabel('Time [sec]');
    ylabel('Count');
%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(-preTrialTime):1:floor(trialDuration+afterTrialTime)]); % set major ticks
%     set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    set(ax,'FontSize',24);
    background = get(gcf, 'color');
    set(gcf,'color','white');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(traceNoise(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(traceNoise(:, code,:)))]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(traceNoise(:, code,:))) max(max(traceNoise(:, code,:)))],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    if saveFigs == true
        savefig(strcat(savePath, '/AllCondRasterAndTrace_',num2str(noiseCodes(code)),'.fig'));
    end
    hold off
end

traceFreqNoise = traceNoise/bin/totalTrials;
traceFreqNoiseSel = traceNoise(:, selectedCodesIndNoise, :)/bin/totalTrials;

%% Plot NEW figure - average figure
figure
for cond = (1:totalConds)
    plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), meanTrace(cond, :), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2); hold on
end
box off
xlabel('Time [sec]');
ylabel('Count');
%     set('facecolor',[1 0 1]);
%     set('BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
ax = gca;
set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
set(ax, 'TickDir', 'out');
set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
%     set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
set(ax,'FontSize',24);
background = get(gcf, 'color');
set(gcf,'color','white');
h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(meanTrace(:,:)))]); %max(h.Values)
h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(meanTrace(:,:)))]);
set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(meanTrace(:,:))) max(max(meanTrace(:,:)))],'c', 'EdgeColor', 'none'); % Add a patch
set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
if saveFigs == true
    savefig(strcat(savePath, '/MeanAllCondTrace.fig'));
end

%% Plot NEW figure - average figure
figure
for cond = (1:totalConds)
    plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), meanTraceNoise(cond, :), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2); hold on
end
box off
xlabel('Time [sec]');
ylabel('Count');
%     set('facecolor',[1 0 1]);
%     set('BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
ax = gca;
set(ax,'XLim',[-preTrialTime+bin trialDuration+afterTrialTime+bin],'FontSize',24);
set(ax, 'TickDir', 'out');
set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
%     set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
set(ax,'FontSize',24);
background = get(gcf, 'color');
set(gcf,'color','white');
h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(meanTrace(:,:)))]); %max(h.Values)
h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(meanTrace(:,:)))]);
set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(meanTrace(:,:))) max(max(meanTrace(:,:)))],'c', 'EdgeColor', 'none'); % Add a patch
set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
if saveFigs == true
    savefig(strcat(savePath, '/MeanAllCondTrace.fig'));
end


%% plot figures

for code = (1:numel(goodCodes))
    % figure 1
    figure;
    % subplot(3,1,1, 'align');
    % title('100 % visual Stimulus');
    % plotSpikeRaster(spikeInCond1,'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
    % set(gca,'XLim',[-preTrialTime trialDuration+afterTrialTime]);
    % set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
    % set(gca,'FontSize',24);
    % set(gca, 'XColor', 'w');
    % ylabel('Trial', 'FontSize',24);
    
    subplot(3,1,[2 3]);
    h=histogram(spikeInTrials1{1,code});
    box off
    xlabel('Time [sec]');
    ylabel('Count');
    set(h,'facecolor',[1 0 1]);
    set(h,'BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
    ax = gca;
    set(ax,'XLim',[-preTrialTime trialDuration+afterTrialTime],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
    set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    set(ax,'FontSize',24);
    background = get(gcf, 'color');
    set(gcf,'color','white');
    if saveFigs == true
        savefig(strcat(path, '100visStim.fig'));
    end
    
    % figure 2
    figure;
    % subplot(3,1,1, 'align');
    % title('100 % visual + optic Stimulation');
    % plotSpikeRaster(spikeInCond2,'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
    % set(gca,'XLim',[-preTrialTime trialDuration+afterTrialTime]);
    % set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
    % set(gca,'FontSize',24);
    % set(gca, 'XColor', 'w');
    % ylabel('Trial', 'FontSize',24);
    % h1 = line([optStimInterval(1) optStimInterval(1)],[0 tempTotalTrials + 1]); %max(h.Values)
    % h2 = line([optStimInterval(2) optStimInterval(2)],[0 tempTotalTrials + 1]);
    % set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    % patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 tempTotalTrials + 1 tempTotalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
    % set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    
    
    subplot(3,1,[2 3]);
    h=histogram(spikeInTrials2{1,code});
    box off
    xlabel('Time [sec]');
    ylabel('Count');
    set(h,'facecolor',[1 0 0]);
    set(h,'BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
    ax = gca;
    set(ax,'XLim',[-preTrialTime trialDuration+afterTrialTime],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
    set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    set(ax,'FontSize',24);
    background = get(gcf, 'color');
    set(gcf,'color','white');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(h.Values)]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(h.Values)]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(h.Values) max(h.Values)],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    if saveFigs == true
        savefig(strcat(path, '100optStim.fig'));
    end
    %
    % % figure 3
    % figure;
    % subplot(3,1,1, 'align');
    % title('0 % visual Stimulus');
    % plotSpikeRaster(spikeInCond3,'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
    % set(gca,'XLim',[-preTrialTime trialDuration+afterTrialTime]);
    % set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
    % set(gca,'FontSize',24);
    % set(gca, 'XColor', 'w');
    % ylabel('Trial', 'FontSize',24);
    %
    % subplot(3,1,[2 3]);
    % h=histogram(spikeInTrials3);
    % box off
    % xlabel('Time [sec]');
    % ylabel('Count');
    % set(h,'facecolor',[1 1 0]);
    % set(h,'BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
    % ax = gca;
    % set(ax,'XLim',[-preTrialTime trialDuration+afterTrialTime],'FontSize',24);
    % set(ax, 'TickDir', 'out');
    % set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
    % set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    % set(ax,'FontSize',24);
    % background = get(gcf, 'color');
    % set(gcf,'color','white');
    % if saveFigs == true
    %     savefig(strcat(path, '0visStim.fig'));
    % end
    %
    % % figure 4
    % figure;
    % subplot(3,1,1, 'align');
    % title('0 % visual + optic Stimulation');
    % plotSpikeRaster(spikeInCond4,'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
    % set(gca,'XLim',[-preTrialTime trialDuration+afterTrialTime]);
    % set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]);
    % set(gca,'FontSize',24);
    % set(gca, 'XColor', 'w');
    % ylabel('Trial', 'FontSize',24);
    % h1 = line([optStimInterval(1) optStimInterval(1)],[0 tempTotalTrials + 1]); %max(h.Values)
    % h2 = line([optStimInterval(2) optStimInterval(2)],[0 tempTotalTrials + 1]);
    % set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    % patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 tempTotalTrials + 1 tempTotalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
    % set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    %
    %
    % subplot(3,1,[2 3]);
    % h=histogram(spikeInTrials4);
    % box off
    % xlabel('Time [sec]');
    % ylabel('Count');
    % set(h,'facecolor',[0 0 1]);
    % set(h,'BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
    % ax = gca;
    % set(ax,'XLim',[-preTrialTime trialDuration+afterTrialTime],'FontSize',24);
    % set(ax, 'TickDir', 'out');
    % set(ax,'xtick',[floor(-preTrialTime):5:floor(trialDuration+afterTrialTime)]); % set major ticks
    % set(ax,'YLim',[0 max(h.Values)],'FontSize',24);
    % set(ax,'FontSize',24);
    % background = get(gcf, 'color');
    % set(gcf,'color','white');
    % h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(h.Values)]); %max(h.Values)
    % h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(h.Values)]);
    % set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    % patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 max(h.Values) max(h.Values)],'c', 'EdgeColor', 'none'); % Add a patch
    % set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    % if saveFigs == true
    %     savefig(strcat(path, '0optStim.fig'));
    % end
end    