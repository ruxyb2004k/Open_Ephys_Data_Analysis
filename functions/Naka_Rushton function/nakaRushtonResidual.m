%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    nakaRushtonResidual    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function residual = nakaRushtonResidual(params,c,r,m)

% decode parameters
p = parseParams(params,m);
% calculate naka-rushton
fitR = nakaRushton(c,p); 

% display fit if called for
if m.dispFit
  f = smartfig('selectionModel_nakaRushtonResidual','reuse');  
  clf;
  semilogx(c,r,'ko');
  hold on
  semilogx(c,fitR,'k-')
  titleStr = sprintf('Rmax: %0.3f c50: %0.2f n: %0.3f\n',p.Rmax,p.c50,p.n);
  title(sprintf('%s offset: %f',titleStr,p.offset));
  drawnow
end

residual = r(:)-fitR(:);
residual = residual(:);

