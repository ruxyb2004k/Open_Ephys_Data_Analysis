%%% created by RB on 10.06.2021

% Fig. 9f - opto-index bar plot for amplitudes vs unit depth

if totalStim ==6
    titleFig9f = {'Opto-index 100% visual stim. vs depth Ampl1',...
        'Opto-index 100% visual stim. vs depth Ampl2',...
        'Opto-index 100% visual stim. vs depth Ampl3',...
        'Opto-index 100% visual stim. vs depth Ampl4',...
        'Opto-index 100% visual stim. vs depth Ampl5',...
        'Opto-index 100% visual stim. vs depth Ampl6'};
    
    saveFig9f = {'Optoindex100Ampl1Depth.fig','Optoindex100Ampl2Depth.fig','Optoindex100Ampl3Depth.fig','Optoindex100Ampl4Depth.fig','Optoindex100Ampl5Depth.fig','Optoindex100Ampl6Depth.fig'};

    cond = 1;
    for stim = (1:totalStim)
        figure
        ax = gca;
        hold on
        ind = ~isnan(OIndexAllStimAmpl((cond+1)/2,:,stim));
        
        scatter(realDepthAll(ind)',OIndexAllStimAmpl((cond+1)/2,ind,stim))
        xl= xlim;
        yl= ylim;
%         c = polyfit(realDepthAll(ind)',OIndexAllStimAmpl((cond+1)/2,ind,stim),1);
        lm = fitlm(realDepthAll(ind),OIndexAllStimAmpl((cond+1)/2,ind,stim));
        d = table2array(lm.Coefficients);
        c = flip(d(:,1))';
        text(xl(2)*0.9, yl(2)*0.9, ['y = ' num2str(round(c(1),4)) '*x + ' num2str(round(c(2),2))],'FontSize',18, 'HorizontalAlignment','right');
        text(xl(2)*0.9, yl(2)*0.8, ['R-sq = ' num2str(round(lm.Rsquared.Ordinary,2))],'FontSize',18, 'HorizontalAlignment','right');

        y_est = polyval(c, [xl(1) xl(2)]);
        % Add trend line to plot
        hold on
        plot(xl,y_est,'r--','LineWidth',2)
        hold off

        xlabel('Depth (um)');
        ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');

        set(ax,'FontSize',fs)        
        background = get(gcf, 'color');
        title(titleFig9f{stim},'FontSize',18);
        if saveFigs == true
            savefig(strcat(savePath, saveFig9f{stim}));
        end
        
    end
elseif totalStim ==1
    titleFig9f = {'Opto-index 100% visual stim. vs depth',...
    'Opto-index 50% visual stim. vs depth', ...
    'Opto-index 25% visual stim. vs depth', ...
    'Opto-index 12% visual stim. vs depth', ...
    'Opto-index 0% visual stim. vs depth'};

    saveFig9f = {'Optoindex100AmplDepth.fig', 'Optoindex50AmplDepth.fig','Optoindex25AmplDepth.fig','Optoindex12AmplDepth.fig','Optoindex0AmplDepth.fig'};
    for cond = (1:2:totalConds-2)
        figure
        ax = gca;
        hold on
        ind = ~isnan(OIndexAllStimAmpl((cond+1)/2,:));
        
        scatter(realDepthAll(ind)',OIndexAllStimAmpl((cond+1)/2,ind))
        xl= xlim;
        yl= ylim;
%         c = polyfit(realDepthAll(ind)',OIndexAllStimAmpl((cond+1)/2,ind),1);
        lm = fitlm(realDepthAll(ind),OIndexAllStimAmpl((cond+1)/2,ind));
        d = table2array(lm.Coefficients);
        c = flip(d(:,1))';
        text(xl(2)*0.9, yl(2)*0.9, ['y = ' num2str(round(c(1),4)) '*x + ' num2str(round(c(2),2))],'FontSize',18, 'HorizontalAlignment','right');
        text(xl(2)*0.9, yl(2)*0.8, ['R-sq = ' num2str(round(lm.Rsquared.Ordinary,2))],'FontSize',18, 'HorizontalAlignment','right');

        y_est = polyval(c, [xl(1) xl(2)]);
        % Add trend line to plot
        hold on
        plot(xl,y_est,'r--','LineWidth',2)
        hold off

        xlabel('Depth (um)');
        ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');

        set(ax,'FontSize',fs)
        title(titleFig9f{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        if saveFigs == true
            savefig(strcat(savePath, saveFig9f{(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig9f{(cond+1)/2}(1:end-3), 'png'));
        end
    end
end