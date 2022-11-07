%%% created by RB on 12.11.2021
% Fig. 50b : Histogram instead of traces of firing rates
% Run after running the first section in PlotPSTHandRaster analysis
 
% exp 2020-08-10_14-18-15

saveFigs = false;
savePath = [strjoin({path{1:end}, 'figs','2021-10',  'PvCre', 'long','evoked', 'inh'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

titleFig50b = {'Histogram firing rates'};
saveFig50b = {'HistFR.fig'};

codes = spikeClusterData.goodCodes;

selUnits = [5,6]; 

edges = (plotBeg+bin:bin*3:plotEnd+bin);

f = figure('Renderer', 'painters'); % all waveforms
subplot(2,1,1)
code = selUnits(1)
codes(code)
cond = 3;
histogram(spikeInTrials{cond+1,code}, edges, 'Normalization', 'countdensity','FaceColor', 'b','FaceAlpha', 1); hold on%
histogram(spikeInTrials{cond,code}, edges, 'Normalization', 'countdensity','FaceColor', 'k', 'FaceAlpha', 1); hold on

yl = ylim;
max_hist1 = yl(2);

fact = 1.06;
h1 = line(sessionInfo.optStimInterval,[max_hist1 max_hist1]*fact);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

fact = 1.02;
x = [sessionInfo.visStim; sessionInfo.visStim + 0.2]';
for i = (1:6)
    h2 = line('XData',x(i,:),'YData',[max_hist1 max_hist1]*fact); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
    set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines   
end
% set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
box off 

ylabel('Firing rate(Hz)');
ax = gca;
set(ax,'XLim',[plotBeg plotEnd+bin],'FontSize',24);
set(gca,'XTick',[], 'TickDir','out');
set(gca, 'XColor', 'w');
yticks([0:100:yl(2)]);
yticklabels({'0','5','10', '15'})



subplot(2,1,2)
code = selUnits(2)
codes(code)
histogram(spikeInTrials{cond,code}, edges, 'Normalization', 'countdensity','FaceColor', 'k', 'FaceAlpha', 1); hold on
histogram(spikeInTrials{cond+1,code}, edges, 'Normalization', 'countdensity','FaceColor', 'b', 'FaceAlpha', 1); hold on

yl = ylim;
box off
xlabel('Time(s)');
% ylabel('Firing rate(Hz)');
ax = gca;
set(ax,'XLim',[plotBeg plotEnd+bin],'FontSize',24);
set(gca,'TickDir','out');
xticks([plotBeg:5:plotEnd]);
xticklabels({'0','5','10', '15', '20'})
yticks([0:200:600]);
yticklabels({'0','10', '20', '30'})


if saveFigs == true
    savefig(strcat(savePath, saveFig50b{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig50b{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig50b{1}(1:end-4)), 'epsc');
end

%%
% exp 2020-10-14_13-27-56

saveFigs = true;
savePath = [strjoin({path{1:end}, 'figs','2022-02',  'NexCre', 'long','evoked', 'exc'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

titleFig50b = {'Histogram firing rates'};
saveFig50b = {'HistFR_2019-07-09_13-51-07.fig'};

codes = spikeClusterData.goodCodes;
C = [[0 0 0]; [0 0 1];  [0.7 0.7 0.7]; [0 0.4470 0.7410]];
% selUnits = [22,15]; % exp 2020-10-14_13-27-56 [22,20]
selUnits = [3,6]; %exp2019-07-09_13-51-07
% selUnits = [2,6]; % exp 2020-07-22_18-07-38
cond = 3;

edges = (plotBeg+bin:bin*3:plotEnd+bin);

f = figure('Renderer', 'painters'); % all waveforms
subplot(2,1,1)
code = selUnits(1)
codes(code)
histogram(spikeInTrials{cond+1,code}, edges, 'Normalization', 'countdensity','FaceColor', C(cond+1,:),'FaceAlpha', 1); hold on%
histogram(spikeInTrials{cond,code}, edges, 'Normalization', 'countdensity','FaceColor', C(cond,:), 'FaceAlpha', 1); hold on

yl = ylim;
max_hist1 = yl(2);

fact = 1.06;
h1 = line(sessionInfo.optStimInterval,[max_hist1 max_hist1]*fact);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

fact = 1.02;
x = [sessionInfo.visStim; sessionInfo.visStim + 0.2]';
if cond <totalConds-1
    for i = (1:6)
        h2 = line('XData',x(i,:),'YData',[max_hist1 max_hist1]*fact); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines   
    end
end    
% set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
box off 

ylabel('Firing rate(Hz)');
ax = gca;
set(ax,'XLim',[plotBeg plotEnd+bin],'FontSize',24);
set(gca,'XTick',[], 'TickDir','out');
set(gca, 'XColor', 'w');
yticks([0:100:yl(2)]);
yticklabels({'0','5','10', '15'})



subplot(2,1,2)
code = selUnits(2)
codes(code)
histogram(spikeInTrials{cond+1,code}, edges, 'Normalization', 'countdensity','FaceColor', C(cond+1,:), 'FaceAlpha', 1); hold on
histogram(spikeInTrials{cond,code}, edges, 'Normalization', 'countdensity','FaceColor', C(cond,:), 'FaceAlpha', 1); hold on

yl = ylim;
box off
xlabel('Time(s)');
% ylabel('Firing rate(Hz)');
ax = gca;
set(ax,'XLim',[plotBeg plotEnd+bin],'FontSize',24);
set(gca,'TickDir','out');
xticks([plotBeg:5:plotEnd]);
xticklabels({'0','5','10', '15', '20'})
yticks([0:200:600]);
yticklabels({'0','10', '20', '30'})


if saveFigs == true
    savefig(strcat(savePath, saveFig50b{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig50b{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig50b{1}(1:end-4)), 'epsc');
end