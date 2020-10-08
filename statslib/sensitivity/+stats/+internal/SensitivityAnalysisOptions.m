classdef SensitivityAnalysisOptions
    %SensitivityAnalysisOptions for SensitivityAnalysis class
    %
    % OPTS = SensitivityAnalysisOptions('Method', METHODVALUE) sets the
    % 'Method', which can be any of:
    %    'Correlation', 'RankCorrelation', 'KendallCorrelation'
    %    'StandardizedRegression', 'RankStandardizedRegression'
    %    'PartialCorrelation', 'RankPartialCorrelation'.
    % Rank-based processing refers to sorting data in rank order before
    % performing analysis computations.  Kendall correlation refers to
    % computing rank-based correlation with Kendall's tau.
    %
    % The 'Method' can also be a function handle to a custom analysis
    % function.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (Dependent)
        Method   % <'Correlation'> | 'PartialCorrelation' | 'StandardizedRegression'
        %          Method may also be 'None'
    end
    
    properties
        ErrorOnWarning   % <true> | false
    end
    
    properties (Access = protected)
        Method_
        BuiltinMethods
        Version_
    end
    
    
    methods
        function this = SensitivityAnalysisOptions(varargin)
            % SENSITIVITYANALYSISOPTIONS Construct SensitivityAnalysisOptions
            %
            
            this.BuiltinMethods = {'Correlation', 'RankCorrelation', 'KendallCorrelation', ...
                'PartialCorrelation', 'RankPartialCorrelation', ...
                'StandardizedRegression', 'RankStandardizedRegression', ...
                'None'};
            
            this.Version_ = 1.1;
            
            if this.isEven(nargin)   % parameter name/value pairs
                % Parse inputs
                p = inputParser();
                addParameter(p, 'Method', 'Correlation', @this.checkMethod);
                addParameter(p, 'ErrorOnWarning', true, @this.checkLogicalCapable1x1);
                parse(p, varargin{:});
                
                % Validate and assign properties
                this.Method = p.Results.Method;
                this.ErrorOnWarning = p.Results.ErrorOnWarning;
                
            else
                msg_details = 'There must be an even number of inputs, in parameter name/value pairs.  Type "help stats.internal.SensitivityAnalysisOptions" for more information';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
        end
        
        % Property Methods for "Method"
        
        function value = get.Method(this)
            value = this.Method_;
        end
        
        function this = set.Method(this, inValue)
            %Validate input
            this.checkMethod(inValue);
            
            % Ensure in cell array
            if ~iscell(inValue)
                if isstring(inValue)
                    inValue = cellstr(inValue);
                else
                    inValue = {inValue};
                end
            end
            
            % Preallocate value as row
            n = numel(inValue);
            value = cell(1, n);
            
            % Each input should either be a built-in method or a handle to
            % a custom analysis function
            for ct = 1:numel(value)
                val = inValue{ct};
                %Accept string and store as character vector
                if isstring(val)
                    val = char(val);
                end
                
                % If there are multiple entries and one is 'None', just use
                % 'None' for the entire property
                if (n>1)  &&  ischar(val)  &&  strcmp('None', val)
                    warning(message('stats:sensitivity:general:warnJustUsingNone'));
                    this.Method_ = val;
                    return
                end
                
                %Store the method
                if isa(val, 'function_handle')
                    value{ct} = val;
                else
                    value{ct} = validatestring(val, this.BuiltinMethods);
                end
            end
            
            % If just 1 entry, extract from cell
            if numel(value) == 1
                value = value{1};
            end
            
            % Assign property
            this.Method_ = value;
        end
        
        % Property Methods for "ErrorOnWarning"
        
        function this = set.ErrorOnWarning(this, newValue)
            if ~this.isLogicalCapable1x1(newValue)
                msg_details = 'The ''ErrorOnWarning'' property must be a scalar logical (true or false).';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
            this.ErrorOnWarning = logical(newValue);
        end
    end
    
    methods (Access = protected)
        function checkMethod(this, value)
            % CHECKMETHOD Verify input is appropriate method Input must be
            % a character vector, string, function handle, or cell array of
            % those.  Text inputs must match built-in methods.
            %
            
            % Put in cell array
            if ~iscell(value)
                if isstring(value)
                    value = cellstr(value);
                else
                    value = {value};
                end
            end
            
            % Validate each entry
            for ct = 1:numel(value)
                val = value{ct};
                
                ok1 =  ischar(val) || isstring(val);
                ok2 =  isa(val, 'function_handle');
                ok  =  ok1  ||  ok2;
                if ~ok
                    error(message('stats:sensitivity:general:errSensAnalOpts_Method'));
                end
                % Work with strings as character vectors
                if isstring(val)
                    val = char(val);
                end
                
                % Verify that text inputs match built-in methods
                if ischar(val)
                    try
                        validatestring(val, this.BuiltinMethods);
                    catch
                        error(message('stats:sensitivity:general:errSensAnalOpts_MethodTxt', val));
                    end
                end
            end
        end
    end
    
    methods (Access = protected,  Static,  Sealed)
        function tf = isEven(n)
            % True for an even number
            tf =  (mod(n,2) == 0);
        end
        
        function checkLogicalCapable1x1(x)
            % Verify that input is logical, or numeric that can be used as logical
            ok1 = islogical(x)  &&  isscalar(x);
            ok2 = isnumeric(x)  &&  isscalar(x)  &&  ...
                ( (x==0)  ||  (x==1) );
            ok = ok1 || ok2;
            if ~ok
                error(message('stats:sensitivity:general:errNotLogicalCapable'));
            end
        end
        
        function tf = isLogicalCapable1x1(x)
            % Verify that input is logical, or numeric that can be used as logical
            ok1 = islogical(x)  &&  isscalar(x);
            ok2 = isnumeric(x)  &&  isscalar(x)  &&  ...
                ( (x==0)  ||  (x==1) );
            tf = ok1 || ok2;
        end
    end
    
    %Version support methods
    methods(Static)
        function obj = loadobj(SavedData)
            %LOADOBJ Load object
            %   Load object and convert from legacy format if necessary
            %
            if isstruct(SavedData) && ~isfield(SavedData,'Version_')
                SavedData = stats.internal.SensitivityAnalysisOptions.convertV1ToV1pt1(SavedData);
                obj = stats.internal.SensitivityAnalysisOptions('Method', SavedData.Method_);
            else
                obj = SavedData;
            end
        end
    end
    methods(Static, Access = protected)
        function SavedData = convertV1ToV1pt1(SavedData)
            %CONVERTV1ToV1pt1   Convert version 1.0 to version 1.1
            %
            
            %   In version 1.0 the object has a Method_ and MethodOptions_
            %   field.  In version 1.1 this information is consolidated
            %   into the Method_ field.
            %
            %   Examples:
            %
            %      Version 1.0
            %         Method_ = 'Correlation'
            %         MethodOptions_ = 'Linear'
            %      Version 1.1
            %         Method_ = {'Correlation'}
            %
            %      Version 1.0
            %         Method_ = 'Correlation'
            %         MethodOptions_ = 'Ranked'
            %      Version 1.1
            %         Method_ = {'RankCorrelation'}
            %
            %      Version 1.0
            %         Method_ = 'All'
            %         MethodOptions_ = 'AllApplicable'
            %      Version 1.1
            %         Method_ = {'Correlation', 'RankCorrelation',
            %            'KendallCorrelation', 'StandardizedRegression',
            %            'RankStandardizedRegression',
            %            'PartialCorrelation', 'RankPartialCorrelation'}
            %
            %      Version 1.0
            %         Method_ = 'None'   or   MethodOptions_ = 'None'
            %      Version 1.1
            %         Method_ = {'None'}
            %
            
            %Parse inputs
            m = SavedData.Method_;
            mo = SavedData.MethodOptions_;
            
            newMethod = stats.internal.SensitivityAnalysisOptions.makeMethod(m, mo);
            SavedData.Method_ = newMethod;
        end
    end
    
    methods (Static, Hidden)
        function newMethod = makeMethod(m, mo)
            %MAKEMETHOD Make method
            %   Given a Method m, and MethodOptions mo, as in version 1.0,
            %   creates Method in newer format, e.g. version 1.1
            %
            %   Examples:
            %
            %      Input
            %         Method = 'Correlation'
            %         MethodOptions = 'Linear'
            %      Output
            %         Method = {'Correlation'}
            %
            %      Input
            %         Method_ = 'Correlation'
            %         MethodOptions = 'Ranked'
            %      Output
            %         Method = {'RankCorrelation'}
            %
            %      Input
            %         Method = 'All'
            %         MethodOptions = 'AllApplicable'
            %      Output
            %         Method = {'Correlation', 'RankCorrelation',
            %            'KendallCorrelation', 'StandardizedRegression',
            %            'RankStandardizedRegression',
            %            'PartialCorrelation', 'RankPartialCorrelation'}
            %
            %      Input
            %         Method_ = 'None'   or   MethodOptions_ = 'None'
            %      Output
            %         Method = {'None'}
            %
            
            if ~iscell(m)
                m = {m};
            end
            if ~iscell(mo)
                mo = {mo};
            end
            
            %Handle case of 'None'
            if strcmp('None', m{1})  ||  strcmp('None', mo{1})
                newMethod = {'None'};
                return
            end
            
            % Check for license for Statistics and Machine Learning Toolbox
            haveStats = license('test','Statistics_Toolbox') && ~isempty(ver('stats'));
            
            %Determine all values for the Method
            A = m;
            allowable = {'Correlation', 'StandardizedRegression', 'PartialCorrelation'};
            if strcmp('All', A{1})
                if ~haveStats
                    allowable = {'Correlation', 'StandardizedRegression'};
                end
                B = allowable;
            else
                B = A;
            end
            
            %Determine all values for MethodOptions
            X = mo;
            Y = cell(1, numel(B)*3);   % preallocate space possibly needed
            Z = cell(1, numel(B)*3);
            idx = 1;
            for ct = 1:numel(B)
                b = B{ct};
                allowable = {'Linear', 'Ranked', 'Kendall'};
                for ctX = 1:numel(X)
                    x = X{ctX};
                    if strcmp(x, 'AllApplicable')
                        
                        if ~(strcmp('Correlation', b)  &&  haveStats)
                            allowable = {'Linear', 'Ranked'};
                        end
                        
                        for ctL = 1:numel(allowable)
                            Y{idx} = b;
                            Z{idx} = allowable{ctL};
                            idx = idx + 1;
                        end
                    else
                        if ~strcmp('Correlation', b)
                            allowable = {'Linear', 'Ranked'};
                        end
                        if ismember(x, allowable)
                            Y{idx} = b;
                            Z{idx} = x;
                            idx = idx + 1;
                        end
                    end
                end
            end
            
            %Remove empties
            Y(cellfun('isempty', Y)) = [];
            Z(cellfun('isempty', Z)) = [];
            
            %Combine Method and MethodOptions
            newMethod = cell(1, numel(Y));   % preallocate
            for ct = 1:numel(Y)
                y = Y{ct};
                z = Z{ct};
                switch z
                    case 'Linear'
                        prefix = [];
                    case 'Ranked'
                        prefix = 'Rank';
                    case 'Kendall'
                        prefix = 'Kendall';
                end
                newMethod{ct} = [prefix  y];
            end
        end
    end
end