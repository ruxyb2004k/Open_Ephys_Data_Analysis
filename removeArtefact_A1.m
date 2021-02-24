% remove false spikes resulting from photostimulation or trial onset
% made by RB on 11.07.2019

code = 8; % code to be modified
timeInterval = 10 + [0.0001 0.02];
spikesToRemove = 1; % in each trial, in this time interval
condsToModify = [2,4];%,6,8,10];%[1,2,4];

for condInt = condsToModify
    currentConName = conditionFieldnames{condInt}; % extract current condition name
    for trialInt = (1:totalTrials)
        tempArray = spikeTimes.(currentConName){trialInt};       
        spikesRemoved = 0;
        i = 1;
        while i <= size(tempArray,1) && spikesRemoved < spikesToRemove
            if tempArray(i,2) == code
                if tempArray(i,1)> timeInterval(1) && tempArray(i,1)< timeInterval(2)
                    condInt, trialInt, tempArray(i,1)
                    tempArray(i,:) = [];
                    spikesRemoved = spikesRemoved +1;
                else
                    i = i+1;
                end
            else
                i = i+1;
            end
        end    
        spikeTimes.(currentConName){trialInt} = tempArray;    
    end
end

        
spikeClusterData.spikeTimes = spikeTimes;
% RefPerAndFalsePos_A1
