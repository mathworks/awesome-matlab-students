animateFrames();
function animateFrames()
    animFilename = 'Rotating_Umbrella.gif'; % Output file name
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
    if(f == 1)
        % set axis and view
        ax=gca; 
        view(3); 
        axis equal;
        hold on;
        % add hgtransform for rotation
        hg1=hgtransform('Parent',ax); 
        %set camera lighting
        camlight('headlight','infinite'); 
        lighting gouraud;
        % ones for generating surfaces
        one=ones(1,21); 
        % surface generating function
        mysurf=@(X,Y,Z,ea,fc) surf(X,Y,Z,EdgeAlpha=ea,FaceColor=fc,Parent=hg1); 
        % umbrella handle
        [Xc,Yc,~]=cylinder([0.02,0.04,0.04]);
        Zc=[5.5;5;1]*one;
        mysurf(0.25+Xc,Yc,Zc,0,'b');
        % umbrella stern
        [Xs,Ys,~]=cylinder([0.04,0.07,0.07,0.05,0.05]);
        Zs=[0.1;0.1;0.09;0.09;0]*one;
        Xs=0.25+[Xs;flipud(Xs)]; 
        Ys=[Ys;flipud(Ys)]; 
        Zs=3.9+[Zs;-flipud(Zs)];
        mysurf(Xs,Ys,Zs,1,'k');
        % umbrella handle
        [Xh,Yh,~]=cylinder([0.04,0.06,0.06]);
        Zh=[1;0.9;0]*one; 
        Xh=0.25+Xh;
        x=Xh(end,:);
        y=Yh(end,:); 
        z=Zh(end,:);
        for i = 1:12
            [x,y,z]=rotate(x,y,z,[0,1,0],pi/12);
            Xh=[Xh;x]; 
            Yh=[Yh;y]; 
            Zh=[Zh;z];
        end
        mysurf(Xh,Yh,Zh,0.2,'g');
        % umbrella canopy and support
        t=linspace(0,pi/4,51)';
        u=pi/12*linspace(-1,1,51); 
        R=5+2*t*u.^2;
        X=R.*(sin(t)*cos(u)); 
        Y=R.*(sin(t)*sin(u)); 
        Z=R.*(cos(t)*ones(size(u))); 
        x=0.07*cos(pi/12*(1:2:23)); 
        y=0.07*sin(pi/12*(1:2:23));
        for i=1:12
            xyzl=[X(:,end),Y(:,end),Z(:,end)];
            xyzl=[xyzl;2*xyzl(end,:)-xyzl(end-1,:)];
            xl=xyzl(:,1); 
            yl=xyzl(:,2); 
            zl= xyzl(:,3);
            mysurf(0.25+X,Y,Z,0,'r');
            plot3(0.25+[x(i),xl(25)],[y(i),yl(25)],[4,zl(25)],'k',LineWidth=1.5,Parent=hg1);
            plot3(0.25+xl,yl,zl, 'k', LineWidth = 1.5,Parent=hg1);
            plot3(0.25+X(end,:),Y(end,:),Z(end,:),'k',Parent=hg1);
            [X,Y,Z] = rotate(X,Y,Z,[0,0,1],pi/6);
         end
        axis([-4,4,-4,4,-1,6]); 
        axis equal;
        hold off
        drawnow;
    else
        fig=gcf();
        ax=fig.Children(1);
        hg1=ax.Children(2);
        set(hg1,'Matrix',makehgtform('zrotate',(f-1)*pi/24));
        drawnow
    end
end
% rotation function
function [X,Y,Z]=rotate(X,Y,Z,U,theta)
    c=cos(theta); 
    s=sin(theta); 
    ux=U(1); 
    uy=U(2); 
    uz=U(3);
    M=[ux*ux*(1-c)+c,uy*ux*(1-c)-uz*s,uz*ux*(1-c)+uy*s
       uy*ux*(1-c)+uz*s,uy*uy*(1-c)+c,uz*uy*(1-c)-ux*s
       uz*ux*(1-c)-uy*s,uy*uz*(1-c)+ux*s,uz*uz*(1-c)+c]; 
    for i=1:size(X,1)
        xyz=M*[X(i,:);Y(i,:);Z(i,:)];
        X(i,:)=xyz(1,:);
        Y(i,:)=xyz(2,:);
        Z(i,:)=xyz(3,:);
    end
end


      
    
    