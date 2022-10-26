%%% created by RB on 15.02.2022

% Fig 62d (12x): spectrogram of lfp  of a single band of two conds + their diff
if totalStim == 6
    titleFig62d = {'Diff and Spectrogram slow waves 100%', 'Diff and Spectrogram slow waves 0%',...
        'Diff and Spectrogram delta 100%','Diff and Spectrogram delta 0%','Diff and Spectrogram theta 100%',...
        'Diff and Spectrogram theta 0%','Diff and Spectrogram alpha 100%','Diff and Spectrogram alpha 0%',...
        'Diff and Spectrogram beta 100%', 'Diff and Spectrogram beta 0%','Diff and Spectrogram gamma 100%', 'Diff and Spectrogram gamma 0%'};

    saveFig62d = {'DiffAndSpectrogramSW100.fig','DiffAndSpectrogramSW0.fig','DiffAndSpectrogramDelta100.fig',...
        'DiffAndSpectrogramDelta0.fig','DiffAndSpectrogramTheta100.fig','DiffAndSpectrogramTheta0.fig',...
        'DiffAndSpectrogramAlpha100.fig','DiffAndSpectrogramAlpha0.fig','DiffAndSpectrogramBeta100.fig',...
        'DiffAndSpectrogramBeta0.fig','DiffAndSpectrogramGamma100.fig','DiffAndSpectrogramGamma0.fig'};
% elseif totalStim == 1
%     titleFig62d = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig62d = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
for freq = freqs    
    yl = [min(F(waveFreqInd_P{freq})) max(F(waveFreqInd_P{freq}))];

    for cond = 1:2:totalConds
        figure
        set(gcf, 'Renderer', 'Painters', 'Position', [680   558   560   480]);
        low = floor(min(min(min(10*log10(abs(P_all_mean(cond:cond+1,waveFreqInd_P{freq},:)))))));
        high= ceil(max(max(max(10*log10(abs(P_all_mean(cond:cond+1,waveFreqInd_P{freq},:)))))));
        
        subplot(3, 1, 1)
        ax = gca;
        surf(T,F(waveFreqInd_P{freq}),10*log10(abs(squeeze(P_all_mean(cond,waveFreqInd_P{freq},:)))),'edgecolor','none');
        ylim(yl);
        yf = 0.98;
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.95, 'ZData', [30 30]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0 0 0] ,'LineWidth',4);% Set properties of lines
            end
        end
        xlim(round([T(1), T(end)]))
        caxis([low high])
        colorbar('Ticks',[low high]);
        view(2)
%         grid off
        set(ax,'xtick',[]);
        set(ax,'ytick',[F(waveFreqInd_P{freq}(1)) F(waveFreqInd_P{freq}(end))]);
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        if ~saveFigs
            title(titleFig62d{(freq-1)*2+(cond+1)/2},'FontSize',18);
        end
        
        
        subplot(3, 1, 2)
        ax = gca;
        surf(T,F(waveFreqInd_P{freq}),10*log10(abs(squeeze(P_all_mean(cond+1,waveFreqInd_P{freq},:)))),'edgecolor','none');
        ylim(yl);
        yf = 0.98;

        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.95, 'ZData', [30 30]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0 0 0] ,'LineWidth',4);% Set properties of lines
            end
        end
        line(optStimCoords, [yl(2) yl(2)]*yf,[50 50], 'Color', [0.25 0.61 1], 'LineWidth', 2);
        xlim(round([T(1), T(end)]))
        caxis([low high])
%         colormap(jet)
        a = colorbar('Ticks',[low high]);
        a.Label.String = 'Power/Frequency (dB/Hz)';
        view(2)
%         grid off
        set(ax,'xtick',[]);
        set(ax,'ytick',[F(waveFreqInd_P{freq}(1)) F(waveFreqInd_P{freq}(end))]);
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        ylabel('Frequency (Hz)')
        zlabel('Frequency power')
        
        
        subplot(3, 1, 3)
        ax = gca;
        Z = smoothdata(10*(log10(abs(squeeze(P_all_mean(cond+1,waveFreqInd_P{freq},:))))-log10(abs(squeeze(P_all_mean(cond,waveFreqInd_P{freq},:))))),2,'movmean',sm_param);
        %%% modify here clipping vallues
        low = prctile(Z(:),20);
        high = prctile(Z(:),80);
        %%%%%
        surf(T,F(waveFreqInd_P{freq}),Z,'edgecolor','none');
        ylim(yl);
        yf = 0.99;
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.97, 'ZData', [30 30]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0 0 0.] ,'LineWidth',4);% Set properties of lines
            end
        end

       
        line(optStimCoords, [yl(2) yl(2)]*yf,[30 30], 'Color',[0.25 0.61 1], 'LineWidth', 2);
        xlim(round([T(1), T(end)]))
        caxis([round(low,2) round(high,2)])
%         colormap(jet)

        a = colorbar('Ticks',[round(low,2) round(high,2)]);
        a.Label.String = '\Delta Power/Frequency (dB/Hz)';
        
        view(2)
%         grid off
        set(ax,'ytick',[F(waveFreqInd_P{freq}(1)) F(waveFreqInd_P{freq}(end))]);
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        xlabel('Time (s)')

        zlabel('Frequency power')
                
        if saveFigs == true
            savefig(strcat(savePath, saveFig62d{(freq-1)*2+(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig62d{(freq-1)*2+(cond+1)/2}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig62d{(freq-1)*2+(cond+1)/2}(1:end-4)), 'epsc');
        end
    end
end