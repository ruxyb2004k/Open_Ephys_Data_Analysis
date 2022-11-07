x=1:10;
y=sin(x);
figure
plot(x,y,'k*-','LineWidth',1.5,'MarkerSize',8);
axes('Position',[.1 .78 .05 .05]);
px=[1 5];
py1=[1 2];
height=1;
py2=py1+height;
plot(px,py1,'k','LineWidth',2);hold all;
plot(px,py2,'k','LineWidth',2);hold all;
fill([px flip(px)],[py1 flip(py2)],'w','EdgeColor','none');
box off;
axis off