animateFrames();
function animateFrames()
    animFilename = 'rose_bouquet.gif'; % Output file name
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
function drawframe(g)
if g==1
s=@sin;c=@cos;f=@surface;e=@size;
[xr,tr]=meshgrid((0:24)./24,(0:0.5:575)./575.*20.*pi+4*pi);
p=(pi/2)*exp(-tr./(8*pi));
cr=s(15*tr)/150;
u=1-(1-mod(3.6*tr,2*pi)./pi).^4./2+cr;
yr=2*(xr.^2-xr).^2.*s(p);
rr=u.*(xr.*s(p)+yr.*c(p));
hr=u.*(xr.*c(p)-yr.*s(p));
rb=0:.01:1;
tb=linspace(0,2,151);
w=rb'*((abs((1-mod(tb*5,2))))/2+.3);
xb=w.*c(tb*pi);
yb=w.*s(tb*pi);
zb=@(a)(-c(w*a*pi)+1).^.2;
Zb=zb(1.2);
cL=[.33 .33 .69;.68 .42 .63;.78 .42 .57;.96 .73 .44];
cMr=sH(hr,cL);
cMb=sH(Zb,cL.*.4+.6);
yz=72*pi/180;
rx1=pi/8;
rx2=pi/9;
Rz2=[c(yz),-s(yz),0;s(yz),c(yz),0;0,0,1];
Rz=@(n)[c(yz/n),-s(yz/n),0;s(yz/n),c(yz/n),0;0,0,1];
Rx=@(n)[1,0,0;0,c(n),-s(n);0,s(n),c(n)];
Rz1=Rz(2);Rz3=Rz(3);
Rx1=Rx(rx1);Rx2=Rx(rx2);
hold on
cp={'EdgeAlpha',0.05,'EdgeColor','none','FaceColor','interp','CData',cMr};
f(rr.*c(tr),rr.*s(tr),hr+0.35,cp{:})
[U,V,W]=rT(rr.*c(tr),rr.*s(tr),hr+0.35,Rx1);
V=V-.4;
f(U,V,W-.1,cp{:})
dS(U,V,W-.1)
for k=1:4
[U,V,W]=rT(U,V,W,Rz2);
f(U,V,W-.1,cp{:})
dS(U,V,W-.1)
end
[u1,v1,w1]=rT(xb./2.5,yb./2.5,Zb./2.5+.32,Rx2);
v1=v1-1.35;
[u2,v2,w2]=rT(u1,v1,w1,Rz1);
[u3,v3,w3]=rT(u1,v1,w1,Rz3);
[u4,v4,w4]=rT(u3,v3,w3,Rz3);
U={u1,u2,u3,u4};
V={v1,v2,v3,v4};
W={w1,w2,w3,w4};
for k=1:5
for b=1:4
[ut,vt,wt]=rT(U{b},V{b},W{b},Rz2);
U{b}=ut;V{b}=vt;W{b}=wt;
f(U{b},V{b},W{b},cp{3:7},cMb)
dS(U{b},V{b},W{b})
end
end
a=gca;axis off
a.Position=[0,0,1,1]+[-1,-1,2,2]./6;
axis equal
end
view(g*2.1,35);
function c=sH(H,cList)
X=(H-min(min(H)))./(max(max(H))-min(min(H)));
x=(0:e(cList,1)-1)./(e(cList,1)-1);
u=cList(:,1);v=cList(:,2);w=cList(:,3);
q=@interp1;
c(:,:,1)=q(x,u,X);
c(:,:,2)=q(x,v,X);
c(:,:,3)=q(x,w,X);
end
function [U,V,W]=rT(X,Y,Z,R)
U=X.*0;V=Y.*0;W=Z.*0;
for i=1:e(X,1)*e(X,2)
v=[X(i);Y(i);Z(i)];
n=R*v;U(i)=n(1);V(i)=n(2);W(i)=n(3);
end
end
function dS(X,Y,Z)
[m,n]=find(Z==min(min(Z)));
m=m(1);n=n(1);
x1=X(m,n);y1=Y(m,n);z1=Z(m,n)+.03;
x=[x1,0,(x1.*c(pi/3)-y1.*s(pi/3))./3].';
y=[y1,0,(y1.*c(pi/3)+x1.*s(pi/3))./3].';
z=[z1,-.7,-1.5].';
p=[x,y,z];
N=50;
t=(1:N)/N;
q=e(p,1)-1;
F=@factorial;
c1=F(q)./F(0:q)./F(q:-1:0);
c2=((t).^((0:q)')).*((1-t).^((q:-1:0)'));
p=(p'*(c1'.*c2))';
plot3(p(:,1),p(:,2),p(:,3),'Color',[88,130,126]./255)
end
end


      
    
    