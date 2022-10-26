%%% created by RB on 12.11.2021
% Fig. 50a : Waveforms complementary to the ACG and CCG figures
% Run after running the waveformAnalysis

saveFigs = false;
savePath = [strjoin({path{1:end}, 'figs','2021-10',  'PvCre', 'long','evoked', 'inh'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

titleFig50a = {'Waveforms'};
saveFig50a = {'Waveforms.fig'};

codes = spikeClusterData.goodCodes;
% exp 2020-08-10_14-18-15
% cCreCellType = [192 0 0; 192/1.5 0 0]/255;
% selUnits = [5,6]; 

% exp 2020-10-14_13-27-56
cCreCellType = [0 176 80; 230 153 153]/255 ;% exc first, inh 2nd
selUnits = [22,20]; 

% exp 2020-07-22_18-07-38
cCreCellType = [0 176 80; 230 153 153]/255 ;% exc first, inh 2nd
selUnits = [2,6]; 

figure; % all waveforms

plot(waveformFiltAvg(selUnits(1),12:52),'LineWidth',5, 'Color', cCreCellType(1,:)); hold on   
plot(waveformFiltAvg(selUnits(2),12:52),'LineWidth',5,'Color', cCreCellType(2,:)); 

h1 = line([2 22],[-200 -200]); % 1 ms
h2 = line([2 2],[-100 -200]); % 100 uV
set(h1,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
set(h2,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
text(10, -220,'1 ms','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center');
h3 = text(0, -150,'100 \muV','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center');
set(h3,'Rotation',90);
axis off
title(titleFig50a);

if saveFigs == true
    savefig(strcat(savePath, saveFig50a{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig50a{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig50a{1}(1:end-4)), 'epsc');
end

%%

saveFigs = true;
savePath = [strjoin({path{1:end}, 'figs','2022-02',  'NexCre', 'long','evoked', 'exc'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

titleFig50a = {'Waveforms'};
saveFig50a = {'Waveforms_2019-07-09_13-51-07.fig'};

codes = spikeClusterData.goodCodes;
% exp 2020-08-10_14-18-15
% cCreCellType = [192 0 0; 192/1.5 0 0]/255;
% selUnits = [5,6]; 

% exp 2020-10-14_13-27-56
% cCreCellType = [0 176 80; 230 153 153]/255 ;% exc first, inh 2nd
% selUnits = [22,15]; 

% exp 2020-07-22_18-07-38
% cCreCellType = [0 176 80; 230 153 153]/255 ;% exc first, inh 2nd
% selUnits = [2,6]; 

% exp 2019-07-09_13-51-07
cCreCellType = [0 176 80; 230 153 153]/255 ;% exc first, inh 2nd
selUnits = [3,6]; 

figure; % all waveforms

plot(waveformFiltAvg(selUnits(1),12:52),'LineWidth',5, 'Color', cCreCellType(1,:)); hold on   
plot(waveformFiltAvg(selUnits(2),12:52),'LineWidth',5,'Color', cCreCellType(2,:)); 

h1 = line([2 22],[-200 -200]); % 1 ms
h2 = line([2 2],[-100 -200]); % 100 uV
set(h1,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
set(h2,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
text(10, -220,'1 ms','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center');
h3 = text(0, -150,'100 \muV','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center');
set(h3,'Rotation',90);
axis off
title(titleFig50a);

if saveFigs == true
    savefig(strcat(savePath, saveFig50a{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig50a{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig50a{1}(1:end-4)), 'epsc');
end
