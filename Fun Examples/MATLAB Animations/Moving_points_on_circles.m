animateFrames();
function animateFrames()
    animFilename = 'Moving_points_on_circles.gif'; % Output file name
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
persistent thetaMesh dTheta R XMesh YMesh pntHdl
% 改变各个圆上点初始相位差
if f==1
alpha0=pi/6;

K=18;        % 圆形个数
R=sqrt(3)/2; % 圆形半径

[XMesh,YMesh]=meshgrid(1:K);
tList=linspace(0,2*pi,100);
tCos=[cos(tList).*R,nan]';
tSin=[sin(tList).*R,nan]';

% 利用nan间断点同时绘制K^2个圆
tX=tCos+XMesh(:)';tX=tX(:);
tY=tSin+YMesh(:)';tY=tY(:);
figure('Units','normalized','Position',[.3,.2,.5,.65]);
plot(tX,tY,'Color',[0,0,0,.2],'LineWidth',1)

% -----------------------------
% 坐标区域修饰
ax=gca;hold on;
ax.XLim=[0,K+1];
ax.YLim=[0,K+1];
ax.XColor='none';
ax.YColor='none';
ax.PlotBoxAspectRatio=[1,1,1];
ax.Position=[0,0,1,1];

% -----------------------------
% 绘制点
dTheta=2*pi/48;
alpha=flipud(XMesh+YMesh);
thetaMesh=alpha(:).*alpha0;
pntHdl=scatter(cos(thetaMesh).*R+XMesh(:),...
               sin(thetaMesh).*R+YMesh(:),...
               15,'filled','CData',[0,0,0]);
end
% -----------------------------
% 循环绘图
thetaMesh=thetaMesh+dTheta;
pntHdl.XData=cos(thetaMesh).*R+XMesh(:);
pntHdl.YData=sin(thetaMesh).*R+YMesh(:);
end


      
    
    