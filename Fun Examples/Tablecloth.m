animateFrames();
function animateFrames()
    animFilename = 'Tablecloth.gif'; % Output file name
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
[i,j]=meshgrid(0:1023);
s=3./(j+99);DIM=1024;
y=(j+sin((i.*i+(j-700).^2.*5)./100./DIM+2*pi/48*f).*35).*s;
P(:,:,1)=(mod(round((i+DIM).*s+y),2)+mod(round((DIM.*2-i).*s+y),2)).*110;
P(:,:,2)=(mod(round(5.*((i+DIM).*s+y)),2)+mod(round(5.*((DIM.*2-i).*s+y)),2)).*127;
P(:,:,3)=(mod(round(29.*((i+DIM).*s+y)),2)+mod(round(29.*((DIM.*2-i).*s+y)),2)).*100;
imshow(uint8(P))
end


      
    
    