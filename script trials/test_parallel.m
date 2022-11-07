clear
n = 100000000;

%%
gcp;
% pause(10)
tic
parfor i = 1:n
    a(i) = i*10;
end
toc

%%
tic
for i = 1:n
    a(i) = i*10;
end
toc

%% comaprison - store times
tp = nan(4,1);
tn = nan(4,1);
for j = (6:9)
    j
    n = 10^j;
    
    gcp;
    tic
    parfor i = 1:n
        a(i) = i*10;
    end
    tp(j-5) = toc;
    clearvars a
    
    tic
    for i = 1:n
        a(i) = i*10;
    end
    tn(j-5) = toc;
    clearvars a
end    
    
figure
plot(tp); hold on
plot(tn)
    
    