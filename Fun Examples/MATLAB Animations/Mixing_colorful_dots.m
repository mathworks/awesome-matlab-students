animateFrames();
function animateFrames()
    animFilename = 'Mixing_colorful_dots.gif'; % Output file name
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

% Credit
% https://twitter.com/Pixelated_Donut/status/1726602167019241671
% https://twitter.com/Yugemaku/status/1726559476172616047
persistent c s

if isempty(c)
    c = colororder;
    idx = randi(6,200,1);
    c = c(idx,:);
    s = ones(200,1)*25;
    N = 60;
    s(N) = 100;
    c(N,:) = [1,1,1];
end

phi = (1+sqrt(5))/2;
factor = 3.0/2;


%% T = 0~0.5
T = 1/48*f;
i = 1:200;

a2 = mod(phi*i-T,1);
a2 = a2 - 0.2;
a2(a2<0) = 0;
a2 = a2/0.8;
alpha = 2*pi*(2*phi*i - a2.^factor);
    
x = sin(alpha).*sqrt(i);
y = cos(alpha).*sqrt(i);

scatter(x,y,s,c,'filled');
axis off equal
set(gcf,'Color','black')
xlim([-15,15]);
ylim([-15,15]);

end


      
    
    