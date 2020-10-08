classdef Sample
    %SAMPLE -- Object containing sample values, and probability distributions
    %   S = sample(X) creates a Sample object containing the sample values
    %   in X.
    %
    %   S = sample(X, SAMPLING) creates a Sample object containing the
    %   sample values in X, and probability distributions in Sampling.  The
    %   number of parameters in X needs to be same as in Sampling.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties  (SetAccess = protected)
        X
        Sampling
    end
    
    properties
        Notes
    end
    
    
    methods
        
        function this = Sample(varargin)   % constructor
            switch nargin
                
                case 0
                    % no operation
                    
                case 1   % input is:  X
                    % Create a Sample object with sample values from X;
                    % Allows X decoupled from Sampling, e.g. for gridded sampling
                    X_value = varargin{1};
                    if isa(X_value, 'table')
                        this.X = X_value;
                    else
                        msg_details = 'Invalid input.  The first input should be a MATLAB table.  Type "help stats.internal.Sample" for more information.';
                        error(message('stats:sensitivity:general:errUnexpected', msg_details));
                    end
                    this.Sampling = [];
                    
                case 2   % inputs are:  X, Sampling
                    % Create a Sample object with sample values from X and
                    % probability distributions in Sampling
                    X_value = varargin{1};
                    Sampling_value = varargin{2};
                    % number of parameters in X needs to be same as in Sampling
                    if isa(X_value, 'table')  &&  ...
                            isa(Sampling_value, 'stats.internal.Sampling')  &&  ...
                            ( width(X_value) == numel(Sampling_value.ParameterNames) )  &&  ...
                            all(strcmp(X_value.Properties.VariableNames, Sampling_value.ParameterNames))
                        this.X = X_value;
                        this.Sampling = Sampling_value;
                    else
                        msg_details = 'Invalid input.  The first input should be a MATLAB table, and the second input should be an instance of the stats.internal.Sampling class.  In addition, the number of parameters in the inputs needs to be the same, and the variable names in the table need to match the ''ParameterNames'' in the ''Sampling'' input.  Type "help stats.internal.Sample" for more information.';
                        error(message('stats:sensitivity:general:errUnexpected', msg_details));
                    end
                    
                otherwise
                    msg_details = 'Invalid number of inputs.  There cannot be more than 2 inputs.  Type "help stats.internal.Sample" for more information.';
                    error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            this.Notes = '';
        end
        
    end
    
end