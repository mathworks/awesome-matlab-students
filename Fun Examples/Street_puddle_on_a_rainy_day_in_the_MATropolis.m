animateFrames();
function animateFrames()
    animFilename = 'Street_puddle_on_a_rainy_day_in_the_MATropolis.gif'; % Output file name
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
% Persistent variable definitions
%   CD: CData of full city reflection image
%    R: surface object for the city image in the puddle reflection

persistent CD R
if f==1
    %% Create city reflection (variable CD)
    rng default
    axes(colorm=gray,Color='k',Projection='perspective')
    hold on
    h=randg(2,5,5); % building heights
    b=bar3(h);      % buildings
    set(b,{'CData'},get(b,'ZData'),{'FaceColor'},{'interp'}) % lighter at top
    b(3).delete % remove a row of buildings

    % Set up axes and field of view
    axis equal
    clim([0,3])
    campos([3,3,0])
    camtarget([4 3 6])
    camva(90)
    camup([-1 0 0])

    % loop through the buildings to add windows
    for i=1:5
        for j=[1 2 4 5]
            s=(j<3)*.82-.41; % which side of the building will be windows be on
            c=.1:.2:h(i,j)-.2;
            d=[c;c];
            z=d(:)'+[0;0;.1;.1];
            y=i+[-.2,.2]+[-1;1;1;-1]/12;
            y=repmat(y,size(c));
            ison=logical(rand(1,numel(d))>0.4);
            patch(z(:,ison)*0+j+s,y(:,ison),z(:,ison),[.48 .46 .17]); % Lights on
            patch(z(:,~ison)*0+j+s,y(:,~ison),z(:,~ison),[.2 .2 .3]); % Lights off
        end
    end

    % Create coherent noise for clouds
    m=400;
    X=linspace(-1,1,m);
    d=hypot(X,X').^-1.7;
    fr=fftshift(fft2(rand(m)));
    sd=ifft2(ifftshift(fr.*d));
    % Scale the noise to within the clim
    cl=rescale(abs(sd),0,2);
    % Plot cloudy sky; x and y extents will be large due to perspective
    w=linspace(-20,30,m);
    surf(w,w,max(h(:))+ones(m)-.9,FaceColor='texturemap',EdgeColor='none',CData=cl);

    % capture image
    fr=getframe;
    CD=flipud(fr.cdata);   % Take a peek:  clf; imagesc(CD); set(gca,'YDir','normal')

    %% Iterate the buffer to the 48th frame so we start with the end-state
    % This will simulate the entire 48-frame animation and use the updated
    % image as a starting point so the animation cycles (because Ned keeps
    % praising animations that cycle :D)
    rng(860411,'twister')
    G=rng;
    updatebuf(CD,1);
    for i=2:48
        updatebuf(CD,0);
    end

    %% Create street terrain
    rng(790316,'twister') % This seed makes a nice puddle
    n=1000; % determines size of the final image
    X=linspace(-1,1,n); %create linear r matrix
    [~,r]=cart2pol(X,X');
    rd=rand(n);
    filt=r.^-2.5; % roughness of puddle edges -- 2.5 is great,2.0-edges are too rough
    fr=fftshift(fft2(rd));
    td=ifft2(ifftshift(fr.*filt));
    st=-rescale(abs(td),-0.2,0); % This scales from 0 to .2

    wlev=0.13;  % Water level;  0.12 and 0.13 look good

    %% Plot street terrain
    clf % clear figure
    g=rescale(imgaussfilt(rand(n),2),0,1); % street texture
    surf(1:n,1:n,st,FaceColor='texturemap',CData=g,EdgeColor='none'); % street
    hold on
    view(2)
    colormap gray
    set(gca,'Position',[0 0 1 1])

    %% Initialize puddle reflection (variable R)
    % add the city image and water level depth
    u=size(CD);
    R=surf(linspace(0,n,u(1)),linspace(0,n,u(2)),zeros(u([2,1]))+wlev,...
        FaceColor='Texturemap',EdgeColor='none',CData=CD);
    clim([0,1])
    
    %% Return random number generator state to replicate ripples
    % This must be at the end of setup
    rng(G)
end

% Update ripples and rain drops on each iteration
[xo,yo]=updatebuf(CD,0);
R.CData=updateCD(CD,xo,yo);
end

function [xo,yo]=updatebuf(CD,TF)
% Update buffers
persistent b1 b2
[r,c]=size(CD,1:2);   % reflection image size

if TF || isempty(b1)
    % Create buffers that map ripples on to the image on first call
    b1=zeros(r,c);
    b2=b1;
end

% Animation: add rain drops
% Set up some variables that won't change between iterations
d=1/36; % dampening parameter determins how quickly the ripples fade,lower values last longer
M=zeros(3); % mask
M(2:2:end)=1;
xM=[-1 0 1];
yM=[-1;0;1];
[x,y]=meshgrid(1:c,1:r);

% On each frame there is a probability of there being a new rain drop
if rand<.2 % increase threshold to increase frequency of new drops
    xp=randi(c);
    yp=randi(r);
    startX=max(1,xp-10);
    startY=max(1,yp-10);
    b2(startY:yp,startX:xp)=-randi(100);
end

% Propagate the ripples
for k=1:3
    b2=filter2(M,b1)/2 - b2;
    b2=b2 - b2*d;
    xo=min(c,max(1,x+filter2(xM,b2))); % x-offset bounded by [1,c]
    yo=min(r,max(1,y+filter2(yM,b2))); % y-offset bounded by [1,r]

    % Swap buffers
    tmp=b2;
    b2=b1;
    b1=tmp;
end
end

function I=updateCD(CD,xo,yo)
% Create the a new image by applying the buffer offsets to the old image CData
f=@(i)interp2(double(CD(:,:,i)),xo,yo);
I(:,:,1)=f(1);
I(:,:,2)=f(2);
I(:,:,3)=f(3);
I=uint8(I);
end


      
    
    