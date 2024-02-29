animateFrames();
function animateFrames()
    animFilename = 'Graph_Equation_of_Apple.gif'; % Output file name
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
global theta1 theta2 theta3 heartHdl star1Hdl star2Hdl hpnts sx1 sx2 sy1 sy2
if f==1
% 所需匿名函数
col1Func=@(n) repmat([255,158,196]./255,[n,1])+repmat([-39,-81,-56]./255,[n,1]).*repmat(rand([n,1]),[1,3]);
col2Func=@(n) repmat([118,156,216]./255,[n,1])+repmat([137,99,39].*.1./255,[n,1]).*repmat(rand([n,1]),[1,3]);
szFunc=@(n) rand([n,1]).*15+8;

hold on
% 计算爱心点位置并绘制爱心
n=120;
x=linspace(-3,3,n); 
y=linspace(-3,3,n);
z=linspace(-3,3,n);
[X,Y,Z]=ndgrid(x,y,z);

F=(X.^2+Y.^2 - (X.^2+Y.^2+0.5*Z.^2).^2).*(abs(2.2*sqrt(X.^2+Y.^2)+0.2*Z-0.08)+abs(2.2*sqrt(X.^2+Y.^2)-0.2*Z+0.08)-0.25)...
    .*   (abs((2.2*X+0.826).^2+abs(3.3*Z+1.54*X-2.7148)+11*Y)+abs((2.2*X+0.826).^2+abs(3.3*Z+1.54*X-2.7148)-11*Y)-1);

FV=isosurface(F,0);
hpnts=FV.vertices;
hpnts=(hpnts-repmat(mean(hpnts),[size(hpnts,1),1])).*repmat([.75,.7,.7],[size(hpnts,1),1]);
hpnts=hpnts+rand(size(hpnts)).*.7;
heartHdl=scatter3(hpnts(:,1),hpnts(:,2),hpnts(:,3),'.','SizeData',5,'CData',col1Func(size(hpnts,1)));

% 计算星星位置并绘制星星
sx1=rand([2e3,1]).*120-60;
sy1=rand([2e3,1]).*120-60;
sz1=ones(size(sx1)).*-30;
star1Hdl=scatter3(sx1,sy1,sz1,'.','SizeData',szFunc(length(sx1)),'CData',col2Func(size(sx1,1)),'LineWidth',1);
sx2=rand([2e3,1]).*120-60;
sy2=rand([2e3,1]).*120-60;
sz2=rand([2e3,1]).*120-20;
star2Hdl=scatter3(sx2,sy2,sz2,'.','SizeData',szFunc(length(sx2)),'CData',[1,1,1]);

% 坐标区域修饰
ax=gca;
ax.XLim=[-20,20];
ax.YLim=[-20,20];
ax.ZLim=[-20,20];
ax.Projection='perspective';
ax.DataAspectRatio=[1,1,1];
view(152,14);
ax.Color=[0,0,0];
ax.XColor='none';
ax.YColor='none';
ax.ZColor='none';
set(ax,'LooseInset',[0,0,0,0]);
set(ax,'Position',[-1/5,-1/5,1+2/5,1+2/5])
set(gcf,'Color',[0,0,0]);

% text(0,0,20,'slandarer','Color','w','HorizontalAlignment','center')

% 旋转爱心和星星
theta1=0;theta2=0;theta3=0;
else
    theta1=theta1-pi/48;
    theta2=theta2-0.003;
    theta3=theta3-0.02;
    set(heartHdl,'XData',hpnts(:,1).*cos(theta1)-hpnts(:,2).*sin(theta1),...
                 'YData',hpnts(:,1).*sin(theta1)+hpnts(:,2).*cos(theta1))
    set(star1Hdl,'XData',sx1.*cos(theta2)-sy1.*sin(theta2),...
                 'YData',sx1.*sin(theta2)+sy1.*cos(theta2))
    set(star2Hdl,'XData',sx2.*cos(theta3)-sy2.*sin(theta3),...
                 'YData',sx2.*sin(theta3)+sy2.*cos(theta3))
end
end


      
    
    