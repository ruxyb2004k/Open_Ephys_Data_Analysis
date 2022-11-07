%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on spont activity (post vs pre)

saveFig16f_fit = {'LMbasePrebasePost0.fig'}; %modify here if needed
cond = totalConds-1;
fs = 24; 

figure;
ax = gca;
scatter(x, y, 'MarkerEdgeColor', 'b', 'LineWidth', 2); hold on

lims = max(xlim, ylim);
xlim(lims)
ylim(lims)

% calculate coefficients from the linear regression model
coeffsLM = table2array(mdl.Coefficients);
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1

f1 = polyval(coeffsLM1, lims);

plot(lims, f1, 'Color', 'b');

lim= max(max(xlim, ylim));
text(lim*0.8, lim*0.1, [num2str(round(coeffsLM1(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', 'b');

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
xlabel('Firing rate pre (norm.)','FontSize',24); % labels for paper
ylabel('Firing rate post (norm.)','FontSize',24); % labels for paper

% xlim([0 1])
% ylim([0 1])

set(ax, 'TickDir', 'out');
set(ax,'FontSize',fs)

if saveFigs == true
    savefig(strcat(savePath, saveFig16f_fit{1}));
    saveas(gcf, strcat(savePath, saveFig16f_fit{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16f_fit{1}(1:end-4)), 'epsc');
end

%% same as above, but for post-pre vs pre

saveFig16f_fit_diff = {'LMbasePrebasePost0.fig'}; %modify here if needed
cond = totalConds-1;
fs = 24; 

figure;
ax = gca;
scatter(x, y2, 'MarkerEdgeColor', 'b', 'LineWidth', 2); hold on

lims = xlim;

% calculate coefficients from the linear regression model
coeffsLM_diff = table2array(mdl_diff.Coefficients);
coeffsLM1_diff = [coeffsLM_diff(2,1), coeffsLM_diff(1,1)]; % coefficients for x1,y1

f1 = polyval(coeffsLM1_diff, lims);

plot(lims, f1, 'Color', 'b');

lim= max(max(xlim, ylim));
text(lim*0.8, lim*0.1, [num2str(round(coeffsLM1_diff(1),2)),'\cdotr_p_r_e + ',num2str(round(coeffsLM1_diff(2), 2)) ] ,'FontSize',fs, 'HorizontalAlignment','center', 'Color', 'b');

legend off

h1 = line([0 lim],[0 0]); % horizontal line
set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
xlabel('Firing rate pre (norm.)','FontSize',24); % labels for paper
ylabel('Firing rate post (norm.)','FontSize',24); % labels for paper

set(ax, 'TickDir', 'out');
set(ax,'FontSize',fs)

if saveFigs == true
    savefig(strcat(savePath, saveFig16f_fit_diff{1}));
    saveas(gcf, strcat(savePath, saveFig16f_fit_diff{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16f_fit_diff{1}(1:end-4)), 'epsc');
end
