animateFrames();
function animateFrames()
    animFilename = 'Pendulum_Wave_Galaxy.gif'; % Output file name
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
function drawframe(t)
    t = t + 2400-24;
    fr = 6000;
    dim = 1:100;
    n = length(dim);
    n2 = n/2;
    idx = 1:2:n;
    sz = linspace(120,60,n2);
    r = [0.1 1];
    rs = linspace(r(2),r(1),n);
    xp = rs.*cosd(((t-1)/(fr-1))*360.*dim);
    yp = rs.*sind(((t-1)/(fr-1))*360.*dim);
    pt = colormap(hsv(n2));
    int = inter(xp,yp);
    pt2 = colormap(spring(size(int,2)));
    % Plot
    figure(1);
    clf
    hold on
    set(gca,'Visible','off');
    set(gcf,'Color','k');
    axis([-1 1 -1 1]);
    scatter(int(1,:),int(2,:),sz(1)/10,pt2,'filled','MarkerEdgeColor','k');
    scatter(xp(idx),yp(idx),sz,pt,'filled');
    function P = inter(xp,yp)
        % Find intersections
        hF = @lt;
        x1  = xp';  x2 = xp;
        y1  = yp';  y2 = yp;
        dx1 = diff(x1); dy1 = diff(y1);
        dx2 = dx1'; dy2 = dy1';  
        S1 = dx1.*y1(1:end-1) - dy1.*x1(1:end-1);
        S2 = dx2.*y2(1:end-1) - dy2.*x2(1:end-1);
        C1 = hF(D(bsxfun(@times, dx1, y2) - bsxfun(@times, dy1, x2), S1), 0);
        C2 = hF(D((bsxfun(@times, y1, dx2) - bsxfun(@times, x1, dy2))', S2'), 0)';
        [i,j] = find(C1 & C2); 
        if ~isempty(i) 
            i=i'; dx2=dx2'; dy2=dy2'; S2 = S2';
            L = dy2(j).*dx1(i) - dy1(i).*dx2(j);
            i = i(L~=0); j=j(L~=0); L=L(L~=0);
            P = unique([dx2(j).*S1(i) - dx1(i).*S2(j), ...
                        dy2(j).*S1(i) - dy1(i).*S2(j)]./[L L],'rows')';
        else
            P = zeros(2,0);
        end
    end
    function u = D(x,y)
        u = bsxfun(@minus,x(:,1:end-1),y).*bsxfun(@minus,x(:,2:end),y);
    end
end


      
    
    