%%% Created by RB on 01.04.2021
%%% categorizes and calculates the total number of selected experiments

mouseline(1,:) = strcmp({expSet.animalStrain}, 'NexCre');
mouseline(2,:) = strcmp({expSet.animalStrain}, 'Gad2Cre');
mouseline(3,:) = strcmp({expSet.animalStrain}, 'PvCre');
duration(1,:) = [expSet.trialDuration] == 6;
duration(2,:) = [expSet.trialDuration] == 7;
duration(3,:) = [expSet.trialDuration] == 9;
duration(4,:) = [expSet.trialDuration] == 18;
sel(1,:) = [expSet.expSel1] == 1; % first experiment selection
sel(2,:) = [expSet.expSel2] == 1; % 2nd experiment selection
selF = and(sel(1,:), sel(2,:));


y = nan(size(mouseline,1), size(duration,1));
for i =1:size(mouseline,1)
    for j = 1:size(duration,1)
        y(i,j) = sum((mouseline(i,:) & duration(j,:) & selF));
    end
end    
figure;
% x = categorical({'NexCre','Gad2Cre','PvCre'});
b= bar(y);
for j = 1:size(duration,1)
    xtips1 = b(j).XEndPoints;
    ytips1 = b(j).YEndPoints;
    labels1 = string(b(j).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
end

xticklabels({'NexCre', 'Gad2Cre', 'PvCre'});
ylabel('No. experiments');
legend({'Contrast - short','Orientation','Contrast - long','Multi-stim'});
