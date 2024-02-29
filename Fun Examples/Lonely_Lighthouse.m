animateFrames();
function animateFrames()
    animFilename = 'Lonely_Lighthouse.gif'; % Output file name
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
    % shortenners
    r=@rand;
    ls=@linspace;

    % Make all our circles the same
    nv=300;
    th=ls(0,2,nv);
    X=cospi(th);
    Y=sinpi(th);
    Z=ones(1,nv);    

    % Stuff in front needs to be pushed ahead of the backdrop images
    FZ=2;
    
    if f==1
        set(gca,'position',[0 0 1 1],'clipping','off');

        hold on
        imagesc([-1 1],[1.5 0],(1:256)');
        colormap(abyss.^2) % square to get more black, but it made the blue niftier too
        
        %% Starry sky
        % do first due to newplot
        N=120;
        si=r(1,N); % Size and Color are related, so use same random #s
        scatter(r(1,N)*2-1,r(1,N)*1.3+.1,(si+.2)*40,(si*.5+.5)'.*[1 1 1],'Marker','.');

        %% Lighthouse
        lh_r=[.16 .1 .15 .15 .05 .05 .14 0]'*.5;
        lh_y=[.1 .78 .78 .82 .82 .89 .89 1]';
        lh_c=[.5 .5 .3 .3 1 1 .3 .3]'; % shade of gray means I only need 1 # per profile ring
        HC=ones(1,nv,3).*lh_c; % convert lh_c to RGB color
        surface(X.*lh_r,Z.*lh_y,Y.*lh_r+FZ,HC,'FaceC','f','EdgeC','n');

        % Make the light part brighter by setting FaceLighting to none
        lhlr=[.1 .1]'*.5;
        surface(X.*lhlr,Z.*[.8 .9]',Y.*lhlr+FZ,'FaceC','w','EdgeC','n','FaceL','n');
        
        %% The lighthouse sits on a rock
        N=120;
        RN=12;

        % This computes random points on a half sphere.
        r_th=r(1,N)*2;
        u=r(1,N)*2-1;
        rth=ls(0,2,RN+1);
        rth(end)=[];
        pts=[0 cospi(r_th).*sqrt(1-u.^2) cospi(rth)
             0 sinpi(r_th).*sqrt(1-u.^2) sinpi(rth)
             0 abs(u) zeros(1,RN)]';

        % Form the patch around the random pts using convex hull
        lf=convhulln(pts);
        % Move pts in/out to make it bumpy and scale into our world.
        % You have to make it bumpy after convex hull b/c that ignores pts 'inside' the hull.
        D=(.9+r(1,N+RN+1)*.3)';
        lv=pts.*D.*[.5 .11 .3];

        % Adjust colors to be darker in depths.
        I=[.55 .41 .36];% brown
        C=hsv2rgb(rgb2hsv(I).*[1 1 .5]);
        q=I-C;
        
        patch('Faces',lf,'Vertices',lv(:,[1 3 2])+[0 0 FZ],'FaceC','i', ...
              'EdgeC','none','FaceVertexCData',rescale(D)*q+C,'FaceL','g');

        %% The light beam (fill in later)
        patch('tag','LB','vertices',[],'faces',[],...
              'edgec','n','facec','w','facea','i','facel','n')

        %% Reflection off the ocean (fill in later)
        image([-1 1],[-.5 .02],rand(200),'tag','O');
        
        %% Nicify axes
        material([.6 .6 .8 2 .8])
        axis([-1 1 -.5 1.5],'off');
        daspect([1 1 1])
        light('pos',[0 0 0],'color',[.5 .5 .6 ],'tag','LBO');
    end

    % Find all our objects from initial creation
    LB=findobj('tag','LB');
    LBO=findobj('tag','LBO');
    O=findobj('tag','O');

    %% Create the light-beam eminating from the lighthouse
    A=interp1([1 49],[0 2],f); % Angle to point light beam for this frame

    % Create a mask (pts) to project through.
    % Mask is a circle in cylindrical coords with a wavy radius (defined by wf)
    wf=cospi(th*50)*.003;
    os=X*.15+A;
    mx=cospi(os).*(.08+wf);
    my=Y*.03+.85;
    mz=sinpi(os).*(.07+wf);
    pts=[mx
         my
         mz]';

    % Light posn for projection
    L=[0 .85 0];
    
    % Set posn of our actual light so the tower/rock is illuminated by
    % the light bean reflecting off the air / virtual fog
    set(LBO,'Pos', [ cospi(A) L(2) sinpi(A) ]);
    
    %% Extrude a cone of light through the mask

    % Compute normalized vectors away from light through each vertex
    vv=(pts-L)./vecnorm(pts-L,2,2);
    % Compute length and alpha based on angle to camera.
    % The idea is that the more 'volume' of light you see through the more particles
    % in the air it reflects off.  Whe light points at you, simulate by less transparency.
    % when pointing at the side, more transparency.
    
    % To do it right, we'd use dot product, but we can estimate in less
    % characters using sin instead since we're pointing flat out in Z
    %ctr=[mx(2) my(2) mz(2)]; % center
    %cp=[0 .5 10];
    S=sinpi(A); %dot(ctr,dn(mean(pts,1),cp),2);
    ce=vv*(max(S,0)^2*2+1);

    % Extrude
    ed=mod((0:(nv-1))'+[0 1],nv)+1;
    R=1:nv;%size(ed,1)

    c1=[ed(R,[2 1 2])+[0 0 nv];% edges connecting top/bottom
        ed(R,[1 1 2])+[0 nv nv]];
    f=[c1
       c1+nv
       c1+nv*2];
    v=[pts
       pts+ce*.3
       pts+ce*.5
       pts+ce];

    av=[S .9 .7 0];
    M=@(a)repmat(a,nv,1);
    a=[ M(av(1))
        M(av(2))
        M(av(3))
        M(av(4)) ] * ...
        rescale(S,.2,.8,'inputmax',1,'inputmin',-.8)^2;

    set(LB,'vertices',v+[0 0 FZ],'faces',f,'facevertexalphadata',a);

    %% Reflect the upper half into the ocean
    f=getframe(gca);
    % Darken it by passing through hsv and lowering V
    % Use guass filter to blur slightly so it doesn't look so computery
    O.CData=hsv2rgb(rgb2hsv(imgaussfilt(f.cdata(1:end-110,:,:),1)).*reshape([1 1 .7],1,1,3));

end


      
    
    