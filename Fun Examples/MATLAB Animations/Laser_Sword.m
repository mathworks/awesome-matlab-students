animateFrames();
function animateFrames()
    animFilename = 'Laser_Sword.gif'; % Output file name
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

set(gcf,'color','k')
BL=4; % Blade length as ratio to handle length
nv = 100+1;
T = linspace(0,2,nv);

SLV=[ 0 0 4 5 5 6 6 10 10 9 9 10 10]';
SRV=[ 0 1 1 1 1.1 1.1 1 1 .9 .9 .7 .7 .6]';

S=@surface;

% Create the silver handle
HX=cospi(T).*SRV;
HY=sinpi(T).*SRV;
HZ=ones(1,nv).*SLV*1.5;
HZ(8:9,:)=repmat(HZ(7,:)+6+sinpi(T),2,1);
surf(HX,HY,HZ,[],'FaceC','#aaa','EdgeC','#333','MeshS','row');
material([.6 .6 .8 2 .8]) % shiny silver

% Black grip
SE=((1-mod(T*10,2)).^2-.3).^3+1.01;
FX=cospi(T).*SE.*SRV(2:3);
FY=sinpi(T).*SE.*SRV(2:3);
FZ=ones(1,nv).*SLV(2:3);
S(FX,FY,FZ,[],'FaceC','#444','EdgeC','none');

% Blade
BL = [10 9.5+BL*10 10+BL*10 ]'*1.5;
BR = [.5 .4 .1]';
BX = cospi(T).*BR;
BY = sinpi(T).*BR;
BZ = ones(1,nv).*BL;

CA={'FaceC', '#66f', 'EdgeC', 'n'};
F=abs(f/24-1);
B=[S(BX,BY,BZ*F,[],CA{:}); % Blade
   S(BX*1.6,BY*1.6,BZ*1.005*F,[],'FaceA',.3,CA{:}); %Halo
   S(BX*1.9,BY*1.9,BZ*1.01*F,[],'FaceA',.2,CA{:})];
material(B,[.6 .6 1 1 1]) % simulate inner glow via more reflectance

% Light and blade glow effects
GL=[light('Pos',[-2 -2 12*1.5],'Style','l','Color','#00f')
    light('Pos',[-10 -30 30],'Style','local','Color','#ddd')];

% Improve overall look of the scene.
axis tight off
view([-45 20])
set(gca,'CameraUp',[0 1 .3],'DataA',[1 1 1]);
axis([-2 2 -1.2 1.2 0 80])

end