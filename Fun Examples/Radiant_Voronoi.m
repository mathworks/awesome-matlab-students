animateFrames();
function animateFrames()
    animFilename = 'Radiant_Voronoi.gif'; % Output file name
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
% I copied this from a fcn I wrote a while ago and it was short enough I
% didn't need to compress it down so it still uses the variables from an
% argument block at the top and computes stuff I could have turned into constants.

    %% Compute vertices for concentric rings.
    opts.N = 400;
    opts.M = 20;
    %opts.rlim = [ 0 2 ]; % simple
    opts.rlim = [ -.4 2 ]; % like a radiant ball
    opts.flow = mod(f/24,1);

    N = floor(opts.N / opts.M)+1; % Total verts is NxM, but input N is total.

    mflow = mod(opts.flow,.5)*2;
    
    ThetaGap = 360/(N);

    proff = .5;

    ringoffset = ThetaGap*proff*opts.M;

    % Fake a 0 at beginning
    xspace = linspace(-1,1,opts.M+1);

    Rp = [0 (10.^xspace)/10 ];
    % Then rescale original
    Rs = rescale(Rp, opts.rlim(1), opts.rlim(2));
    Rs(1) = [];
    % Flow after rescale.
    % Compute the flowed versions, 1 shorter, also add 0 to beginning
    R = Rs(1:end-1)+diff(Rs)*mflow;

    % Theta Offsets against each ring
    TO = linspace(0,ringoffset,opts.M);
    if opts.flow>=.5
        TO = TO+ThetaGap*proff;
    end
    
    % Theta for a ring.
    TB = linspace(0,360-ThetaGap,(N-1))';

    T = TB + TO;% + opts.flow*ThetaGap;
    
    X = R.*cosd(T);
    Y = R.*sind(T);

    V = [ X(:) Y(:) ];

    %% Compute the voronoi
    T = delaunayTriangulation(rmmissing(V));

    [ V, r ] = voronoiDiagram(T);
    n = numel(r);
    F=nan(n,12);
    for q=1:n
        if size(F,2) < numel(r{q})
            for fi = (size(F,2)+1):numel(r{q})
                F(:,fi) = nan;
            end
        end
        F(q,1:numel(r{q}))=r{q};
    end

    FVC = hypot(V(:,1),V(:,2));

    %% Upate patch
    newplot
    patch('Vertices',V,'Faces',F,'FaceVertexCData',FVC, ...
          'FaceColor','none','EdgeColor','interp',...
          'LineStyle', '-', 'LineWidth',2);
    daspect([1 1 1]);
    axis([-1 1 -1 1],'off');
    set(gca,'position',[0 0 1 1]);
    set(gcf,'color','k');
    colormap(flipud(parula))

end


      
    
    