animateFrames();
function animateFrames()
    animFilename = 'Snake_Toy.gif'; % Output file name
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
    %% Core Matrices
    numblock=24;
    v = [ -1 -1 -1 ; 1 -1 -1 ; -1  1 -1 ; -1  1  1 ; -1 -1  1 ; 1 -1  1 ];
    pf = [ 1 2 3 nan; 5 6 4 nan; 1 2 6 5; 1 5 4 3; 3 4 6 2 ];
    clr = hsv(numblock);
    
    % Left in a few options for anyone interested in remixing other shapes
    % and colors
    %n = pi/2;
    shapes = [ 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1 % box
               %0 0 .5 -.5 .5 0 1 0 -.5 .5 -.5 0 1 0 .5 -.5 .5 0 1 0 -.5 .5 -.5 0 % fluer
               %0 0 1 1 0 .5 -.5 1 .5 .5 -.5 -.5 1 .5 .5 -.5 -.5 1 .5 .5 -.5 -.5 1 .5 % bowl
               %0 1 0 0 0 1 1 0 1 0 0 1 0 1 1 0 0 0 1 0 1 1 0 1 % dog
               %0 1 0 0 0 0 0 1 1 0 .5 0 1 1 0 1 1 0 -.5 0 1 1 0 0 % chicken
               %0 1 0 0 0 1 1 0 0 0 0 1 0 0 1 0 0 0 0 1 1 0 0 0 % filled box
               %0 1 -n 0 0 0 1 n n 0 1 0 0 0 n 0 1 1 0 1 1 0 n 0 % cobra
               0 .5 -.5 -.5 .5 -.5 .5 .5 -.5 .5 -.5 -.5 .5 -.5 .5 .5 -.5 .5 -.5 -.5 .5 -.5 .5 .5]; % ball

    % Helper for making transform matrices.
    xform=@(R)makehgtform('axisrotate',[0 1 0],R,'zrotate',pi/2,'yrotate',pi,'translate',[2 0 0]);

    if f==1
        %% Create a neon type snake toy on a black background
        set(gcf,'color','black');
        axes('position',[0 0 1 1],'visible','off')
        P=hgtransform('Parent',gca,'Matrix',makehgtform('xrotate',pi*.5,'zrotate',pi*-.8));
        for i = 1:numblock
            P = hgtransform('Parent',P,'Matrix',xform(shapes(end,i)*pi));
            patch('Parent',P, 'Vertices', v, 'Faces', pf, 'FaceColor',clr(i,:),'EdgeColor','none');
            patch('Parent',P, 'Vertices', v*.75, 'Faces', pf(end,:), 'FaceColor','none',...
                  'EdgeColor','w','LineWidth',2);
        end

        %% Axes setup
        daspect([1 1 1]);
        view([10 60]);
        axis tight vis3d off
        camlight
    end

    % Get our stack of transforms.  These will magically be in the right order.
    h=findobj('type','hgtransform')';
    h=h(2:end); % Skip the first one

    % Orbit once around
    view([-f*360/48 20]);

    % Script Steps (transform there and back again)
    if f<=5
        return
    elseif f<=41
        steps=35;
        r=shapes(end,:)*pi; % Start at the Ball shape
        sh=shapes(1,:)*pi; % Go to the box shape
        s=f-6;

        % Transform to next step
        df = (sh-r)/steps;
        arrayfun(@(tx)set(h(tx),'Matrix',xform(r(tx)+df(tx)*s)),1:numblock);
    end

end


      
    
    