animateFrames();
function animateFrames()
    animFilename = 'chinese_clock.gif'; % Output file name
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
persistent hdlSet lC nC lTM tN
if n==1
CLt='零一二三四五六七八九十';
WLt='一二三四五六日';
TLt='子丑寅卯辰巳午未申酉戌亥';

tN=datetime('now');
dNb=weekday(tN);
dNb=mod(dNb-2,7)+1;
tM=[tN.Year,tN.Month,tN.Day,dNb,...
    ceil((mod(tN.Hour+1,24)+1)/2),tN.Hour,tN.Minute,round(tN.Second)];
tM(6:8)=tM(6:8)+1;
lTM=tM;

% 计算获取年月日char矩阵
yLt=[CLt(str2num(num2str(tM(1))')'+1),'年'];
nLt=char(32.*ones(60,3));
for i=0:60
    tNm=CLt(str2num(num2str(i)')'+1);
    if length(tNm)>1,tNm=[tNm(1),'十',tNm(2)];end
    if length(tNm)>1&&abs(tNm(end))==38646,tNm(end)=[];end
    if length(tNm)>1&&abs(tNm(1))==19968,tNm(1)=[];end
    nLt(i+1,end-length(tNm)+1:end)=tNm;
end
mLt=[nLt(2:13,:),char(ones(12,1).*26376)];
dLt=[nLt(2:32,:),char(ones(31,1).*26085)];
wLt=[char(ones(7,1).*26143),char(ones(7,1).*26399),WLt'];
tbLt=[TLt',char(ones(12,1).*26102)];
hLt=[nLt(1:24,:),char(ones(24,1).*26102)];
miLt=[nLt(1:60,:),char(ones(60,1).*20998)];
sLt=[nLt(1:60,:),char(ones(60,1).*31186)];

hold on;ax=gca;
set(ax,'Position',[0,0,1,1],'PlotBoxAspectRatio',[1,1,1],'XLim',[-1,1].*1.17,'YLim',[-1,1].*1.17,...
    'XColor','none','YColor','none','Color',[2,34,57]./255);

% 绘制钟表handle
lC={yLt,mLt,dLt,wLt,tbLt,hLt,miLt,sLt};
nC={1,12,31,7,12,24,60,60};
RCell={0,.22,.39,.53,.64,.78,.96,1.15};
for k=1:8
    tList=lC{k};
    for i=1:nC{k}
        tTheta=2*pi/nC{k}*(i-1);tNm=mod(i-1+tM(k)-1,nC{k})+1;
        hdlSet{k,i}=text(ax,cos(tTheta).*RCell{k},sin(tTheta).*RCell{k},tList(tNm,:),'FontName','黑体',...
            'Color',[1,1,1],'FontSize',4,'HorizontalAlignment','right','Rotation',tTheta/pi*180);
    end
end
set(hdlSet{1,1},'HorizontalAlignment','center')
fill(ax,[-.1,1.17,1.17,-.1],[-1,-1,1,1].*.025,[0,0,0],'FaceAlpha',0,'EdgeColor',[1,1,1],'LineWidth',.5)
end
dNb=weekday(tN);
dNb=mod(dNb-2,7)+1;
tM=[tN.Year,tN.Month,tN.Day,dNb,...
    ceil((mod(tN.Hour+1,24)+1)/2),tN.Hour,tN.Minute+(round(tN.Second)+n>=60),mod(round(tN.Second)+n,60)];
tM(6:8)=tM(6:8)+1;
K=find(lTM~=tM);
if ~isempty(K)
    for k=K
        tList=lC{k};
        for i=1:nC{k}
            tNm=mod(i-1+tM(k)-1,nC{k})+1;
            set(hdlSet{k,i},'String',tList(tNm,:))
        end
    end
end
lTM=tM;
drawnow;
end


      
    
    