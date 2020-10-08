classdef SamplingOptions
	%SamplingOptions for Sampling class, for sampling multiple distributions.
	%   SampOpts = SamplingOptions() creates a SamplingOptions object
	%
	%   OPTS = SamplingOptions('Method', VALUE) sets the Method, which can
	%   be any of the following:
	%      'random' for random sampling (the default)
	%      'lhs' for Latin hypercube
    %      'sobol' for Sobol set
    %      'halton' for Halton set
	%      'copula' for copulas
	%
	% OPTS also has a field 'MethodOptions' which is a struct whose fields
    % depend on the value of 'Method'.
	%
	%    'random':  no fields
    %
	%    'lhs':     no fields
    %
    %    'sobol':
    %       'Skip'            - nonnegative integer (default 1)
    %       'Leap'            - nonnegative integer (default 0)
    %       'ScrambleMethod'  - The default scramble method is equivalent
    %                           to setting ScrambleMethod to:
    %                           struct('Type', {}, 'Options', {})
    %                         - To use MatousekAffineOwen scrambling, set
    %                           ScrambleMethod to:
    %                           struct('Type', 'MatousekAffineOwen', 'Options', {{}})
    %       'PointOrder'      - 'standard' (default) or 'graycode'
    %
    %    'halton':
    %       'Skip'            - nonnegative integer (default 1)
    %       'Leap'            - nonnegative integer (default 0)
    %       'ScrambleMethod'  - The default scramble method is equivalent
    %                           to setting ScrambleMethod to:
    %                           struct('Type', {}, 'Options', {})
    %                         - To use RR2 scrambling, set ScrambleMethod to:
    %                           struct('Type', 'RR2', 'Options', {{}})
    %
    %    'copula':
	%       'Family'          - can be 'Gaussian' (default) or 't'
	%       'Type'            - can be 'Spearman' (default) or 'Kendall'
	%       'DOF'             - should be the empty array, [], for
	%                           'Gaussian' family
	%                         - should be a positive real scalar for 't'
    %                           family

	%  Copyright 2013-2016 The MathWorks, Inc.

	
	properties (Dependent = true)
		Method
		MethodOptions
	end
	
	
	properties (Access = protected)
		Method_
		MethodOptions_
	end
	
	
	methods
		
		function this = SamplingOptions(varargin)   % Constructor
			
			if this.isEven(nargin)   % parameter name/value pairs
				% Parse inputs
				p = inputParser();
				addParameter(p, 'Method', 'random', @this.checkChar);
				parse(p, varargin{:});
				
				% Assign properties
				this.Method_ = p.Results.Method;
				this.MethodOptions_ = localResetMethodOptions(p.Results.Method);

				
			else
				msg_details = 'There must be an even number of inputs, in parameter name/value pairs.  Type "help stats.internal.SamplingOptions" for more information';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			
		end
		
		
		% Property methods for "Method"
		
		function value = get.Method(this)
			value = this.Method_;
		end
		
		function this = set.Method(this, newValue)
			newValue = validatestring(newValue, {'random', 'lhs', 'sobol', 'halton', 'copula'});	
			% If 'Method' is being changed, reset 'MethodOptions'
			if ~strcmp(this.Method, newValue)
				this.MethodOptions_ = localResetMethodOptions(newValue);
			end
			this.Method_ = newValue;
		end
		
		
		% Property methods for MethodOptions
		
		function value = get.MethodOptions(this)
			value = this.MethodOptions_;
		end
		
		function this = set.MethodOptions(this, newValue)
			try
				this = setMethodOptions(this, newValue);
			catch E
				throw(E);
			end
		end
		
	end
			
	
	methods (Access = protected,  Static,  Sealed)
		
		function tf = isEven(n)
			% True for an even number
			tf =  (mod(n,2) == 0);
		end
		
		function checkChar(x)
			% Check whether input is a character array (string)
			if ~ischar(x)
				error(message('stats:sensitivity:general:errNotString'));
			end
		end
		
		function ok = matchingFieldNames(value_1, value_2)
			% Check if field names are the same
			
			if ~strcmp(class(value_1), class(value_2))   % not same class
				ok = false;
				
			elseif ~all(size(value_1) == size(value_2))   % not same size
				ok = false;
				
			elseif (isstruct(value_1)  &&  isstruct(value_2))   % structures
				% Check that structures have matching field names
				fn1 = fieldnames(value_1);
				fn2 = fieldnames(value_2);
				
				if (isempty(fn1)  &&  isempty(fn2))   % both empty
					ok = true;
					
				else
					ok = (numel(fn1) == numel(fn2));   % same # of fields
					ok = ok  &&  all(strcmp(fn1, fn2));   % matching field names
				end
				
			end
			
			
		end
		
	end
	
	methods (Access = protected)
		
		function this = setMethodOptions(this, newValue)
			% Helper for set.MethodOptions
			if ~this.matchingFieldNames(this.MethodOptions, newValue)
				msg_details = 'Invalid input.  The ''MethodOptions'' property needs to be a valid set of options for the ''Method'' being used.  Type "help stats.internal.SamplingOptions" for more information';
				error(message('stats:sensitivity:general:errUnexpected', msg_details));
			end
			this.MethodOptions_ = newValue;
		end
		
	end
	
	
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function MO = localResetMethodOptions(method_value)
% Reset method options
switch method_value
	case 'random'
		MO = struct([]);   % no options
		
	case 'lhs'
		MO = struct([]);
		
    case 'sobol'
		MO = struct(...
            'Skip',             1,  ...
			'Leap',             0, ...
            'ScrambleMethod',   struct('Type', {}, 'Options', {}), ...
            'PointOrder',       'standard'  );
        
    case 'halton'
        MO = struct(...
            'Skip',             1,  ...
            'Leap',             0, ...
            'ScrambleMethod',   struct('Type', {}, 'Options', {}) );

    case 'copula'
		MO = struct(...
            'Family',  'Gaussian',  ...
			'Type',    'Spearman', ...
            'DOF',     [] );
		
end
end