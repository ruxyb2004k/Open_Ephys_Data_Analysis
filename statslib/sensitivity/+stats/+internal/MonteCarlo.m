classdef MonteCarlo
    %MonteCarlo -- Object for evaluating samples in a model
    %
    %   MC = MonteCarlo(ModelFcn, ParameterNames, OutputNames)
    %
    %   MC = MonteCarlo(ModelFcn, nParameters, nOutputs)
    %       nParameters is the number of parameters in the model
    %       nOutputs is the number of model outputs
    %
    %   MC = MonteCarlo(ModelFcn, X, OutputNames)
    %      (note, the table X cannot be empty)
    %
    %   MC = MonteCarlo(ModelFcn, Sampling, OutputNames)
    %
    %   MC = MonteCarlo(ModelFcn, Sample, OutputNames)
    %
    %   When providing parameter names or output names, the names must be a
    %   character vector, or a cell array of character vectors of unique
    %   valid MATLAB variable names, and where the cell is one-dimensional,
    %   e.g. a row or column.  These are stored as a row in the MonteCarlo
    %   object.
    %
    %   To set the model function of an existing MonteCarlo object, use the
    %   setModel method.  Type "help stats.internal.MonteCarlo.setModel"
    %   for more information.
    %
    %   To evaluate the model, use the evaluate method.  Type help
    %   stats.internal.MonteCarlo.evaluate for more information.
    %
    
    %  Copyright 2013-2018 The MathWorks, Inc.
    
    properties (SetAccess = protected)
        ModelFcn
    end
    
    properties (Dependent)
        Sampling
        Sample
        X
    end
    
    properties  (SetAccess = protected)
        Y
    end
    
    properties (Dependent)
        OutputNames
    end
    
    properties (SetAccess = protected)
        YInfo
    end
    
    properties
        Options
        Notes
        EvaluateDirty
    end
    
    %-------------------------------------------------------
    
    properties (Hidden)
        DataUpdateHandler   % can be set to a stats.internal.DataUpdateHandler
        %                     object to manage data update events
        StopHandler   % can be set to a stats.internal.StopHandler object
        %               to manage requests to stop model evaluation
    end
    
    properties (Access = protected)
        Sampling_
        Sample_
        ParameterNames_
        OutputNames_
        SampleDirty_
        InputSize_
        OutputSize_
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods
        
        function this = MonteCarlo(varargin)   % Constructor
            % MonteCarlo constructs a MonteCarlo interface
            if nargin == 0
                % no operation
                
            elseif (nargin==3)  &&  ...   % ModelFcn, ParameterNames, OutputNames
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isTableVarNames(varargin{2})  &&  ...
                    this.isTableVarNames(varargin{3})
                this.ModelFcn = varargin{1};
                % Set Sampling and Sample properties
                Param_Names = varargin{2};
                Param_Names = this.ensureRowCellstr(Param_Names);
                this.Sampling_ = stats.internal.Sampling(Param_Names);
                this.Sample_ = [];
                this.SampleDirty_ = true;
                % Prepare output names
                Outp_Names = varargin{3};
                Outp_Names = this.ensureRowCellstr(Outp_Names);
                % Construct remaining properties
                this = constructRemainingProperties(this, Outp_Names);
                
                
            elseif (nargin==3)  &&  ...   % ModelFcn, nParameters, nOutputs
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isPosIntScalar(varargin{2})  &&  ...
                    this.isPosIntScalar(varargin{3})
                this.ModelFcn = varargin{1};
                % Set Sampling and Sample properties
                nParameters = varargin{2};
                this.Sampling_ = stats.internal.Sampling(nParameters);
                this.Sample_ = [];
                this.SampleDirty_ = true;
                % Prepare output names
                nOutputs = varargin{3};
                Outp_Names = this.namesCreate('Output_', (1:nOutputs));
                % Construct remaining properties
                this = constructRemainingProperties(this, Outp_Names);
                
                
                
                
                
                
            elseif (nargin==3)  &&  ...   % ModelFcn, X, OutputNames
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isaNonempty(varargin{2}, 'table')  &&  ...
                    this.isTableVarNames(varargin{3})
                this.ModelFcn = varargin{1};
                % Set Sampling and Sample properties
                this.Sampling_ = [];
                X = varargin{2};
                this.Sample_ = stats.internal.Sample(X);
                this.SampleDirty_ = false;
                % Prepare output names
                Outp_Names = varargin{3};
                Outp_Names = this.ensureRowCellstr(Outp_Names);
                % Construct remaining properties
                this = constructRemainingProperties(this, Outp_Names);
                
                
            elseif (nargin==3)  &&  ...   % ModelFcn, Sampling, OutputNames
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isa1x1(varargin{2}, 'stats.internal.Sampling')  &&  ...
                    this.isTableVarNames(varargin{3})
                this.ModelFcn = varargin{1};
                % Set Sampling and Sample properties
                this.Sampling_ = varargin{2};
                this.Sample_ = [];
                this.SampleDirty_ = true;
                % Prepare output names
                Outp_Names = varargin{3};
                Outp_Names = this.ensureRowCellstr(Outp_Names);
                % Construct remaining properties
                this = constructRemainingProperties(this, Outp_Names);
                
                
            elseif (nargin==3)  &&  ...   % ModelFcn, Sample, OutputNames
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isa1x1(varargin{2}, 'stats.internal.Sample')  &&  ...
                    this.isTableVarNames(varargin{3})
                this.ModelFcn = varargin{1};
                % Set Sampling and Sample properties
                this.Sample_ = varargin{2};
                this.Sampling_ = varargin{2}.Sampling;   % may or may not be empty
                this.SampleDirty_ = false;
                % Prepare output names
                Outp_Names = varargin{3};
                Outp_Names = this.ensureRowCellstr(Outp_Names);
                % Construct remaining properties
                this = constructRemainingProperties(this, Outp_Names);
                
                
            else
                msg_details = 'Invalid inputs.  Type "help stats.internal.MonteCarlo" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Property methods for Sampling
        
        function value = get.Sampling(this)
            value = this.Sampling_;
        end
        
        function this = set.Sampling(this, value)
            ok = this.isa1x1(value, 'stats.internal.Sampling')  &&  ...
                ( this.InputSize_ == numel(value.ParameterNames) );
            if ~ok
                msg_details = 'The ''Sampling'' property must be a 1x1 stats.internal.Sampling object with the same number of parameters as the MonteCarlo class.  Type "help stats.internal.MonteCarlo" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            this.Sampling_ = value;
            this.SampleDirty_ = true;
            % Check for and propagate new names
            newNames = value.ParameterNames;
            if this.checkNameChange(newNames, 'ParameterNames_')
                % Names are new, propagate them
                this.ParameterNames_ = newNames;
                this = updateNamesSample(this, newNames);
            end
        end
        
        
        % Property methods for Sample
        
        function value = get.Sample(this)
            value = this.Sample_;
        end
        
        function this = set.Sample(this, value)
            ok = this.isa1x1(value, 'stats.internal.Sample')  &&  ...
                ( this.InputSize_ == width(value.X) );
            if ~ok
                msg_details = 'The ''Sample'' property must be a 1x1 stats.internal.Sample object.  Type "help stats.internal.MonteCarlo" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            this.Sample_ = value;
            this.SampleDirty_ = false;
            this.EvaluateDirty = true;
            
            % Check for and propagate new names
            newNames = value.X.Properties.VariableNames;
            if this.checkNameChange(newNames, 'ParameterNames_')
                % Names are new, propagate them
                this.ParameterNames_ = newNames;
                this = updateNamesSampling(this, newNames);
            end
        end
        
        
        % Property methods for X
        
        function value = get.X(this)
            % X is dependent on Sample
            if ~isempty(this.Sample)   % use value from Sample
                value = this.Sample.X;
            else   % output empty table consistent with Sampling
                paramNames = this.Sampling.ParameterNames;
                value = this.emptyTable(paramNames);
            end
        end
        
        function this = set.X(this, value)
            ok = istable(value)  &&  ~isempty(value)  &&  ...
                ( this.InputSize_ == width(value) );
            if ~ok
                msg_details = 'The input must be a nonempty table, with the same number of columns as the number of parameters in the MonteCarlo object.  Type "help stats.internal.MonteCarlo" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            % Construct Sample, using the input value for X
            this.Sample_ = stats.internal.Sample(value);   % X is dependent
            this.SampleDirty_ = false;
            this.EvaluateDirty = true;
            % Check for and propagate new names
            newNames = value.Properties.VariableNames;
            if this.checkNameChange(newNames, 'ParameterNames_')
                % Names are new, propagate them
                this.ParameterNames_ = newNames;
                this = updateNamesSampling(this, newNames);
            end
        end
        
        
        % Property methods for OutputNames
        
        function value = get.OutputNames(this)
            value = this.OutputNames_;
        end
        
        function this = set.OutputNames(this, value)
            if ~iscell(value)  ||  ~this.isTableVarNames(value)  ||  ...
                    ~( this.OutputSize_ == numel(value) )
                msg_details = 'The input must be a cell array of character vectors of unique valid MATLAB variable names, and the number of character vectors must match the number of outputs in the MonteCarlo object.  Type "help stats.internal.MonteCarlo" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            value = reshape(value, 1, []);   % ensure row
            this.OutputNames_ = value;
            this.Y.Properties.VariableNames = value;
        end
        
        
        % Property methods for Options
        
        function this = set.Options(this, value)
            if ~this.isa1x1(value, 'stats.internal.MonteCarloOptions')
                msg_details = 'The class of the input must be stats.internal.MonteCarloOptions.  Type "help stats.internal.MonteCarlo" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            this.Options = value;
        end
        
        
        % Regular methods
        
        function this = evaluate(this)
            % EVALUATE -- Evaluate the model.
            %
            %    MC = evaluate(MC)
            %
            %    Results are stored in the MonteCarlo object's properties Y
            %    and YInfo.  Y is a table with evaluation results.  YInfo
            %    is a structure with the following fields:
            %
            %       Status:  Whether evaluations were successful or errored
            %
            %       Log:     Additional information that may be provided as
            %                a second output of the model function.  To use
            %                this, it is necessary to set the MonteCarlo
            %                object's ModelHasLogOutput option to true, in
            %                order for evaluation to capture the second
            %                output in the log.  Similarly, if the
            %                ModelHasLogOutput option is true, the model
            %                must have a second output.
            %
            %       Stats:   Timing information indicating how long
            %                evaluation took
            %
            if nargout == 0
                msg_details = 'The evaluate method should be called with an output argument.  Otherwise the result will be lost, because MonteCarlo is a value class.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Make sure the Sample property is up-to-date
            if this.SampleDirty_
                if isempty(this.Sample)
                    nSamples = 2*this.InputSize_ + 1;
                else
                    nSamples = height(this.X);
                end
                this.Sample_ = this.Sampling.sample(nSamples);
            end
            
            dOpt = this.Options.Display;
            logOpt = this.Options.ModelHasLogOutput;
            
            % Make a matrix of the generated values
            X_values = table2array(this.X);
            
            % Preallocate memory for output
            h = height(this.X);   % number of samples
            nTry = h;   % in case evaluation fails and options are to stop
            Ymat = NaN(h, this.OutputSize_);
            eLog = repmat({[]}, h, 1);   % evaluation log
            status = repmat({'did not run'}, h, 1);
            
            % Fill output, looping over rows of the generated values
            MdlFcn = this.ModelFcn;
            start_time = clock;
            switch this.Options.UseParallel
                case false   % Serial model evaluation
                    
                    for k = 1:h
                        
                        % Manage stop requests
                        if ~isempty(this.StopHandler)  && ...
                                this.StopHandler.StopRequested
                            break   % stop model evaluations
                        end
                        
                        xk = X_values(k,:);
                        [y, status{k}, eLog{k}] = localEvaluateModel(MdlFcn, xk, k, dOpt, logOpt);
                        if ~strcmp(y, 'error')
                            Ymat(k,:) = y;
                            % Manage data update event
                            manageDataUpdateEvent(this, xk, y, eLog{k}, k/h);
                        end
                        % Stop if there should have been 2 outputs but there was only 1
                        if isa(status{k}, 'MException')  &&  ...
                                strcmp('stats:sensitivity:general:errEvaluate_ExpectedLog', ...
                                status{k}.identifier)
                            throw(status{k})
                        end
                        % If evaluation errored, entire evaluation loop may
                        % stop, depending on option setting
                        if strcmp(this.Options.StopOnEvaluateError, 'stop')  ...
                                && isa(status{k}, 'MException')
                            nTry = k;
                            break   % stop model evaluations
                        end
                    end
                    
                case true   % Parallel model evaluation
                    % Verify license for Parallel Computing Toolbox
                    if ~license('test','Distrib_Computing_Toolbox') || isempty(ver('parallel'))
                        error(message('stats:sensitivity:general:errEvaluate_OptionsParallelNoLicense'))
                    end
                    
                    %Use parfeval loop to evaluate the model
                    ppool = gcp();
                    for k=h:-1:1
                        F(k) = parfeval(ppool, @localEvaluateModel, 3, MdlFcn, X_values(k,:), k, dOpt, logOpt);
                    end
                    more = true;
                    k = 0;
                    while ~all([F.Read]) && more
                        try
                            [idx, y_idx, status_idx, eLog_idx]  = fetchNext(F,1);
                        catch E
                            throw(E) %Should not happen as localEvaluateModel traps errors
                        end
                        if ~isempty(idx)
                            if ~strcmp(y_idx,'error')
                                Ymat(idx,:) = y_idx;
                                eLog{idx} = eLog_idx;
                                % Manage data update event
                                k = k+1; %Progress
                                manageDataUpdateEvent(this, X_values(idx,:), y_idx, eLog_idx, k/h);
                            end
                            status{idx} = status_idx;
                            % Stop if there should have been 2 outputs but there was only 1
                            if isa(status_idx, 'MException')  &&  ...
                                    strcmp('stats:sensitivity:general:errEvaluate_ExpectedLog', ...
                                    status_idx.identifier)
                                throw(status_idx)
                            end
                            % If evaluation errored, entire evaluation loop
                            % may stop, depending on option setting
                            if strcmp(this.Options.StopOnEvaluateError,'stop') && ...
                                    isa(status_idx,'MException')
                                nTry = sum([F.Read]);
                                more = false; %Stop model evaluations
                            end
                        end
                        %Manage stop requests
                        if ~isempty(this.StopHandler)  && ...
                                this.StopHandler.StopRequested
                            % Evaluation terminated by user. Cancel any
                            % pending parallel evaluations.
                            more = false;
                        end
                    end
                    cancel(F)
                    
            end
            end_time = clock;
            
            % Display message: model evaluation complete
            if any(strcmp(this.Options.Display, {'iter','final'}))
                disp( getString(message('stats:sensitivity:general:Evaluate_Completed',  ...
                    num2str(nTry) )) );
            end
            
            this.Y = array2table(Ymat, 'VariableNames', this.OutputNames_);
            
            % Return additional information about model evaluation
            this.YInfo.Status = status;
            this.YInfo.Log = eLog;
            this.YInfo.Stats.StartTime = start_time;
            this.YInfo.Stats.EndTime = end_time;
            
            this.EvaluateDirty = false;
        end
        
        
        function this = setModel(this, varargin)
            % setModel is the way to provide a new model function to a
            % Monte Carlo object.
            %
            % MC = setModel(MC, MODELFCN, PARAMETERNAMES, OUTPUTNAMES)
            % MC = setModel(MC, MODELFCN, NPARAMETERS, NOUTPUTS)
            
            
            if numel(varargin)==3  &&  ...   % ModelFcn, ParameterNames, OutputNames
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isTableVarNames(varargin{2})  &&  ...
                    this.isTableVarNames(varargin{3})
                this.ModelFcn = varargin{1};
                newParamNames = varargin{2};
                newParamNames = this.ensureRowCellstr(newParamNames);
                newOutpNames = varargin{3};
                newOutpNames = this.ensureRowCellstr(newOutpNames);
                
                
            elseif numel(varargin)==3  &&  ...   % ModelFcn, nParameters, nOutputs
                    this.isa1x1(varargin{1}, 'function_handle')  &&  ...
                    this.isPosIntScalar(varargin{2})  &&  ...
                    this.isPosIntScalar(varargin{3})
                this.ModelFcn = varargin{1};
                nParameters = varargin{2};
                nOutputs = varargin{3};
                newParamNames = this.namesCreate('Param_', (1:nParameters));
                newOutpNames = this.namesCreate('Output_', (1:nOutputs));
                
                
                
            else
                msg_details = 'Invalid inputs.  Type "help stats.internal.MonteCarlo.setModel" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Updates associated with model Parameters
            if numel(newParamNames) == this.InputSize_
                % The number of parameters has stayed the same.  Retain
                % previous values of Sample and Sampling, but check if
                % parameter names have changed, and update names.
                if this.checkNameChange(newParamNames, 'ParameterNames_')
                    % Names are new, propagate them
                    this.ParameterNames_ = newParamNames;
                    this = updateNamesSample(this, newParamNames);
                    this = updateNamesSampling(this, newParamNames);
                end
            else
                % The number of parameters has changed.  Reset Sample
                % and Sampling.
                this.ParameterNames_ = newParamNames;
                this.InputSize_ = numel(newParamNames);
                this.Sampling_ = stats.internal.Sampling(newParamNames);
                this.Sample_ = [];
            end
            
            % Updates associated with model Outputs
            this.OutputSize_ = numel(newOutpNames);
            this.OutputNames_ = newOutpNames;
            % Clear the output, since the model has been reset
            this.Y = this.emptyTable(newOutpNames);
            this.YInfo = [];
        end
        
        
        
        function this = sample(this, nSamples)
            % sample generates values from probability distributions
            %
            % aSample = sample(MC, NSAMPLES) generates NSAMPLES values
            % drawn from the probability distributions in the Sampling
            % property of the MonteCarlo object MC.  The Sampling property
            % must not be empty.
            
            % Check input number of samples
            if ~this.isPosIntScalar(nSamples)
                msg_details = 'The input for the number of samples should be a positive integer.  Type"help stats.internal.MonteCarlo.sample" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Check that Sampling is not empty
            if isempty(this.Sampling)
                msg_details = 'The ''Sampling'' property of the MonteCarlo object must not be empty.  Type"help stats.internal.MonteCarlo.sample" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Generate values
            this.Sample = this.Sampling.sample(nSamples);
            this.SampleDirty_ = false;
        end
        
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access = public, Hidden = true)
        function this = setY(this,y,yinfo)
            %SETY
            %
            %   obj = setY(obj,y,info)
            %
            %   Hidden method to set the Y and YInfo properties. This is
            %   used by clients that want to set these properties without
            %   having to call the evaluate() method.
            %
            
            this.Y = y;
            this.YInfo = yinfo;
        end
    end    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods (Access = private)
        function this = constructRemainingProperties(this, Outp_Names)
            % Construct remaining properties for parameters
            if ~isempty(this.Sample)   % use Sample for parameter names
                this.ParameterNames_ = this.Sample.X.Properties.VariableNames;
            else   % use Sampling for parameter names
                this.ParameterNames_ = this.Sampling.ParameterNames;
            end
            this.InputSize_ = numel(this.ParameterNames_);
            % Properties remaining properties for outputs
            this.OutputNames_ = Outp_Names;
            this.Y = this.emptyTable(Outp_Names);
            this.YInfo = [];
            this.OutputSize_ = numel(Outp_Names);
            % Construct remaining properties
            this.Options = stats.internal.MonteCarloOptions();   % default options
            this.Notes = '';
            this.EvaluateDirty = true;
            this.DataUpdateHandler = [];
            this.StopHandler = [];
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods (Access = protected)
        function manageDataUpdateEvent(this, X, Y, eLog, p)
            % Manage data update events during model evaluation
            if ~isempty(this.DataUpdateHandler)
                Data = struct('X', X,  'Y', Y, 'Log', eLog, 'Progress', p);
                eventData = stats.internal.GenericEventData(Data);
                notify(this.DataUpdateHandler, 'NewData', eventData);
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods (Access = protected, Sealed)
        
        function tf = checkNameChange(this, newValue, propertyName)
            tf = false;
            if ~all( strcmp(newValue, this.(propertyName)) )
                tf = true;
                % Either warn or throw error, depending on options setting
                msg_details = 'The parameter names entered are different from the previous names.  The new names are being used.';
                if strcmp('Yes', this.Options.ErrorOnWarning)
                    error(message('stats:sensitivity:general:errUnexpected', msg_details));
                else
                    warning(message('stats:sensitivity:general:errUnexpected', msg_details));
                end
            end
        end
        
        function this = updateNamesSample(this, newNames)
            % Update names in Sample property
            if ~isempty(this.Sample_)
                % Obtain properties
                X_val        = this.Sample_.X;
                Sampling_val = this.Sample_.Sampling;
                Notes_val    = this.Sample_.Notes;
                % Update names
                X_val.Properties.VariableNames = newNames;
                Sampling_val.ParameterNames = newNames;
                % Form new Sample and assign
                newSample = stats.internal.Sample(X_val, Sampling_val);
                newSample.Notes = Notes_val;
                this.Sample_ = newSample;
            end
        end
        
        function this = updateNamesSampling(this, newNames)
            % Update names in Sampling property
            if ~isempty(this.Sampling_)
                this.Sampling_.ParameterNames = newNames;
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods (Access = protected,  Static,  Sealed)
        
        function tf = isa1x1(value, type)
            % TF = isa1x1(VALUE, TYPE) checks whether VALUE is 1x1
            % instance of class TYPE
            tf = isscalar(value)  &&  isa(value, type);
        end
        
        function tf = isaNonempty(value, type)
            % TF = isa1x1(VALUE, TYPE) checks whether VALUE is nonempty
            % instance of class is TYPE
            tf = ~isempty(value)  &&  isa(value, type);
        end
        
        function tf = isTableVarNames(x)
            % Check whether input is a valid set of variable names for a
            % table.  The input may be a character vector or cell array of
            % character vectors.  The character vectors must be unique
            % valid MATLAB variable names.  If there are multiple character
            % vectors, they must be in a cell array where the cell is
            % one-dimensional, e.g. a row or column.
            
            tf =  ischar(x) && isvarname(x);
            tf = tf  ||  ...
                ( iscellstr(x)  &&  isvector(x)  &&  ...
                (numel(x) == numel(unique(x)))  &&  ...
                all(cellfun(@(c) isvarname(c), x))  );
        end
        
        function X = ensureRowCellstr(X)
            % Ensure that X is a row of cell of character vectors 
            % For example, converts X from a column to a row
            if ~iscell(X)
                X = {X};
            end
            X = reshape(X, 1, []);   % ensure cell is a row
        end
        
        function tf = isPosIntScalar(x)
            tf = isnumeric(x)  &&  isscalar(x)  &&  isreal(x)  &&  ...
                (x >= 1)  &&  (mod(x,1)==0);
        end
        
        function t = emptyTable(varNames)
            % Make an empty table with specified variable names
            empty_args = repmat( {[]}, 1, numel(varNames));
            t = table(empty_args{:}, 'VariableNames', varNames);
        end
        
        function names = namesCreate(prefix, numbers)
            % Create names in cell array
            % prefix -- a character vector
            % numbers -- a vector of non-negative integers
            numbers = reshape(numbers, 1, []);   % ensure row
            names = arrayfun( @(x) sprintf([prefix '%d'], x),  numbers,  ...
                'UniformOutput', false );
        end
        
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y, status, eLog] = localEvaluateModel(MdlFcn, xk, k, dOpt, logOpt)

