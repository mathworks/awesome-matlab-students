animateFrames();
function animateFrames()
    animFilename = 'Bucky_Ball.gif'; % Output file name
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
    % Truncated icosahedron
    B = bucky;
    P = plot(graph(B), Layout = 'force3');
    V = [P.XData.', P.YData.', P.ZData.'];
    V = V/max(max(abs(V)));
    cla
    C = allcycles(graph(B), maxCycleLength = 6);
    L = cellfun(@length, C);
    F = NaN(height(C), max(L));
    for k = 1:height(C)
        F(k,1:L(k)) = C{k};
    end
    colors = [0 0 0.5; 1 1 1];
    faceColor = colors((L == max(L))+1, :);
    view(3)
    axis square
    if nargin > 0
        t = (f-1)*180/24;
        R = [cosd(t) sind(t) 0; -sind(t) cosd(t) 0; 0 0 1];
        V = V*R;
    end
            
    patch( ...
        Faces = F, ...
        Vertices = V, ...
        EdgeColor = colors(1,:), ...
        FaceVertexCData = faceColor, ...
        FaceColor = 'flat')
end