animateFrames();
function animateFrames()
    animFilename = 'Blender.gif'; % Output file name
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
    c=(sqrt(5)+1)/2;
    d=2*pi/c;
    alpha = interp1([0 48],[0 48*2*pi/12],f);
    theta = (1:600)*d;
    r = sqrt(theta);
    
    theta = theta + alpha;
    
    x = r.*cos(theta);
    y = r.*sin(theta);
    
    sz = 30*(1-(1:numel(x))/numel(x)) + 1;
    clr = sz;
    scatter(x,y,sz,clr,"filled")
    axis equal off
    axis(45*[-1 1 -1 1])
    set(gcf,Color=0.3*[1 1 1])
    
end


      
    
    