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












