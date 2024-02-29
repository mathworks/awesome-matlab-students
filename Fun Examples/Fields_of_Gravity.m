animateFrames();
function animateFrames()
    animFilename = 'Fields_of_Gravity.gif'; % Output file name
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
    persistent r rs theta phi res gx gy c mp mv
    % initialize start values constants
    if isempty(mp)
        r=0.1;      % radius of spheres
        rs=32;      % resolution of spheres
        theta = pi*(-rs:2:rs)/rs;
        phi = (pi/2)*(-rs:2:rs)'/rs;   
        res=200;
        [gx,gy]=meshgrid(linspace(-1,1,res),linspace(-1,1,res));
        c=complex(gx,gy);
        mp=exp(j*(0:2:4)*pi/3)*0.7;
        mv=mp*j*0.039;
    end
    % move masses
    for i=1:length(mp)
        mp(i)=mp(i)+mv(i);
    end
    % calculate forces and new velocities
    for i=1:length(mp)
        mf=0;
        for p=mp
            dp=p-mp(i);
            d=abs(dp);
            if d>eps
                mf=mf+0.001*dp/d^3;
            end
        end
        mv(i)=mv(i)+mf;
    end
    gz=0*c;
    for p=mp
        sx = r*cos(phi)*cos(theta)+real(p);
        sy = r*cos(phi)*sin(theta)+imag(p);
        sz = 12*r*sin(phi)*ones(size(theta));
        surf(sx,sy,sz);
        hold on;
        gz=gz-1./abs(p-c).^2;
    end
    gz(gz<-20)=-20;
    surf(gx,gy,gz);
    shading interp;
    axis off;
    set (gca,'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-19.9,1.5]);
    colormap(parula);
    lightangle(80,-40);
    lightangle(-90,60);
    hold off;
end

      
    
    