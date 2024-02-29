animateFrames();
function animateFrames()
    animFilename = 'Lanterns.gif'; % Output file name
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

tic
persistent frms     % Once again, doing all the primary plotting at f==1 and just
                    % Storing the frame data

rng default

if f==1

NL=200;                                     % Number of lanterns
xyzL=rand(3,NL).*[6;6;3]*10+[0;0;2]*1;      % Locations

% Create lanterns & interiors and store handles
for n = 1:NL
    [xc,yc,zc,cmp]=lantern(.6+.4*rand(1),(rand(1)-.5)*.1);
    r=sqrt(xc(1).^2+yc(1).^2);
    [xl,yl,zl]=ll(r,zc(1));
    S{n}=warp(xc+xyzL(1,n),yc+xyzL(2,n),zc+xyzL(3,n),cmp);
    hold on;
    S2{n}=warp(xl+xyzL(1,n),yl+xyzL(2,n),zl+xyzL(3,n),cmp(1:10,1,:).^.5);
    C1{n}=S{n}.CData;
    C2{n}=S2{n}.CData;
end

% Twinkler
lgt=exp(-linspace(-1,1,49).^2*200)'*ones(1,NL);
for n=1:NL
    lgt(:,n)=1-circshift(lgt(:,n),randi(48,1))*rand(1)*.7;
end

% This lantern will be the focus of the scene
sl=[5,5,3];
[xc,yc,zc,cmp]=lantern(.6+.4*rand(1),(rand(1)-.5)*.1);
r=sqrt(xc(1).^2+yc(1).^2);
[xl,yl,zl]=ll(r,zc(1));
warp(xc+sl(1),yc+sl(2),zc+sl(3),cmp);
warp(xl+sl(1),yl+sl(2),zl+sl(3),cmp(1:10,1,:).^.6);

% Create motion vector for each lantern
rand(6,NL);                     % Jogging the random stream to a position I like
xm=randn(3,NL).*[1;.5;1]/40;

% Make figure big to reduce aliasing
S{1}.Parent.Parent.Position(3:4)=[1120,840];

% Pretty
axis equal off
set(gcf,'color',[.2,.1,.15]);
camproj p
camva(40);
camtarget(sl);

% Loop poses
for n = 1:48
    % Update lantern positions & twinkle
    for m = 1:NL
        S{m}.XData=S{m}.XData+xm(1,m);
        S2{m}.XData=S2{m}.XData+xm(1,m);
        S{m}.YData=S{m}.YData+xm(2,m);
        S2{m}.YData=S2{m}.YData+xm(2,m);
        S{m}.ZData=S{m}.ZData+xm(3,m);
        S2{m}.ZData=S2{m}.ZData+xm(3,m);
        S{m}.CData=C1{m}.*lgt(n,m);
        S2{m}.CData=C2{m}.*lgt(n,m);
    end
    % Update camera position
    campos([n/(17),n/100,n/80]);
    
    % Get frame, apply anti-alias filter and decimate
    R=getframe(gcf);
    R=imgaussfilt(double(R.cdata)/255,2);
    frms{n}=R(1:2:end,1:2:end,:);
end
close
end

% Load frame
IG=frms{f};

% Apply glow
for n = 1:2
IG=max(IG,imgaussfilt(IG,21));
end

% Final frame:
image(IG);
axis equal off
camva(5)
toc

end

% Lantern interior: a lit hemisphere
function [x,y,z]=ll(r,zo)

[x,y,z]=sphere(20);
x=x(11:end,:)*r;
y=y(11:end,:)*r;
z=z(11:end,:)+zo; 

end

% Lantern exterior
% f (randomized when called) controls shape
% s (randomized when called) controls hue

function [x,y,z,cmp]=lantern(f,s)

wn=tukeywin(30,f);
[xc,yc,zc]=cylinder(wn,20);
xc=xc(9:end,:);
yc=yc(9:end,:);
zc=zc(9:end,:);
zc=zc-.5;
x=xc.*(rescale(zc)+2)/3;
y=yc.*(rescale(zc)+2)/3;
z=erf(zc*4)*1.5;
z=z*max((min(1-f,.3)/.3),.5);

% Special colormap for lanterns
y1=[245,241,130]/255;
y2=[255,142,76]/255;
y3=[203,121,71]/255;
cmp=interp1([1,80,256]',[y1;y2;y3*.5],(1:256)','spline');

% Rotate hue of colormap
g=rgb2hsv(min(cmp,1));
g(:,1)=g(:,1)+s;
g(g<0)=1+g(g<0);
cmp=hsv2rgb(g);
cmp=permute(cmp,[1,3,2]);
%S.D.G.
end


      
    
    