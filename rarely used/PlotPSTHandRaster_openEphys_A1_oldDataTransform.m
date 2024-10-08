%%% plot PSTH and Raster plot of spikes for all conditions %%%
%%% It can be executed after spikedataloading.m %%%
%%% modified 25.02.2019 by Ruxandra %%%

% experimentName = '2020-07-22_18-07-38'
% sessionName = 'V1_20200722_2'
% clearvars -except experimentName sessionName
bin = 0.2;

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathKlusta = strjoin({basePath, 'klusta analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
% filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series - delete from here
filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
% [timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries); % delete for here
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);

savePath = basePathMatlab;
saveFigs = true;

savePathFigs = fullfile(basePathMatlab, 'figs');
if ~exist(basePathData, 'dir')
     mkdir(savePathFigs);
end     

savePathGood = fullfile(savePathFigs, 'good');
if ~exist(savePathGood, 'dir')
    mkdir(savePathGood);
end

savePathMua = fullfile(savePathFigs, 'mua');
if ~exist(savePathMua, 'dir')
    mkdir(savePathMua);
end

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

if sum(spikeClusterData.uniqueCodes(:,2)) == 0
    goodCodes = unclCodes;
    warning('Channel numbers not updated')
    saveFigs = false;
end    
    
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

% saveFigs = 1;

C = repmat(['r', 'g', 'b', 'y', 'm', 'k'], [1,2]);
trace=zeros(totalConds, numel(goodCodes), (plotEnd-plotBeg)/bin);
edges = [];
meanTrace = zeros(totalConds, (plotEnd-plotBeg)/bin);
selectedCodesInd = [2,7,9,10,11,12,13];%(1:numel(goodCodes));% selected codes indices
selectedCodesIndSpont  = [1,1,1,1,0,1,0];
selectedCodes = goodCodes(selectedCodesInd); % selected codes 
selectedCodesDepth = spikeClusterData.uniqueCodesRealDepth(selectedCodesInd);
for cond = (1:totalConds) % for all conds
    for code = (1:numel(goodCodes)) % for all good codes      
        [trace(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrials{cond,code},(plotBeg:bin:plotEnd)); % calculate the histocount
    end
    meanTrace(cond,:) = mean(trace(cond,selectedCodesInd,:),2);% compute mean over codes (good or selected)
end

close all
for code = selectedCodesInd%(1:numel(goodCodes))%(20:22) % plot figures for good or selected codes
    figure
    for cond = (1:totalConds)
        if cond == 2
            title(goodCodes(code))
        end
        currentConName = conditionFieldnames{cond};
        subplot(totalConds+4,1,cond, 'align');
        plotSpikeRaster(spikeScatter.(currentConName)(code,:),'PlotType','scatter','XLimForCell',[plotBeg plotEnd]);
        set(gca,'XLim',[plotBeg plotEnd+bin]);
        set(gca,'XTick',[]); %floor(-preTrialTime):5:floor(plotEnd)]);
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 totalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 totalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 totalTrials + 1 totalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
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
        plot((plotBeg+bin:bin:plotEnd), squeeze(trace(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    
    box off
    ylabel('Count');
    ax = gca;
    set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
    set(gca,'XTick',[]);
    set(gca, 'XColor', 'w');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(trace(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(trace(:, code,:)))]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(trace(:, code,:))) max(max(trace(:, code,:)))],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.

    
    subplot(totalConds+4,1,[totalConds+3 totalConds+4], 'align');
    plot((plotBeg+bin:bin:plotEnd),squeeze(sum(trace(1:2:end,code,:),1)),'Color', 'k','LineWidth',2);
    hold on
    plot((plotBeg+bin:bin:plotEnd),squeeze(sum(trace(2:2:end,code,:),1)),'Color', 'b','LineWidth',2);
    
    y1=ylim;
    box off
    ylabel('Count');
    xlabel('Time [sec]');

%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(plotBeg):1:floor(plotEnd)]); % set major ticks
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
        
