%%% created by RB on 24.07.2020

% Stats max 
hMua = nan(totalConds/2,numel(statsCodesIndMua),numel(stimTime));
pMua = nan(totalConds/2,numel(statsCodesIndMua),numel(stimTime));
pMuaW = nan(totalConds/2,numel(statsCodesIndMua),numel(stimTime));
hMuaW = nan(totalConds/2,numel(statsCodesIndMua),numel(stimTime));
keepTrialsMua = false(totalTrials,numel(statsCodesIndMua));

for code = (1:numel(statsCodesIndMua))
    keepTrialsMua(:,code) = squeeze(mean(mean(traceByTrialMua(:, statsCodesIndMua(code),:,:)),4))>0;
end   

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(statsCodesIndMua)) % for all selected good codes         
        for time = (1:numel(stimTime))
            [hMua((cond+1)/2, code, time),pMua((cond+1)/2, code, time)] = ttest( maxTraceByTrialMua(cond, statsCodesIndMua(code), keepTrialsMua(:,code), time), maxTraceByTrialMua(cond+1, statsCodesIndMua(code), keepTrialsMua(:,code), time));
%             [pMuaW((cond+1)/2,code, time),hMuaW((cond+1)/2,code, time)] = signrank( squeeze(maxTraceByTrialMua(cond, statsCodesIndMua(code), keepTrialsMua(:,code), time)), squeeze(maxTraceByTrialMua(cond+1, statsCodesIndMua(code), keepTrialsMua(:,code), time)));
        end
    end
end

% Stats baseline compared to same time in control cond
hMuaBase = nan(totalConds/2,numel(statsCodesIndMua),numel(baseTime));
pMuaBase = nan(totalConds/2,numel(statsCodesIndMua),numel(baseTime));
pMuaBaseW = nan(totalConds/2,numel(statsCodesIndMua),numel(baseTime));
hMuaBaseW = nan(totalConds/2,numel(statsCodesIndMua),numel(baseTime));

for cond = (1:2:totalConds) % for all conds
    for code = (1:numel(statsCodesIndMua)) % for all selected good codes 
        for time = (1:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hMuaBase((cond+1)/2, code, time),pMuaBase((cond+1)/2, code, time)] = ttest( baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsMua(:,code),time), baselineByTrialMua(cond+1, statsCodesIndMua(code), keepTrialsMua(:,code),time));
%             [pMuaBaseW((cond+1)/2,code, time),hMuaBaseW((cond+1)/2,code, time)] = signrank( squeeze(baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsMua(:,code),time)), squeeze(baselineByTrialMua(cond+1, statsCodesIndMua(code), keepTrialsMua(:,code),time)));                        
        end       
    end    
end

% Stats baseline compared to first baseline, same cond
hMuaBaseSameCond = nan(totalConds,numel(statsCodesIndMua),numel(baseTime));
pMuaBaseSameCond = nan(totalConds,numel(statsCodesIndMua),numel(baseTime));
pMuaBaseSameCondW = nan(totalConds,numel(statsCodesIndMua),numel(baseTime));
hMuaBaseSameCondW = nan(totalConds,numel(statsCodesIndMua),numel(baseTime));
keepTrialsBaseMua = false(totalConds,numel(statsCodesIndMua),totalTrials);

for cond = (1:totalConds) % for all conds
    for code = (1:numel(statsCodesIndMua)) % for all selected good codes 
        keepTrialsBaseMua(cond,code,:) = squeeze(mean(traceByTrialMua(cond, statsCodesIndMua(code),:,:),4))>0;
        for time = (2:numel(baseTime))
            % compare conditions with photostim to conditions without photostim
            [hMuaBaseSameCond(cond, code, time),pMuaBaseSameCond(cond, code, time)] = ttest( baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsBaseMua(cond,code,:),1), baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsBaseMua(cond,code,:),time));
%             [pMuaBaseSameCondW(cond,code, time),hMuaBaseSameCondW(cond,code, time)] = signrank( squeeze(baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsBaseMua(cond,code,:),1)), squeeze(baselineByTrialMua(cond, statsCodesIndMua(code), keepTrialsBaseMua(cond,code,:),time)));                       
        end       
    end    
end

% Stats baseline compared to first baseline in photostim combined conds 
hMuaBaseComb = nan(numel(statsCodesIndMua),numel(baseTime));
pMuaBaseComb = nan(numel(statsCodesIndMua),numel(baseTime));
pMuaBaseCombW = nan(numel(statsCodesIndMua),numel(baseTime));
hMuaBaseCombW = nan(numel(statsCodesIndMua),numel(baseTime));


for code = (1:numel(statsCodesIndMua)) % for all selected good codes
    for time = (2:numel(baseTime))
        % compare combined condition to first baseline in photostim combined cond 
        keepTrialsCombMua = squeeze(mean(traceByTrialMua(2:2:totalConds, statsCodesIndMua(code),:,:),4)>0)';
        keepTrialsCombMua = keepTrialsCombMua(:);
        tr1 = squeeze(baselineByTrialMua(2:2:totalConds, statsCodesIndMua(code), :,1))';
        tr2 = squeeze(baselineByTrialMua(2:2:totalConds, statsCodesIndMua(code), :,time))';
        tr1 = tr1(:);
        tr2 = tr2(:);    
        tr1 = tr1(keepTrialsCombMua);
        tr2 = tr2(keepTrialsCombMua);  
        [hMuaBaseComb(code, time),pMuaBaseComb(code, time)] = ttest(tr1, tr2);
%         [pMuaBaseCombW(code, time),hMuaBaseCombW(code, time)] = signrank(tr1, tr2);
    end
end
