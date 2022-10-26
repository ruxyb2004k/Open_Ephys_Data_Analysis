% Created by RB on ~ 02.2022
% Old - now replaced by analysis of P1_shortMean, P1_shortLast3Mean, P1_shortVisOptStimMean
% % spectrogram of all units during the photostimulated time interval
% 
% optStimAndVisCoords = sessionInfo.preTrialTime + sessionInfo.visStim(2:4); 
% 
% % entire photostim time
% % T_optStimInt = find(T == optStimCoords(1)):find(T == optStimCoords(2)); %
% 
% % T_optStimInt = (1118:1618); % part of the photostim time
% 
% % one sec after the vis stim during photostim
% T_optStimInt = [find(T == optStimAndVisCoords(1)):find(T == (optStimAndVisCoords(1)+1)), ...     
%     (1143:1268),...   %find(T == optStimAndVisCoords(2)):find(T == (optStimAndVisCoords(2)+1)), ...
%     find(T == optStimAndVisCoords(3)):find(T == (optStimAndVisCoords(3)+1))];
% 
% % spectrum of freq in the selected time range - selected channel only
% P_all_optStimInt = squeeze(mean(P_all(:,:,:, T_optStimInt),4));
% 
% smooth_param = 1;
% l = 0; % lower limit rescale
% u = nan(size(selChExp));
% % mean over all exp
% P_all_optStimInt_scaled = nan(size(P_all_optStimInt));
% 
% for exp = 1:size(P_all_optStimInt,1)
%     for cond = 1: size(P_all_optStimInt, 2)
%         if cond == 1
%             u(exp) = max(smooth(squeeze(P_all_optStimInt(exp,cond,:)), smooth_param));
%         end    
%         P_all_optStimInt_scaled(exp, cond, :) = smooth(squeeze(P_all_optStimInt(exp,cond,:)), smooth_param)/ u(exp); % channels, conds, freq
%         % not scaled
% %         P_all_optStimInt_scaled(exp, cond, :) = smooth(squeeze(P_all_optStimInt(exp,cond,:)), smooth_param); % channels, conds, freq
% 
%         %         figure;
% %         plot(squeeze(P_all_optStimInt_scaled(exp, cond, :)));
%     end
% end
% 
% % cond = 4;
% % dpInt = (1:45);
% % figure; % one trace for each exp
% % for i = 1: size(P_all_optStimInt_scaled,1)
% %     plot(F(dpInt),smooth(squeeze(P_all_optStimInt_scaled(i, cond, dpInt)),1)); hold on
% % end
% % title('Single-Sided Amplitude Spectrum of X(t)')
% % xlabel('f (Hz)')
% % ylabel('|P1(f)|')
% 
% 
% % average of the spectrogram over the photostimulated duration
% % after scaling teh individual experiments, there is a similar effect to
% % the P1 FFT
% 
% 
% P_all_optStimIntMean = squeeze(mean(P_all_optStimInt_scaled,1));
% 
% 
% STEM_P_all_optStimInt = nan(size(P_all_optStimIntMean));
% 
% for cond = 1 : totalConds
%     for datapoint = 1:size(P_all_optStimIntMean,2)
%         STEM_P_all_optStimInt(cond, datapoint) = nanstd(P_all_optStimInt_scaled(:, cond, datapoint))/sqrt(sum(~isnan(P_all_optStimInt_scaled(:, cond, datapoint))));
%     end 
% end
% 
% cond = 1;
% dpInt = (1:45);
% figure; % one trace for each exp
% % plot(F(dpInt),smooth(P_all_optStimIntMean_scaled(cond, dpInt),1)); hold on
% % plot(F(dpInt),smooth(P_all_optStimIntMean_scaled(cond+1, dpInt),1));
% shadedErrorBar1(F(dpInt),P_all_optStimIntMean(cond,dpInt),STEM_P_all_optStimInt(cond,dpInt), {'LineWidth', 1,'Color', C(cond,:)}); hold on
% shadedErrorBar1(F(dpInt),P_all_optStimIntMean(cond+1,dpInt),STEM_P_all_optStimInt(cond + 1,dpInt), {'LineWidth', 1,'Color', C(cond+1,:)}); hold on
% 
% 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