%         mkdir(savePathGood);
        savefig(strcat(savePathGood,  filesep, 'AllCondRasterAndTrace_',num2str(goodCodes(code)),'.fig'));
    end
    hold off
    
end

traceFreqGood = trace(:, 1:numel(goodCodes), :)/bin/totalTrials;
traceFreqGoodSel = trace(:, selectedCodesInd, :)/bin/totalTrials;

% quantifications of max and baselines

clear normtrace traceByTrial edgesByTrial maxTraceByTrial baselineByTrial

for code = (1:numel(goodCodes))
    normby = repelem(1:2:totalConds,2);%[1:totalConds];
    searchMaxInt = 0.4/bin;%stimTime(1):stimTime(1)+0.4/bin;%(17:19);
    for cond = 1:totalConds
        for stim = 1:numel(stimTime)
            [M(cond,code, stim),I(cond,code, stim)] = max(trace (cond,code,stimTime(stim):stimTime(stim)+ searchMaxInt));
            %normtrace(cond,code,:) = trace(cond,code,:)/M(cond,code);
            %normtrace(cond,code,:) = trace(cond,code,:)/(trace(cond,code,I(cond,code)-1:I(cond,code)+1));
            I(cond,code, stim) = I(cond,code,stim)+stimTime(stim)-1;

        end    
        
        normtrace(cond,code,:) = trace(cond,code,:)/M(normby(cond),code,1); % normalize by the control cond
        for trialInt = 1:totalTrials % histocounts by cond, code, trial and timepoint
            [traceByTrial(cond, code, trialInt, :), edgesByTrial(cond, code, trialInt, :)] = histcounts(spikeByTrial{cond, code, trialInt},(plotBeg:bin:plotEnd));
        end
        for stim = 1:numel(stimTime) % quantify max for each trial
            if cond < totalConds-1 % conds with visual stim
                maxTraceByTrial(cond, code, :,stim) = squeeze(mean(traceByTrial(cond, code, :, I(cond, code, stim):I(cond, code, stim)+round(0.2/bin)),4));
            else % conds without visual stim
                maxTraceByTrial(cond, code, :, stim) = squeeze(mean(traceByTrial(cond, code,:,stimTime(stim):stimTime(stim)+round(0.4/bin)),4));
            end
            % just needed for orientation experiments
            amplByTrial(cond, code, :, stim) = squeeze(sum(traceByTrial(cond, code, :, stimTime(stim):stimTime(stim)+0.8/bin),4));
        end
        
           
        for time =(1:numel(baseTime)) % quantify base for each trial
            baselineByTrial(cond, code, :, time) = squeeze(mean(traceByTrial(cond, code,:,baseTime(time):baseTime(time)+1/bin-1),4));
        end    
    end
 
end


% Stats 1
statsCodesInd = 1:numel(goodCodes);%selectedCodesInd;%
statsSuaF

%%

clusterTimeSeries.spikeInTrials = spikeInTrials;[];%
clusterTimeSeries.spikeByTrial = spikeByTrial;[];%
clusterTimeSeries.bin = bin;

clusterTimeSeries.traceByTrial = traceByTrial;[];%
clusterTimeSeries.maxTraceByTrial = maxTraceByTrial;[];%
clusterTimeSeries.baselineByTrial = baselineByTrial;[];%
clusterTimeSeries.traceFreqGood = traceFreqGood;
clusterTimeSeries.traceFreqGoodSel = traceFreqGoodSel;

clusterTimeSeries.statsSua.keepTrials = keepTrials;
clusterTimeSeries.statsSua.keepTrialsBase = keepTrialsBase;

clusterTimeSeries.statsSua.statsCodesInd = statsCodesInd;
clusterTimeSeries.statsSua.hSua = hSua;
clusterTimeSeries.statsSua.pSua = pSua;
clusterTimeSeries.statsSua.hSuaW = hSuaW;
clusterTimeSeries.statsSua.pSuaW = pSuaW;

