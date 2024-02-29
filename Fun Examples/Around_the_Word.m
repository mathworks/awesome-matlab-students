animateFrames();
function animateFrames()
    animFilename = 'Around_the_Word.gif'; % Output file name
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
    % Rotation
    rx=f/48*pi;

    % Shorteners
    q=@triangulation;
    j=@polyshape;
    K='KeepCollinearPoints';

    % Transforms
    persistent WX EX
    
    if f==1
        %% WORD SHAPE
        % Basic idea - draw a word using a text object in a wide
        % figure, screen-cap it, then contourit.
        f=figure('Color','w','Vis','of','Pos',[ 100 100 3000 300 ]);
        ax=axes(f,'Vis','off');
        t=text(ax,15,15,'MATLAB','Units','pixel',...
               'FontSize',30,'FontWeight','bold','FontUnits','Pix',...
               'VerticalA','baseline');
        F=getframe(ax,t.Extent);
        close(f)
        V=contourc(double(flipud(F.cdata(:,:,1))),[50 50])';
        % Convert contour matrix into polyshape verts
        idx=1;
        while idx<size(V,1)
            n=V(idx,2);
            V(idx,:)=nan;
            idx=idx+1+n;
        end
        % Center and scale to unit height
        V=(V-min(V))/max(V,[],'all');
        % Convert to polyshape so we get a clean triangulation
        W1=j(V(2:end,:),K,true);
        W1=XP(W1.polybuffer(.006));

        %% Create the WordSphere

        % Constants
        R1=1.3; % radius of inner/outer part of sphere.
        R2=1.5;
        SP=.8; % Span of the word
        
        T=q(W1);
        
        % Aspects of the triangulation.
        V=T.Points; % Get improved V
        F=T.ConnectivityList;
        E=T.freeBoundary;

        % Constants for this shape when computing connecting edges
        R=1:size(E,1);   % All the boundary edges.
        L2=size(V,1);       % Layer 2 starts here.

        % New triangulation faces
        NF=[F; F+L2; % top and bottom
            E(R,[2 1 2])+[0 0 L2]; % edges connecting top/bottom
            E(R,[1 1 2])+[0 L2 L2];
           ];

        x=max(V);
        T=V(:,1)/x(1)*SP; % Stretch around part of theta

        zV=(V(:,2)-x(2)/2);
        P=zV*.2/R1/max(zV);

        %% Cheap Earth (do this before patches due to newplot)
        axes(CreateFcn='earthmap');
        EX=hgtransform;
        set(findobj('type','surface'),'parent',EX);

        %% Word Sphere (or 2 half spheres)
        WX=hgtransform;
        for o=[0 1]
            V2=[cospi(T+o).*cospi(P),sinpi(T+o).*cospi(P),sinpi(P)];

            WT=q(NF,[V2.*[R1 R1 1]
                     V2.*[R2 R2 1]]);

            patch(WX,'Vertices',WT.Points,'Faces',WT.ConnectivityList,...
                  'FaceC','#0076a8','FaceA',1,'FaceL','n',...
                  'FaceVertexCData',[T;T],...
                  'EdgeC','n');

            patch(WX,'Vertices',WT.Points,'Faces',WT.featureEdges(pi/4.5),...
                  'FaceVertexCData',[],'FaceC','none','EdgeC','#fff00f','LineW',1);
        end
        clim(clim);

        % Prettify
        set(gcf,'Color','k');
        daspect([1 1 1]);
        view([220 5])
        axis([-1.5 1.5 -1.5 1.5 -1.1 1.1],'off')
        camzoom(1.7)
    end

    WX.Matrix=makehgtform('zrotate',-rx+pi/3);
    EX.Matrix=makehgtform('zrotate',rx*2);

    %% HELPER FCNS
    % The below fcns add verticies into a polyshape so that the resolution along
    % long edges is high enough so we can bend those edges around the sphere.
    function ps=XP(psIn)
    % Make all long straight edges in the polyshape be made of many short
    % segments.

        % Get the regions
        r=regions(psIn);
        % New polyshape should keep all the extra pts we'll be adding.
        ps=j();
        % Loop over all the regions

        for i=1:numel(r)
            [x,y]=boundary(r(i),1); % Exclude all the holes in this region
            ps=union(ps,XE(x,y),K,true);
        end

        % Get the holes in those regions
        h=holes(psIn);
        
        % Loop over all the holes
        for i=1:numel(h)
            [x,y]=boundary(h(i),1);
            ps=subtract(ps,XE(x,y),K,true);
        end
    end

    function ps=XE(x,y)
    % Expand the edges for one polyregion
        if x(end)==x(1) && y(end)==y(1)
            inp=[x y];
        else
            inp=[x(end) y(end)% This is a loop, re-add the end
                 x y];
        end
        
        P=[];
        for i=2:size(inp,1)
            d=norm(inp(i-1,:)-inp(i,:));% distance between adjacent pts
            n=max(2,floor(150*d));% n pts to increase it to
            if n==2
                P=[P%#ok
                   inp(i-1,:)];
            else
                %disp expand
                xe=linspace(inp(i-1,1),inp(i,1),n)'; % interp
                ye=linspace(inp(i-1,2),inp(i,2),n)';
                % Add all but last pt to avoid dups
                P=[P;%#ok
                   xe(1:end-1) ye(1:end-1)];
            end
        end

        ps=j(P,K,true);
    end

end


      
    
    