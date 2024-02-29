animateFrames();
function animateFrames()
    animFilename = 'Midnight_Marathon__Apartment_Edition.gif'; % Output file name
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

axes(Color='k',Pr='p')
hold   
h=ones(9,2)*2+.4;     % building heights
b=bar3(h,.5);
set(b,FaceC=[.3,.3,.3]);
axis equal
camva(30)
campos([1.5 10 .2])
for i=1:9 %rows of buildings     1:size(h,1)
    for j=1:2 %L/R buildings
        c=.1:.2:h(i,j)-.2;
        d=[c;c];
        z=d(:)'+[0;0;.1;.1];
        y=i-[15;5;5;15]*.01+[0,.2];
        y=repmat(y,1,numel(c));
        patch((.75+j/2*(z*0+1)),y+0.1*f,z,[.8,.8,.8])
    end
end
camlight
end


      
    
    