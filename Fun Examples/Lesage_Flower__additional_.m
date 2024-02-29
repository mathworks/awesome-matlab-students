animateFrames();
function animateFrames()
    animFilename = 'Lesage_Flower__additional_.gif'; % Output file name
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
N = 400;
N2 = 4;

maxAz = 2*pi/N * 10;
dAz = maxAz*4/46;

w = 30 * 1.5;
edth = 2/4*pi;

offs = [0:dAz:maxAz*2 maxAz*2:-dAz:0];
if f==1; f=24; end
if f==48; f=47; end
off = offs(f);

if off <= maxAz
    dAz = off/maxAz;
    z = dAz;
else
    dAz = 1-max((off-maxAz*1.5),0)/maxAz;
    z = 1;
end
thickness = floor(1.2^(abs(24-f)));
le = 1 - abs(24-f)/24;
for n=1:N2
    alpha = ((N2-n+1)/N2) ^ 2;
    for l=1:thickness:N
        th = off + l*2*pi/N;
        r = 3^(n/N2*3);
        x1 = 1 * cos(th);
        y1 = 1 * sin(th);
        x2 = r * off*dAz*N/100*5*cos(le*th+edth*dAz+3*pi*le);
        y2 = r * off*dAz*N/100*6*sin(th+edth*dAz+3*pi*le);
        hewcolor = hsv2rgb([l/N n/N2*0.5+0.5 z*0.8+0.2]);
        plot3([x1 x2],[y1 y2],[0 z],color=[hewcolor alpha],LineWidth=thickness);
        if (n==1 && l==1)
            hold on
        end
    end
end
hold off
axis off
xlim([-w w])
ylim([-w w])
zlim([0 1])

end


      
    
    