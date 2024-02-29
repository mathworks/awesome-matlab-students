animateFrames();
function animateFrames()
    animFilename = 'Xmas_Tree.gif'; % Output file name
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
global sp1 sp2 sHdl1 sHdl2
if f==1
h0=25;r0=12;a0=.5.*pi;
XFunc=@(h,r,a,z) (h-z)./h.*r.*cos(a.*z);
YFunc=@(h,r,a,z) (h-z)./h.*r.*sin(a.*z);
ZFunc=@(h,r,z) z+sqrt(12^2-((h-z)./h.*r).^2);
% 生成最外圈散点
Z0=linspace(0,12.5,150);
X0=XFunc(h0,r0,a0,Z0);
Y0=YFunc(h0,r0,a0,Z0);
% 生成中心点
ZC=ZFunc(h0,r0,Z0);
t0=linspace(.05,1,25)';
% 生成树枝上的散点
treeXYZ=zeros([length(Z0)*length(t0),3]);
for i=1:length(Z0)
    treeXYZ((i-1)*length(t0)+1:i*length(t0),:)=...
        [0,0,ZC(i)]+[X0(i),Y0(i),Z0(i)-ZC(i)].*t0;
end

ax=gca;hold on;
set(gcf,'Color',[22,32,51]./255);

% 绘制圣诞树
treeXYZ=treeXYZ+rand(size(treeXYZ))./3;
treeCData=repmat([0,235,81]./255,[length(Z0)*length(t0),1]);
treeCData=treeCData+rand(size(treeXYZ))./2;
treeCData(treeCData>1)=1;
scatter3(treeXYZ(:,1),treeXYZ(:,2),treeXYZ(:,3)-3,3,'o','filled','CData',treeCData,...
    'MarkerFaceAlpha',.7,'MarkerEdgeColor','none')

% 绘制水晶球
[ballX,ballY,ballZ]=sphere(20);
surf(ballX.*18,ballY.*18,ballZ.*15+8,'EdgeColor','none','FaceAlpha',.1);
colormap(gray);
light;lighting phong;shading interp;

% 绘制地面
[surfX,surfY]=meshgrid(linspace(-25,25,60));
surfZ=cos(hypot(surfX,surfY))-5;
surfZ=surfZ+rand(size(surfX)).*1.2;
surfX=surfX+rand(size(surfX))./1.8;
surfY=surfY+rand(size(surfX))./1.8;
scatter3(surfX,surfY,surfZ,3,'o','filled','CData',[91,131,253]./255,...
    'MarkerFaceAlpha',.4,'MarkerEdgeColor','none')
% 坐标区域修饰
set(ax,'XLim',[-27 27],'YLim',[-27,27],'ZLim',[-9,28],'PlotBoxAspectRatio',[1,1,.8],...
    'XColor','none','YColor','none','ZColor','none','Color',[22,32,51]./255,'View',[-37.5,19.5],...
    'Position',[-.5,-.2,2,1.4])

% 绘制雪花
sp1=rand(27,3);
sp1(:,1:2)=sp1(:,1:2).*50-25;
sp1(:,3)=sp1(:,3).*30;
sp2=rand(60,3);
sp2(:,1:2)=sp2(:,1:2).*50-25;
sp2(:,3)=sp2(:,3).*30;
sHdl1=plot3(sp1(:,1),sp1(:,2),sp1(:,3),'*','Color',[1 1 1]);
sHdl2=plot3(sp2(:,1),sp2(:,2),sp2(:,3),'.','Color',[.6,.6,.6]);
else
% 旋转图像、雪花飘落
    sp1(:,3)=sp1(:,3)-.1;sp2(:,3)=sp2(:,3)-.01;
    sp1(sp1(:,3)<-5,3)=30;sp2(sp2(:,3)<-5,3)=30;
    sHdl1.XData=sp1(:,1);sHdl1.YData=sp1(:,2);sHdl1.ZData=sp1(:,3);
    sHdl2.XData=sp2(:,1);sHdl2.YData=sp2(:,2);sHdl2.ZData=sp2(:,3);
    view([f,19.5]);
end
end


      
    
    