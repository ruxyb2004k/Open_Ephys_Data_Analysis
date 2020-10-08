classdef MonteCarloOptions
	%MonteCarloOptions for MonteCarlo class
	%
	%   OPTS = MonteCarloOptions() creates a MonteCarloOptions object
	%
	%   OPTS = MonteCarloOptions(NAME, VALUE) sets the property NAME to
	%      be VALUE.
	%
	%   Properties:
	%      UseParallel - specifies whether parallel computing is used
	%      during model evaluation (only available if Parallel Computing
	%      Toolbox is available).  Values: [ {false} | true ]
	%
	%      StopOnEvaluateError - specifies behavior if model errors when
	%      evaluating a sample.  Values: [ {'continue'} | 'stop' | 'ask' ].
	%
	%      ModelHasLogOutput - specifies whether the model function being
	%      evaluated has a second output that contains log data from each
	%      model evaluation.  If set to true, the model function is
	%      required to return two outputs: the model output vector and the
	%      log data.  Values: [ {false} | true ]
	%
	%      Display - specifies how much information to display about the
	%      model evaluation.  Values: [ {'final'} | 'iter' | 'off' ]
	%
	%      ErrorOnWarning - specifies behavior if model evaluation
	%      encounters a warning, i.e., whether a warning or hard error is
	%      thrown.  Values: [ {false} | true ]
	
	
	%  Copyright 2013-2016 The MathWorks, Inc.
	
	
	properties
		UseParallel   % [ {false} | true ]
		StopOnEvaluateError   % [ {'continue'} | 'stop' | 'ask' ]
		ModelHasLogOutput   % [ {false} | true ]
		Display   % [ {'final' | 'iter' | 'off']
		ErrorOnWarning   % [ {false} | true ]
	end
	
	
	methods
		
		function this = MonteCarloOptions(varargin)   % Constructor
			
			if this.isEven(nargin)   % parameter name/value pairs
				% Parse inputs
				p = inputParser();
				addParameter(p, 'UseParallel', false, @this.checkLogicalCapable1x1);
				addParameter(p, 'StopOnEvaluateError', 'continue', @this.checkChar);
				addParameter(p, 'ModelHasLogOutput', false, @this.checkLogicalCapable1x1);
				addParameter(p, 'Display', 'final', @this.checkChar);
				addParameter(p, 'ErrorOnWarning', false, @this.checkLogicalCapable1x1);
				parse(p, varargin{:});
				
				% Assign properties
				field_names = fieldnames(p.Results);
				for ii = 1:numel(field_names)
					name = field_names{ii};
					this.(name) = p.Results.(name);   % set object property
				end
				
				
			else
				msg_details = 'There must be an even number of inputs, in parameter name/value pairs.  Type "help stats.internal.MonteCarloOptions" for more information';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			
		end
		
		
		% Property Methods
		
		function this = set.UseParallel(this, newValue)
			if ~this.isLogicalCapable1x1(newValue)
				msg_details = 'The ''UseParallel'' property must be a scalar logical (true or false).';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			this.UseParallel = logical(newValue);
		end
		
		function this = set.StopOnEvaluateError(this, newValue)
			this.StopOnEvaluateError = validatestring(newValue,  ...
				{'continue', 'stop', 'ask'});
		end
		
		function this = set.ModelHasLogOutput(this, newValue)
			if ~this.isLogicalCapable1x1(newValue)
				msg_details = 'The ''ModelHasLogOutput'' property must be a scalar logical (true or false).';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			this.ModelHasLogOutput = logical(newValue);
		end
		
		function this = set.Display(this, newValue)
			this.Display = validatestring(newValue, {'off', 'final', 'iter'});
		end
		
		function this = set.ErrorOnWarning(this, newValue)
			if ~this.isLogicalCapable1x1(newValue)
				msg_details = 'The ''ErrorOnWarning'' property must be a scalar logical (true or false).';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			this.ErrorOnWarning = logical(newValue);
		end
		
	end
	
	
	methods (Access = protected,  Static,  Sealed)
		
		function tf = isEven(n)
			% True for an even number
			tf =  (mod(n,2) == 0);
		end
		
		function checkChar(x)
			% Check whether input is a character array (string)
            ok = ischar(x) || (isstring(x) && isscalar(x));
			if ~ok
				error(message('stats:sensitivity:general:errNotString'));
			end
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
	
end