clusterTimeSeries.statsSua.hSuaBase = hSuaBase;
clusterTimeSeries.statsSua.pSuaBase = pSuaBase;
clusterTimeSeries.statsSua.hSuaBaseW = hSuaBaseW;
clusterTimeSeries.statsSua.pSuaBaseW = pSuaBaseW;

clusterTimeSeries.statsSua.hSuaBaseSameCond = hSuaBaseSameCond;
clusterTimeSeries.statsSua.pSuaBaseSameCond = pSuaBaseSameCond;
clusterTimeSeries.statsSua.hSuaBaseSameCondW = hSuaBaseSameCondW;
clusterTimeSeries.statsSua.pSuaBaseSameCondW = pSuaBaseSameCondW;

clusterTimeSeries.statsSua.hSuaBaseComb = hSuaBaseComb;
clusterTimeSeries.statsSua.pSuaBaseComb = pSuaBaseComb;
clusterTimeSeries.statsSua.hSuaBaseCombW = hSuaBaseCombW;
clusterTimeSeries.statsSua.pSuaBaseCombW = pSuaBaseCombW;


%% Stats 2

statsCodesInd = selectedCodesInd;%
statsSuaF

clusterTimeSeries.selectedCodes = selectedCodes;
clusterTimeSeries.selectedCodesDepth = selectedCodesDepth;
clusterTimeSeries.selectedCodesInd = selectedCodesInd;
clusterTimeSeries.selectedCodesIndSpont = selectedCodesIndSpont;


clusterTimeSeries.statsSuaSel.keepTrials = keepTrials;
clusterTimeSeries.statsSuaSel.keepTrialsBase = keepTrialsBase;

clusterTimeSeries.statsSuaSel.statsCodesInd = statsCodesInd;
clusterTimeSeries.statsSuaSel.hSua = hSua;
clusterTimeSeries.statsSuaSel.pSua = pSua;
clusterTimeSeries.statsSuaSel.hSuaW = hSuaW;
clusterTimeSeries.statsSuaSel.pSuaW = pSuaW;

clusterTimeSeries.statsSuaSel.hSuaBase = hSuaBase;
clusterTimeSeries.statsSuaSel.pSuaBase = pSuaBase;
clusterTimeSeries.statsSuaSel.hSuaBaseW = hSuaBaseW;
clusterTimeSeries.statsSuaSel.pSuaBaseW = pSuaBaseW;

clusterTimeSeries.statsSuaSel.hSuaBaseSameCond = hSuaBaseSameCond;
clusterTimeSeries.statsSuaSel.pSuaBaseSameCond = pSuaBaseSameCond;
clusterTimeSeries.statsSuaSel.hSuaBaseSameCondW = hSuaBaseSameCondW;
clusterTimeSeries.statsSuaSel.pSuaBaseSameCondW = pSuaBaseSameCondW;

clusterTimeSeries.statsSuaSel.hSuaBaseComb = hSuaBaseComb;
clusterTimeSeries.statsSuaSel.pSuaBaseComb = pSuaBaseComb;
clusterTimeSeries.statsSuaSel.hSuaBaseCombW = hSuaBaseCombW;
clusterTimeSeries.statsSuaSel.pSuaBaseCombW = pSuaBaseCombW;

%% save later
save(filenameClusterTimeSeries, 'clusterTimeSeries')

%% plot NEW figures - mua codes

C = ['r', 'g', 'b', 'y', 'm', 'k'];
traceMua=zeros(totalConds, numel(muaCodes), (plotEnd - plotBeg)/bin);
edges =[];
meanTraceMua = zeros(totalConds, (plotEnd - plotBeg)/bin);
% selectedCodesIndMua = (1:numel(muaCodes)); % selected codes indices
% selectedCodesMua = muaCodes(selectedCodesIndMua); % selected codes 

selectedCodesMua = [19 23 24 32 43];%muaCodes(selectedCodesIndMua); % selected codes 
aux = 1:numel(muaCodes);
selectedCodesIndMua = aux(ismember( muaCodes, selectedCodesMua ));

