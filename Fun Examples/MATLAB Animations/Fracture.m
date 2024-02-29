animateFrames();
function animateFrames()
    animFilename = 'Fracture.gif'; % Output file name
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

% Done with my kids! Explosion using voronoi cells.

persistent V T T2 Vg Xo R C L L2

rng default

N=150;                      % Number of voronoi domains
v=@(x)vecnorm(x);           % This is used a lot...

    if f==1
    
        % Distribute points in the unit sphere, biased toward the center
        Xo=randn(3,N);
        Xo=Xo./v(Xo).*rand(1, N);

        % Bounding layer of points that will create our outer surface. Need
        % lots of them...
        NA=100;
        ps=randn(3,NA);
        ps=1.3*ps./v(ps);

        % Concatenate
        X=[Xo,ps]';

        % Voronoi diagram
        [V,R]=voronoin(X);
        mnR=cellfun(@min, R)~=1;                              % Which cells have inf's
        ginds=unique(cell2mat(R(~mnR)'));                     % Get bordering nodes
        Iinds=setdiff(1:size(V,1), ginds);                    % Get interior nodes
        mxr=max(v(V(Iinds,:)'));
        ginds(1)=[];                                          % Get rid of inf        
        
        % Make non-inf outer-nodes have unit radius * some small scale factor
        V(ginds,:)=1.3*V(ginds,:)./v(V(ginds,:)')';
        
        % Glow
        Vg=ones(size(V,1),1);
        Vg(ginds)=0;        
        
        TS=@(k,x,y,z,C)trisurf(k,x,y,z,'FaceC',C,'EdgeC','none');
        cnt = 1;
        for n = 1:length(mnR)
            if mnR(n) == 1
                xt=V(R{n},1);
                yt=V(R{n},2);
                zt=V(R{n},3);
                C=[1,1,1];
                k = convhull(xt,yt,zt);
                T{n}=TS(k,xt,yt,zt,C/2);
                hold on;
                material(T{n},[0,1,0,3]);
                s=1.1;
                T2{n}=TS(k,xt*s,yt*s,zt*s,C);
                material(T2{n},[1,0,0,3]);
                set(T2{n},'FaceAlpha','interp','FaceVertexAlphaData',.1*Vg(R{n}),'AlphaDataMapping','None');
                
                if cnt == 1
                    set(gca, 'color', 'k');
                    axis equal off
                    axis([-1,1,-1,1,-1,1]*6);
                    cnt = cnt + 1;
                    camproj p
                    camva(70);
                    campos([-55-5 -71 52]/30);
                    set(gcf,'color','k');
                    L2=light;
                    L{1}=light('position',[0,0,0],'style','local');
                    L{2}=light('position',[0.1,0,0], 'style','local');                    
                end
            end
        end

    elseif f<10
        for n=1:N
            T2{n}.FaceVertexAlphaData = .1*Vg(R{n})*f;
        end
    L2.Color = C/f;
    elseif f >= 10 
      
        % Loop over fragments and expand
        for n = 1:N
            T2{n}.Vertices=1.3*V(R{n},:)*4000/f.^3;
            T2{n}.FaceVertexAlphaData=T2{n}.FaceVertexAlphaData*.95;
            T{n}.Vertices=T{n}.Vertices+2.5*Xo(:,n)'/f;            
        end
        if f > 20
        for n=1:2
            L{n}.Color=L{n}.Color*.96;
        end
        L2.Color = C*f/48;
        end
    end
end


      
    
    