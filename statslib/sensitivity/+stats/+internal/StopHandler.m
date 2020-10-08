classdef StopHandler < handle
    %StopHandler -- Manage requests to stop model evaluation or analysis
    %
    %   SH = StopHandler()
    %
    %   This may be used by stats.internal.MonteCarlo or
    %   stats.internal.SensitivityAnalysis to manage requests to
    %   stop model evaluation or analysis computation.
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties
        StopRequested = false;
    end
    
    methods
        function set.StopRequested(this, x)
            % Verify that input is logical, or numeric that can be used as
            % logical.  The input also must be scalar.
            ok1 = islogical(x)  &&  isscalar(x);
            ok2 = isnumeric(x)  &&  isscalar(x)  &&  ...
                ( (x==0)  ||  (x==1) );
            ok = ok1 || ok2;
            
            if ok
                this.StopRequested = logical(x);   % Set the value
            else
                error(message('stats:sensitivity:general:errStopHandler_StopRequestedInvalid'));
            end
            
        end
    end
end