selectedCodesDepthMua = spikeClusterData.uniqueCodesRealDepth(selectedCodesIndMua);
for cond = (1:totalConds)
    for code = (1:numel(muaCodes))    
        [traceMua(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrialsMua{cond,code},(plotBeg:bin:plotEnd));
    end
    meanTraceMua(cond,:) = mean(traceMua(cond,:,:),2);
end

clear normtraceMua traceByTrialMua edgesByTrialMua maxTraceByTrial baselineByTrial
close all
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
        set(gca,'XLim',[plotBeg+bin plotEnd+bin]);
        set(gca,'XTick',[]); 
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 totalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 totalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 totalTrials + 1 totalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
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
        plot((plotBeg+bin:bin:plotEnd), squeeze(traceMua(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    
    box off
    ylabel('Count');
    ax = gca;
    set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
    set(gca,'XTick',[]);
    set(gca, 'XColor', 'w');
    h1 = line([optStimInterval(1) optStimInterval(1)],[0 max(max(traceMua(:, code,:)))]); %max(h.Values)
    h2 = line([optStimInterval(2) optStimInterval(2)],[0 max(max(traceMua(:, code,:)))]);
    set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1) ],[0 0 max(max(traceMua(:, code,:))) max(max(traceMua(:, code,:)))],'c', 'EdgeColor', 'none'); % Add a patch
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.

    
    
    subplot(totalConds+4,1,[totalConds+3 totalConds+4], 'align');
    plot((plotBeg+bin:bin:plotEnd),squeeze(sum(traceMua(1:2:end,code,:),1)),'Color', 'k','LineWidth',2);
    hold on
    plot((plotBeg+bin:bin:plotEnd),squeeze(sum(traceMua(2:2:end,code,:),1)),'Color', 'b','LineWidth',2);

    y1= ylim;
    box off
    xlabel('Time [sec]');
    ylabel('Count');
%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(plotBeg):1:floor(plotEnd)]); % set major ticks
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

%         mkdir(savePathMua);
        savefig(strcat(savePathMua,  filesep, 'AllCondRasterAndTrace_',num2str(muaCodes(code)),'.fig'));
    end
    hold off
end


% quantifications of max and baselines
clear normtraceMua traceByTrialMua edgesByTrialMua maxTraceByTrial baselineByTrial

for code = (1:numel(muaCodes))%(20:22)%

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
            [traceByTrialMua(cond, code, trialInt, :), edgesByTrialMua(cond, code, trialInt, :)] = histcounts(spikeByTrialMua{cond, code, trialInt},(plotBeg:bin:plotEnd));
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

traceFreqMuaSel = traceMua(:, selectedCodesIndMua, :)/bin/totalTrials;
traceFreqMua = traceMua(:, 1:numel(muaCodes), :)/bin/totalTrials;

% Stats 1
statsCodesIndMua = (1:numel(muaCodes));%selectedCodesIndMua;%
statsMuaF
%%

clusterTimeSeries.spikeInTrialsMua = spikeInTrialsMua;
clusterTimeSeries.spikeByTrialMua = spikeByTrialMua;


clusterTimeSeries.traceByTrialMua = traceByTrialMua;
clusterTimeSeries.maxTraceByTrialMua = maxTraceByTrialMua;
clusterTimeSeries.baselineByTrialMua = baselineByTrialMua;
clusterTimeSeries.traceFreqMua = traceFreqMua;
clusterTimeSeries.traceFreqMuaSel = traceFreqMuaSel;

clusterTimeSeries.statsMua.keepTrialsMua = keepTrialsMua;
clusterTimeSeries.statsMua.keepTrialsBaseMua = keepTrialsBaseMua;

clusterTimeSeries.statsMua.statsCodesIndMua = statsCodesIndMua;
clusterTimeSeries.statsMua.hMua = hMua;
clusterTimeSeries.statsMua.pMua = pMua;
clusterTimeSeries.statsMua.hMuaW = hMuaW;
clusterTimeSeries.statsMua.pMuaW = pMuaW;

