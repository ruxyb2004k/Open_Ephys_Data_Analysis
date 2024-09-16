%%% created by RB on 12.04.2022
%%% depicts a linear model of the photostim effect on spont activity

if strcmp(dataLM, 'base') 
    saveFig16fMod = {'LMbasePrebasePost0.fig'}; %modify here if needed
    cond = totalConds-1;
elseif strcmp(dataLM, 'magn')
    saveFig16fMod = {'LMmagnPremagnPost.fig'}; %modify here if needed  
    cond = 1;
end    

figure;
ax = gca;
scatter(x1, y1, 'MarkerEdgeColor', 'k', 'LineWidth', 2); hold on
scatter(x2, y2, 'MarkerEdgeColor', 'b', 'LineWidth', 2);


lims = max(xlim, ylim);
xlim(lims)
ylim(lims)

% calculate coefficients from the linear regression model
coeffsLM = table2array(mdl.Coefficients);
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1
coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)+coeffsLM(3,1)]; % coefficients for x2,y2
 
f1 = polyval(coeffsLM1, lims);
f2 = polyval(coeffsLM2, lims);

plot(lims, f1, 'Color', 'k');
plot(lims, f2, 'Color', 'b');


lim= max(max(xlim, ylim));
% text(lim*0.25, lim*0.98, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond,:));
% text(lim*0.25, lim*1.05, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', C(cond+1,:));
text(lim*0.8, lim*0.1, [num2str(round(coeffsLM1(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', 'k');
text(lim*0.8, lim*0.25, [num2str(round(coeffsLM2(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', 'b');

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines

if strcmp(dataLM, 'base')
    xlabel('Norm. base pre','FontSize',24); % modify here if needed
    ylabel('Norm. base post','FontSize',24); % modify here if needed
elseif strcmp(dataLM, 'magn')
    xlabel('Norm. magn. pre','FontSize',24); % modify here if needed
    ylabel('Norm. magn. post','FontSize',24); % modify here if needed
end

set(ax, 'TickDir', 'out');
set(ax,'FontSize',fs)

table_data1 = table(x1,y1,x2,y2);
table_data1 = renamevars(table_data1 , ["x1", "y1", "x2", "y2"],...
    ["CtrlPre", "CtrlPost","25%Pre", "25%Post"]);


if saveFigs == true
    savefig(strcat(savePath, saveFig16fMod{1}));
    saveas(gcf, strcat(savePath, saveFig16fMod{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16fMod{1}(1:end-4)), 'epsc');
    writetable(table_data1, strcat(savePath, saveFig16fMod{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:D')
end