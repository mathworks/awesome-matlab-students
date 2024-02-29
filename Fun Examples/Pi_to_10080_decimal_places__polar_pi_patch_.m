animateFrames();
function animateFrames()
    animFilename = 'Pi_to_10080_decimal_places__polar_pi_patch_.gif'; % Output file name
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
persistent x y d pitxt
nDecimalPlaces = 10080;

if f==1 || isempty(x)
    digits(nDecimalPlaces+2);
    piStr = char(vpa(pi));
    pDigits = piStr(3:end-1)-'0';

    % Assign each digit an angular coordinate based on its value 0:9
    theta = ((0:36:324)+linspace(0,36,nDecimalPlaces+1)')*pi/180;
    ang = theta(sub2ind(size(theta),1:nDecimalPlaces,pDigits+1));

    % Compute the length of each line segment; used to set color
    [x,y] = pol2cart(ang,1);
    [~,~,d] = uniquetol(hypot(diff(x),diff(y)));
    d = [d;d(end)];

    % Plot line segements using the edge property of a Patch object
    % Plot segments using patch so we can control transparency within one
    % graphics object.
    set(gcf, 'Color','k');
    axes(Position = [0 0 1 1]);
    pitxt = plotpitxt(text());
    hold on
    axis equal padded off
    % Labels
    gap = 3; % gap between segments in degrees
    startpt = ((0:36:324) + gap/2)*pi/180; % starting point of each segment, radians
    segAng = (0:0.02:1)'.*((36-gap)*pi/180) + startpt; % angular coordinates for segments
    radius = 1.08;
    [segx,segy] = pol2cart(segAng,radius);

    plot(segx,segy,'-w',LineWidth=1,Color=[.8 .8 .8])

    % add bounds labels
    midAng = ((0:36:324)+18) * pi/180;
    tradius = radius + .08;
    [tx,ty] = pol2cart(midAng,tradius);

    text(tx, ty, string(0:9), ...,
        FontUnits='normalized',...
        FontSize=0.05, ...
        Color=[.8 .8 .8], ...
        HorizontalAlignment='center',...
        VerticalAlignment='middle');
end

nFrames = 48;
frameIdx = [1,find(mod(1:nDecimalPlaces,nDecimalPlaces/nFrames)==0)];
plotalpha = @(parent,x,y,color,alpha) patch(parent,'XData',[x(:);nan],'YData',[y(:);nan],'EdgeColor',color,'EdgeAlpha',alpha);
cmap = jet(10);

for i = frameIdx(f) : frameIdx(f+1)
    if i==nDecimalPlaces
        continue
    end
    plotalpha(gca,x(i:i+1),y(i:i+1),cmap(d(i),:),0.1)
end
pitxt = plotpitxt(pitxt);  % faster than uistack

    function pitxt = plotpitxt(h)
        h.delete
        pitxt = text(0,0.05,'\pi', ...
            HorizontalAlignment='Center', ...
            FontUnits='normalized', ...
            FontSize = 0.2, ...
            Color = 'k');
    end
end


      
    
    