clusterTimeSeries.statsMua.hMuaBase = hMuaBase;
clusterTimeSeries.statsMua.pMuaBase = pMuaBase;
clusterTimeSeries.statsMua.hMuaBaseW = hMuaBaseW;
clusterTimeSeries.statsMua.pMuaBaseW = pMuaBaseW;

clusterTimeSeries.statsMua.hMuaBaseSameCond = hMuaBaseSameCond;
clusterTimeSeries.statsMua.pMuaBaseSameCond = pMuaBaseSameCond;
clusterTimeSeries.statsMua.hMuaBaseSameCondW = hMuaBaseSameCondW;
clusterTimeSeries.statsMua.pMuaBaseSameCondW = pMuaBaseSameCondW;

clusterTimeSeries.statsMua.hMuaBaseComb = hMuaBaseComb;
clusterTimeSeries.statsMua.pMuaBaseComb = pMuaBaseComb;
clusterTimeSeries.statsMua.hMuaBaseCombW = hMuaBaseCombW;
clusterTimeSeries.statsMua.pMuaBaseCombW = pMuaBaseCombW;


%% stats 2
statsCodesIndMua = selectedCodesIndMua;%
statsMuaF

clusterTimeSeries.selectedCodesMua = selectedCodesMua;
clusterTimeSeries.selectedCodesDepthMua = selectedCodesDepthMua;
clusterTimeSeries.selectedCodesIndMua = selectedCodesIndMua;

clusterTimeSeries.statsMuaSel.keepTrialsMua = keepTrialsMua;
clusterTimeSeries.statsMuaSel.keepTrialsBaseMua = keepTrialsBaseMua;

clusterTimeSeries.statsMuaSel.statsCodesIndMua = statsCodesIndMua;
clusterTimeSeries.statsMuaSel.hMua = hMua;
clusterTimeSeries.statsMuaSel.pMua = pMua;
clusterTimeSeries.statsMuaSel.hMuaW = hMuaW;
clusterTimeSeries.statsMuaSel.pMuaW = pMuaW;

clusterTimeSeries.statsMuaSel.hMuaBase = hMuaBase;
clusterTimeSeries.statsMuaSel.pMuaBase = pMuaBase;
clusterTimeSeries.statsMuaSel.hMuaBaseW = hMuaBaseW;
clusterTimeSeries.statsMuaSel.pMuaBaseW = pMuaBaseW;

clusterTimeSeries.statsMuaSel.hMuaBaseSameCond = hMuaBaseSameCond;
clusterTimeSeries.statsMuaSel.pMuaBaseSameCond = pMuaBaseSameCond;
clusterTimeSeries.statsMuaSel.hMuaBaseSameCondW = hMuaBaseSameCondW;
clusterTimeSeries.statsMuaSel.pMuaBaseSameCondW = pMuaBaseSameCondW;

clusterTimeSeries.statsMuaSel.hMuaBaseComb = hMuaBaseComb;
clusterTimeSeries.statsMuaSel.pMuaBaseComb = pMuaBaseComb;
clusterTimeSeries.statsMuaSel.hMuaBaseCombW = hMuaBaseCombW;
clusterTimeSeries.statsMuaSel.pMuaBaseCombW = pMuaBaseCombW;


%% save 

cfCTS = checkFields(clusterTimeSeries);
if ~cfCTS
    disp(['Saving ', experimentName, ' / ' ,  sessionName, ' .clusterTimeSeries.mat file'])
    save(filenameClusterTimeSeries, 'clusterTimeSeries')
else
    disp('.clusterTimeSeries.mat file was not saved')
end

%% Plot NEW figure - average figure
figure
for cond = (1:totalConds)
    plot((plotBeg:bin:plotEnd-bin), meanTrace(cond, :), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2); hold on
