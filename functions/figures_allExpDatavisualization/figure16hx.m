%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on spont activity


saveFig16hx = {'LMbasePreAmplPostCoeffs.fig'}; %modify here if needed
   

figure
ax = gca;
bar(1:totalCoeffs, coeffsLM(1:totalCoeffs,1), 'FaceColor', 'k', 'EdgeColor', 'none', 'BarWidth', 0.8); hold on
errorbar(1:totalCoeffs, coeffsLM(:,1),coeffsLM(:,2), 'LineStyle','none', 'LineWidth', 2,'Color', C(1,:));

for coeff = 1:totalCoeffs % add stars in case of significance
    yp = max((coeffsLM(coeff,1)+coeffsLM(coeff,2)),0.1)*1.1;
    if coeffsLM(coeff,4) <= 0.001
        %             pStars = '***';
        text(coeff, yp, '***','FontSize',10,  'HorizontalAlignment','center')
    elseif coeffsLM(coeff,4) <= 0.01
        %             pStars = '**';
        text(coeff, yp, '**','FontSize',10, 'HorizontalAlignment','center')
    elseif coeffsLM(coeff,4) <= 0.05
        %             pStars = '*';
        text(coeff, yp, '*','FontSize',10, 'HorizontalAlignment','center')
    end

end
ylim([min(coeffsLM(:,1)-coeffsLM(:,2)), max(coeffsLM(:,1)+coeffsLM(:,2))]*1.3) 
if totalCoeffs == 7  
    xticklabels({'\beta_0', '\beta_1', '\beta_2', '\beta_3', '\beta_4', '\beta_5', '\beta_6'})
    text(2,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1*r_p_r_e + \beta_2*x + \beta_3*r_p_r_e*s + \newline+\beta_4*r_p_r_e*x + \beta_5*s*x + \beta_6*r_p_r_e*s*x','FontSize',12)

elseif totalCoeffs == 8     
    xticklabels({'\beta_0', '\beta_1', '\beta_2', '\beta_3', '\beta_4', '\beta_5', '\beta_6', '\beta_7'})
    text(2,max(ylim),'r_p_o_s_t = \beta_0 + \beta_1*r_p_r_e + \beta_2*x + \beta_3*r_p_r_e*s + \newline+\beta_4*r_p_r_e*x + \beta_5*s*x + \beta_6*r_p_r_e*s*x + \beta_7*s','FontSize',12)
end
box off
set(ax,'FontSize',fs)
if saveFigs == true
    savefig(strcat(savePath, saveFig16hx{1}));
    saveas(gcf, strcat(savePath, saveFig16hx{1}(1:end-3), 'png'));
end