%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on activity

saveFig16fx_fitParam = {'LMmagnPreMagnPostCoeffs.fig'}; %modify here if needed   
totalCoeffs = size(coeffsLM,1);

fsStars = 20;
figure
ax = gca;
bar(1:totalCoeffs, coeffsLM(1:totalCoeffs,1), 'FaceColor', 'k', 'EdgeColor', 'none', 'BarWidth', 0.8); hold on
errorbar(1:totalCoeffs, coeffsLM(:,1),coeffsLM(:,2), 'LineStyle','none', 'LineWidth', 2,'Color', C(1,:));

for coeff = 1:totalCoeffs % add stars in case of significance
    yp = max((coeffsLM(coeff,1)+coeffsLM(coeff,2)),0.1)*1.1;
    if coeffsLM(coeff,4) <= 0.001
        %             pStars = '***';
        text(coeff, yp, '***','FontSize',fsStars,  'HorizontalAlignment','center')
    elseif coeffsLM(coeff,4) <= 0.01
        %             pStars = '**';
        text(coeff, yp, '**','FontSize',fsStars, 'HorizontalAlignment','center')
    elseif coeffsLM(coeff,4) <= 0.05
        %             pStars = '*';
        text(coeff, yp, '*','FontSize',fsStars, 'HorizontalAlignment','center')
    end

end
ylim([min(coeffsLM(:,1)-coeffsLM(:,2)), max(coeffsLM(:,1)+coeffsLM(:,2))]*1.3) 
xticklabels({'\beta_0', '\beta_1'}) % intercept, slope
set(ax, 'TickDir', 'out');
box off
set(ax,'FontSize',fs)
% text(0.8,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1\cdotr_p_r_e + \beta_2\cdots + \beta_3\cdotr_p_r_e\cdots','FontSize',18)
if saveFigs == true
    savefig(strcat(savePath, saveFig16fx_fitParam{1}));
    saveas(gcf, strcat(savePath, saveFig16fx_fitParam{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16fx_fitParam{1}(1:end-4)), 'epsc');
end

%%


saveFig16fx_fitParam_diff = {'LMmagnPreMagnPostCoeffs.fig'}; %modify here if needed   
totalCoeffs = size(coeffsLM_diff,1);

fsStars = 20;
figure
ax = gca;
bar(1:totalCoeffs, coeffsLM_diff(1:totalCoeffs,1), 'FaceColor', 'k', 'EdgeColor', 'none', 'BarWidth', 0.8); hold on
errorbar(1:totalCoeffs, coeffsLM_diff(:,1),coeffsLM_diff(:,2), 'LineStyle','none', 'LineWidth', 2,'Color', C(1,:));

for coeff = 1:totalCoeffs % add stars in case of significance
    yp = min((coeffsLM_diff(coeff,1)-coeffsLM_diff(coeff,2)),0.1)*1.1;
    if coeffsLM_diff(coeff,4) <= 0.001
        %             pStars = '***';
        text(coeff, yp, '***','FontSize',fsStars,  'HorizontalAlignment','center')
    elseif coeffsLM_diff(coeff,4) <= 0.01
        %             pStars = '**';
        text(coeff, yp, '**','FontSize',fsStars, 'HorizontalAlignment','center')
    elseif coeffsLM_diff(coeff,4) <= 0.05
        %             pStars = '*';
        text(coeff, yp, '*','FontSize',fsStars, 'HorizontalAlignment','center')
    end

end
ylim([min(coeffsLM_diff(:,1)-coeffsLM_diff(:,2)), max(coeffsLM_diff(:,2))]*1.3) 
xticklabels({'\beta_0', '\beta_1'}) % intercept, slope
set(ax, 'TickDir', 'out');
box off
set(ax,'FontSize',fs)
% text(0.8,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1\cdotr_p_r_e + \beta_2\cdots + \beta_3\cdotr_p_r_e\cdots','FontSize',18)
if saveFigs == true
    savefig(strcat(savePath, saveFig16fx_fitParam_diff{1}));
    saveas(gcf, strcat(savePath, saveFig16fx_fitParam_diff{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16fx_fitParam_diff{1}(1:end-4)), 'epsc');
end