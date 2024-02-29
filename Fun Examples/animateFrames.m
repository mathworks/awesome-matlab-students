function animateFrames()
    animFilename = 'animation.gif'; % Output file name
 
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
            imwrite(A,map,animFilename, LoopCount=Inf, DelayTime=delayTime);
        else
            imwrite(A,map,animFilename, WriteMode="append", DelayTime=delayTime);
        end
    end
end