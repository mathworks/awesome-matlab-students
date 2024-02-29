animateFrames();
function animateFrames()
    animFilename = 'River.gif'; % Output file name
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

persistent C h i n

if f == 1
    n = 48;
    C = rand(n);
    h = pcolor(C);
    i = 1:n^2;
end

h.CData(mod(i+1,n^2)+1) = h.CData(mod(i,n^2)+1);
i = i+1;

end


      
    
    