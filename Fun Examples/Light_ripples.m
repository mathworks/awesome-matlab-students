animateFrames();
function animateFrames()
    animFilename = 'Light_ripples.gif'; % Output file name
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

persistent S wgt dd2
 
if f == 1
rng default
tic

% Underwater scene.

% 1) Procedural ripples from 2 years ago
N=400;
H=randn(N);
y=1:N;
r=@round;
k=zeros(N);
k(r(rand(3)*N^2))=1;
k=conv2(k,ones(29),'same')<1;
for n=1:400
    d=gradient(H);
    g=1.4*(d+1)/6;
    m=mod(r(y+randn(N).*k*4),N)+1; 
    o=mod(r(y'+(5-9*d).*k),N)+1;
    H=conv2(H-g+accumarray([o(:),m(:)],g(:),[N,N]),ones(3)/9,'same');
end

% 2) Light caustics
[x,y]=meshgrid(linspace(0,1,N));
xyzg=[x(:),y(:),x(:)*0];
xyzi=rand(N*5,3);
zscl=0.1;
xyzi=[xyzi-[0,0,1];xyzi;xyzi+[0,0,1]].*[1,1,zscl];
kdOBJ = KDTreeSearcher(xyzi);
zvl=0:.021:1;
clear distS
for n = 1:48
    [idx, dist] = knnsearch(kdOBJ,xyzg+[0,0,zvl(n)*zscl],'k',1);
    distS(:,:,n)=reshape(erf(dist.^2*150), size(x));
end


toc
rng default
% 3) Weight map between color schemes
dst = sqrt((x-.1).^2 + (y-.1).^2);
wgt = erf((1-dst*3)*3)/2+.5;
wga = erf((1-dst*1.5)*5)/2+.5;
% distS = (distS+0.8).^((wgt+0.2)/1.2)-.8;
distS = distS.*(wgt+.2)/1.2;

% 4) Color schemes
cst = distS(:,:,1);
cR = rescale(min(6*cst, 1), 0.7, 1);
cst3 = cat(3,cR.^8,cR.^2.5,cR.^0.9);
cst3B = cat(3,cR,cR.^1.1,cR.^1.8);
cnw = cst3B.*wgt + cst3.*(1-wgt); 

% x(wga<1e-2)=nan;
% y(wga<1e-2)=nan;
% imagesc(wga)
%
%%
clf
cv=.63; 
CC=[cv.^8,cv.^2.5,cv.^.9];
set(gcf,'color',CC);

% "Light" causes loop to time out, so this leverages surfnorm to calculate
% lambertian scattering from a local source
cpxyz = [.4,.4,.7]*1;
xyzl = ([x(:),y(:),0*x(:)]-cpxyz)';
xyzl = xyzl./vecnorm(xyzl);
[nx,ny,nz]=surfnorm(x,y,H/2000+randn(size(H))/6000);
dd2 = abs(reshape(sum(xyzl.*[nx(:),ny(:),nz(:)]'),[400,400]));
dd2=dd2.^.9;
S=surf(x,y,H/2000+randn(size(H))/6000,cnw.*dd2, 'SpecularStrength', 0, 'AmbientStrength', 0, 'DiffuseStrength', 1,'FaceAlpha','flat','AlphaData',wga);

shading flat

camproj p

campos([0.0, 0.0, 0.15]);
camtarget([0.5, 0.5, 0]*0.4);
camva(30);

% light('position', [.5, .5, .5], 'style', 'local');
% light('position', [.5, .5, .5], 'style', 'local','color',[1,1,1]*.3);
axis equal off
axis([-2,2,-2,2,-2,2]);
S.UserData=distS;
% lighting g
%%
end
    ags = linspace(0,2*pi,49);
% for n = 1;
    cst = S.UserData(:,:,f);
    cR = rescale(min(6*cst, 1), 0.7, 1);
    cst3 = cat(3,cR.^8,cR.^2.5,cR.^0.9);
    cst3B = cat(3,cR,cR.^1.1,cR.^1.8);
     
    cnw = cst3B.*wgt + cst3.*(1-wgt);  
    camup([0, sin(ags(f)+pi/2)*0.05, cos(ags(f)+pi/2)*0.05+1]);
    campos([0.0, 0.0, 0.15+sin(ags(f))/45]);
    
    S.CData = cnw.*dd2;
    % drawnow;
    toc

end


      
    
    