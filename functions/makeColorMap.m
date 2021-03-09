function [ColorMap] = makeColorMap(data,limit,threshold,color)
% colorcode data > threshold differently (lighter)

for code= 1:limit
   if (data(code) > threshold)
       ColorMap(code,:) = color+0.5;
   else
       ColorMap(code,:) = color;
   end   
end

end

