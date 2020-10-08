classdef Sampling
	%Sampling Object for sampling multiple distributions.
	%   S = Sampling(NPARAM) creates a Sampling object, where the number of
	%   parameters is NPARAM
	%
	%   S = Sampling({'Param1', 'Param2', ...}) creates a Sampling object
	%   with parameters named 'Param1', 'Param2', etc.
	%
	%   S = Sampling(PD, OPTS) creates a Sampling object with probability
	%   distributions PD and options OPTS.  OPTS must be of type
	%   SamplingOptions.
	%
	%   See also sample, correlate, Sample, SamplingOptions, MonteCarlo,
	%   SensitivityAnalysis
	
	%  Copyright 2013-2018 The MathWorks, Inc.
	
	properties  (Dependent = true)
		ParameterNames
		ParameterDistributions
		RankCorrelation
		Options
	end
	
	properties
		Notes
	end
	
	properties  (Access = protected)
		ParameterNamesReadOnly_
		ParameterNames_
		ParameterDistributions_
		RankCorrelation_
		Options_
		Size_
	end
	
	
	methods
		
		function this = Sampling(varargin)  % Constructor
			
			% Parse inputs
			if nargin==0
				nParam = 0;
				this.ParameterNames_ = {};
				this.ParameterDistributions_ = repmat(...
					this.getDistributionDefault(), 1, nParam);
				
				
			elseif nargin==1   % Number of parameters, Names, or Distributions
				arg = varargin{1};
				
				if isnumeric(arg)   % Number of parameters
					if ~isscalar(arg)  ||  ~isreal(arg)  ||  ~(arg >= 1)  ||  ...
							~(mod(arg,1) == 0)
						msg_details = 'The input argument must be a real, positive, scalar integer.  Type "help stats.internal.Sampling" for more information.';
						error(message('stats:sensitivity:general:errUnexpected', msg_details));
					end
					
					% Populate parameter names and distributions
					nParam = arg;
					this.ParameterNames_ = this.defaultParamNames(1, nParam);
					this.ParameterDistributions_ = repmat(...
						this.getDistributionDefault(), 1, nParam);
					
					
				elseif ischar(arg) || iscellstr(arg)  || isstring(arg) || ... % Names of parameters
                        (iscell(arg) && all(cellfun(@(x) isstring(x),arg)))
                    if isstring(arg)
                        arg = cellstr(arg);
                    end
                    if iscell(arg) && ~iscellstr(arg)
                        arg = cellstr(arg);
                    end
                    arg = this.ensureCell(arg);
					arg = reshape(arg, 1, []);   % ensure row
					error(this.checkInputNames(arg));   % check input names
					
					% Populate parameter names and distributions
					this.ParameterNames_ = arg;
					nParam = numel(arg);
					this.ParameterDistributions_ = repmat(...
						this.getDistributionDefault(), 1, nParam);
                    
                elseif  isa(arg, 'prob.UnivariateDistribution')  &&  ...  % Distributions
						isvector(arg)  &&  ~isempty(arg)
					arg = reshape(arg, 1, []);   % ensure row
					% Populate parameter names and distributions
					this.ParameterDistributions_ = arg;
					nParam = numel(arg);
					this.ParameterNames_ = this.defaultParamNames(1, nParam);
					
					
				else
					msg_details = 'The input argument must be an integer, a character vector or cell array of character vectors, or an array of probability distributions.  Type "help stats.internal.Sampling" for more information.';
					error(message('stats:sensitivity:general:errUnexpected', msg_details));
				end
				
				
			else
				error(message('stats:sensitivity:general:errUnexpected',...
					['Invalid number of input arguments.  '  ...
					'Type "help stats.internal.Sampling" for more information.'] ));
			end
			
			% Set remaining properties
			this.RankCorrelation_ = [];
			this.Options = stats.internal.SamplingOptions();
			this.Notes = [];
			this.Size_ = nParam;
			this.ParameterNamesReadOnly_ = false;
		end
		
		
		%-------------------------------------------------------
		
		
		% Property methods: Parameter Names
		
		function value = get.ParameterNames(this)
			value = this.ParameterNames_ ;
		end
		
		function this = set.ParameterNames(this, newValue)
            if this.ParameterNamesReadOnly_
                error(message('stats:sensitivity:general:errSampling_SetProhibitedReadOnly', 'ParameterNames'));
            end
            if isstring(newValue)
                newValue = cellstr(newValue);
            end
            if iscell(newValue) && all(cellfun(@(x) isstring(x),newValue))
                newValue = cellstr(newValue);
            end
            if iscellstr(newValue)  &&  ...
                    all( cellfun( @(c) isvarname(c), newValue) )  &&  ...
                    (numel(newValue) == this.Size_ )  &&  ...
                    ( numel(unique(newValue)) == this.Size_ )
                
                this.ParameterNames_ = newValue;
                
            else
                msg_details = 'Invalid input.  Parameter names must be unique valid MATLAB variable names, consistent with the number of distributions, and also with the size of the ''RankCorrelation'' matrix if it is defined.  Type "help stats.internal.Sampling" for more information.';
                error(message('stats:sensitivity:general:errUnexpected', msg_details));
            end
		end
		
		
		% Property methods: Parameter Distributions
		
		function value = get.ParameterDistributions(this)
			value = this.ParameterDistributions_ ;
		end
		
		function this = set.ParameterDistributions(this, value)
			try
				this = setParameterDistributions(this, value);
			catch E
				rethrow(E);
			end
		end
		
		% Property methods: Rank Correlation
		
		function value = get.RankCorrelation(this)
			value = this.RankCorrelation_ ;
		end
		
		function this = set.RankCorrelation(this, newValue)
			try
				this = setRankCorrelation(this, newValue);
			catch E
				rethrow(E);
			end
		end
		
		% Property methods: Options
		
		function value = get.Options(this)
			value = this.Options_ ;
		end
		
		function this = set.Options(this, newValue)
			try
				this = setOptions(this, newValue);
			catch E
				rethrow(E);
			end
		end
		
		%-------------------------------------------------------
		
		
		% Regular Methods
		
		function aSample = sample(this, nSamples)
			% Populate table of random samples
			
			% Generate array of sample values
			switch this.Options.Method
				
				case 'random'
					A = this.random(this.ParameterDistributions_, nSamples);
                    if ~isempty(this.RankCorrelation_ )
                        % Impose correlation using Iman-Conover
                        A = this.correlate(A, this.RankCorrelation_);
                    end
                    
                case 'lhs'   % Latin hypercube design
                    % Generate LHS samples
                    A = this.lhsdesign(this.ParameterDistributions_, nSamples);
                    if ~isempty(this.RankCorrelation_ )
                        % Impose correlation using Iman-Conover
                        A = this.correlate(A, this.RankCorrelation_);
                    end
                    
                case 'sobol'
                    % Generate Sobol samples
                    A = this.sobol(this.ParameterDistributions_, nSamples, ...
                        this.Options.MethodOptions);
                    if ~isempty(this.RankCorrelation_ )
                        % Impose correlation using Iman-Conover
                        A = this.correlate(A, this.RankCorrelation_);
                    end
                    
                case 'halton'
                    % Generate Halton samples
                    A = this.halton(this.ParameterDistributions_, nSamples, ...
                        this.Options.MethodOptions);
                    if ~isempty(this.RankCorrelation_ )
                        % Impose correlation using Iman-Conover
                        A = this.correlate(A, this.RankCorrelation_);
                    end
                    
                case 'copula'
					if isempty(this.RankCorrelation)
						error(message('stats:sensitivity:general:errSampling_CopulaNoRankCorr'))
					else   % generate copula samples
						A = this.copula(this.ParameterDistributions_,  ...
							this.RankCorrelation, nSamples,  ...
							this.Options.MethodOptions);
					end
					
			end
			
			% Make a table, containing sample values
			X = array2table(A,  'VariableNames', this.ParameterNames_);
			
			% Make a Sample, containing sample values
			aSample = stats.internal.Sample(X, this);
		end
		
		
		function this = setDistribution(this, pID, distribution)
			% Set probability distributions of parameters
			%
			% S = setDistribution(S, P_NAME, DISTRIBUTION) sets the
			% parameter named P_NAME so that its distribution is
			% DISTRIBUTION.  P_NAME needs to be a parameter in Sampling
			% object S.
			%
			% S = setDistribution(S, P_IDX, DISTRIBUTION) sets the
			% parameter located at index P_IDX so that its distribution is
			% DISTRIBUTION.
			%
			% See also addParameter, removeParameter
			
			% Verify that the object is not empty
			if this.Size_ == 0
				error(message('stats:sensitivity:general:errUnexpected',  ...
					['Can not set distribution, there are no parameters '  ...
					'in the Sampling object.'] ));
			end
			
			% Check input
			if isnumeric(pID)  ...   % parameter index
					&&  isscalar(pID)  &&  isreal(pID)  &&  ...
					(pID >= 1)  &&  (pID <= this.Size_ )  &&  ...
					(mod(pID,1) == 0)
				idx = pID;
				
			elseif (ischar(pID)  || (isstring(pID) && isscalar(pID))) &&  ...   % parameter name
					any( strcmp(pID, this.ParameterNames) )
				idx = find( strcmp(pID, this.ParameterNames) );
				
			else
				msg_details = 'The parameter identifier must be either a character vector that matches the name of a parameter in the Sampling object, or a positive integer index between 1 and the number of parameters. Type "help stats.internal.Sampling.setDistribution" or "help stats.internal.Sampling" for more information.';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			
			% Set the distribution
			this.ParameterDistributions_(idx) = distribution;
		end
		
		
		function this = addParameter(this, varargin)
			% Add parameter to parameter list
			%
			% S = addParameter(S) adds a parameter to Sampling object S.
			%
			% S = addParameter(S, NAMES) adds parameters called NAMES to
			% Sampling object S.  NAMES may be a character vector for one
			% parameter, or a cell array of character vectors.
			%
			% S = addParameter(S, DISTRIBUTIONS) adds parameters with
			% probability distributions DISTRIBUTIONS to Sampling object S.
			% DISTRIBUTIONS may be a single distribution, or an array of
			% uni-variate distributions.
			%
			% S = addParameter(S, NAMES, DISTRIBUTIONS) adds parameters
			% called NAMES and probability distributions DISTRIBUTIONS to
			% Sampling object S.
			
			narg = numel(varargin);
			switch narg
				
				case 0   % 0 arguments - Use default name and distribution
					newNames = { ['Param_' num2str(this.Size_ + 1)] };
					newNames = matlab.lang.makeUniqueStrings(newNames, this.ParameterNames);   % ensure unique
					newDistribs = this.getDistributionDefault();
					
				case 1   % 1 argument - Either parameter names, or distributions
					arg = varargin{1};
					if ischar(arg) || iscellstr(arg) || isstring(arg) || ... % parameter names
                            (iscell(arg) && all(cellfun(@(x) isstring(x),arg)))
                        if isstring(arg)
                            arg = cellstr(arg);
                        end
                        if iscell(arg) && ~iscellstr(arg)
                            arg = cellstr(arg);
                        end
						arg = this.ensureCell(arg);
						arg = reshape(arg, 1, []);   % ensure row
						error( this.checkInputNames([arg, this.ParameterNames]) );
						newNames = arg;
						
						newDistribs = repmat(this.getDistributionDefault(),  ...
							1, numel(newNames) );
						
					elseif isa(arg, 'prob.UnivariateDistribution')   % distributions
						i1 = this.Size_ + 1;
						i2 = i1 + numel(arg) - 1;
						newNames = this.defaultParamNames(i1, i2);
						newNames = matlab.lang.makeUniqueStrings(newNames, this.ParameterNames);   % ensure unique
						newDistribs = arg;
						
					else
						
						msg_details = 'The input must be a character vector or cell array of character vectors of unique valid MATLAB variable names, or a probability distribution or array of uni-variate probability distributions.  Type "help stats.internal.Sampling.addParameter" for more information.';
						error(message('stats:sensitivity:general:errUnexpected', msg_details));
					end
					
					
				case 2   % 2 arguments - parameter names and distributions
					newNames = varargin{1};
					newDistribs = varargin{2};
					newNames = this.ensureCell(newNames);
					error( this.checkInputDims(newNames, newDistribs) );
					newNames = reshape(newNames, 1, []);   % ensure row
					error( this.checkInputNames([newNames, this.ParameterNames]) );
					
					
				otherwise
					error(message('stats:sensitivity:general:errUnexpected',...
						['Invalid number of input arguments.  '  ...
						'Type "help stats.internal.Sampling" for more information.'] ));
			end
			
			
			% Ensure dimensions conform for new entities
			newDistribs = reshape(newDistribs, 1, []);
			
			% Add new parameter names and distributions, and adjust
			% correlation matrix
			if this.Size_ == 0   % object is empty
				this.ParameterNames_ = newNames;
				this.ParameterDistributions_ = newDistribs;
				this.RankCorrelation_ = [];
				
			else   % object has contents
				this.ParameterNames_ = [this.ParameterNames_  newNames];
				i1 = this.Size_ + 1;
				i2 = i1 + numel(newDistribs) - 1;
				this.ParameterDistributions_(i1:i2) = newDistribs;
			end
			
			% Augment correlation matrix
			if ~isempty(this.RankCorrelation_ )
				% Notation:  Existing matrix is p x p
				%  There are q rows and columns to be added
				%  Final matrix is (p+q) x (p+q)
				p = size(this.RankCorrelation_, 1);
				q = numel(newNames);
				%
				right_part = zeros(p,q);
				bottom_part = zeros(q,p);
				bottom_full = [bottom_part  eye(q)];
				%
				i1 = this.Size_ + 1;
				i2 = i1 + numel(newNames) - 1;
				this.RankCorrelation_(:, i1:i2) = right_part;
				this.RankCorrelation_(i1:i2, :) = bottom_full;
			end
			
			this.Size_ = numel(this.ParameterNames_ );
		end
		
		
		function this = removeParameter(this, value)
			% Remove parameters from parameter list
			% S = removeParameter(S, ParamNames)
			% S = removeParameter(S, idx)
            
            if isstring(value)
                value = cellstr(value);
            end
            if (iscell(value) && all(cellfun(@(x) isstring(x),value)))
                value = cellstr(value);
            end
			
			if ischar(value) || iscellstr(value)   % names of parameters
				value = this.ensureCell(value);
				[tf, loc] = ismember(value, this.ParameterNames);
				if ~all(tf)   % check match to existing parameter names
					msg_details = 'All inputs need to match parameter names in the Sampling object.  Type "help stats.internal.Sampling.removeParameter" for more information.';
					error(message('stats:sensitivity:general:errUnexpected', msg_details));
				end
				iRemove = loc;   % indices to remove
				
			elseif isnumeric(value)   % indices of parameters
				if ~(...   % check index values
						isreal(value)  &&  all( mod(value,1) == 0 )  &&  ...
						all(value >= 1)  &&  all(value <= this.Size_ )  )
					msg_details = 'Each input index value must be a real, positive, integers, between 1 and the number of parameters in the Sampling object.  Type "help stats.internal.Sampling.removeParameter for more information.';
					error(message('stats:sensitivity:general:errUnexpected', msg_details));
				end
				iRemove = value;   % indices to remove
			else
				msg_details = 'The input did not match the expected format.  Type "help stats.internal.Sampling.removeParameter" for more information.';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			
			% Remove parameters and update properties
			iKeep = setdiff(1:this.Size_, iRemove);   % row of indices to keep
			this.ParameterNames_ = this.ParameterNames_(iKeep);
			this.ParameterDistributions_ = this.ParameterDistributions_(iKeep);
			if ~isempty(this.RankCorrelation_ )
				this.RankCorrelation_ = this.RankCorrelation_(iKeep, iKeep);
			end
			this.Size_ = numel(iKeep);
		end
		
	end
	
	
	%-------------------------------------------------------
	
	
	methods (Static, Hidden)
		
		function X = random(PD, varargin)
			% RANDOM Random number generation.
			%
			%  X = RANDOM(PD) generates a random sample drawn from the
			%  probability distributions in the array PD.
			%
			%  X = RANDOM(PD,N) generates a random sample of length N.
			%
			%  See also Sampling.lhsdesign, Sampling.copula
			
            if nargin > 1
                nSamples = varargin{1};
            else
                nSamples = 1;
            end
            
            % Generate samples
            Data = [];
            X = lGenerateSamples(PD, nSamples, @lRandom, Data);
		end
		
		
		function X = lhsdesign(PD, varargin)
			% LHSDESIGN Generate a latin hypercube sample.
			%
			%  X = LHSDESIGN(PD) generates a latin hypercube sample drawn
			%  from the probability distributions PD.
			%
			%  X = LHSDESIGN(PD,N) generates a latin hypercube sample of
			%  length N.
            %
            %  See also SamplingOptions, Sampling.random.
            
            if nargin > 1
                nSamples = varargin{1};
            else
                nSamples = 1;
            end
            
            Data = [];
            X = lGenerateSamples(PD, nSamples, @lLhsdesign, Data);
        end
		
        function X = sobol(PD, varargin)
            % SOBOL Generate a Sobol set.
            %
            %  X = SOBOL(PD) generates a Sobol set of samples drawn from
            %  the probability distributions PD.
            %
            %  X = SOBOL(PD, N) generates a Sobol set with N samples.
            %
            %  X = SOBOL(PD,...,OPTIONS) specifies additional options for the sampling
            %  algorithm. Use the SensitivityAnalysis.sampleOptions command to create the
            %  option set OPTIONS.
            % 
            %
            %  See also SamplingOptions, Sampling.random
            
            % Verify license for Statistics and Machine Learning Toolbox
            if ~license('test','Statistics_Toolbox') || isempty(ver('stats'))
                error(message('stats:sensitivity:general:errSample_SobolStatsNoLicense'))
            end
            
            % Look for number of samples
            if ~isempty(varargin)  &&  isnumeric(varargin{1})
                nSamples = varargin{1};
                varargin = varargin(2:end);
            else
                nSamples = 1;
            end
            
            % Set up Sobol set object
            nParams = numel(PD);
            sobolSet = sobolset(nParams);

            % Look for options
            if ~isempty(varargin)
                MethodOptions = varargin{1};
                sobolSet.Skip = MethodOptions.Skip;
                sobolSet.Leap = MethodOptions.Leap;
                sobolSet.ScrambleMethod = MethodOptions.ScrambleMethod;
                sobolSet.PointOrder = MethodOptions.PointOrder;
            end
            
            % Create Data to store state
            Data.qrObj = sobolSet;
            Data.nextSkip = sobolSet.Skip;
            
            X = lGenerateSamples(PD, nSamples, @lQuasiRandom, Data);
        end

        function X = halton(PD, varargin)
            % HALTON Generate a Halton set.
            %
            %  X = HALTON(PD) generates a Halton set of samples drawn from
            %  the probability distributions PD.
            %
            %  X = HALTON(PD, N) generates a Halton set with N samples.
            %
            %  X = HALTON(PD,...,OPTIONS) specifies additional options for the sampling
            %  algorithm. Use the SensitivityAnalysis.sampleOptions command to create the
            %  option set OPTIONS.
            % 
            %
            %  See also SamplingOptions, Sampling.random
            
            % Verify license for Statistics and Machine Learning Toolbox
            if ~license('test','Statistics_Toolbox') || isempty(ver('stats'))
                error(message('stats:sensitivity:general:errSample_HaltonStatsNoLicense'))
            end
            
            % Look for number of samples
            if ~isempty(varargin)  &&  isnumeric(varargin{1})
                nSamples = varargin{1};
                varargin = varargin(2:end);
            else
                nSamples = 1;
            end
            
            % Set up Halton set object
            nParams = numel(PD);
            haltonSet = haltonset(nParams);

            % Look for options
            if ~isempty(varargin)
                MethodOptions = varargin{1};
                haltonSet.Skip = MethodOptions.Skip;
                haltonSet.Leap = MethodOptions.Leap;
                haltonSet.ScrambleMethod = MethodOptions.ScrambleMethod;
            end
            
            % Create Data to store state
            Data.qrObj = haltonSet;
            Data.nextSkip = haltonSet.Skip;
            
            X = lGenerateSamples(PD, nSamples, @lQuasiRandom, Data);
        end
        
        function Rc = correlate(R, RC)
            % CORRELATE Induce rank correlation in random data.
            %
            %  XC = CORRELATE(X,RC) induces rank correlation RC on the sample X.
            %
            %  See also Sampling.copula, Sampling.Sample, Sampling.lhsdesign
            
            
            % Restricted pairing technique of Iman & Conover for inducing
            % rank correlation on independent data vectors
            Cstar = RC;
            [~,p] = chol(Cstar);
            if p > 0
                error(message('stats:sensitivity:general:errSampling_RankCorrPositiveDefinite'))
            end
            
            C = Cstar;
            [N,k] = size(R);
            % Calculate the sample correlation matrix T
            T = corrcoef(R);
            
            %Check for NaN values, can happen if a column of R is constant
            if any(isnan(T))
                error(message('stats:sensitivity:general:errSampling_ImanConoverSampleCorrelationNaN'));
            end
            
            %Check that matrix is positive definite (could fail to be if R
            %is perfectly correlated, or perfectly negatively correlated)
            if any(eig(T) < eps)
                error(message('stats:sensitivity:general:errSampling_ImanConoverSampleCorrelationTooPerfect'));
            end
            
            % Calculate lower triangular cholesky decomposition of Cstar, i.e. P*P’ = C
            P = chol(C)';
            % Calculate lower triangular cholesky decomposition of T, i.e. Q*Q’ = T
            Q = chol(T)';
            % S*T*S’ = C
            S = P*inv(Q);
            
            % Replace values in samples with corresponding
            % rank-indices and convert to van der Waerden scores
            RvdW = -sqrt(2).*erfcinv(2*(stats.internal.tie_rank(R)/(N+1)));
            
            % Matrix RBstar has a correlation matrix exactly equal to C
            RBstar = RvdW*S';
            % Match up the rank pairing in R according to RBstar
            ranks = stats.internal.tie_rank(RBstar);
            
            sortedR = sort(R,1);
            Rc = NaN(size(sortedR,1), k);
            for i=1:k
                Rc(:,i) = sortedR(ranks(:,i),i);
            end
            
            %Check the output
            if (norm(sort(R,1) - sort(Rc,1))) >= eps
                error(message('stats:sensitivity:general:errSampling_ImanConoverInvalidOutput'));
            end
        end
		
		
		function X = copula(PD,R,varargin)
			% COPULA Generate a random sample from a copula.
			%
			%  X = COPULA(PD,R) returns a random sample drawn from the probability
			%  distributions PD generated from a Gaussian copula with a rank
			%  correlation matrix R.
			%
			%  X = COPULA(PD,R,N) generates a random sample of length N.
			%
			%  X = COPULA(PD,...,OPTIONS) specifies additional options for the sampling
			%  algorithm. Use SensitivityAnalysis.sampleOptions command to create the
			%  option set OPTIONS.
			%
            %  See also ParamInfo, SensitivityAnalysis.lhsdesign.
            
            % Verify license for Statistics and Machine Learning Toolbox
            if ~license('test','Statistics_Toolbox') || isempty(ver('stats'))
                error(message('stats:sensitivity:general:errSample_CopulaStatsNoLicense'))
            end
            
            % Parse input for correlation matrix
            if (nargin > 1 && isempty(R)) || (nargin <= 1)
                R = eye(length(PD));
            end
            
			% Look for number of samples
			if ~isempty(varargin) && isnumeric(varargin{1})
				nSamples = varargin{1};
				varargin = varargin(2:end);
			else
				nSamples = 1;
			end
			
			% If there is only one probability distribution, use the first
			% column of random vectors generated from the uncorrelated
			% bivariate copula
            if  length(PD)<2
                R = eye(2);
            end
            
            % Based on options, form the function to be used for generating
            % copula samples
            if ~isempty(varargin)   % use MethodOptions
                MethodOptions = varargin{1};
                switch MethodOptions.Family
                    case 'Gaussian'
                        rho = copulaparam('Gaussian', R,  ...
                            'type', MethodOptions.Type);
                        fcn = @(mtx, n) copularnd('Gaussian', mtx, n);
                    case 't'
                        rho = copulaparam('t', R, MethodOptions.DOF,  ...
                            'type', MethodOptions.Type);
                        fcn = @(mtx, n) copularnd('t', mtx, MethodOptions.DOF, n);
                end
            else   % no MethodOptions
                rho = copulaparam('Gaussian', R);
                fcn = @(mtx, n) copularnd('Gaussian', mtx, n);
            end
                                    
            % Use linear correlation if rank correlation would error
            stateRng = rng;   % Store state of random number generator
            try
                uFcn = @(n) fcn(rho, n);   % rank correlation matrix used
                uFcn(1);   % try generating one sample
            catch
                uFcn = @(n) fcn(R, n);   % linear correlation matrix used
            end
            % Restore state of random number generator
            rng(stateRng);

            % Generate samples
            Data.uFcn = uFcn;
            X = lGenerateSamples(PD, nSamples, @lCopula, Data);
        end
    end
	
	%-------------------------------------------------------
	
	
	methods (Access = protected)
		
		function this = setParameterDistributions(this, value)
			if ~isa(value, 'prob.UnivariateDistribution')  ||  ...
					(numel(value) ~= this.Size_ )
				msg_details = 'Invalid input.  Input must be uni-variate probability distributions, and there can be no more distributions than the number of parameters in the Sampling object.  For information on adding or removing parameters, type "help stats.internal.Sampling.addParameter or "help stats.internal.Sampling.removeParameter"';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			this.ParameterDistributions_ = value;
		end
		
		
		function this = setRankCorrelation(this, newValue)
			if isnumeric(newValue)  &&  ...
					( isempty(newValue)  ...
					||  ...
					( isreal(newValue)  &&  ...
					all( size(newValue) == this.Size_ * [1 1] )  &&  ...
					all(all(newValue == newValue')) )  ...
					)
				this.RankCorrelation_ = newValue;
			else
				msg_details = 'Invalid input.  The ''RankCorrelation'' property must be a real symmetric matrix, and the number of rows must be the same as the number of parameters in the Sampling object.  Or, ''RankCorrelation'' may be the empty matrix, [].';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
		end
		
		function this = setOptions(this, newValue)
			if ~isa(newValue, 'stats.internal.SamplingOptions')  ||  ...
					~isscalar(newValue)
				msg_details = 'Invalid input.  The input must be scalar stats.internal.SamplingOptions object.  Type "help stats.internal.Sampling" or "help stats.internal.SamplingOptions" for more information.';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			else
				this.Options_ = newValue;
			end
        end
	end
	
	
	%-------------------------------------------------------
	
	
	methods (Access = protected,  Static,  Sealed)
		
		function names = defaultParamNames(a,b)
			% Default names for parameters, numbered from "a" to "b"
			ct = (a:b);   % row vector
			numID = num2cell(ct);   % cell of numbers
			numID = cellfun(@(e) num2str(e), numID,  'UniformOutput', false);   % cell of number character vectors
			names = cellfun(@(e) ['Param_' e], numID,  'UniformOutput', false);   % append param name
		end
		
		function distrib = getDistributionDefault()
			% Produce default probability distribution
			distrib = makedist('Uniform', 0, 1);
		end
		
		function x = ensureCell(x)
			% Ensure that X is in a cell array For example, converts X from
			% a single character vector to a cell array of character vector
			if ~iscell(x)
				x = {x};
			end
		end
		
		function msg = checkInputNames(names, varargin)
			% Make sure names are unique, valid variable names
			%
			% checkInputNames(NEW) checks that the names in cell array
			% NEW are unique, valid variable names
			%
			% checkInputNames(NEW, EXISTING) checks that the names in
			% the cell arrays NEW and EXISTING are all unique, valid
			% variable names
			
			if ~all(cellfun(@(c) isvarname(c), names))  ||  ...
					( numel(unique(names)) < numel(names) )
				msg = message('stats:sensitivity:general:errUnexpected',  ...
					['All parameter names must be unique, valid MATLAB '  ...
					'variable names']);
			else
				msg = [];
			end
		end
		
		function msg = checkInputDims(A,B)
			% Make sure inputs are vectors with same number of elements
			if isvector(A)  &&  isvector(B)  &&  (numel(A) == numel(B))
				msg = [];
			else
				msg_detail = 'Both inputs must be vectors with the same number of elements.';
				msg = message('stats:sensitivity:general:errUnexpected', msg_detail);
			end
		end
		
    end
    
    methods (Hidden)
        function y = utMethod(~, fcnName, varargin)
            % UTMETHOD For testing methods
            %
            % fcnName is a character vector with the name of the method
            % varargin contains input arguments for the method
            %
            y = feval(fcnName, varargin{:} );
        end
    end
end

function X = lGenerateSamples(PD, n, sampFcn, Data)
% LGENERATESAMPLES Generate samples, ensuring all values are finite
%
X = NaN(n, numel(PD));   % preallocate
rowA = 1;
while rowA <= n
    nNeeded = n - rowA + 1;
    [xTry, Data] = sampFcn(PD, nNeeded, Data);
    % Only use rows will all finite values
    iOK = all(isfinite(xTry), 2);
    rowB = rowA + sum(iOK) - 1;
    X(rowA:rowB, :) = xTry(iOK, :);
    % Setup for next iteration
    rowA = rowB + 1;
end
end

function [X, Data] = lRandom(PD, n, Data)
% LRANDOM Generate random samples
%
nPD = numel(PD);
X = NaN(n, nPD);   % preallocate
for ct = 1:nPD
    pd = PD(ct);
    x = random(pd, n, 1);
    X(:,ct) = x;
end
end

function [X, Data] = lLhsdesign(PD, n, Data)
% LLHSDESIGN Generate Latin hypersquare samples
%
nPD = numel(PD);
X = NaN(n, nPD);   % preallocate
for ct = 1:nPD
    pd = PD(ct);
    
    % Get random values from uniform distribution on [0,1]
    u = rand(n, 1);
    r = (u + (0:n-1)')/n;   % Each r(i) lies in the interval ((i-1)/N,i/N)
    
    % Compute random sample by inverting the cdf
    x = icdf(pd, r);
    
    % Random permutation of values of x for random pairing of variables.
    X(:,ct) = x(randperm(n));
end
end

function [X, Data] = lQuasiRandom(PD, n, Data)
% LQUASIRANDOM Generate quasi-random samples
%

% Generate samples on unit hypercube from 0 to 1
qrObj = Data.qrObj;
qrObj.Skip = Data.nextSkip;
X  = net(qrObj, n);

% Map from quasi-random points between 0 and 1, to values
% appropriate for probability distribution
for ct = 1:numel(PD)
    pd = PD(ct);
    X(:,ct) = icdf(pd, X(:,ct));
end

% Set up if subsequent call is needed.  Setting the Data field instead of
% the object field prevents qrObj.Skip from erroring due to exceeding max
% value if it doesn't have to unless a subsequent call is actually made.
Data.nextSkip = qrObj.Skip + n;
end

function [X, Data] = lCopula(PD, n, Data)
% LCOPULA Generate copula samples
%

% Generate samples on unit hypercube from 0 to 1
uFcn = Data.uFcn;
U = uFcn(n);

% Convert uniform to specified probability distributions.  If there is only
% one probability distribution, use the first column of random vectors
% generated from the uncorrelated bivariate copula.
X = NaN(size(U,1), numel(PD));   % preallocate
for ct = 1:numel(PD)
    pd = PD(ct);
    u = U(:,ct);
    % Compute random sample by inverting the cdf
    x = icdf(pd, u);
    X(:,ct) = x;
end
end
