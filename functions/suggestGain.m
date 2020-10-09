function y = suggestGain(x)
if 32768/x >= 100
    y = 100;
elseif 32768/x >= 50
    y = 50;
elseif 32768/x >= 20
    y = 20;
elseif 32768/x >= 10
    y = 10;   
else 
    y = 1;
end    
    
    