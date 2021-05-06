%%% Created by RB on 01.04.2021
%%% categorizes and calculates the total number of selected experiments

categs = {'animalStrain', 'trialDuration'}; % specify here 2 categories for the quantification of experiments

sel(1,:) = [expSet.expSel1] == 1; % first experiment selection
sel(2,:) = [expSet.expSel2] == 1; % 2nd experiment selection
selF = and(sel(1,:), sel(2,:))'; % only selected experiments

for i = 1:numel(categs) % for the categories 'animalStrain', 'trialDuration'
    categ = categs{i};
    a.(categ) = unique(extractfield(expSet, categ)); % find the unique values of each category
    totalElemCateg(i) = numel(a.(categ)); % count the experiments of each category value
    if isnumeric(a.(categ)(1)) % if this category has numerical values
        for j = 1: totalElemCateg(i)  % for each category value
            b.(categ)(:,j) = ([expSet.(categ)] == a.(categ)(j))'; % identify which experiments match that category values
        end    
    elseif ischar(a.(categ){1})   % if this category has char values
        for j = 1: totalElemCateg(i)
            b.(categ)(:,j) = strcmp({expSet.(categ)}, a.(categ)(j))'; % identify which experiments match that category values
        end
    end      
end

y = nan(totalElemCateg); % varaible to store the number of experiments matching intersections of category values
for i =1:totalElemCateg(1)
    for j = 1:totalElemCateg(2)
        y(i,j) = sum( b.(categs{1})(:,i) &  b.(categs{2})(:,j) & selF);
    end
end

figure;
barfig= bar(y);
for j = 1:size(y,2) % add the number of exps for each bar
    xtips1 = barfig(j).XEndPoints;
    ytips1 = barfig(j).YEndPoints;
    labels1 = string(barfig(j).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
end
box off
xticklabels(a.(categs{1}));
ylabel('No. experiments');

legend({'Contrast - short','Orientation','Contrast - long','Multi-stim'}, 'location', 'bestoutside'); % in ascending order of the trial time (6,7,9,18)
clearvars a b categ categs i j labels1 xtips1 ytips1 sel selF totalElemCateg