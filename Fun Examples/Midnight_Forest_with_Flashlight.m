animateFrames();
function animateFrames()
    animFilename = 'Midnight_Forest_with_Flashlight.gif'; % Output file name
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
    E=5; % Size of one forest environment segment

    % FogColor Vibe
    FC=[0 0 0];
    %FC=[1 1 1];

    % Abbreviations
    J=@rand;
    K=@rescale;

    if f==1
        set(gcf,'color',FC);
        
        % Random placement of trees.  Clump neare middle
        n=40;
        v1=[K(randn(n,1)) J(n,1) K(J(n,1),.3,.5)]*E-[E/2 0 0];

        % Place a navigable path around zero
        M=v1(:,1)<=.1;
        v1(M,1)=v1(M,1)-.2;
        v1(:,3)=v1(:,3)*.2+.2;

        % Duplicate so we are in a repeating donut
        %vx=[v1;v1+[0 E 0]];
        
        %B=validatecolor(["#A52A2A"
        %                 "#DAA06D"
        %                 "#6E260E"
        %                 "#954535"
        %                 "#7B3F00"
        %                 "#80471c"
        %                 "#814141"
        %                 "#966919"],...
        %                'multiple');
        %G=validatecolor(["#097969"
        %                 "#228b22"
        %                 "#50C878"
        %                 "#4F7942"
        %                 "#008000"
        %                 "#355E3B"
        %                 "#2AAA8A"
        %                 "#32CD32"],...
        %                'multiple');
        % How to compress some colors:
        %
        % % Turn into flints
        % U=floor(CLRS*256);
        % % Turn that into chars, offset forward by SPACE
        % CH=char(U+' ');
        % 
        % % Turn this into decode code
        % A="'"+CH+"'";
        % disp("([" + join(A,";") + "-' '])/256;");
        % 
        % Compressed version of above:
        B=(['ÆJJ';'ûÁ';'F.';'¶eU';'_ ';'¡g<';'¢aa';'·9'-' '])/256;
        G=([')';'B¬B';'pé';'ob';' ¡ ';'U~[';'JË«';'RîR']-' ')/256;

        for i=1:size(v1,1)

            %% Tree Trunks
            N=30;
            Q=.1;  % variation in distance from center
            RN=12;  % n pts in bounding rings
            rv=[.05 .02]; % Radius values
            rh=[0 1]; % Radius heights
                      % Random pts on cylinder
            rt=linspace(0,2*pi,RN+1);
            rt(end)=[];
            T=[J(1,N)*pi*2 rt rt];
            h=[K(randn(1,N)) ones(1,RN)*rh(1) ones(1,RN)*rh(2)];
            % Adjust the radius based on height
            R=interp1(rh,rv,h);

            pts=[cos(T).*R
                 sin(T).*R
                 h]';

            % triangulate the perfect cylinder
            tf=convhulln(pts);

            % Push points in/out with variance of Q
            D=(1-Q+J(1,size(pts,1))*(Q*2))';
            tv=pts.*(D.*[1 1 0]+[0 0 1]);        

            mkP(tf,(tv+v1(i,:).*[1 1 0]).*[1 1 v1(i,3)+.1],i,B,D);
            mkP(tf,(tv+v1(i,:).*[1 1 0]).*[1 1 v1(i,3)+.1]+[0 E 0],i,B,D); % identical trunk in next section

            %% Tree tops
            N=150;
            % Alg for random distribution of pts on a sphere.
            T=J(1,N)*pi*2;
            u=J(1,N)*2-1;
            
            pts=[0 cos(T).*sqrt(1-u.^2)
                 0 sin(T).*sqrt(1-u.^2)
                 0 u ]';

            % triangulate the perfect sphere
            lf=convhulln(pts);

            % Push points around to make foliage frumphy
            Q=.15;
            D=(1-Q+J(1,size(pts,1))*(Q*2))';
            lvr=pts.*D;
            
            % Scale down into our world and push up into treetops
            ss=v1(i,3)*.15;
            llv=lvr.*[.12+ss .12+ss .08+ss]+[0 0 .1];

            mkP(lf,llv+v1(i,:),i,G,D);
            mkP(lf,llv+v1(i,:)+[0 E 0],i,G,D); % identical tree in next section

            %% Lumpy Ground!
            N=200;
            Q=.2;

            % coordinates
            T=J(1,N)*2;
            R=J(1,N)+.05;

            x=cospi(T).*R*E;
            y=sinpi(T).*R*E*2+E;

            % Triangulate the flat disc so we can draw it
            pv=[x' y'];
            pf=delaunay(pv);
            
            % Variation
            D=(J(1,size(pv,1))*Q)';

            mkP(pf,[pv+.5 D],4,G,D);
            
            %% Decorate!
            set(gca,'position',[0 0 1 1],'vis','off','proj','p');
            view(3);
            daspect([1 1 1]);

        end
    end
    
    %% Navigate!
    yp=f/48*E;
    cp=[0 yp .3];
    ct=cp+[0 10 .1];
    campos(cp);
    camtarget(ct);
    camva(90);

    O=findobj('type','patch');
    for i=1:numel(O)
        gloom(O(i));
    end

    %% Shorten patch creation
    function mkP(f,v,i,C,D)
        % f - faces
        % v - vertices
        % i - thing index
        % C - Array of colors to pick from
        % D - distance array

        % Create our colors based on D
        bC=C(mod(i,size(C,1))+1,:);
        C2=hsv2rgb(rgb2hsv(bC).*[.1 1 .3]);
        q=bC-C2;
        fvc=K(D)*q+C2;

        % Create patch and stash colors
        patch('Faces',f,'vertices',v,'EdgeC','n','FaceC','i',...
              'FaceVertexC',fvc,'U',fvc);
    end

    function gloom(p)
        v1=p.Vertices-cp; % Center around camera position.
        clr=p.UserData;

        % Compute depth from camera, and rescale as 0-1
        B1=K(hypot(hypot(v1(:,1),v1(:,2)),v1(:,3)),'InputMin',0,'InputMax',5);
        B=B1.^.2;
        
        % Compute how far off each pt is from being directly ahead of camera
        % to simulate the cone of a flashlight.
        pd=DN([0 0 .3],v1); % Angle from each pt to camera
        cd=DN([0 0 .3],[0 1 .1]); % Direction cam is pointing
        str=dot(pd,repmat(cd,size(pd,1),1), 2);

        % Where STR is near 1, set B to 0 so there is no blending.
        a=.95; % size of light cone is 1-a;
        r=.5; % Range of the flashlight
        B(str>a&B1<r)=max(B(str>a&B1<r)-E/2,.1);
        
        % Treat fog as a semi-transparent white on top of the patch.
        % The depth implies the volume of fog you need to see through to get to the vertex.
        set(p,'FaceVertexC',FC.*B+clr.*(1-B))
    end
    function N=DN(p, t)
        % Computed the normalized vector representing normal from POS toward TGT
        d=t-p;
        N=d./vecnorm(d,2,2);
    end
       
end


      
    
    