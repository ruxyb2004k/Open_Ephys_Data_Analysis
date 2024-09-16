y = allStimMagn(:,baseSelect);
figure
for i = 1:size(y,2)
    subplot(5,6,i)
    scatter(y(1:2:8,i), y(2:2:8,i)); hold on
    yl = ylim;
    plot([yl(1), yl(2)], [yl(1), yl(2)])
end
%% use this with example cells 5 and 8
y = allStimMagn(:,baseSelect);
lastCond = totalConds-2;
x = y(1:2:lastCond,:);
y1 = y(1:2:lastCond,:) - y(2:2:lastCond,:);%
figure
j = 1;
for i =[5,8]% 1:size(y,2)
    %subplot(5,6,j)
    subplot(1,2,j)
    scatter(x(:,i), y1(:,i)); hold on
    yl = ylim;
%     plot([yl(1), yl(2)], [yl(1), yl(2)])
    P = polyfit(x(:,i),y1(:,i),1);
    yfit = P(1)*x(:,i)+P(2);
    hold on;
    plot(x(:,i),yfit,'r-.');
    xl = xlim;
    %ylim([min([xl,yl]), max([xl,yl])*0.6]);
    ylim([min([xl,yl]), yl(2)+1]);
    xlabel('Magnitude no photostim. (Hz)');
    ylabel('Suppression (Hz)');
    j = j+1;
end

%%

y = allStimMagnDiff(:,baseSelect);
figure
for i = 1:size(y,2)
    subplot(5,6,i)
    plot((1:4), y(1:4,i))
end

y = allStimMagnDiffNorm(:,baseSelect);
figure
for i = 1:size(y,2)
    subplot(5,6,i)
    plot((1:4), y(1:4,i))
end

figure
j=1;
for i = find(baseSelect)
    subplot(5,6,j)
    scatter(allStimMagn(1:4,i), allStimMagnDiff(1:4,i))
    j = j+1;
end


figure
j=1;
for i = find(baseSelect)
    scatter(allStimMagn(1:4,i), allStimMagnDiff(1:4,i)); hold on
end

