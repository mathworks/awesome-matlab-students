animateFrames();
function animateFrames()
    animFilename = 'Matlon5.gif'; % Output file name
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

% Cloudy planet
% Thanks to Vinay for extending the compiling time limit!

persistent T T2 H pn H2

if f==1
rng(9,'twister');

% Some shorteners
u=@rescale;
v=@vecnorm;
rn=@(x)rand(x,1)/3+1;

% % % Creating the clouds

% Create a Fibonacci sphere with 5e4 points
n1=5e4;
po=FS(n1);

% Add noise & smooth
rd=rn(n1);
[p,k,s]=SM(po',rd,1);

% Now add storm swirling action
% - This will be done using the cross-product with points scattered on the
% surface

% Storms
xp=randn(3,26);
xp=xp./v(xp);
cpz=[-1,0,0];
xp=[xp,cpz(:),cpz(:)];

% Compute migration vectors
p2=p';
c=1;
for nn = 1:148
pob = p2./v(p2);
for n = 1:size(xp, 2)
if n == 1
xc = XP(xp(:,n),pob);
else
xc = xc + XP(xp(:, n),pob);
end
end
p2 = (p2./v(p2) + xc/1500).*s';

% Store for movement in animation
if nn>50&&mod(nn,2)==0
sn=(s'.*u(v(xc),1,1.5)).^.2;
pn{c}=pob.*sn;
tp=(erf((u(sn)-.5)*10)/2+.5)';
c=c+1;
end

end

% Shorteners
A='AmbientS';
E='EdgeC';
F='FaceC';
D='DiffuseS';
O='none';
S='SpecularS';
G='FaceA';

% Plot clouds
T=trisurf(k,pn{1}(1,:),pn{1}(2,:),pn{1}(3,:),E,O,F,'w',A,.1,D,1,G,'interp','FaceVertexAlphaD',tp,'AlphaDataM',O);       % Plot
hold on;

% % % Now for the planet surface...
rng(6,'twister');
n2=5e3;                 % Fewer points...
po=FS(n2);

% Same procedure but with different smoothing, compression for ocean values
% etc.
rd=rn(n2);
[~,k,s]=SM(po',rd,2);
s=(u(s)-.6)*10;
s(s<0)=erf(s(s<0));
s=(s+.5)/60+1;
p=po'.*s;

% Plot
trisurf(k,p(:,1),p(:,2),p(:,3),s,E,O,A,0,D,1,S,.2,F,'interp');       % Plot

% Make a terrain colormap
ci = [.1,.1,.3;.2,.7,.8;.2,.3,0;.9,.8,.6;1,.9,.8];
z=[0,.05,.1,.6,1];
c=interp1(z(:),ci,(0:255)'/255,'linear');
colormap(c);
caxis([1,1.1]);

% Add light etc.
axis equal off
set(gcf,'color','k');
b='position';
j=@light;
j(b,[-1,-1,1]);
j(b,[-1,-1,1],'color',[1,1,1]*.5);

% % % Have enough room left for some atmosphere effect. Make a ring around
% planet with gaussian transparency
[xf,yf,zf]=sphere(400);
scl=1.12;
xf=xf*scl;
yf=yf*scl;
zf=zf*scl;
ap=exp(-(u(xf)-.35).^2*150);
T2=surf(xf,yf,zf,'FaceC',[.5,.8,1],E,O,G,'flat','AlphaData',ap,A,.15,D,1,S,0);
V=@(x)hgtransform('Parent',gca);

% Transforms
H=V();
H2=V();
w='parent';
set(T2,w,H);
axis vis3d
s=randn(3,n1);

% Adding some stars in the background
s=9*s./v(s);
l=rand(1,n1);
scatter3(s(1,:),s(2,:),s(3,:),l*100,l'.*[1,1,1],'.',w,H2);

% Camera position etc.
campos([-8,0,0]);
camva(12);
camtarget([0,-.2,0]);
end

% Plot 
agc=0:.016:.78;
a=agc(f);
T.Vertices = pn{f}';
campos([-8*cos(a),-8*sin(a),0]);
S=@(x,y)set(x,'Matrix',makehgtform('zrotate',a*y));
S(H,1);
S(H2,.9);

end

% Fibonacci sphere
function s=FS(n)
N=0:n-1;
t=2*pi*N/((1+5^.5)/2);
p=acos(1-2*(N+.5)/n);
s=[cos(t).*sin(p);sin(t).*sin(p);cos(p)];
end

% Flow direction on sphere surface
function cp=XP(n,p)

n=n/vecnorm(n)*.9;
d=sqrt(sum((n - p).^2));
cp=cross(p, n.*ones(1,size(p,2)))./d.^2;

end

% Mesh smoothing
function [p,k,s]=SM(in,rd,r)
n=size(in,1);
k=convhull(in);                              % Points on "in" must lie on unit circle
c=@(x)sparse(k(:,x)*[1,1,1],k,1,n,n);        % Connectivity            
t=c(1)|c(2)|c(3);                            % Connectivity
f=spdiags(-sum(t,2)+1,0,t*1.)*r;             % Weighting
s=((speye(n)+f'*f)\rd);                      % Solve for s w/regularizer
p=in.*s;                                     % Apply
end


      
    
    