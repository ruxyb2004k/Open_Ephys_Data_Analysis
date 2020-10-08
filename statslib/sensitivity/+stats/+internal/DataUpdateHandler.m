classdef DataUpdateHandler < handle
    %DataUpdateHandler -- Manage data update events during model evaluation
    %
    %   DU = DataUpdateHandler()
    %
    %   This may be used by stats.internal.MonteCarlo to manage data update
    %   events during model evaluation.
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    events
        NewData
    end
    
end