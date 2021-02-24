%%% created by RB on 04.02.2021

% select only units with spontaneous firing rate above the threshold level
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; 
% for cond = 1: totalConds
%     for unit = find(iUnitsFilt&baseSelect)
%         [maxTraceFreqAll(cond, unit), maxIndTraceFreqAll(cond, unit)] = max(traceFreqAllMinusBase(cond, unit, searchMax));
%         maxIndTraceFreqAll(cond, unit) = maxIndTraceFreqAll(cond, unit) + searchMax(1)-1;
%         %             smoothMaxTraceFreqAll(cond, unit) = mean(mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit)-1:maxIndTraceFreqAll(cond,unit)+1))); % smooth over 3 points
%         smoothMaxTraceFreqAll(cond, unit) = mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit))); % just max
%     end
% end

normTraceFreqAllToAmpl100 = nan(totalConds,totalUnits, totalDatapoints);

for cond = 1:totalConds % normalize all traces from all conditions to the amplitude of the first vis resp in the 100% cond
    for unit = find(iUnitsFilt & baseSelect)
        normTraceFreqAllToAmpl100(cond, unit, :) = smoothTraceFreqAll(cond, unit,:)/allStimAmpl(1, unit,1);
    end
end

meanNormTraceFreqAllToAmpl100 = squeeze(nanmean(normTraceFreqAllToAmpl100,2)); % average over units

allStimAmplNorm100 = nan(size(allStimAmpl)); % cond, units, stim
for cond = 1:totalConds
    for unit = find(iUnitsFilt& baseSelect)
        for stim = 1:totalStim % ??? 2 calculations: hz values and normalized values
            % amplitude of each vis stim form the traces normalized to the first stim in 100% cond 
            allStimAmplNorm100(cond, unit, stim) = nanmean(normTraceFreqAllToAmpl100(cond, unit, (stim-1)*(3/bin)+amplInt(1):(stim-1)*(3/bin)+amplInt(2)),3);
            
        end
    end
end

%%
figure; %plots the averages of all conds normalized to 1st stim in the 1st cond
% for unit = find(iUnitsFilt & baseSelect)
%     plot(squeeze(normTraceFreqAllToAmpl100(1,unit,:))); hold on
% end   
for cond = 1:totalConds
    plot(meanNormTraceFreqAllToAmpl100(cond,:)); hold on
end    

%%
figure % plots1st vs 3rd stim in the control cond  
scatter(allStimAmplNorm100(1,:,1),allStimAmplNorm100(1,:,3));

%%
allStimMagn = allStimAmpl-allStimBase;

magnCondDiff = nan(totalConds/2, totalUnits, totalDatapoints);

for cond = 1:totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        % subtract S from V or Sph from Vph
        magnCondDiff(cond, unit, :) = smoothTraceFreqAll(cond, unit,:)-smoothTraceFreqAll(totalConds-mod(cond,2), unit,:);
    end
end
meanMagnCondDiff = nanmean(magnCondDiff,2);

figure;

% for cond = 1:totalConds-2
%     plot(meanMagnCondDiff(cond,:)); hold on
% end   
plot(meanMagnCondDiff(1,:), 'Color', 'k', 'LineWidth', 3); hold on
plot(meanMagnCondDiff(2,:), 'Color', 'b', 'LineWidth', 3); 

%% not modified:
% Analysis Fig. 6b (1x)  - normalized amplitude to the first stim amplitude in the same non photostim cond 
%%%%% !!!! needs double checking !!!! %%%%%%
% Normalized amplitude calculations : select first line or the next ones 
if totalStim ==6
    normAllStimAmpl100 = allStimAmplNormTrace; % normalize to first stim in the same non-photostim cond
elseif totalStim == 1
    normAllStimAmpl100 = allStimAmplNormTrace100;
end    
% normAllStimAmpl100 = nan(totalConds, totalUnits, totalStim)
% for cond = 1:totalConds-2
%     for unit = find(iUnitsFilt)
%         for stim = 1:totalStim
%             normAllStimAmpl100(cond, unit, stim) = allStimAmpl(cond, unit, stim)/allStimAmpl(1, unit,1); % normalize to first stim in first condition
%            
%         end
%     end
% end

% Calculate mean and STEM of normalized amplitude

meanNormAllStimAmpl100 = squeeze(nanmean(normAllStimAmpl100,2));
% if totalStim == 1 % Correction for normalization: maybe it can also be applied to P7 ? 
meanNormAllStimAmpl100 = meanNormAllStimAmpl100 /meanNormAllStimAmpl100(1);
normAllStimAmpl100 = normAllStimAmpl100 /meanNormAllStimAmpl100(1);
% end
    
    
for cond = 1:totalConds 
    for stim = 1:totalStim
        STEMnormAllStimAmpl100(cond, stim) = nanstd(normAllStimAmpl100(cond,:, stim))/sqrt(sum(~isnan(normAllStimAmpl100(cond,:, stim))));  
    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hNormAllStimAmpl100((cond+1)/2, stim), pNormAllStimAmpl100((cond+1)/2, stim)] =ttest(normAllStimAmpl100(cond,:, stim),normAllStimAmpl100(cond+1,:, stim)); % opt vs vis
        [pNormAllStimAmpl100W((cond+1)/2, stim), hNormAllStimAmpl100W((cond+1)/2, stim)] =signrank(normAllStimAmpl100(cond,:, stim),normAllStimAmpl100(cond+1,:, stim)); %  opt vs vis
    end
end

