function [baseStim, baseDuration] = adjustBase(baseStim, bin, longBase)
if longBase
    if isequal(baseStim, [12 27 42 57 72 87]) % if visStim == [16,31,46,61,76,91], baseStim = [5,20,35,50,65,80]
        baseStim = [12 27 42 57 72 87]-7;
        baseDuration = 3/bin-1; % additional data points for baseline quantification (3 sec)
    elseif isequal(baseStim, [6, 12, 26])
        baseStim = [1, 12, 21];% modify baseStim to allow longer baseline quantification time
        baseDuration = 2/bin-1; % additional data points for baseline quantification (2 sec)
    elseif isequal(baseStim, [6, 12, 41])
        baseStim = [1, 12, 36];% modify baseStim to allow longer baseline quantification time
        baseDuration = 2/bin-1; % additional data points for baseline quantification (2 sec)
    end
elseif longBase == 0 % do the opposite of above
    if isequal(baseStim, [12 27 42 57 72 87]-7) 
        baseStim = [12 27 42 57 72 87];
    elseif isequal(baseStim, [1, 12, 21])
        baseStim = [6, 12, 26];
    elseif isequal(baseStim, [1, 12, 36])
        baseStim = [6, 12, 41];
    end
    baseDuration = 1/bin-1;
end    