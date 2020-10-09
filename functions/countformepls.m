%numcon = number of conditions per interval
%exclude = plots, not intervals, to be excluded (in random order)

function [subTrialsforAnalysis] = countformepls(subTrialsforAnalysis,numcon,exclude)
    if ~isempty(exclude)
        exclude = sort(exclude,'descend');
        %saving as much brainspace as possible!
        %Start deleting the bigger numbers first, so we won't have to take
        %previously deleted intervals into account.

        for i = 1:numel(exclude)
            if any(subTrialsforAnalysis(:) == exclude(i)) %check whether the given number is still present
                   delthisInterval = ((fix((exclude(i)-1)/numcon))*numcon+1); %this line sets the beginning fo the interval to be deleted
                   delthisInterval = [delthisInterval:(delthisInterval+(numcon-1))]; %now, also set the ending of the interval
                   subTrialsforAnalysis([delthisInterval])=[]; 
            end
        end
    end
end