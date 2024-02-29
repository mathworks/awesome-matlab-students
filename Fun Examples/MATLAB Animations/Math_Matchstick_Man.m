animateFrames();
function animateFrames()
    animFilename = 'Math_Matchstick_Man.gif'; % Output file name
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
function drawframe(n)
persistent txtHdl armHdl
if n==1
ax=gca;
ax.DataAspectRatio=[1,1,1];
ax.XLim=[-5,5];
ax.YLim=[-5,5];
ax.XColor='none';
ax.YColor='none';
hold on
txtHdl = text(0,3.5,'y = x','FontSize',20,'FontName','Times New Roman','FontWeight','bold',...
    'HorizontalAlignment','center','Color',[0,.25,.45]);
armHdl = plot([-pi,pi],[-pi,pi],'Color',[.8,0,0],'LineWidth',3);

t=linspace(0,2*pi,200);
fill(cos(t),sin(t)+1,[1,1,1],'EdgeColor',[.4,.4,1],'LineWidth',3)
plot(cos(t(101:200)).*.5,sin(t(101:200)).*.5+1,'Color',[.4,.4,1],'LineWidth',3)
fill(cos(t).*.8,sin(t).*1.4-1.4,[1,1,1],'EdgeColor',[.4,.4,1],'LineWidth',3)
plot([-0.38,-0.97,-1.81],[-2.64,-4.50,-4.76],'Color',[.4,.4,1],'LineWidth',3)
plot([ 0.38, 0.97, 1.81],[-2.64,-4.50,-4.76],'Color',[.4,.4,1],'LineWidth',3)
plot([-0.15,-0.42],[ 1.98, 2.15],'Color',[.4,.4,1],'LineWidth',3)
scatter([-0.2,0.2],[1.2,1.2],25,[.4,.4,1],'filled','o')
end

switch true
    case n>=7  && n<=12
        armHdl.XData  = [-pi,0, pi];
        armHdl.YData  = [ pi,0, pi];
        txtHdl.String = 'y = |x|';
    case n>=13 && n<=18
        armHdl.XData  = [-pi,0, pi];
        armHdl.YData  = [-pi,0,-pi];
        txtHdl.String = 'y = - |x|';
    case n>=19 && n<=24
        armHdl.XData  =  -2:.02:2;
        armHdl.YData  = (-2:.02:2).^2;
        txtHdl.String = 'y = x^2';
    case n>=25 && n<=30
        armHdl.XData  =  -2:.02:2;
        armHdl.YData  = (-2:.02:2).^3;
        txtHdl.String = 'y = x^3';
    case n>=31 && n<=36
        armHdl.XData  =  -pi:.01:pi;
        armHdl.YData  = sin(-pi:.01:pi);
        txtHdl.String = 'y = sin(x)';
    case n>=37 && n<=42
        armHdl.XData  =  -2.5:.02:2.5;
        armHdl.YData  =  2.^(-2.5:.02:2.5)-1;
        txtHdl.String = 'y = 2^x - 1';
    case n>=43 && n<=48
        t=linspace(0,2*pi,200);
        armHdl.XData  =  cos(t).*2;
        armHdl.YData  =  sin(t).*2+2;
        txtHdl.String = 'x^2 + (y-2)^2 = 4';
end
end


      
    
    