% Evaluate model
try
    %Receive output from model evaluation.  There should be two outputs if
    %the option to return a log output is true.
    if logOpt
        [y, eLog] = MdlFcn(xk);
    else
        y = MdlFcn(xk);
        eLog = [];
    end
    if all(isnan(y))
        status = 'failure';
        if strcmp(dOpt, 'iter')
            fprintf('Model evaluation returned all NaN at sample element %d.\n', k);
        end
    else
        status = 'success';
        if strcmp(dOpt, 'iter')
            fprintf('Model evaluated at sample element %d.\n', k);
        end
    end
catch E   % error in model evaluation
    y = 'error';
    % Check if there should have been 2 outputs but there was only 1.
    % This can happen if the function is:              y = ModelFcn(...
    % or only varargout{1} is assigned for:    varargout = ModelFcn(...
    if strcmp('MATLAB:TooManyOutputs', E.identifier)  || ...
            strcmp('MATLAB:unassignedOutputs', E.identifier)
        status = MException('stats:sensitivity:general:errEvaluate_ExpectedLog', ...
            getString(message('stats:sensitivity:general:errEvaluate_ExpectedLog')) );
    else
        status = E;
    end
    eLog = [];
    if strcmp(dOpt, 'iter')
        fprintf('Model evaluation failed at sample element %d.\n', k);
    end
end
end
