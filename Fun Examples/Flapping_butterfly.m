animateFrames();
function animateFrames()
    animFilename = 'Flapping_butterfly.gif'; % Output file name
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
% % sw: 48<=flapN<=1000;
flapN = 96; 
n=20000;
phi=23/180*pi;  
tM=70;  
flap=linspace(0,4*pi,flapN)';
theta=tM/180*pi*sin(flap+(pi-asin(17/tM))*ones(flapN,1));
% % % plot(vx,vy,'b-','MarkerSize',0.5); axis off
vt=linspace(0,20*pi,n)';
vx=sin(vt).*(exp(cos(vt))-2*cos(4*vt)-(sin(vt/12)).^5)*cos(phi);
vy=cos(vt).*(exp(cos(vt))-2*cos(4*vt)-(sin(vt/12)).^5)*cos(phi);
% % % sw: My color scheme;
cA=[0.298,0.7647,1];  cB=[1,0.0196,0.4863];
% CM=(1-abs(vx)/max(vx))*cA+abs(vx)/max(vx)*cB;
CM=(1-0.5*(abs(vx)/max(vx)+abs(vy)/max(abs(vy))))*cA+0.5*(abs(vx)/max(vx)+abs(vy)/max(abs(vy)))*cB;
% % % sw: Calculate positions;
PT=zeros(n,3,length(flap));
for ti=1:length(flap)
    PT(:,:,ti)=[zeros(n,1),vy,vy*sin(phi)]+[vx*cos(theta(ti)),abs(vx)*sin(theta(ti))*cos(pi/2+phi),abs(vx)*sin(theta(ti))*sin(pi/2+phi)];
end
% % % sw: Cuboid framework;
a=floor(max(abs(vx)))+1;
b=floor(max(vy))+1; 
c=floor(min(vy));
% figure;
set(gcf,'color','black');
xlim([-a,a]); ylim([c,b]);  zlim([-b,b]);
FW=[-a,c,-b; -a, b, -b; a, c, -b; -a, b, -b; -a,c,b; -a, b, b; a, c, b; -a, b, b];
% % % sw: Draw flapping butterfly;
% view(3); axis equal;
% figure(gcf);
clf;
tj=mod(f,flapN)+1;
scatter3(FW(:,1),FW(:,2),FW(:,3),0.1,[0,0,0],'.','MarkerFaceAlpha',0,'MarkerEdgeAlpha',0);  hold on;
scatter3(PT(:,1,tj),PT(:,2,tj),PT(:,3,tj),1,CM,'.'); hold on;
grid off; axis off;
axis vis3d;
view(-30+360*ti/length(flap),39);
end


      
    
    