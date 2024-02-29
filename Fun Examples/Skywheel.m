animateFrames();
function animateFrames()
    animFilename = 'Skywheel.gif'; % Output file name
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

persistent u w c gu g1 g2 c1 cd a0;
cp=@(a,c) colormap(a,c);

if f==1

rd=@(v) round(v);
sf=@(x,y,z) surface(x,y,z,EdgeColor='no');


n=1e2;

[x,y,z]=mkp(10,9.8,n);
z=.2*z-.1;

[x1,y1,z1]=sphere(4);
x1=.1*rd(x1);
y1=.1*rd(y1);
z1=12*rd(z1);

[z2,y2,x2]=mkp(1,.95,n);
z2=z2+12;
x2=.1*x2-.05;

[z3,y3,x3]=mkp(.9,.01,n);
z3=z3+12;
x3=.9*x3-.45;

a0=axes;
view(3);

r0=30;
[x0,y0,z0]=sphere(n);
sf(r0*x0,r0*y0,r0*z0);

hold on;

c0=cp(a0,'abyss');
c0=flip(c0);
c0(:,1:2)=c0(:,1:2)/2;
c0(:,3)=c0(:,3)/1.4;

c1=cp(a0,'sky');
cp(a0,c1);

cd=(c0-c1)/48;

rs=25;
ns=2e2;
ts=rand(ns, 1)*pi+pi;
ps=acos(rand(ns, 1));
xs=rs*sin(ps) .* cos(ts);
ys=rs*sin(ps) .* sin(ts);
zs=rs*cos(ps);

rdsz=3*rand(ns, 1);
rdc=repmat((rand(ns, 1)+1)*.5, 1, 3);

u=scatter3(xs,ys,zs,rdsz,rdc,'fi');

gu=hgtransform(Pa=a0);
set(u,Pa=gu);

campos([-10 -2 5]);
camtarget([0 -15 10]);
camva(49);

axis equal off;

a1=axes;
view(3);

cm=cp(a1,'spring');
cm=cm/2;
cp(a1,cm);
material metal;

light(Po=[-10 0 20],St='local');
light(Po=[-10 -30 5],St='local');
light(Po=[-20 -20 20],Col=[.7 .7 .5],St='local');

axis equal off;

s=[1 .8 .7];

for i=1:3
    x=s(i)*x;
    y=s(i)*y;
    z=s(i)*z;
    w(i+12)=sf(z-.5,y,x);
    w(i+14)=sf(z+.5,y,x);
end

t=pi/6;
rx=[1 0 0;0 cos(t) -sin(t);0 sin(t) cos(t)];

for i=1:6
    [x1,y1,z1]=rot(x1,y1,z1,rx);
    w(i)=sf(x1-.5,y1,z1);
    w(i+6)=sf(x1+.5,y1,z1);
end

for i=1:12
    [x2,y2,z2]=rot(x2,y2,z2,rx);
    c(i,1)=sf(x2-.4,y2,z2);
    c(i,2)=sf(x2+.4,y2,z2); 
end

for i=1:12
    [x3,y3,z3]=rot(x3,y3,z3,rx);
    c(i,3)=sf(x3,y3,z3);
end

alpha(c(:,3),0.2);

g1=hgtransform(Pa=a1);
set(w,Pa=g1);

g2=hgtransform(Pa=g1);
set(c,Pa=g2);

campos([-10 -2 5]);
camtarget([0 -15 10]);
camva(49);

end

r=f*pi/6/48;
rx1=makehgtform(xrotate=r);
tl1=makehgtform(translate=[0 -sin(r) -cos(r)]);
set(g1,Ma=rx1);
set(g2,Ma=tl1);
rx2=makehgtform(yrotate=pi/9,zrotate=r/10);
set(gu,Mat=rx2);

if f<=24
    c1=c1+cd;
    alpha(u,f/24)
else
    c1=c1-cd;
    alpha(u,(48-f)/24)
end
cp(a0,c1);

end

function [x,y,z]=mkp(or,ir,n)
    x=zeros(5,n+1);
    y=x;
    z=x;
    [x([1 4],:),y([1 4],:),z([1 4],:)]=cylinder(ir,n);
    [x(2:3,:),y(2:3,:),z(2:3,:)]=cylinder(or,n);
    x(5,:)=x(1,:);
    y(5,:)=y(1,:);
    z(5,:)=z(1,:);
end

function [x,y,z]=rot(x,y,z,t)
    r=@(v,s) reshape(v,s);
    s=size(x);
    p=[x(:) y(:) z(:)]';
    p=(t*p)';
    x=r(p(:,1),s);
    y=r(p(:,2),s);
    z=r(p(:,3),s);
end


      
    
    