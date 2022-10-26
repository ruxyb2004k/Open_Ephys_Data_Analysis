%%% created by RB on 11.05.2021
%%% depicts a linear model of the photostim effect on spont + evoked activity


saveFig16h = {'LMbasePreAmplPost.fig'}; %modify here if needed
    
figure;
ax = gca;
scatter(x1, y1, [], C(1,:), 'LineWidth', 2); hold on
scatter(x2, y2, [], C(2,:), 'LineWidth', 2);
scatter(x3, y3, [], C(totalConds-1,:), 'LineWidth', 2); hold on
scatter(x4, y4, [], C(totalConds,:), 'LineWidth', 2);


lims = max(xlim, ylim);
xlim(lims)
ylim(lims)

% fitline1 = fit(x1, y1, 'poly1');
% fitline2 = fit(x2, y2, 'poly1');
% fitline3 = fit(x3, y3, 'poly1');
% fitline4 = fit(x4, y4, 'poly1');
% 
% coeffs1 = coeffvalues(fitline1);
% coeffs2 = coeffvalues(fitline2);
% coeffs3 = coeffvalues(fitline3);
% coeffs4 = coeffvalues(fitline4);

% calculate coefficients from the linear regression model
coeffsLM = table2array(mdl.Coefficients);
coeffsLM1 = [coeffsLM(2,1)+coeffsLM(5,1), coeffsLM(1,1)+coeffsLM(3,1)]; % coefficients for x1,y1
coeffsLM3 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x3,y3
if totalCoeffs == 7
    coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1)+coeffsLM(5,1)+coeffsLM(7,1), coeffsLM(1,1)+coeffsLM(3,1)+coeffsLM(6,1)]; % coefficients for x2,y2
    coeffsLM4 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)]; % coefficients for x4,y4

elseif totalCoeffs == 8    
    coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1)+coeffsLM(5,1)+coeffsLM(7,1), coeffsLM(1,1)+coeffsLM(3,1)+coeffsLM(6,1)+ coeffsLM(8,1)]; % coefficients for x2,y2
    coeffsLM4 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)+ coeffsLM(8,1)]; % coefficients for x4,y4
end

f1 = polyval(coeffsLM1, lims);
f2 = polyval(coeffsLM2, lims);
f3 = polyval(coeffsLM3, lims);
f4 = polyval(coeffsLM4, lims);

plot(lims, f1, 'Color', C(1,:));
plot(lims, f2, 'Color', C(2,:));
plot(lims, f3, 'Color', C(totalConds-1,:));
plot(lims, f4, 'Color', C(totalConds,:));

lim= max(max(xlim, ylim));
% text(lim*0.2, lim*0.90, [num2str(round(coeffs1(1),2)),'*x + ',num2str(round(coeffs1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
% text(lim*0.2, lim*0.97, [num2str(round(coeffs2(1),2)),'*x + ',num2str(round(coeffs2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));
% text(lim*0.2, lim*0.75, [num2str(round(coeffs3(1),2)),'*x + ',num2str(round(coeffs3(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
% text(lim*0.2, lim*0.82, [num2str(round(coeffs4(1),2)),'*x + ',num2str(round(coeffs4(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', 'b');
text(lim*0.8, lim*0.37, [num2str(round(coeffsLM1(1),2)),'*x + ',num2str(round(coeffsLM1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
text(lim*0.8, lim*0.30, [num2str(round(coeffsLM2(1),2)),'*x + ',num2str(round(coeffsLM2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(2,:));
text(lim*0.8, lim*0.22, [num2str(round(coeffsLM3(1),2)),'*x + ',num2str(round(coeffsLM3(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds-1,:));
text(lim*0.8, lim*0.15, [num2str(round(coeffsLM4(1),2)),'*x + ',num2str(round(coeffsLM4(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', C(totalConds,:));

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
xlabel('Pre (norm. spike freq)','FontSize',24); % modify here if needed
ylabel('Post (norm. spike freq)','FontSize',24); % modify here if needed
% xlim([0 1])
% ylim([0 1])
set(ax,'FontSize',fs)
if saveFigs == true
    savefig(strcat(savePath, saveFig16h{1}));
    saveas(gcf, strcat(savePath, saveFig16h{1}(1:end-3), 'png'));
end