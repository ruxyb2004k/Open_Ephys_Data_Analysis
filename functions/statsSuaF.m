%% Created by RB on 24.07.2020

% Stats max 
hSua = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
pSua = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
pSuaW = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
hSuaW = nan(totalConds/2,numel(statsCodesInd),numel(stimTime));
keepTrials = false(totalTrials,numel(statsCodesInd));

for code = (1:numel(statsCodesInd))
    keepTrials(:,code) = squeeze(mean(mean(traceByTrial(:, statsCodesInd(code),:,:)),4))>0;
end   

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(statsCodesInd)) % for all selected good codes         
        for time = (1:numel(stimTime))
            [hSua((cond+1)/2, code, time),pSua((cond+1)/2, code, time)] = ttest( maxTraceByTrial(cond, statsCodesInd(code), keepTrials(:,code), time), maxTraceByTrial(cond+1, statsCodesInd(code), keepTrials(:,code), time));
            [pSuaW((cond+1)/2,code, time),hSuaW((cond+1)/2,code, time)] = signrank(squeeze(maxTraceByTrial(cond, statsCodesInd(code), keepTrials(:,code), time)), squeeze(maxTraceByTrial(cond+1, statsCodesInd(code), keepTrials(:,code), time)));
        end
    end
end

% Stats baseline compared to same time in control cond
hSuaBase = nan(totalConds/2,numel(statsCodesInd),numel(baseTime));
pSuaBase = nan(totalConds/2,numel(statsCodesInd),numel(baseTime));
pSuaBaseW = nan(totalConds/2,numel(statsCodesInd),numel(baseTime));
hSuaBaseW = nan(totalConds/2,numel(statsCodesInd),numel(baseTime));

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(statsCodesInd)) % for all selected good codes 
        for time = (1:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hSuaBase((cond+1)/2, code, time),pSuaBase((cond+1)/2, code, time)] = ttest( baselineByTrial(cond, statsCodesInd(code), keepTrials(:,code),time), baselineByTrial(cond+1, statsCodesInd(code), keepTrials(:,code),time));
            [pSuaBaseW((cond+1)/2,code, time),hSuaBaseW((cond+1)/2,code, time)] = signrank( squeeze(baselineByTrial(cond, statsCodesInd(code), keepTrials(:,code),time)), squeeze(baselineByTrial(cond+1, statsCodesInd(code), keepTrials(:,code),time)));
                        
        end       
    end    
end

% Stats baseline compared to first baseline, same cond
hSuaBaseSameCond = nan(totalConds,numel(statsCodesInd),numel(baseTime));
pSuaBaseSameCond = nan(totalConds,numel(statsCodesInd),numel(baseTime));
pSuaBaseSameCondW = nan(totalConds,numel(statsCodesInd),numel(baseTime));
hSuaBaseSameCondW = nan(totalConds,numel(statsCodesInd),numel(baseTime));
keepTrialsBase = false(totalConds,numel(statsCodesInd),totalTrials);

for cond = (1:totalConds) % for all conds
    for code = (1:numel(statsCodesInd)) % for all selected good codes 
        keepTrialsBase(cond,code,:) = squeeze(mean(traceByTrial(cond, statsCodesInd(code),:,:),4))>0;
        for time = (2:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            if sum( keepTrialsBase(cond,code,:)) ~= 0
                [hSuaBaseSameCond(cond, code, time),pSuaBaseSameCond(cond, code, time)] = ttest( baselineByTrial(cond, statsCodesInd(code), keepTrialsBase(cond,code,:),1), baselineByTrial(cond, statsCodesInd(code), keepTrialsBase(cond,code,:),time));
                [pSuaBaseSameCondW(cond,code, time),hSuaBaseSameCondW(cond,code, time)] = signrank( squeeze(baselineByTrial(cond, statsCodesInd(code), keepTrialsBase(cond,code,:),1)), squeeze(baselineByTrial(cond, statsCodesInd(code), keepTrialsBase(cond,code,:),time)));
            end       
        end    
    end
end    

% Stats baseline compared to first baseline in photostim combined conds 
hSuaBaseComb = nan(numel(statsCodesInd),numel(baseTime));
pSuaBaseComb = nan(numel(statsCodesInd),numel(baseTime));
pSuaBaseCombW = nan(numel(statsCodesInd),numel(baseTime));
hSuaBaseCombW = nan(numel(statsCodesInd),numel(baseTime));

for code = (1:numel(statsCodesInd)) % for all selected good codes
    for time = (2:numel(baseTime))
        % compare combined condition to first baseline in photostim combined cond 
        keepTrialsComb = squeeze(mean(traceByTrial(2:2:totalConds, statsCodesInd(code),:,:),4)>0)';
        keepTrialsComb = keepTrialsComb(:);
        tr1 = squeeze(baselineByTrial(2:2:totalConds, statsCodesInd(code), :,1))';
        tr2 = squeeze(baselineByTrial(2:2:totalConds, statsCodesInd(code), :,time))';
        tr1 = tr1(:);
        tr2 = tr2(:);    
        tr1 = tr1(keepTrialsComb);
        tr2 = tr2(keepTrialsComb);  
        [hSuaBaseComb(code, time),pSuaBaseComb(code, time)] = ttest(tr1, tr2);
        [pSuaBaseCombW(code, time),hSuaBaseCombW(code, time)] = signrank(tr1, tr2);
    end
end

