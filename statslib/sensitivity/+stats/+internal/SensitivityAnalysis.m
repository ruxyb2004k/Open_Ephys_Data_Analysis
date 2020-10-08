classdef SensitivityAnalysis
    %SensitivityAnalysis Object for analyzing effects of inputs on outputs
    %
    %   SA = SensitivityAnalysis(MC) uses input MonteCarlo object MC.
    %
    %   SA = SensitivityAnalysis(X,Y) uses input tables X and Y.  X and Y
    %   must have the same number of rows.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (Dependent)
        MonteCarlo
        X
        Y
    end
    
    properties
        Options
        Notes
    end
    
    properties (Hidden)
        StopHandler   % can be set to a stats.internal.StopHandler object
        % object to manage requests to stop analysis
    end
    
    properties  (Access = protected)
        MonteCarlo_
        X_
        Y_
    end
    
    
    methods
        
        function this = SensitivityAnalysis(varargin)
            % SENSITIVITYANALYSIS Construct SensitivityAnalysis object
            if nargin==0
                % no operation
                
                
            elseif (nargin==1)  &&  ...   % MonteCarlo
                    this.isa1x1(varargin{1}, 'stats.internal.MonteCarlo')
                MC = varargin{1};
                this.MonteCarlo_ = MC;
                this.X_ = [];
                this.Y_ = [];
                
                
            elseif (nargin==2)  &&  ...   % X, Y
                    this.isaNonempty(varargin{1}, 'table')  &&  ...
                    this.isaNonempty(varargin{2}, 'table')  &&  ...
                    ( height(varargin{1}) == height(varargin{2}) )
                this.MonteCarlo_ = [];
                this.X_ = varargin{1};
                this.Y_ = varargin{2};
                
                
            else
                msg_details = 'Invalid inputs.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Set remaining properties
            this.Options = stats.internal.SensitivityAnalysisOptions;
            this.Notes = '';
            this.StopHandler = [];
        end
        
        
        %---------------------------------------------------
        
        
        % Property methods for MonteCarlo
        
        function value = get.MonteCarlo(this)
            value = this.MonteCarlo_;
        end
        
        function this = set.MonteCarlo(this, newMC)
            % Set MonteCarlo property and use its X and Y fields for the
            % SensitivityAnalysis object's X and Y fields
            if ~this.isa1x1(newMC, 'stats.internal.MonteCarlo')  &&  ...
                    ~isempty(newMC)
                msg_details = 'Invalid inputs.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            if isempty(this.MonteCarlo_)
                warning(message('stats:sensitivity:general:warnSensitivityAnalysisXandY_BeingOverwritten'));
                this.X_ = [];
                this.Y_ = [];
            end
            this.MonteCarlo_ = newMC;
        end
        
        
        % Property methods for X
        
        function value = get.X(this)
            % Get X from the MonteCarlo property's X, unless MonteCarlo is
            % empty
            if ~isempty(this.MonteCarlo_)
                value = this.MonteCarlo_.X;
            else
                value = this.X_;
            end
        end
        
        function this = set.X(this, newX)
            % Assign  data to the MonteCarlo property's X, unless
            % MonteCarlo is empty
            ok = false;
            if this.isaNonempty(newX, 'table')
                if isempty(this.Y)  ||  ...
                        ( height(newX) == height(this.Y) )
                    ok = true;
                end
            end
            if ~ok
                msg_details = 'Invalid inputs.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            % Set value in MonteCarlo, if it is not empty
            if ~isempty(this.MonteCarlo_)
                this.MonteCarlo_.X = newX;
            else
                this.X_ = newX;
            end
        end
        
        
        % Property methods for Y
        
        function value = get.Y(this)
            % Get Y from the MonteCarlo property's Y, unless MonteCarlo is
            % empty
            if ~isempty(this.MonteCarlo_)
                value = this.MonteCarlo_.Y;
                
            else
                value = this.Y_;
            end
        end
        
        function this = set.Y(this, newY)
            % Assign  data to the MonteCarlo property's X, unless
            % MonteCarlo is empty
            if ~this.isaNonempty(newY, 'table')  ||  ...
                    ~(height(newY) == height(this.X))
                msg_details = 'Invalid inputs.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            % Setting the value depends on whether MonteCarlo is empty
            if ~isempty(this.MonteCarlo_)
                try
                    this.MonteCarlo_.Y = newY;   % trap set of read-only property
                catch ME
                    rethrow(ME);
                end
            else   % MonteCarlo is empty
                this.Y_ = newY;
            end
        end
        
        
        % Property methods for Options
        
        function this = set.Options(this, newOptions)
            if ~this.isa1x1(newOptions, 'stats.internal.SensitivityAnalysisOptions')
                msg_details = 'Invalid inputs.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            this.Options = newOptions;
        end
        
        
        %---------------------------------------------------
        
        
        % Regular Methods
        
        function [data, evaluation] = analyze(this)
            % ANALYZE Sensitivity analysis computations
            %
            
            % Check if Evaluation of the model is necessary
            if ~isempty(this.MonteCarlo_)  &&  this.MonteCarlo_.EvaluateDirty
                switch this.Options.ErrorOnWarning
                    case true
                        msg_details = 'A new set of ''Y'' property values needs to be computed by evaluating the model.  Based on the setting of ''ErrorOnWarning'' in the ''Options'' property, an error is being thrown to prevent the ''Y'' values from being computed without being stored.  You can update the ''MonteCarlo'' property by running its evaluate method, and storing the result as the ''MonteCarlo'' property of the SensitivityAnalysis object.  Then you can call "analyze"';
                        error(message('stats:sensitivity:general:errUnexpected', msg_details));
                    case false
                        msg_details = 'The model is being evaluated to compute the ''Y'' property.  The ''MonteCarlo'' object, updated with the new ''Y'' values, is available as the third output argument.  It will not be stored, so subsequent analyses may need to reevaluate the model to compute ''Y''.  As an alternative, you can update the ''MonteCarlo'' property by running its evaluate method, and storing the result as the ''MonteCarlo'' property of the SensitivityAnalysis object.  Also, you can set ''ErrorOnWarning'' in the ''Options'' property so that an error occurs, rather than evaluating without storing the result.';
                        warning(message('stats:sensitivity:general:errUnexpected', msg_details));
                        this.MonteCarlo_ = evaluate(this.MonteCarlo_);   % compute Y
                        evaluation = this.MonteCarlo_;
                end
            else
                evaluation = [];
            end
            
            % Make sure X and Y are non-empty and compatible
            Xtbl = this.X;
            Ytbl = this.Y;
            if  isempty(Xtbl)  ||  isempty(Ytbl)  ||  ...
                    (height(Xtbl) ~= height(Ytbl))
                msg_details = 'The ''X'' and ''Y'' properties of the SensitivityAnalysis object must be non-empty, and must have the same number of rows.  Type "help stats.internal.SensitivityAnalysis" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            
            % Make sure there are more than 2 samples, for meaningful
            % analysis
            if height(Xtbl) <= 2
                error(message('stats:sensitivity:general:errAnalysis_TooFewSamples'));
            end
            
            % Extract list of analyses to be computed
            methodList = this.Options.Method;
            if ~iscell(methodList)
                methodList = {methodList};
            end
            
            % Make sure the method is not set to 'None'
            for ct = 1:numel(methodList)
                fcn = methodList{ct};
                if ischar(fcn)  &&  strcmp('None', fcn)
                    error(message('stats:sensitivity:general:errAnalysis_NoMethod'));
                end
            end
            
            % Compute each analysis
            data = cell(size(methodList));   % preallocate
            for ct = 1:numel(methodList)
                % Manage stop requests
                if ~isempty(this.StopHandler)
                    drawnow   % ensure that stop requests are processed
                    if this.StopHandler.StopRequested
                        break   % stop analysis computations
                    end
                end
                
                % Do analysis computation
                fcn = methodList{ct};
                if isa(fcn, 'function_handle')
                    % Custom analysis method
                    result = fcn(Xtbl, Ytbl);
                    % The output of the custom analysis function must be a
                    % table
                    if ~isa(result, 'table')
                        error(message('stats:sensitivity:general:errAnalysis_CustomFcnNotTable'));
                    end
                    if isempty(result.Properties.Description)
                        result.Properties.Description = func2str(fcn);
                    end
                else
                    % Built-in analysis method
                    hFcn = this.howCompute(fcn);
                    result = hFcn(Xtbl, Ytbl);
                end
                % Assign result for this analysis method
                data{ct} = result;
            end
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods (Static, Hidden)
        
        function CC = corr(X, Y, varargin)
            % CORR Linear and rank correlation coefficients between two tables.
            %
            %  CC = CORR(X,Y) computes pairwise linear correlation
            %  coefficients between input variables and model outputs.
            %
            %  RCC = CORR(X,Y,'type',TYPE) computes pairwise correlation
            %  coefficients of the type specified. Possible types are
            %  'Pearson' (default, linear), 'Spearman' (rank), or 'Kendall'
            %  (rank).
            %
            %  See also Sampling.sample, MonteCarlo.evaluate, partialcorr,
            %  stdregcoef
            
            % Determine type of correlation to compute
            if nargin >= 3
                input_type = varargin{1};
                valid_strings = {'Pearson', 'Spearman', 'Kendall'};
                idx = 3;
                type = validatestring(input_type, valid_strings, idx);
            else
                type = 'Pearson';
            end
            
            % Correlation coefficient matrix
            x = table2array(X);
            y = table2array(Y);
            nx = width(X);
            ny = width(Y);
            
            switch type
                case 'Pearson'
                    mtx = corrcoef([x y],  'rows', 'pairwise');
                    RHO = mtx(1:nx, end-ny+1:end);
                    desc = getString(message('stats:sensitivity:general:SensitivityAnalysis_CorrCoeff'));
                    
                case 'Spearman'
                    x = stats.internal.tie_rank(x);
                    y = stats.internal.tie_rank(y);
                    mtx = corrcoef([x y],  'rows', 'pairwise');
                    RHO = mtx(1:nx, end-ny+1:end);
                    desc = getString(message('stats:sensitivity:general:SensitivityAnalysis_RankCorrCoeff'));
                    
                case 'Kendall'
                    % Verify license for Statistics and Machine Learning Toolbox
                    if ~license('test','Statistics_Toolbox') || isempty(ver('stats'))
                        error(message('stats:sensitivity:general:errAnalysis_KendallCorr_StatsNoLicense'))
                    end
                    RHO = corr(x, y,  'type', type,  'rows', 'pairwise');
                    desc = getString(message('stats:sensitivity:general:SensitivityAnalysis_KendallCorrCoeff'));
            end
            
            % Construct output table
            CC = array2table(RHO, 'VariableNames', Y.Properties.VariableNames);
            CC.Properties.Description = desc;
            CC = localRemainingPropertiesTable(CC, X, Y);
        end
        
        
        function PCC = partialcorr(X, Y, varargin)
            % PARTIALCORR Linear and rank partial correlation coefficients
            % between two datasets.
            %
            %  PCC = PARTIALCORR(X,Y) computes pairwise linear partial
            %  correlation coefficients between input variables and model
            %  outputs.
            %
            %  PRCC = PARTIALCORR(X,Y,'type',TYPE) computes partial
            %  correlation coefficients of the type specified. Possible
            %  types are 'Pearson' (default, linear) or 'Spearman' (rank).
            %
            %  See also Sampling.sample, MonteCarlo.evaluate, corr, stdregcoef
            
            % Verify license for Statistics and Machine Learning Toolbox
            if ~license('test','Statistics_Toolbox') || isempty(ver('stats'))
                error(message('stats:sensitivity:general:errAnalysis_PartialCorr_StatsNoLicense'))
            end
            % Determine type of partial correlation to compute
            if nargin >= 3
                input_type = varargin{1};
                valid_strings = {'Pearson', 'Spearman'};
                idx = 3;
                type = validatestring(input_type, valid_strings, idx);
            else
                type = 'Pearson';
            end
            
            % Partial correlation coefficient matrix
            x = table2array(X);
            y = table2array(Y);
            RHO = partialcorri(y, x, 'type', type, 'rows', 'pairwise');
            RHO = transpose(RHO);   % format for output
            
            % Construct output table
            PCC = array2table(RHO, 'VariableNames', Y.Properties.VariableNames);
            PCC = localRemainingPropertiesTable(PCC, X, Y);
            
            % Include description of analysis type
            switch type
                case 'Pearson'
                    PCC.Properties.Description = getString(message('stats:sensitivity:general:SensitivityAnalysis_PartialCorrCoeff'));
                case 'Spearman'
                    PCC.Properties.Description = getString(message('stats:sensitivity:general:SensitivityAnalysis_RankPartialCorrCoeff'));
            end
            
        end
        
        function SRC = stdregcoef(X, Y, varargin)
            % STDREGCOEF Linear and rank standardized regression
            % coefficients between two datasets.
            %
            %  SRC = STDREGCOEF(X,Y) computes linear standardized
            %  regression coefficients between input variables and model
            %  outputs.
            %
            %  SRRC = STDREGCOEF(X,Y,'type',TYPE) computes standardized
            %  regression coefficients of the type specified. Possible
            %  types are 'Pearson' (default, linear) or 'Spearman' (rank).
            %
            %  See also Sampling.sample, MonteCarlo.evaluate, corr,
            %  partialcorr
            
            % Determine type of correlation to compute
            if nargin >= 3
                input_type = varargin{1};
                valid_strings = {'Pearson', 'Spearman'};
                idx = 3;
                type = validatestring(input_type, valid_strings, idx);
            else
                type = 'Pearson';
            end
            
            x = table2array(X);
            y = table2array(Y);
            if strcmp(type, 'Spearman')
                x = stats.internal.tie_rank(x);
                y = stats.internal.tie_rank(y);
            end
            
            % Regression coefficient matrix
            A = [ones(size(x,1),1) x];
            b = A\y;
            b = b(2:end,:); % b0 terms (i.e., first row of b) not needed.
            Sx = std(x);
            Sy = std(y);
            RHO = b.*repmat(Sx',size(Sy))./repmat(Sy,size(Sx'));
            
            % Construct output table
            SRC = array2table(RHO, 'VariableNames', Y.Properties.VariableNames);
            SRC = localRemainingPropertiesTable(SRC, X, Y);
            
            % Include description of analysis type
            switch type
                case 'Pearson'
                    SRC.Properties.Description = getString(message('stats:sensitivity:general:SensitivityAnalysis_StandardizedRegressionCoeff'));
                case 'Spearman'
                    SRC.Properties.Description = getString(message('stats:sensitivity:general:SensitivityAnalysis_RankStandardizedRegressionCoeff'));
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods (Access = protected,  Sealed)
        
        function f = howCompute(this, name)
            % Specify how to compute various analyses
            switch name
                
                %Correlation
                case 'Correlation',        f=@(X,Y) this.corr(X,Y);
                case 'RankCorrelation',    f=@(X,Y) this.corr(X, Y, 'Spearman');
                case 'KendallCorrelation', f=@(X,Y) this.corr(X, Y, 'Kendall');
                    
                    % Partial Correlation
                case 'PartialCorrelation',     f=@(X,Y) this.partialcorr(X,Y);
                case 'RankPartialCorrelation', f=@(X,Y) this.partialcorr(X, Y, 'Spearman');
                    
                    % Standardized Regression
                case 'StandardizedRegression',      f=@(X,Y) this.stdregcoef(X,Y);
                case 'RankStandardizedRegression',  f=@(X,Y) this.stdregcoef(X, Y, 'Spearman');
                    
            end
            
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    methods (Access = protected,  Static,  Sealed)
        function tf = isa1x1(value, type)
            % TF = isa1x1(VALUE, TYPE) checks whether VALUE is 1x1
            % instance of class is TYPE
            tf = isscalar(value)  &&  isa(value, type);
        end
        
        function tf = isaNonempty(value, type)
            % TF = isa1x1(VALUE, TYPE) checks whether VALUE is nonempty
            % instance of class is TYPE
            tf = ~isempty(value)  &&  isa(value, type);
        end
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function A = localRemainingPropertiesTable(A, X, Y)
% Fill in additional properties in table A, drawing on tables X and Y
A.Properties.VariableDescriptions = Y.Properties.VariableDescriptions;
A.Properties.VariableUnits = Y.Properties.VariableUnits;
A.Properties.DimensionNames = {'ParameterName', 'OutputName'};
A.Properties.RowNames = X.Properties.VariableNames;
end