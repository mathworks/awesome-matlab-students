animateFrames();
function animateFrames()
    animFilename = 'Pokeball.gif'; % Output file name
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
    [t,p] = meshgrid(linspace(-1,1,200));
    t=t*pi;
    p=p*pi/2;
    x = cos(t).*cos(p);
    y = sin(t).*cos(p);
    z = sin(p);
    s = (x.^2+z.^2<0.3^2).*(y<0);
    g = (x.^2+z.^2<0.2^2).*(y<0);
    r = min(1.1,max(1,1 + 0.05*(abs(z)>0.1) - 0.1*s + 2*g));
    surf(r.*x,r.*y,r.*z,min(3,max(0,(sin(p)<-0.1) + 2*(sin(p)>0.1) -2*s + 5*g)));
    colormap([0 0 0; 1 1 1; 1 0 0; 0.9 0.9 0.9]);
    shading interp;
    axis equal off;
    camlight headight;
    view([720/47*(f-1) 15+30*sin(2*pi*f/48)]); 
end