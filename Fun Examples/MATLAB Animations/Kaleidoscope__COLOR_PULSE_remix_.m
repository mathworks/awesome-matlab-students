animateFrames();
function animateFrames()
    animFilename = 'Kaleidoscope__COLOR_PULSE_remix_.gif'; % Output file name
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

    % @"kishimisu" I don't know who you are but you are GLSL god.
    % this is my transposed version in MATLAB.
    % https://www.shadertoy.com/view/mtyGWy

    % What I've learned transposing GLSL to MATLAB:
    % vec.length = vecnorm( vec,2,3)
    % vec.fract  = mod( vec, 1)
    % - all the rest is nearly pure math and talent.
    
iRes = cat(3, 800, 800);
iTime = f/47*3;

persistent fragCoord
if isempty(fragCoord)
    [x,y]=meshgrid(1:iRes(1), 1:iRes(2));
    fragCoord = cat(3,x,y);
end
img = mainImage(fragCoord);

imagesc(img)
axis equal
axis off

function out=palette( t )
    cc = ones(1,1,3);
    aa = cc/2; 
    dd = reshape([0.263,0.416,0.557],1,1,3);
    out = aa + aa.*cos( 6.28318*( cc .* t + dd) );
end

function finalColor=mainImage( fragCoord )
    
    uv = (fragCoord * 2 - iRes) / iRes(2);
    uv0 = uv;
    finalColor = 0;
    i=0;
    while i < 4
        uv = mod(uv * 1.5, 1) - 0.5;

        d = vecnorm(uv,2,3) .* exp(-vecnorm(uv0,2,3));
        col = palette( vecnorm(uv0,2,3) + i *0.4 + iTime*0.4);
        d = sin( d*10 + iTime )/8;
        d = abs(d);
        d = (0.01 ./ d).^ 1.2;

        finalColor = finalColor + col .* d;
        i=i+1;
    end
    finalColor = finalColor/2;
    finalColor = finalColor + imrotate(finalColor, 45, 'bicubic', 'crop');

end
end

      
    
    