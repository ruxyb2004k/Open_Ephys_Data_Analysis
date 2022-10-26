%%% created by RB on 15.02.2022

% Fig 63 (12x): Trace depicting average spectrogram of lfp  of a single band
if totalStim == 6
    titleFig63 = {'Slow (< 1 Hz) 100%', 'Slow (< 1 Hz) 0%', 'Delta (1-4 Hz) 100%','Delta (1-4 Hz) 0%',...
        'Theta (5-8 Hz) 100%','Theta (5-8 Hz) 0%','Alpha (9-12 Hz) 100%','Alpha (9-12 Hz) 0%',...
        'Beta (13-30 Hz) 100%', 'Beta (13-30 Hz) 0%','Gamma (31-70 Hz) 100%', 'Gamma (31-70 Hz) 0%'};

    saveFig63 = {'TraceAvgSpSW100.fig','TraceAvgSpSW0.fig','TraceAvgSpDelta100.fig',...
        'TraceAvgSpDelta0.fig','TraceAvgSpTheta100.fig','TraceAvgSpTheta0.fig',...
        'TraceAvgSpAlpha100.fig','TraceAvgSpAlpha0.fig','TraceAvgSpBeta100.fig',...
        'TraceAvgSpBeta0.fig','TraceAvgSpGamma100.fig','TraceAvgSpGamma0.fig'};
% elseif totalStim == 1
%     titleFig63 = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig63 = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end

for freq = freqs
    for cond = 1:2:totalConds
        figure
        ax = gca;
        shadedErrorBar1(T,P_allWaveMean(cond,freq, :),STEM_P_allWave(cond,freq,:), {'LineWidth', 1,'Color', C(cond,:)}); hold on
        shadedErrorBar1(T,P_allWaveMean(cond+1,freq, :),STEM_P_allWave(cond+1,freq,:), {'LineWidth', 1,'Color', C(cond+1,:)}); hold on
        title(titleFig63{(freq-1)*2+(cond+1)/2},'FontSize',18);
        
        xlim(round([T(1), T(end)]))
        yl = ylim;
        ylim([yl(1), yl(2)*1.05]);
        h1 = line(optStimCoords, [yl(2) yl(2)]*1.05);
        set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
        
        visStimLine(:,1) = sessionInfo.preTrialTime +sessionInfo.visStim;
        visStimLine(:,2) = sessionInfo.preTrialTime +sessionInfo.visStim + sessionInfo.visStimDuration;
        if cond < totalConds-1
            for i = (1:numel(sessionInfo.visStim))
                h2 = line([visStimLine(i,1) visStimLine(i,2)], [yl(2) yl(2)]*1.03); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
            end
        end
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        box off
        xlabel('Time (s)')
        ylabel('Power/Frequency (dB/Hz)')
        if saveFigs == true
            savefig(strcat(savePath, saveFig63{(freq-1)*2+(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig63{(freq-1)*2+(cond+1)/2}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig63{(freq-1)*2+(cond+1)/2}(1:end-4)), 'epsc');
        end
    end
end

