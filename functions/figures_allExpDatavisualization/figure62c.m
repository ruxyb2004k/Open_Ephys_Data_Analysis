%%% created by RB on 15.02.2022

% Fig 62c (12x): Difference spectrogram of lfp  of a single band
if totalStim == 6
    titleFig62c = {'Diff Spectrogram slow waves 100%', 'Diff Spectrogram slow waves 0%',...
        'Diff Spectrogram delta 100%','Diff Spectrogram delta 0%','Diff Spectrogram theta 100%',...
        'Diff Spectrogram theta 0%','Diff Spectrogram alpha 100%','Diff Spectrogram alpha 0%',...
        'Diff Spectrogram beta 100%', 'Diff Spectrogram beta 0%','Diff Spectrogram gamma 100%', 'Diff Spectrogram gamma 0%'};

    saveFig62c = {'DiffSpectrogramSW100.fig','DiffSpectrogramSW0.fig','DiffSpectrogramDelta100.fig',...
        'DiffSpectrogramDelta0.fig','DiffSpectrogramTheta100.fig','DiffSpectrogramTheta0.fig',...
        'DiffSpectrogramAlpha100.fig','DiffSpectrogramAlpha0.fig','DiffSpectrogramBeta100.fig',...
        'DiffSpectrogramBeta0.fig','DiffSpectrogramGamma100.fig','DiffSpectrogramGamma0.fig'};
% elseif totalStim == 1
%     titleFig62c = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig62c = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
sm_param = 19;
for freq = freqs    
    yl = [min(F(waveFreqInd_P{freq})) max(F(waveFreqInd_P{freq}))];
    for cond = 1:2:totalConds
        figure
        set(gcf, 'Renderer', 'Painters');
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
                set(h2,'Color',[0.75 0.75 0.75] ,'LineWidth',4);% Set properties of lines
            end
        end

        title(titleFig62c{(freq-1)*2+(cond+1)/2},'FontSize',18);
        
        line(optStimCoords, [yl(2) yl(2)]*yf,[30 30], 'Color', 'w', 'LineWidth', 2);
        xlim(round([T(1), T(end)]))
        caxis([round(low,2) round(high,2)])
%         colormap(jet)

        a = colorbar('Ticks',[round(low,2) round(high,2)]);
        a.Label.String = '\Delta Power/Frequency (dB/Hz)';
        
        view(2)
        grid off
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        zlabel('Frequency power')
                
        if saveFigs == true
            savefig(strcat(savePath, saveFig62c{(freq-1)*2+(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig62c{(freq-1)*2+(cond+1)/2}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig62c{(freq-1)*2+(cond+1)/2}(1:end-4)), 'epsc');
        end
    end
end