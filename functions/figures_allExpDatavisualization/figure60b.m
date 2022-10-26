%%% created by RB on 10.02.2022

% Fig. 60b (1x) : average normalized amplitude of lfp bands

if totalStim == 6
    titleFig60b = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.', 'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};

    saveFig60b = {'FFTsp100Bar.fig', 'FFTsp0Bar.fig'};
elseif totalStim == 1
%     titleFig60b = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.'};
% 
%     saveFig60b = {'FFTsp100Bar.fig'};
end

BonfCorrF = 1;
if applyBonfCorr %in case we don't use Bonf Corr, comment out the next line
    warning(['Bonferoni Correction applied']);
    BonfCorrF = size(waveFreq,1);
end

if totalStim == 6
    for cond = 1:2:totalConds
        figure; % one trace for each exp
        ax = gca;
        freqs = 1:size(waveFreq,1);
        xval = [freqs*2-1; freqs*2]+[0.2;-0.2];
        xval = xval(:);
        
        barYval = P1_shortMeanAllWaveMean(cond:cond+1,freqs);
        barYval = barYval(:);
        
        b60b =bar(xval, barYval(:), 'EdgeColor', 'none', 'BarWidth', 1); hold on
        b60b.FaceColor = 'flat';
        for i =1:2:12
            b60b.CData(i,:) = C(cond,:);
            b60b.CData(i+1,:) = C(cond+1,:);
        end
        errorbar(xval(1:2:end),barYval([1:2:numel(freqs)*2]),STEM_P1_shortMeanAllWave(cond,freqs), '.','Color', C(cond,:),'LineWidth', 2); hold on
        errorbar(xval(2:2:end),barYval([2:2:numel(freqs)*2]),STEM_P1_shortMeanAllWave(cond+1,freqs),'.','Color', C(cond+1,:),'LineWidth', 2); hold on
        
        for freq = freqs
            p_temp =  pP1_shortMeanAllWave((cond+1)/2, freq);
            y = max(max(P1_shortMeanAllWaveMean(:, freqs)+STEM_P1_shortMeanAllWave(:, freqs)))*1.1;
            yf = 0.95;
            x = find(freqs==freq)*2;
            if p_temp <= 0.001/BonfCorrF
                text(x-0.5, y*0.98,'***','FontSize',18, 'HorizontalAlignment','center');
                h1 = line([x-1 x],[y*yf y*yf]);
                set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
            elseif p_temp <= 0.01/BonfCorrF
                text(x-0.5, y*0.98,'**','FontSize',18, 'HorizontalAlignment','center');
                h1 = line([x-1 x],[y*yf y*yf]);
                set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
            elseif p_temp <= 0.05/BonfCorrF
                text(x-0.5, y*0.98,'*','FontSize',18, 'HorizontalAlignment','center');
                h1 = line([x-1 x],[y*yf y*yf]);
                set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
            end
            
        end
        
        ylabel('Norm. |P1(f)|')
        set(ax,'XLim',[0.4 numel(freqs)*2+0.6],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        set(ax,'xtick',(1.5:2:freqs(end)*2)) % set major ticks
        set(ax,'ytick',(0:0.2:1)) % set major ticks
        xticklabels({'slow waves', 'delta', 'theta', 'alpha', 'beta', 'gamma'})
        set(ax,'FontSize',fs*0.5)
        title(titleFig60b{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        box off
        
        if saveFigs == true
            savefig(strcat(savePath, saveFig60b{(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig60b{(cond+1)/2}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig60b{(cond+1)/2}(1:end-4)), 'epsc');
        end
        
        % Create table to save data
        stem = STEM_P1_shortMeanAllWave(cond:cond+1, freqs);
        stem = stem(:);
        pval = pP1_shortMeanAllWave((cond+1)/2, freqs);
        pval = [pval; nan(size(pval))];
        pval = pval(:);
        t_stats = table(barYval(:), stem, pval);
        
        if saveStats == true
            writetable(t_stats,strcat(savePath, saveFig60b{(cond+1)/2}(1:end-4), '_stats.xlsx'))
        end
        
        % for cond = 1:2:totalConds
        %     figure; % one trace for each exp
        %     ax = gca;
        %     shadedErrorBar1(f(dpInt),P1_shortMeanAllMean(cond,dpInt),STEM_P1_shortMeanAll(cond,dpInt), {'LineWidth', 1,'Color', C(cond,:)}); hold on
        %     shadedErrorBar1(f(dpInt),P1_shortMeanAllMean(cond+1,dpInt),STEM_P1_shortMeanAll(cond + 1,dpInt), {'LineWidth', 1,'Color', C(cond+1,:)}); hold on
        %     title('Single-Sided Amplitude Spectrum of X(t)')
        %     xlabel('f (Hz)')
        %     ylabel('Norm. |P1(f)|')
        %     set(ax, 'TickDir', 'out');
        %     set(ax,'FontSize',fs*0.9)
        %     set(gca, 'YScale', 'log')
        %     yl = ylim;
        %     y = yl(2)*0.97;
        %     for freq = 1:size(waveFreq,1)
        %         p_temp =  pP1_shortMeanAllWave((cond+1)/2,freq);
        %         yf = 0.95;
        %         x = median(waveFreq(freq,:));
        %         xi = waveFreq(freq,1);
        %         xf = waveFreq(freq,2);
        %         if p_temp <= 0.001/BonfCorrF
        %             text(x, y,'***','FontSize',14, 'HorizontalAlignment','center');
        %             h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
        %             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        %         elseif p_temp <= 0.01/BonfCorrF
        %             text(x, y,'**','FontSize',14, 'HorizontalAlignment','center');
        %             h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
        %             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        %         elseif p_temp <= 0.05/BonfCorrF
        %             text(x, y,'*','FontSize',14, 'HorizontalAlignment','center');
        %             h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
        %             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        %         end
        %     end
        %     box off
    end
elseif totalStim == 1

end


