animateFrames();
function animateFrames()
    animFilename = 'Morning_ascent.gif'; % Output file name
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
% Trying to meet last years character limits!
if f == 1
rng(1,'v4')
x=(-1:.005:1).^2;
g=30*abs(ifft2(exp(6*i*rand(401))./(x'+x+1e-5)));
s=@(x,y)surf(x,'EdgeC','none','FaceC',y);
s(g,'k');
hold
s(conv2(g+1,ones(20)/400),'w');
axis equal off
camproj p;
camva(40);
end
campos([20 20+f 45+f/2]);
set(gcf,'color',[0,.1,.3]+f/69);
light('color',[2,1,1]/4);

end


      
    
    