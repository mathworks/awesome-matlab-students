animateFrames();
function animateFrames()
    animFilename = 'Rainy_evening_in_the_MATropolis.gif'; % Output file name
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
persistent handles
if f == 1 || isempty(handles)
    rng('default')

    axes(colormap=gray,View=[172,22],Color='k')
    hold on
    camva(3)
    h=randg(1,25);          % building heights
    b=bar3(h);
    axis equal
    g=.17;                  % height and width of windows
    [m,k]=ndgrid(1:25);     % (x,y) building indices
    handles.w = gobjects(0);
    for i=1:625             % loop through each building
        % Interpolate building color according to building height
        % Ideally this should be outside the loop but that would require more characters
        q=b(m(i));
        set(q,'CData',q.ZData,'FaceColor','interp')
        for j=1:2                   % loop through each column of windows
            L=k(i)-.27+(j-1)*.37;   % in k-a+(j-1)*b, a is the signed distance from center of building in row k(i) to left edge of window in column j and b is the interval between left edges of windows.
            x=L+[0,g,g,0]';         % [L;R;R;L] edges of windows in building i, window column j
            z=ones(4,1)*(.2:.4:h(i)-.2)+[0;0;g;g]; % 4xn height of windows for n levels of windows; in a:b:c a is height of first row of windows, b is the interval between window-bottoms, c is height of tallest window.
            y=z*0+m(i)+.45;          % 4xn location of front face of building
            % Plot windows for building i, column j
            for w = 1:width(z)
                handles.w(end+1)=patch(z(:,w)*0+x,y(:,w),z(:,w),'y');
                if rand(1) < 0.25
                    handles.w(end).FaceColor = 'none';
                end
            end
        end
    end
    set(gcf,'color','k')
    axis off
    camva(2.5)
    campos([58.256 185.12 25.621])
    view([165.27, 7.0091])
    clim([0 8])

    % lightning light
    handles.light = light('style','infinite',...
        'Position',[-0.21759 1.3841 0.1921], ...
        'Visible', 'off');
    % lightning background
    ax = gca;
    handles.Z = patch(ax.XLim([2,2,1,1]),...
        ax.YLim([1 1 1 1]),...
        ax.ZLim([1 2 2 1]),...
        [6 7.5 -3 -6],...
        'Visible','off');
    
    handles.rain = gobjects(1);
    xlim(xlim) % lazy way of freezing axis limits
    ylim(ylim)
    zlim(zlim)
end

% randomly toggle on/off some window lights
p = 0.001;  % portion (0:1) of lights to toggle
n = numel(handles.w);
idx = randperm(n,ceil(n*p));
colors = {handles.w(idx).FaceColor};
isnone = cellfun(@ischar, colors);
set(handles.w(idx(isnone)), 'FaceColor', 'y')
set(handles.w(idx(~isnone)), 'FaceColor', 'none')

% Show lightning on select frames 
lightningFrames = [24 26 28 29 31:34];
onoff = ismember(f,lightningFrames);
handles.light.Visible = onoff;
handles.Z.Visible = onoff;

% Rain
if mod(f,2)>0 % update every odd frame
    handles.rain.delete
    xyRain0 = rand(3,300).*[26;26;10]-[0;0;2];
    xyRain1 = xyRain0 + [-1;0;-2]; % orientation and length of rain lines
    handles.rain = plot3([xyRain0(1,:);xyRain1(1,:)], ...
        [xyRain0(2,:);xyRain1(2,:)], ...
        [xyRain0(3,:);xyRain1(3,:)], ...
        'color',[.7 .7 .7 .4]);
end
end


      
    
    