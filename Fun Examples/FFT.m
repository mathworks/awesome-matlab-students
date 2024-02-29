animateFrames();
function animateFrames()
    animFilename = 'FFT.gif'; % Output file name
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
N = 32;
y1 = -ones(N,1);
y1(end/2+1:end) = 1;

h = fft(y1);
w = zeros(N, (length(h))/4);

for m0=1:size(w,2)
    w(:,m0) = abs(h(m0*2)*2/length(h))*cos(2*pi*(m0*2-1)*(0:N-1)/N+angle(h(m0*2)));
end
N=N*2;
w=repmat(w,2,1);
t=linspace(-1,1,N);
figure(1)
cla
hold on;
m0=f;
grid on;
if m0>6
    yy = sum(w(:,1:ceil(m0/6)-1),2) + w(:,ceil(m0/6))*(mod(m0-1,6)+1)/6;
    plot3(t, 0*ones(N,1), yy,'Color',[0.8500 0.3250 0.0980],'LineWidth',1)
    plot3(t, 0*ones(N,1), w(:,ceil(m0/6)),'Color',[0.8500 0.3250 0.0980 1-(mod(m0-1,6)+1)/6])
else
    yy = sum(w(:,1:1),2);
    plot3(t, 0*ones(N,1), yy,'Color',[0.8500 0.3250 0.0980],'LineWidth',1)
end
str=cell(5,1);
for m2=1:5
    if(ceil(m0/6)+m2 <= size(w,2))
        plot3(t, (m2-(mod(m0-1,6)+1)/6)*ones(N,1), w(:,ceil(m0/6)+m2),'color',[0 0.4470 0.7410])
        str{m2} = ceil(m0/6)+m2;
    end
end
yticks((1:6)-(mod(m0-1,6)+1)/6)
yticklabels(str)
axis([-1 1 0 6 -1.3 1.3])
view([30 30]);
xlabel('time')
ylabel('order')
zlabel('amplitude')
title('FFT')

end


      
    
    