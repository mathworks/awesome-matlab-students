animateFrames();
function animateFrames()
    animFilename = 'Rainy_window.gif'; % Output file name
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
persistent T dropSzFcn dropFcn
if f==1 || isempty(T)

    rng(359,'twister')      % set the random number generator for reproducibility
    nc=50;                  % number of colors in colormap
    cmap=gray(nc);          % used to set the background color

    axes(Position=[0 0 1 1]) % example axes to full size of figure
    colormap(cmap(1:ceil(0.4*nc),:)) % cut out the upper (lighter) part of the colormap
    hold on

    % background image
    bx=1:50;              % set size of the square image
    by=exp(-(((bx-6).^2)/(2*8.^2))); % gaussian
    I=imagesc([0,1],[0,1],by'+0*bx); 

    axis tight equal off

    % add distant lights
    ncl=99;               % number of colors for the lights
    LC=hot(ncl);          % light colors
    nl=30;                % number of lights
    r=@()rand(nl,1);      % generate nlx1 random numbers 0:1
    b=bubblechart(r(),r(),r(),LC(randi(ncl,nl,1),:),MarkerEdgeColor='n'); % street lights
    figSz=get(gcf,'Pos');
    bubblesize([3,0.1*max(figSz(3:4))]) % Scale light size to figure size

    % blur the image
    % the background and lights are flattened into a single image and
    % blurred.
    f=getframe;
    b.delete
    I.CData=imfilter(flipud(f.cdata),ones(10)/100);

    % Add rain drops
    nd=99;                % number of drops
    T=table();            % use a table to store some variables
    T.obj=gobjects(nd,1); % droplet surf objects
    T.dropSz=nan(nd,1);   % scale factor for drop size
    dropSzFcn=@()max(min(randg(1),6),.8)/150;  % Drop size, truncated gamma distribution
    [x,y,z]=sphere(20);   % use a larger number for smoother raindrop surfaces, but slower.
    dropFcn=@(sz)surf(sz*x+rand,2*sz*y+rand*1.1,sz*max(z,0),... % function to create raindrops
        FaceCo='w',FaceAl=.2,EdgeCo='n',...
        SpecularSt=1,SpecularExp=2, ...
        DiffuseSt=1,AmbientSt=.1);
    for i=1:nd % Create the rain drops
        T.dropSz(i)=dropSzFcn();
        T.obj(i)=dropFcn(T.dropSz(i));
    end
    light(Po=[0.5 -1 0.1]); % rain drops should be dark on top and light on bottom
    xlim([0,1])
    ylim([0,1])
    set(gcf,Color='k')
end

% Add new drops
n=5;                     % number of rain drops to add
T2=table();              % create a temporary table to store variables
T2.obj=gobjects(n,1);    % droplet surf objects
T2.dropSz=nan(n,1);      % scale factor for drop size
for k=1:n                % add more raindrops
    T2.dropSz(k)=dropSzFcn();
    T2.obj(k)=dropFcn(T2.dropSz(k));
end
T=[T;T2];

% Determine which rain drops are falling by drop size (larger ones fall)
% figure(); histogram(T.dropSz)  % for decision making
T.isFalling=T.dropSz > 0.01; % Reduce threshold to increase the number of falling rain drops

% The amount of downward displacement is determined by drop size
for j=find(T.isFalling')
    T.obj(j).YData=T.obj(j).YData-T.dropSz(j); % shift downward
end

% Determine if any drops overlap
% Reduce the computational expense by assuming drops are rectangular and
% useing MATLAB's rectint, though it contains 1 extra step that isn't needed
% (computing area of overlap) but it's still fast and clean.
[mmy(:,1),mmy(:,2)]=arrayfun(@(h)bounds(h.YData,'all'),T.obj); % [min,max] for ydata
[mmx(:,1),mmx(:,2)]=arrayfun(@(h)bounds(h.XData,'all'),T.obj); % [min,max] for xdata
% Covert the drop's x and y data to rectangular vectors [x,y,width,height]
T.xywh=[mmx(:,1),mmy(:,1),diff(mmx,1,2),diff(mmy,1,2)];

% If a water drop is off the figure, remove it
T.isoff=mmy(:,2) < 0;
T.obj(T.isoff).delete;
T(T.isoff,:)=[];

% Compare all pairs of drops without duplicate comparisons
objPairs=nchoosek(1:height(T),2);
overlap=false(height(objPairs),1);
for q=1:height(objPairs)
    % Because we're treating the raindrops as rectangles, there will be
    % falsely labeled overlaps in the corner of the rectangles. To reduce
    % the number of false positives, we'll require the overlap to be at least
    % 21.5% of the smallest raindrop since a circle consumes 78.5% of its
    % bounding box.
    minArea=min(prod(T.xywh(objPairs(q,:),[3,4]),2))*(1-.785);
    overlap(q)=rectint(T.xywh(objPairs(q,1),:),T.xywh(objPairs(q,2),:)) > minArea;
    if overlap(q) && all(isvalid(T.obj(objPairs(q,:))))
        % highlight the overlapping raindrops, for troubleshooting
        % set(T.obj(objPairs(q,:)),'facecolor','m','AmbientStrength',1 )

        % Which drop has the smallest width?
        [~,minidx]=min(T.xywh(objPairs(q,:),3));

        % The smaller drop is absorbed (removed)
        T.obj(objPairs(q,minidx),:).delete;

        % Elongate the surviving droplet
        maxidx=abs(3*(minidx-1)-2);  % converts 2 to 1 or 1 to 2;
        yd=T.obj(objPairs(q,maxidx)).YData;
        ydmu=mean(yd,'all');
        ef=1.05;  % elongation factor
        T.obj(objPairs(q,maxidx)).YData=(ef*(yd-ydmu))+ydmu;
        % Update dropSz
        T.dropSz(objPairs(q,maxidx))=ef*T.dropSz(objPairs(q,maxidx));
        % Make the elongaged drops narrower
        xd=T.obj(objPairs(q,maxidx)).XData;
        xdmu=mean(xd,'all');
        T.obj(objPairs(q,maxidx)).XData=(1/ef*(xd-xdmu))+xdmu;
    end
end

% Remove rows of the table that belong to deleted rain drops
T(:,3:end)=[];  % Remove the columns that will be recomputed on next iteration
T(~isvalid(T.obj),:)=[];
end


      
    
    