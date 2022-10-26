%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on spont activity

% titleFig16f = {'Base1 vs base4 100% no photostim', 'Base1 vs base4 100% with photostim',...
%     'Base1 vs base4 0% no photostim','Base1 vs base4 0% with photostim'};
if strcmp(dataLM, 'base') 
    saveFig16f = {'LMbasePrebasePost0.fig'}; %modify here if needed
    cond = totalConds-1;
elseif strcmp(dataLM, 'magn')
    saveFig16f = {'LMmagnPremagnPost.fig'}; %modify here if needed  
    cond = 1;
end    

figure;
ax = gca;
scatter(x1, y1, 'MarkerEdgeColor', C(cond,:), 'LineWidth', 2); hold on
scatter(x2, y2, 'MarkerEdgeColor', C(cond +1,:), 'LineWidth', 2);


lims = max(xlim, ylim);
xlim(lims)
ylim(lims)

% calculate coefficients from the linear regression model
coeffsLM = table2array(mdl.Coefficients);
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1
coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)+coeffsLM(3,1)]; % coefficients for x2,y2
 
f1 = polyval(coeffsLM1, lims);
f2 = polyval(coeffsLM2, lims);

plot(lims, f1, 'Color', C(cond,:));
plot(lims, f2, 'Color', C(cond+1,:));


lim= max(max(xlim, ylim));
% text(lim*0.25, lim*0.98, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond,:));
% text(lim*0.25, lim*1.05, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond+1,:));
text(lim*0.8, lim*0.1, [num2str(round(coeffsLM1(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond,:));
text(lim*0.8, lim*0.25, [num2str(round(coeffsLM2(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond+1,:));

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
if totalStim == 6
    if strcmp(dataLM, 'base') 
        xlabel('Norm. base pre','FontSize',24); % modify here if needed
        ylabel('Norm. base post','FontSize',24); % modify here if needed
    elseif strcmp(dataLM, 'magn')
        xlabel('Norm. magn. pre','FontSize',24); % modify here if needed
        ylabel('Norm. magn. post','FontSize',24); % modify here if needed
    end    
    xlabel('Firing rate pre (norm.)','FontSize',24); % labels for paper
    ylabel('Firing rate post (norm.)','FontSize',24); % labels for paper
else
    xlabel('Norm. comb. base pre','FontSize',24); % modify here if needed
    ylabel('Norm. comb. base post','FontSize',24); % modify here if needed
end    
% xlim([0 1])
% ylim([0 1])
set(ax, 'TickDir', 'out');
set(ax,'FontSize',fs)
if saveFigs == true
    savefig(strcat(savePath, saveFig16f{1}));
    saveas(gcf, strcat(savePath, saveFig16f{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16f{1}(1:end-4)), 'epsc');
end