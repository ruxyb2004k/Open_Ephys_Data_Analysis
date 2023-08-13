%%% created by RB on 14.02.2023

% Fig 7k (10x): Scatter plots of Opto-index vs firing rates - 
% comparison baselines between before and during photostim. 


titleFig7k = {'Opto-index vs. Firing rate 100% visual stim. +/- photostim. Base2',...
    'Opto-index vs. Firing rate 100% visual stim. +/- photostim. Base3',...
    'Opto-index vs. Firing rate 100% visual stim. +/- photostim. Base4',...
    'Opto-index vs. Firing rate 100% visual stim. +/- photostim. Base5',...
    'Opto-index vs. Firing rate 100% visual stim. +/- photostim. Base6',...
    'Opto-index vs. Firing rate 0% visual stim. +/- photostim. Base2',...
    'Opto-index vs. Firing rate 0% visual stim. +/- photostim. Base3',...
    'Opto-index vs. Firing rate 0% visual stim. +/- photostim. Base4',...
    'Opto-index vs. Firing rate 0% visual stim. +/- photostim. Base5',...
    'Opto-index vs. Firing rate 0% visual stim. +/- photostim. Base6'};

saveFig7k = {'OptoindexFR100Base2Class.fig', 'OptoindexFR100Base3Class.fig',...
    'OptoindexFR100Base4Class.fig', 'OptoindexFR100Base5Class.fig',...
    'OptoindexFR100Base6Class.fig',...
    'OptoindexFR0Base2Class.fig', 'OptoindexFR0Base3Class.fig',...
    'OptoindexFR0Base4Class.fig', 'OptoindexFR0Base5Class.fig',...
    'OptoindexFR0Base6Class.fig'};
fC=0.8; % 0.8 for waveforms
%EI_Color = [1,fC,fC; fC,fC,1];
EI_Color = [213,94,0; 0,114,178]/255;
%EI_Color = [239,191,170; 153,199,225]/255;

catCells = {'exc', 'inh'};
cat = catCells(classUnitsAll);
cat = cellstr(cat)';
for cond = 3%(1:2:totalConds)
    for stim =4%2:totalStim
        x = allStimBase(cond,baseSelect,1);
        y = OIndexAllStimBase((cond+1)/2,baseSelect, stim);        

        Q = quantile(x,[0 0.25 0.5 0.75 1]);
        for i = (1:numel(Q)-1)
            ind_q = x>=Q(i) & x<Q(i+1);
            m(i) = nanmean(y(ind_q));
            s(i) = nanstd(y(ind_q))/sqrt(sum(ind_q));
        end    
        width_bar = diff(Q);
        middle_bar = Q(1:end-1)+width_bar/2;
        f = figure('Renderer', 'painters', 'Position', [100,100,460,420]);  
        ax = gca;
        hold on
        line([min(x) max(x)], [0 0], 'Color', [0.4 0.4 0.4]) 
        set(gca, 'XScale', 'log')
        scatter(x,y, 'MarkerEdgeColor', cCreCellType, 'MarkerFaceColor', cCreCellType);
        for i=1:length(Q)-1
%             rectangle('position',[Q(i) -1 width_bar(i) m(i)+1], 'EdgeColor', [0.3 0.3 0.3],'LineWidth', 1)
            rectangle('position',[Q(i) min(0,m(i)) width_bar(i) abs(m(i))], 'EdgeColor', [0.2 0.2 0.2],'LineWidth', 2)

        end
        for i=2:length(Q)-1
            line([Q(i) Q(i)], [-1 1], 'LineStyle','--','Color', [0.4 0.4 0.4]) 
        end
        errorbar(middle_bar,m,s,'.','Color', [0.2 0.2 0.2],'LineWidth',2);
        set(gca, 'XScale', 'log')
                 
        set(ax,'XLim', [0.5,max(x)], 'YLim', [-1 1],'FontSize',24);
        title(titleFig7k{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'xtick', [0.1,1,10,100], 'ytick',(-1:0.5:1))
        xticklabels({[0.1,1,10,100]})
        xlabel('Firing rate (Hz)');
        ylabel('OI');

        box off
        
        mdl =fitlm(x,y)
        lims = max(xlim, ylim);
        lim = max(lims)
        
        % calculate coefficients from the linear regression model
        coeffsLM = table2array(mdl.Coefficients);
        coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1        
        %f1 = polyval(coeffsLM1, lims);  
        x_lin = linspace(lims(1),lims(2),20);
        y_pred = polyval(coeffsLM1, x_lin); 
        
        %plot(lims, f1, '--r');   
        plot(x_lin, y_pred, '--r', 'LineWidth', 2); 
        
        text(lim*0.3, -0.55, [num2str(round(coeffsLM1(1),2)),'\cdotFR + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',fs-8, 'HorizontalAlignment','center');
        text(lim*0.3, -0.85, ['R^2 = ',num2str(round(mdl.Rsquared.Ordinary, 2)) ] ,'FontSize',fs-8, 'HorizontalAlignment','center');

        table_data1 = table(x',y');
        table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["FR (Hz)", "OI"]);
        
        if saveFigs == true
            savefig(strcat(savePath, saveFig7k{(cond+1)/2*5+(stim-6)}));
            title('');
            saveas(gcf, strcat(savePath, saveFig7k{(cond+1)/2*5+(stim-6)}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig7k{(cond+1)/2*5+(stim-6)}(1:end-4)), 'epsc');
            writetable(table_data1, strcat(savePath, saveFig7k{(cond+1)/2*5+(stim-6)}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
        end
    end
end


