animateFrames();
function animateFrames()
    animFilename = 'Solar_system__meteor_and_UFO.gif'; % Output file name
    firstFrame = true;
    framesPerSecond = 24;
    delayTime = 1/framesPerSecond;

    % Create the gif
    for frame = 1:48
        drawframe(frame);
        fig = gcf();
        fig.Units = 'pixels';
        fig.Position(3:4) = [300,300];
        im = getframe(fig);
        [A,map] = rgb2ind(im.cdata,256);

        if firstFrame
            firstFrame = false;
            imwrite(A,map,animFilename, 'LoopCount', Inf, 'DelayTime', delayTime);
        else
            imwrite(A,map,animFilename, 'WriteMode', 'append', 'DelayTime', delayTime);
        end
    end
end
function drawframe(f)
tiledlayout(1,1,'Padding','none')
nexttile

% stars
ax1 = axes('Position',[0 0 1 1]);
x1=0:0.01:1;
x2=0:0.02:1;
rng(1)
y1=rand(1,101);
y2=rand(1,51);
if mod(f,2)==0
    c1='w';
    c2='w';
else   
    c2=[.09 .09 .71];
    c1='w';
end
plot(ax1,x1,y1,'p','MarkerEdgeColor',c1,'MarkerFaceColor',c1,'markersize',4)
hold on
plot(ax1,x2,y2,'p','MarkerEdgeColor',c2,'MarkerFaceColor',c2,'markersize',3)
ax1.Color=[.09 .09 .71];

% meteor
for i=1:f
a=rand(1);
b=rand(1);
plot(ax1,[a+0.05-f/48 a-f/48],[b+0.05-f/48 b-f/48],'w-','linewidth',1)
end
% UFO
plot(ax1,0+f/48,0.1,'<','color','r','markerfacecolor','r','markersize',8)
plot(ax1,0.02+f/48,0.1,'s','color','r','markerfacecolor','r','markersize',11)
plot(ax1,0.04+f/48,0.1,'>','color','r','markerfacecolor','r','markersize',8)
text(ax1,0+f/48,0.1,'UFO','fontsize',4,'color','w')
xlim([0 1])
ylim([0 1])

% basics
name={'\bf Mercury', '\bf Venus', '\bf Earth', '\bf Mars', '\bf Jupiter', '\bf Saturn', '\bf Uranus', '\bf Neptune'};

ax2 = axes('Position',[0 0 1 1]);
% sun
[X1,Y1,Z1] = sphere(50);
X2 = X1 * 4.5;
Y2 = Y1 * 4.5;
Z2 = Z1 * 4.5;
s=surf(ax2,X2,Y2,Z2);
s.EdgeColor='none';
hold on

% planets
r=[1 1 1.3 1.2 2.5 1.8 1.5 1.5];
for i=1:8
    [x,y,z] = cylinder(3+3*i,50);
    plot3(x(1,:),y(1,:),z(1,:),'c-');
    hold on
    [X1,Y1,Z1] = sphere(50);
    X2=X1 * r(i)+(3+3*i)*cos(f*pi/24+5*i);
    Y2=Y1 * r(i)+(3+3*i)*sin(f*pi/24+5*i);
    Z2 = Z1 * r(i);
    s=surf(ax2,X2,Y2,Z2);
    s.EdgeColor='none';
    colormap('jet');
    text(ax2,X2(26,1),Y2(26,1),Z2(26,1)+3,name{i},'color','w','fontsize',6)
end

view(45,45)    
axis equal
ax2.Visible='off';
axis([-28 28 -28 28 -5 5])

end


      
    
    