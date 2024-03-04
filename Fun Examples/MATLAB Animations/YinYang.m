animateFrames();
function animateFrames()
    animFilename = 'YinYang.gif'; % Output file name
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
% draw a black circle edge
x = 0; y = 0; r = 4;
th1 = 0:pi/50:2*pi;
xunit = r * cos(th1) + x;
yunit = r * sin(th1) + y;
plot(xunit, yunit,'-k');
hold on
% draw Yin part
th2 = linspace(pi/2,pi/2+pi,20);
n1 = min(f,20);
s = th2(1:n1);
vx = [x, r *cos(s)+x, x];
vy = [y, r *sin(s)+y, y];
patch(vx,vy,'k','EdgeColor','none');

% draw head of Yin&Yang fish
if f >20
    n2 = f - 20;
    n2 = min(n2,20);
    th3 = flip(th2);
    xw = 0; yw = 2; rw = 2;
    s = th3(1:n2);
    vx = [xw, rw *cos(s)+xw, xw];
    vy = [yw, rw *sin(s)+yw, yw];
    patch(vx,vy,'w','EdgeColor','none');
    xb = 0; yb = -2; rb = 2;
    th4 = linspace(pi/2, -pi/2, 20);
    s = th4(1:n2);
    vx = [xb, rb *cos(s)+xb, xb];
    vy = [yb, rb *sin(s)+yb, yb];
    patch(vx,vy,'k');
end

% draw eyes
if f >40
    n3 = f-40;
    r = linspace(0.01,0.55,8);
    th0 = 0:pi/50:2*pi;
    xk = 0; yk = 2;
    xw = 0; yw = -2;
    xunitk = r(n3) * cos(th0) + xk;
    yunitk = r(n3) * sin(th0) + yk;
    patch(xunitk, yunitk,'k');
    xunitw = r(n3) * cos(th0) + xw;
    yunitw = r(n3) * sin(th0) + yw;
    patch(xunitw, yunitw,'w');
end
axis off
axis equal
hold off
end