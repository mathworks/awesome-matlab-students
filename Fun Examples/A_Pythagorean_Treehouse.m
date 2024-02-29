animateFrames();
function animateFrames()
    animFilename = 'A_Pythagorean_Treehouse.gif'; % Output file name
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
    theta = interp1([0 48],[0 pi/2],f);
    
    clf
    hgt = hgtransform(Parent=gca);
    
    c = 1;
    maxdepth = 6;
    pythag_seg(hgt,c,theta,maxdepth);
    
    x = c*[0 0 1 1];
    y = c*[0 1 1 0];
    cmap = parula(maxdepth+1);
    p = patch(x,y,cmap(1,:));
    
    axis equal
    axis([-4 4.5 0 7.5])
    axis off
    set(gcf,Color='white')

end

function pythag_seg(hgtp,c,theta,maxdepth,depth)
    
    if nargin < 5
        depth = 1;
    end
    
    depth = depth + 1;
    if depth > maxdepth
        return
    end
    
    hgtc1 = hgtransform(Parent=hgtp);
    hgtc2 = hgtransform(Parent=hgtp);
    
    x = c*[0 0 1 1];
    y = c*[0 1 1 0];
    
    cmap = parula(maxdepth+1);
    color = cmap(depth+1,:);
    patch(x,y,color,EdgeColor='black',Parent=hgtc1);
    patch(x,y,color,EdgeColor='black',Parent=hgtc2);
   
    a = c*cos(theta);
    b = c*sin(theta);
    
    Txy = makehgtform('translate',0,c,0);
    Rz  = makehgtform('zrotate',theta);
    S   = makehgtform('scale',a/c);
    set(hgtc1,Matrix=Txy*Rz*S);
    
    Txy = makehgtform('translate',a*cos(theta),c+a*sin(theta),0);
    Rz  = makehgtform('zrotate',theta-pi/2);
    S   = makehgtform('scale',b/c);
    set(hgtc2,Matrix=Txy*Rz*S);
    
    pythag_seg(hgtc1,c,theta,maxdepth,depth)
    pythag_seg(hgtc2,c,theta,maxdepth,depth)
    
end


      
    
    