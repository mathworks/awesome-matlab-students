animateFrames();
function animateFrames()
    animFilename = 'Emerald.gif'; % Output file name
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
% Snake skin with keeled scales
% (~ Emerald viper)
persistent frms     % All we will be keeping is the cell array of frames because
                    % the whole loop will run on the first function call.
                    % The reason for this is that some spatially variant
                    % blurring will be applied to the RGB data on each
                    % loop.
tic
if f == 1
    
% Base texture scale
x=linspace(-4, 4, 400);
% Shape of scale - ovalish but extended on one side
m=1-(erf(50*(3*x'.^2+x.^2-.5)+max(24*x.^5,-20))+1)/2;   % Basic scale shape & mask
m=max(m,circshift(m,[0,5]));                            % Needs to be a bit longer
% Scales are slightly curved
s=m.*cos(2*x');
s=s-x.*m/3;         % Needs change in height so that it overlaps well
k=m.*rescale(1./(abs(x') + 0.01))*0.1.*(min(0,x-0.3).^2);           % Add keel
s=s+k+conv2(m.*randn(size(k))/100, ones(1,11)/11, 'same');          % Some textury-noise
% Now the tiling...
so=s;
SS=40;
for n = 1:9
    so = max(so, circshift(s, n*SS));
end
so = max(so, circshift(so, [SS/2, 40]));
for n = 1:4;
    so = max(so, circshift(so, [0, 80*n]));
end
so(so<0.7)=0.7;
% Turn into radial distance
so=so*0.4;
so=so'+10;
so=flipud(so);
% More tiling
so=[so,so,so,so];
so=[so;so;so;so];
% Apply to snake body. Snakes are not cylindrical, they have a prominent
% spine and flat underside (sort of / lots of variation here)
a=linspace(0,2*pi,size(so, 2))-pi;
sob=so;
so = so + (exp(-(a).^2*50) - exp(-(a+pi).^2*2)*2)- exp(-(a-pi).^2*2)*2;
x=sin(a).*so;
y=cos(a).*so;
z=linspace(-1,1,size(x,1))'.*ones(1,length(a))*8*3;
% Woops, that was too high resolution. Cut off the backside so it renders
x=x(:, (1:650)+750);
y=y(:, (1:650)+750);
z=z(:, (1:650)+750);
sob=sob(:, (1:650)+750);
% Still too high resolution. Decimate...
x=x(1:2:end, 1:2:end);
y=y(1:2:end, 1:2:end);
z=z(1:2:end, 1:2:end);
sob=sob(1:2:end, 1:2:end);
% Plot
S=surf(x,z,y,rescale(sob).*cat(3,0.1,0.8,0), 'SpecularStrength', 0.5, 'DiffuseStrength', 1, 'AmbientStrength', 0);
shading flat
% Too pixelated. Make larger
S.Parent.Parent.Position(3:4)=[1120,840];
% Camera setup etc.
axis equal off
set(gcf, 'color', 'k');
light('position', [0, 0, 1]);
view([90, 10]);
camtarget([0,-4,5]);
campos([265, 0.05*n*4, 48]);
camproj p
camva(5);
% Rotate snake through image in 48 frames
for n = 1:48   
    S.YData = z -.05*n*4;
    S.ZData = y - .004*(S.YData+4).^2;
    drawnow;
    frms{n}=getframe(gcf);
end
% Close because we are actually going to work with the rgb data
close
end
% Now lens blur simulation -> weight w/cosine tapering
wn=min((1-cos(linspace(0, 2*pi, size(frms{f}.cdata(:,:,1),2))))/1.9, 1);
IG=flt(frms{f}.cdata,wn,2);
% Decimate
IG=IG(1:2:end, 1:2:end, :);
image(IG);
axis equal off
camva(6)
toc
end
% Local smoother
function in=flt(in,wgt,nits)
if nargin == 1
    wgt = zeros(size(in(:,:,1)));
    nits=1;
end
in = double(in)/255;
% Blur kernel
krn = [1, 2, 3, 4, 5, 4, 3, 2, 1]';
krn = krn*krn';
krn = krn/sum(krn(:));
% Apply to each color channel
for m = 1:3
    for mm = 1:nits
        in(:, :,m) = wgt.*in(:,:,m) + (1-wgt).*conv2(in(:,:,m), krn, 'same');
    end
end
% S.D.G.
end


      
    
    