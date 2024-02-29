animateFrames();
function animateFrames()
    animFilename = 'EIGENWALKERS_in_love.gif'; % Output file name
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
    % Remix of Cleve Moler's EIGENWALKER with a handholding partner
    period = 151.5751;
    omega = 2*pi/period;
    fps = 48;
    dt = 2*pi/omega/fps;
    scale = 0.1;
    t = (f-1)*dt;
    c = scale*[1 sin(omega*t) cos(omega*t) sin(2*omega*t) cos(2*omega*t)]';
    V = coefficients;
    X = reshape(V*c,15,3);
    X([2 3],1) = [223.1 197.7];
    L = {[1 5],[5 12],[2 3 4 5 6 7 8],[9 10 11 12 13 14 15],[1]};
    p = zeros(4,1);
    cla
    axis([-310 750 -750 750 0 1500],'off')
    set(gca,'xtick',[],'ytick',[],'ztick',[])
    for k = 1:4
       p(k) = line(X(L{k},1),X(L{k},2),X(L{k},3), ...
          'color',[0 2 3]/4, ......
          'marker','o','markersize',8, ...
          'linestyle','-','linewidth',1.5);
       p(k) = line(-X(L{k},1)+440,X(L{k},2),X(L{k},3), ...
          'color',[3 2 0]/4, ......
          'marker','o','markersize',8, ...
          'linestyle','-','linewidth',1.5);
    end
    p(5) = line(X(L{5},1),X(L{5},2),X(L{5},3), ...
          'color',[0 2 3]/4, ......
          'marker','.','markersize',60, ...
          'linestyle','-','linewidth',1.5);
    p(5) = line(-X(L{5},1)+440,X(L{5},2),X(L{5},3), ...
          'color',[3 2 0]/4, ......
          'marker','.','markersize',60, ...
          'linestyle','-','linewidth',1.5);
    view(-202,10)
    
    function V = coefficients 
    V = [  5 -43 -182 0 1
        2064 14 -131 11 39
        2092 -215 -192 28 15
        1660 -72 -173 -1 3
        -7 -78 -173 2 1
        -1664 -79 -178 4 -3
        -2097 -246 -200 -28 -20
        -2016 -36 -168 -19 -49
        536 53 127 0 15
        794 11 83 -3 47
        931 -73 -145 1 -2
        20 -63 -113 1 0
        -883 -74 -146 1 -1
        -831 17 74 2 -47
        -567 61 125 0 -20
        205 -11 -4 -37 27
        500 -1010 -256 37 9
        -686 -606 -174 -11 17
        -59 -153 -52 -57 32
        -114 -7 -4 -62 35
        -177 139 44 -61 34
        -717 691 170 -12 16
        414 1174 254 36 0
        -544 2214 -576 327 -259
        859 1247 170 51 264
        -42 -10 -29 -115 80
        78 -10 0 -115 67
        -58 -10 33 -116 79
        832 -1240 -175 56 266
        -557 -2227 586 349 -271
        13837 1 0 70 86
        7695 -189 -11 124 6
        9721 61 44 82 59
        12251 -20 22 76 85
        12058 1 0 74 85
        12320 21 -23 78 82
        9774 -65 -39 83 49
        7766 224 17 119 -23
        984 -120 548 -105 266
        4122 250 49 123 30
        7897 -12 -31 70 84
        8766 1 1 70 87
        7889 13 32 70 86
        4157 -249 -52 124 35
        985 127 -548 -116 269];
    end 
end 


      
    
    