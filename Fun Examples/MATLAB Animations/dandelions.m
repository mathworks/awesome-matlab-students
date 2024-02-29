animateFrames();
function animateFrames()
    animFilename = 'dandelions.gif'; % Output file name
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
n=80;
h=pi*(3-5^.5);
z=linspace(1-1/n,1/(n-1),n);
t=h.*linspace(0,n,n);
r=(1-z.^2);
p=r*f/60.*cos(t*f);
q=r*f/60.*sin(t*f);
u=r*f/90.*cos(t);
v=r*f/90.*sin(t);
image(zeros(99,100,3))
hold on
plot(flip(30*(z.^2))+34,80*(-z)+110,'-','LineWidth',4,'Color',[.41 .59 .29])
plot(30*(z.^2)+45,80*(-z)+100,'-','LineWidth',4,'Color',[.41 .59 .29])
for k=1:n
plot3(17*([0 u(k)]+2),17*([0 v(k)]+1.8),170*([0 z(k)]),'*--w','markersize',.1)
plot3(17*([0 p(k)]+4.4),17*([0 q(k)]+1.2),170*([0 z(k)]),'*--w', 'markersize',.1)
end
ht=text(55,80,'🌿','color','g','FontSize',60+f/4,'Color',[.41 .59 .29]);
kt=text(27,80,'🌿','color','g','FontSize',55+f/4,'Color',[.41 .59 .29]);
kt.Rotation = 90
axis equal off %I kind of liked the stem coming out of the figure
end


      
    
    