classdef ProbabilityDistributionRegistry < handle
%PROBABILITYDISTRIBUTIONREGISTRY Registry for ProbabilityDistribution classes
%   Registered distributions are those which inherit from
%   TOOLBOXDISTRIBUTION and reside in package PROB.  Registered
%   distributions are recognized by Statistics and Machine Learning Toolbox
%   functions such as MAKEDIST and, if fittable, by FITDIST and DFITTOOL.

%   Copyright 2012-2015 The MathWorks, Inc.

   properties(Access=private)
      Registry = [];
   end
   methods(Access=private)
      function newObj = ProbabilityDistributionRegistry()
         newObj.Registry = buildRegistry;
      end
   end
   
   methods(Static)
       function result = get(name)
           obj = prob.ProbabilityDistributionRegistry.instance();
           name(name==' ') = [];
           if ~isKey(obj.Registry,name)
              keys = obj.Registry.keys;
              name = statslib.internal.getParamVal(name,keys,'''Distribution''');
           end
           result = obj.Registry(name);
       end
       function tf = query(name)
           name(name==' ') = [];
           obj = prob.ProbabilityDistributionRegistry.instance();
           tf = isKey(obj.Registry,name);
       end
       function keys = list(theFilter)
           %
           % Currently we support only 3 options:
           %
           % no input argument: list ALL registered distributions.  This
           %             option is not currently used in the Statistics
           %             and Machine Learning Toolbox.
           %
           % 'fittable': list distributions that inherit from 
           %             prob.FittableDistribution.  This option is used
           %             by fitdist and by private/dfgetdistributons.
           %
           % 'parametric': list distributions that inherit from
           %             prob.ParametricDistribution.  This option is used
           %             by makedist.
           %
           % 'fittable' and 'parametric' are positional arguments and
           % only one argument is tested.  Thus these two options are
           % mutually exclusive.  If in the future we want more flexible
           % filters on the registry we will want to revise this simple
           % scheme.
           % There is no error checking because 
           % (1) this function is intended for internal use,
           % (2) the use cases are simple and very limited, and
           % (3) we don't want to waste computing time.

           obj = prob.ProbabilityDistributionRegistry.instance();
           keys = obj.Registry.keys;
           if nargin<1
               return
           else
               subset = true(size(keys));
               
               if strcmp(theFilter,'fittable')
                   for j = 1:length(subset)
                       result = obj.Registry(keys{j});
                       subset(j) = result.fittable && result.toolboxcompliant;
                   end
               elseif strcmp(theFilter,'parametric')
                   for j = 1:length(subset)
                       result = obj.Registry(keys{j});
                       subset(j) = result.parametric;
                   end
               else
                   % Ignore any input argument that does not match
                   % expectations.
                   return
               end
               
               keys = keys(subset);
           end
       end
       function refresh
           prob.ProbabilityDistributionRegistry.instance(true);
       end
end
   methods(Static,Access=private)
      function obj = instance(force)
         persistent singleton
         if isempty(singleton) || (nargin>=1 && force)
            obj = prob.ProbabilityDistributionRegistry();
            singleton = obj;
         else
            obj = singleton;
         end
      end
   end
end
function Registry = buildRegistry()
    Registry = containers.Map();
    
    s = findSubClasses('prob','prob.ProbabilityDistribution');
    
    for i=1:length(s)
        fullname = s{i}.Name;
        basename = regexprep(fullname,'Distribution$','');
        basename = regexprep(basename,'^prob.','');
        fittable = ismember('prob.FittableDistribution',superclasses(fullname));
        toolboxcompliant = ismember('prob.ToolboxDistribution',superclasses(fullname));
        parametric = ismember('prob.ParametricDistribution',superclasses(fullname));
        spec = struct('classname',fullname,...
                      'fittable',fittable,...
                      'toolboxcompliant',toolboxcompliant,...
                      'parametric',parametric,...
                      'basename',basename);
        Registry(lower(basename)) = spec;
    end
end

function classes = findSubClasses(packageName, superclassName)
%FINDSUBCLASSES   Find sub-classes within a package
%
%   CLASSES = FINDSUBCLASSES(PACKAGE, SUPERCLASS) is a cell-array of meta.class
%   objects, each element being a sub-class of SUPERCLASS and a member of the
%   given PACKAGE.
%
%   Note that only non-abstract classes are returned.
%
%   Example
%      classes = cfdev.findSubClasses( 'cfdev.data', 'cfdev.data.DevData' )

%   Copyright 2009-2011 The MathWorks, Inc.

narginchk( 2, 2 ) ;

% Get the package object
package = meta.package.fromName( packageName );
if isempty( package )
    warning(message('stats:probdists:ProbDistNotFound'));
    classes = {};

else
    % For each class in the package ...
    %  1. check for given super-class
    %  2. check for abstract classes
    classes = package.Classes;
    keep = cellfun( @(x) isAClass( superclassName, x.SuperClasses ) && ~isAbstract( x ), ...
        classes );
    
    % Return list of non-abstract classes that sub-class the given super-class
    classes = classes(keep);
end
end

function tf = isAClass( className, list )
% Check the LIST of classes and their superclasses for given CLASSNAME
tf = false;
for i = 1:length( list )
    tf = strcmp( className, list{i}.Name ) || isAClass( className, list{i}.SuperClasses );
    if tf
        break
    end
end

end

function tf = isAbstract( class )
% A class is abstract if it has any abstract methods or properties
tf = any( cellfun( @(x) x.Abstract, class.Methods ) ) ...
    || any( cellfun( @(x) x.Abstract, class.Properties ) );
end


% The following lines list functions that are supplied with the toolbox and
% that are going to be located by the meta.package.fromName call above.
% They are listed here so the compiler will be able to include them.
%#function prob.BetaDistribution
%#function prob.BinomialDistribution
%#function prob.BirnbaumSaundersDistribution
%#function prob.BurrDistribution
%#function prob.ExponentialDistribution
%#function prob.ExtremeValueDistribution
%#function prob.GammaDistribution
%#function prob.GeneralizedExtremeValueDistribution
%#function prob.GeneralizedParetoDistribution
%#function prob.InverseGaussianDistribution
%#function prob.FittableDistribution
%#function prob.FittableParametricDistribution
%#function prob.HalfNormalDistribution
%#function prob.KernelDistribution
%#function prob.LogisticDistribution
%#function prob.LoglogisticDistribution
%#function prob.LognormalDistribution
%#function prob.MultinomialDistribution
%#function prob.NakagamiDistribution
%#function prob.NegativeBinomialDistribution
%#function prob.NormalDistribution
%#function prob.ParametricDistribution
%#function prob.PiecewiseLinearDistribution
%#function prob.PoissonDistribution
%#function prob.ProbabilityDistribution
%#function prob.ProbabilityDistributionRegistry
%#function prob.RayleighDistribution
%#function prob.RicianDistribution
%#function prob.StableDistribution
%#function prob.tLocationScaleDistribution
%#function prob.ToolboxDistribution
%#function prob.ToolboxFittableParametricDistribution
%#function prob.ToolboxParametricDistribution
%#function prob.TriangularDistribution
%#function prob.TruncatableDistribution
%#function prob.UniformDistribution
%#function prob.UnivariateDistribution
%#function prob.WeibullDistribution
