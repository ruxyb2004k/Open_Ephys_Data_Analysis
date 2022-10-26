%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on spont activity

if strcmp(dataLM, 'base') 
    saveFig16fx = {'LMbasePrebasePost0Coeffs.fig'}; %modify here if needed
elseif strcmp(dataLM, 'magn') 
    saveFig16fx = {'LMmagnPreMagnPostCoeffs.fig'}; %modify here if needed   
end

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
xticklabels({'\beta_0', '\beta_1', '\beta_2', '\beta_3'})
set(ax, 'TickDir', 'out');
box off
set(ax,'FontSize',fs)
% text(0.8,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1\cdotr_p_r_e + \beta_2\cdots + \beta_3\cdotr_p_r_e\cdots','FontSize',18)
if saveFigs == true
    savefig(strcat(savePath, saveFig16fx{1}));
    saveas(gcf, strcat(savePath, saveFig16fx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig16fx{1}(1:end-4)), 'epsc');
end