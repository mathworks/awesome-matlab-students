animateFrames();
function animateFrames()
    animFilename = 'lissajous.gif'; % Output file name
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
persistent thetaList ratio pntHdl lineColHdl lineRowHdl Xpnt Ypnt XlineCol YlineCol XlineRow YlineRow lineMatHdl
if f==1||f==49
ax=gca;hold on
ax.Color=[102,117,149]./255;
ax.Position=[0,0,1,1];
ax.XColor='none';ax.XLim=[.4,8.6];ax.YTick=[];
ax.YColor='none';ax.YLim=[.4,8.6];ax.XTick=[];
ax.DataAspectRatio=[1,1,1];
ax.InnerPosition=[0,0,1,1];

% 绘制圆圈
t=linspace(0,2*pi,200)';
X=cos(t).*0.42;Y=sin(t).*0.42;
plot(X+ones(1,7),Y+(1:7),'Color',[1,1,1,.7],'LineWidth',2);
plot(X+(2:8),Y+ones(1,7).*8,'Color',[1,1,1,.7],'LineWidth',2);
% 绘制点和基础线
[Xpnt,Ypnt]=meshgrid(2:8,1:7);
pntHdl=plot(Xpnt+0.42,Ypnt,'Color',[1,1,1],'LineStyle','none',...
    'Marker','o','MarkerFaceColor',[1,1,1]);
XlineCol=2:8;YlineCol=8.*ones(1,7);
XlineRow=ones(1,7);YlineRow=1:7;
lineColHdl=plot([XlineCol;Xpnt(1,:)]+0.42,[YlineCol;Ypnt(1,:)],...
    'Color',[1,1,1,.5],'LineStyle','-.','Marker','o','MarkerFaceColor',[1,1,1]);
lineRowHdl=plot([XlineRow;Xpnt(:,end)']+0.42,[YlineRow;Ypnt(:,end)'],...
    'Color',[1,1,1,.5],'LineStyle','-.','Marker','o','MarkerFaceColor',[1,1,1]);
% 绘制折线句柄
for m=1:7
    for n=1:7
        lineMatHdl{m,n}=plot(Xpnt(n,m),Ypnt(n,m),...
            'Color',[1,1,1,.6],'LineWidth',1.2);
    end
end
ratio=1:7;
thetaList=linspace(0,2*pi,49);
end
% 循环绘图
theta=thetaList(f).*ratio;
tX=cos(theta).*0.42;
tY=sin(theta).*0.42;
for j=1:7
    pntHdl(j).XData=Xpnt(:,j)+tX(j);
    pntHdl(j).YData=Ypnt(:,j)+tY(end:-1:1)';
    lineColHdl(j).XData=[XlineCol(j);Xpnt(1,j)]+tX(j);
    lineColHdl(j).YData=[YlineCol(j);Ypnt(1,j)]+[tY(j);tY(7)];
    lineRowHdl(j).XData=[XlineRow(j);Xpnt(j,end)']+[tX(8-j);tX(7)];
    lineRowHdl(j).YData=[YlineRow(j);Ypnt(j,end)']+tY(8-j);
end
%
ttList=thetaList(1:f);
for m=1:7
    for n=1:7
        lineMatHdl{m,n}.XData=cos(ttList.*m).*0.42+Xpnt(n,m);
        lineMatHdl{m,n}.YData=sin(ttList.*(8-n)).*0.42+Ypnt(n,m);
    end
end
end


      
    
    