animateFrames();
function animateFrames()
    animFilename = 'Blooming_Rose.gif'; % Output file name
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
%% Hack so last frame is first frame making our icon look compelling
    f = mod(f-2,48)+1;
    
    %% Rose Part    
    %openness = min((f-1)/40,1.02); - too simple
    % Add some bounce...
    openness = 1.05-cospi(f/(48/2.5)).*(1-f/48).^2;

    opencenter = openness*.2;
    pnum = 3.6;
    nr = 30;
    pr = 10;
    B = 1.27689;
    np = 40;
    petalsep = 5/4;
    
    % How much rotation in radians is one petal?
    % pnum is # petals in 2pi.
    petalTheta = (1/pnum) * pi * 2;
    
    % Number of data points to draw
    % np = number of petals
    % pr = thetapetalresolution (# of pts per petal in theta)
    % +1 since we need 1 more pt to finish the sequence.
    nt = np * pr + 1;

    r=linspace(0,1,nr);
    theta=linspace(0, np*petalTheta,nt);
    [R,THETA]=ndgrid(r,theta);

    M = (1 - mod(pnum*THETA, 2*pi)/pi);

    x = 1 - (petalsep*M.^2 - 1/4).^2 /2;
    
    phi = (pi/2)*linspace(opencenter,openness,nt).^2;
    y = 1.995*(R.^2).*(B*R - 1).^2.*sin(phi);
    R2 = x.*(R.*sin(phi) + y.*cos(phi));

    X=R2.*sin(THETA);
    Y=R2.*cos(THETA);
    Z=x.*(R.*cos(phi)-y.*sin(phi))*1;
    C=hypot(hypot(X,Y), Z*.9);

    surf(X,Y,Z,C, FaceC='i', EdgeC='n');

    %% Decorations
    set(gcf,'color', 'w');
    % When closed, black base looked dumb, so start out full red
    % everywhere, and as it opens, add in the black to give it depth.
    colormap( [ linspace((48-f)/48,1,256).^2; zeros(1,256); zeros(1,256)]' );
    daspect([1 1 1])
    axis([-1 1 -1 1 -.5 1], 'off')
    set(gca,'clipping','off')
    camzoom(1.6)
    camorbit(-f*3,0)
end


      
    
    