animateFrames();
function animateFrames()
    animFilename = 'Moonrun.gif'; % Output file name
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

if f == 1

%% Make landscape
clf
rng(4,'v4');
N=200;
q=linspace(-1,1,N);
k=abs(ifft2(exp(6i*randn(N))./(q.^2+q'.^2+1e-9)));
k=rescale(1./(k+1));
imagesc(k);

[x,y]=meshgrid(linspace(-1,1,N*7)*7);
k=repmat(k,[7,7]);
surf(x,y,k/2,'edgeC','none','SpecularS',0);
axis equal
colormap(copper)


hold on;

% Make moon
bscl = 1e5;

rng default

nl=1e4;
rd = rand(nl,1)/3+1;
po = randn(3,nl);
po = po./vecnorm(po);
[p,k,s]=SM(po',rd,7);

ms = mean(s);
ns = s - ms;
s = erf(ns*500)/50+ms;

[~,~,sb]=SM(po',randn(nl,1),1);


% Now, take a page from Adam D.' book for the craters
rng(1,'twister');
x = randn(3,16);     % Let's add 16 craters
x = x./vecnorm(x);

mfc = @(x,y,z)y.*(erf((x-z)*30)/2+.5);  % Using erf as the crater function...

for n = 1:size(x, 2)

    d = vecnorm(x(:,n)-p');
    s = mfc(d',s-1.14,rand(1)/2)+1.14;
end

s = s + sb/20;
s = (s-mean(s))/10+mean(s);
p2 = (p.'./vecnorm(p.'))'.*s;

E='EdgeC';
F='FaceC';
O='none';
G='FaceA';

% Plot moon
hold on;
bscl=1e1;
T2=trisurf(k,bscl*p2(:,1)+1*bscl,bscl*p2(:,2)+4*bscl,bscl*p2(:,3)+1*bscl,'FaceC','flat','FaceVertexCData',rescale(s,.4,1).*[1,1,1],E,O);       % Plot
material([0,1,0,10]);
axis equal off
set(gcf,'color','k');
light('position',[1,-1,1]); 
light('position',[1,-1,1]);

camproj p
campos([0,-7.2,.35]);
camva(40);


end

x = linspace(0, 1, 49)*2;
dx=mean(diff(x));
x = 0:dx:200*dx;
y = cos(pi*x)/15;
a=linspace(0,2*pi,49)-2;
% for n = 1:1:48
n=f;
    cpos = [0.05, -7.2+2, .42] + [y(n), x(n), y(n)/2];
    camup([0, sin(a(n))/2, cos(a(n))/2+1]);
    campos(cpos);
    camtarget([0.05, -7.2+2, .42] + [y(n+1), x(n+1), y(n+1)/2]);


1;

end

function [p,k,s]=SM(in,rd,r)
n=size(in,1);
k=convhull(in);                              % Points on "in" must lie on unit circle
c=@(x)sparse(k(:,x)*[1,1,1],k,1,n,n);        % Connectivity            
t=c(1)|c(2)|c(3);                            % Connectivity
f=spdiags(-sum(t,2)+1,0,t*1.)*r;             % Weighting
s=((speye(n)+f'*f)\rd);                      % Solve for s w/regularizer
p=in.*s;                                     % Apply
end