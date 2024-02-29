animateFrames();
function animateFrames()
    animFilename = 'Christmas_tree.gif'; % Output file name
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
function drawframe(n)
persistent H0 H1 H2 s w
if n==1
tF=@(h)[h(1),h(h>0&h<=3).*0+1.5,8-(h(h>3)-3).*0.3636];
[X,Y,Z]=cylinder(tF(0:0.2:25));
% 随机移动树冠上点的位置
Z=Z.*25;
i=1:21;j=16:126;
a=atan(Y(j,i)./X(j,i));
D=rand(111,21)-0.5;
X(j,i)=X(j,i)+cos(a).*D;
Y(j,i)=Y(j,i)+sin(a).*D;
Z(j,i)=Z(j,i)+(rand(111,21)-0.5).*0.5;
X(:,end)=X(:,1);Y(:,end)=Y(:,1);Z(:,end)=Z(:,1);
% 绘制圣诞树
ax=gca;hold on;c=[22,32,51]./255;
set(gcf,'Color',c);
surfl(X,Y,Z,'light');
% 当前坐标区域修饰
set(ax,'PlotBoxAspectRatio',[1,1,1.2],'Color',c,'View',[-37.5,4],'Colormap',bone(),'Position',[0,0,1,.9]);
axis([-10,10,-10,10,0,30])
lighting phong;shading interp;axis off
% 绘制星星
MF='MarkerFaceColor';ME='MarkerEdgeColor';MS='MarkerSize';MA='MarkerFaceAlpha';
plot3(0,0,25.6,'p',MS,24,MF,[255,223,153]/255,ME,'none','LineWidth', 1);
H0=scatter3(0,0,25,6e3,'o',MF,'w',ME,'w','MarkerEdgeAlpha',0,MA, 0.1);
% 绘制圣诞树上的彩灯
lX=@(h,r,a,z) (h-z)./h.*r.*cos(a.*z);
lY=@(h,r,a,z) (h-z)./h.*r.*sin(a.*z);
h=25;r=8;
lZ1=linspace(4,25-4,200);a1=0.3*pi;
lX1=lX(h,r*1.4,a1,lZ1);
lY1=lY(h,r*1.4,a1,lZ1);
plot3(lX1,lY1,lZ1+.1,'.','LineWidth',2,'Color',[253,249,220]/255,MS,4)
lZ1=linspace(4,25-4,45);a1=0.3*pi;
lX1=lX(h,r*1.2,a1,lZ1);
lY1=lY(h,r*1.2,a1,lZ1);
scatter3(lX1,lY1,lZ1+.1,300,ME,'none',MF,[253,249,220]/255,MA,.08)
scatter3(lX1,lY1,lZ1+.1,50,ME,'none',MF,[231,217,129]./255,MA,.95)
% 绘制礼物
dP(2,-4,0,3,3,2);
dP(-4,3,0,2,3,1.5);
dP(5,3,0,4,3,3);
dP(-7,-5,0,5,3,1);
dP(-9,-6,0,2,2,2);
dP(0,4,0,4,3,3);
    
% 绘制雪花
s=rand(70,3);
s(:,1:2)=s(:,1:2).*26-13;
s(:,3)=s(:,3).*30;
w=rand(90,3);
w(:,1:2)=w(:,1:2).*26-13;
w(:,3)=w(:,3).*30;
H1=plot3(s(:,1),s(:,2),s(:,3),'*','Color',[1 1 1]);
H2=plot3(w(:,1),w(:,2),w(:,3),'.','Color',[.6,.6,.6]);
end
% 旋转图像、雪花飘落
H0.SizeData=6e3+sin(n/5).*1e3;
s(:,3)=s(:,3)-.2;w(:,3)=w(:,3)-.02;
s(s(:,3)<0,3)=30;w(w(:,3)<0,3)=30;
H1.XData=s(:,1);H1.YData=s(:,2);H1.ZData=s(:,3);
H2.XData=w(:,1);H2.YData=w(:,2);H2.ZData=w(:,3);
view([n*2,4]);
    function dP(x,y,z,sx,sy,sz)
        p=ones(1,5)/2;
        U=[p; 0 1 1 0 0; 0 1 1 0 0; 0 1 1 0 0;p];
        V=[p; 0 0 1 1 0; 0 0 1 1 0; 0 0 1 1 0;p];
        W=[0*p;0*p;p;2*p;2*p];
        p=@repmat;
        rM=cat(3,p(rand,[5,5])./2+.5,p(rand,[5,5])./2+.5,p(rand,[5,5])./2+.5);
        surf((U*sx+x),(V*sy+y), (W*sz+z),'CData',rM);
    end
end



      
    
    