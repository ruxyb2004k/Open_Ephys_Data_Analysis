
ind1=[1 3 4 5];
data_points=[];
for iii=1:size(ind1,2)
    ind_=ind1(iii)
    load(['data06_E',num2str(ind_),'.mat']);
    dt2=trace_1;
    dt1=dt2(:,3:end);
    Mx=max(dt1);
    tr=.7*Mx;
    for i=1:5
        dt2=dt1(1:find(dt1(:,i)==Mx(i)),i);
        ind=max(find(dt2<=tr(i)));
        cmpr(i)=dt1(ind,i);
    end
    M=fliplr(Mx);
    compr=fliplr(cmpr);
    data_points=[data_points;compr];
    % t=[6.25 12.5 25 50 100];
end


Rmx=[];Bm=[];
ind1=[1 2 3 4 5 8 9];
for iii=1:size(ind1,2)
    ind_=ind1(iii)
    load(['data22_E',num2str(ind_),'.mat']);
    R=trace_1(:,3);
    Rmx=[Rmx;max(R)];
    B=mean(trace_1(:,3));
    Bm=[Bm;B];
    
end

clear
close all
clc
global gg kk
% 9200,12096,11232, 7680
conds=zeros(7680,110,12);
ggg=[8 9];

for iii=1:size(ggg,2)
    
    gg=ggg(iii)
    
    Data_Analysis;
    condsbin3=condsbinfltr;
    condsbin4(:,:,1)=condsbin3(:,:,1);
    condsbin4(:,:,2)=condsbin3(:,:,2);
    condsbin4(:,:,3)=(condsbin3(:,:,3)+condsbin3(:,:,4))/2;
    condsbin4(:,:,4)=(condsbin3(:,:,5)+condsbin3(:,:,6))/2;
    condsbin4(:,:,5)=(condsbin3(:,:,7)+condsbin3(:,:,8))/2;
    condsbin4(:,:,6)=(condsbin3(:,:,9)+condsbin3(:,:,10))/2;
    condsbin4(:,:,7)=(condsbin3(:,:,11)+condsbin3(:,:,12))/2;
    %     darbin_50;
    sr_roireshape2;
    globalTC;
    save(['data22_E',num2str(gg)],'trace_1');
    ppp=input('if you want to continue pls enter a non zero number: ');
    if ppp==0
        break;
    end
    clear condsbinfltr condsbin3 condsbin4 trace_1
    close all
    
end


load('parameters.mat')
load('finaldata_.mat')
for i=1:23
    [x,resnorm]=NR_lstfit(R,2,.25,B,data_);
end
