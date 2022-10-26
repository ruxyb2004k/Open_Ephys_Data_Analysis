%%% created by RB on 10.02.2022

% Fig 60 (2x): FFT of lfp 
if totalStim == 6
    titleFig60a = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
    'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};

    saveFig60a = {'FFTsp100.fig','FFTsp0.fig'};
elseif totalStim == 1
    titleFig60a = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
    'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
    'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
    'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
    'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};

    saveFig60a = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
dpInt = (1:395);
dpInt = (1:595);


BonfCorrF = 1;
if applyBonfCorr %in case we don't use Bonf Corr, comment out the next line
    warning(['Bonferoni Correction applied']);
    BonfCorrF = size(waveFreq,1);
end

for cond = 1:2:totalConds
    figure; % one trace for each exp
    ax = gca;
    shadedErrorBar1(f(dpInt),P1_shortMeanAllMean(cond,dpInt),STEM_P1_shortMeanAll(cond,dpInt), {'LineWidth', 1,'Color', C(cond,:)}); hold on
    shadedErrorBar1(f(dpInt),P1_shortMeanAllMean(cond+1,dpInt),STEM_P1_shortMeanAll(cond + 1,dpInt), {'LineWidth', 1,'Color', C(cond+1,:)}); hold on
    title(titleFig60a{(cond+1)/2},'FontSize',18);
    xlabel('f (Hz)')
    ylabel('Norm. |P1(f)|')
    set(ax, 'TickDir', 'out');
    set(ax,'FontSize',fs*0.9)
    set(gca, 'YScale', 'log')
    yl = ylim;
    ylim([yl(1) yl(2)*1.2]);
    yl = ylim;
    xlim([0 70]);
    y = yl(2)*0.97;
    for freq = 1:size(waveFreq,1)
        p_temp =  pP1_shortMeanAllWave((cond+1)/2,freq);
        yf = 0.95;
        x = median(waveFreq(freq,:));
        xi = waveFreq(freq,1);
        xf = waveFreq(freq,2);
        if p_temp <= 0.001/BonfCorrF
            text(x, y,'***','FontSize',10, 'HorizontalAlignment','center');
            h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.01/BonfCorrF
            text(x, y,'**','FontSize',10, 'HorizontalAlignment','center');
            h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.05/BonfCorrF
            text(x, y,'*','FontSize',10, 'HorizontalAlignment','center');
            h1 = line([xi+0.5 xf-0.5],[y*yf y*yf]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        end
    end  
    box off
    
    if saveFigs == true
        savefig(strcat(savePath, saveFig60a{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig60a{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig60a{(cond+1)/2}(1:end-4)), 'epsc');
    end
end