end
box off
xlabel('Time [sec]');
ylabel('Count');
%     set('facecolor',[1 0 1]);
%     set('BinEdges',[-preTrialTime:bin:trialDuration+afterTrialTime]); % trialDuration+afterTrialTime
ax = gca;
set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
set(ax, 'TickDir', 'out');
set(ax,'xtick',[floor(plotBeg):5:floor(plotEnd)]); % set major ticks
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
    savefig(strcat(savePathFigs, filesep, 'MeanAllCondTrace.fig'));
end


%% plot NEW figures - noise codes

C = ['r', 'g', 'b', 'y', 'm', 'k'];
traceNoise=zeros(totalConds, numel(noiseCodes), (plotEnd - plotBeg)/bin);
meanTraceNoise = zeros(totalConds, (plotEnd - plotBeg)/bin);
edges =[];
meanTrace = zeros(totalConds, (plotEnd - plotBeg)/bin);
selectedCodesIndNoise = (1:numel(noiseCodes)); % selected codes indices
selectedCodesNoise = noiseCodes(selectedCodesIndNoise); % selected codes 
selectedCodesDepthNoise = spikeClusterData.uniqueCodesRealDepth(selectedCodesIndNoise);
for cond = (1:totalConds)
    for code = (1:numel(noiseCodes))    
        [traceNoise(cond, code,:), edges(cond, code,:)] = histcounts(spikeInTrialsNoise{cond,code},(plotBeg:bin:plotEnd));
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
        set(gca,'XLim',[plotBeg+bin plotEnd+bin]);
        set(gca,'XTick',[]); 
%         set(gca,'FontSize',24);
        set(gca, 'XColor', 'w');
        ylabel(currentConName, 'FontSize',8);
        if mod(cond,2)==0
            h1 = line([optStimInterval(1) optStimInterval(1)],[0 totalTrials + 1]); %max(h.Values)
            h2 = line([optStimInterval(2) optStimInterval(2)],[0 totalTrials + 1]);
            set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
            patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 totalTrials + 1 totalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
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
        plot((plotBeg+bin:bin:plotEnd), squeeze(traceNoise(cond, code,:)), 'Color', C(fix((cond+1)/2)), 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on
        %plot((-preTrialTime:bin:trialDuration+afterTrialTime-bin), squeeze(trace(cond, code,:)), 'Color', C1, 'LineWidth', mod(cond,2)+2, 'LineStyle', ls); hold on

    end
    box off
    xlabel('Time [sec]');
    ylabel('Count');
%     set('facecolor',[1 0 1]);
    ax = gca;
    set(ax,'XLim',[plotBeg+bin plotEnd+bin],'FontSize',24);
    set(ax, 'TickDir', 'out');
    set(ax,'xtick',[floor(plotBeg):1:floor(plotEnd)]); % set major ticks
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
        savePathNoise = fullfile(basePathMatlab, 'figs', 'noise');
        mkdir(savePathNoise);
        savefig(strcat(savePathNoise, '/AllCondRasterAndTrace_',num2str(noiseCodes(code)),'.fig'));
    end
    hold off
end

traceFreqNoise = traceNoise/bin/totalTrials;
traceFreqNoiseSel = traceNoise(:, selectedCodesIndNoise, :)/bin/totalTrials;


%% Plot NEW figure - average noise figure
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
    % h1 = line([optStimInterval(1) optStimInterval(1)],[0 totalTrials + 1]); %max(h.Values)
    % h2 = line([optStimInterval(2) optStimInterval(2)],[0 totalTrials + 1]);
    % set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    % patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 totalTrials + 1 totalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
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
    % h1 = line([optStimInterval(1) optStimInterval(1)],[0 totalTrials + 1]); %max(h.Values)
    % h2 = line([optStimInterval(2) optStimInterval(2)],[0 totalTrials + 1]);
    % set([h1 h2],'Color','c','LineWidth',1)% Set properties of lines
    % patch([optStimInterval(1) optStimInterval(2) optStimInterval(2) optStimInterval(1)],[0 0 totalTrials + 1 totalTrials + 1],'c', 'EdgeColor', 'none');% Add a patch
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