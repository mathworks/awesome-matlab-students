animateFrames();
function animateFrames()
    animFilename = 'Will_O__Wisp.gif'; % Output file name
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
    E=4; % Size of the forest environment

    % Abbreviations
    J=@rand;
    K=@rescale;
    VN=@vecnorm;

    persistent L
    
    if f==1
        set(gcf,'color','k');
        
        % Select some nice tree locations
        %v1=[0 0 1.3
        %    1.4 0 1
        %    -1.3 0 1.2
        %    1 -1 1.3
        %    -1 -1 1.2
        %    -.5 -2.1 .9
        %    .34 -2 1
        %    .7 -2.3 .8
        %    -1.5 -4 1
        %    .6 1 1.2
        %    .4 2 1.3
        %    -.55 1.5 1.4];
        % Below is the compressed version of the above, saving almost 50 chars!
        v1=reshape(K('啥猸㦴檳䀘䪿岣摏㕱戭巫䦮啥啥啥䀘䀘⢩⫋⑧0檳耀留焗檳滵焗滵梑檳晰檳滵焗猸'-'0',-4,2),12,3);

        % Compressed version of color array: See parent of this remix
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
            ss=v1(i,3)*.34;
            llv=lvr.*[.12+ss .12+ss .08+ss]+[0 0 .1];

            mkP(lf,llv+v1(i,:),i,G,D);

            %% Bumpy high-res ground
            N=400;
            Q=.2;

            % coordinates
            T=J(1,N)*2;
            R=J(1,N)+.05;

            x=cospi(T).*R*E;
            y=sinpi(T).*R*E;

            % Triangulate the flat disc so we can draw it
            pv=[x' y'];
            pf=delaunay(pv);
            
            % Variation
            D=(J(1,size(pv,1))*Q)';

            % flip faces due to normals needing to match trees
            mkP(fliplr(pf),[pv D],4,G,D);
        end
        
        %% Our Wisp!
        L=line(1,1,1,'Marker','.','Markers',20,'Color','y');
        light('color','k'); % This light forces normals to be
                            % computed on the patches but since it
                            % is black, it has no visible effect.
            
        %% Decorate!
        set(gca,'position',[0 0 1 1],'vis','off','proj','p');
        axis([-E E -E E -1 E]);
        view(3);
        daspect([1 1 1]);
        campos([0 3 .5]);
        camva(60);
        camtarget([0 0 .7]);
        drawnow; % Force all vertex normals to be computed
    end
    
    %% Update Light
    lp=[cospi(f/24)*.5 sinpi(f/24)*1.5-.5 cospi(f/12)*.2+.7];
    set(L,'XData',lp(1),'YData',lp(2),'ZData',lp(3));

    %% Apply lighting to all the patches
    O=findobj('type','patch');
    for i=1:numel(O)
        doL(O(i));
    end

    function doL(p)
        % Perform a lighting operation on the object provided in p.
        % This algorithm is an adaption from the ML lighting
        % algorithm in webGL, but ignoring specular (to make it
        % spooky) and adding in distance based ambient lighting,
        % and adding range to the local light.
        cp=campos;
        v=p.Vertices;
        
        % Distance from camera, extending to range.
        gl_dist=K(min(VN(v-cp,2,2),max(E)),'InputMin',0,'InputMax',E*3);

        % Weight of ambient lighting.  Desaturate some of the red on tree in front
        w_amb=[.3 .4 .4].*(1.1-gl_dist);

        % Effects of the wisp
        s_diff=.7; % diffuse strength

        lr=1.5; % max distance light can illuminate
        d=v-lp;
        l_dist=min(VN(d,2,2),lr);
        s_dist=1-K(l_dist,'InputMax',lr,'InputMin',0);
        
        % Diffuse Weight
        % Invert vertex normals due to faces being in wrong order and - being short
        w_diff=L.Color.*dot(-p.VertexNormals,d./VN(d,2,2),2)*s_diff;
        
        % CbaseColorFactor (ambiant and diffuse)
        bcf = min(max(w_diff,0), 1).*s_dist;

        % Accumulate all the terms and put on patch as color
        set(p,'FaceVertexCData',min(p.UserData.*(w_amb+bcf), 1));
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
              'Amb',1,'FaceL','g','FaceVertexC',fvc,'U',fvc);
    end

end


      
    
    