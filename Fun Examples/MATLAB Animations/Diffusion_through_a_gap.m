animateFrames();
function animateFrames()
    animFilename = 'Diffusion_through_a_gap.gif'; % Output file name
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

persistent Go ix jx dT dX
if(f==1)
    ix = 101; jx = 101; dT = 3; dX = 4;
    Go(1:ix,1:jx) = 0;
    Go(1:50,1:jx) = 1;
    Go(51:56,1:41) = 0;
    Go(51:56,61:101) = 0;
end


for t=1:100
    Gn(1:50,1:jx) = 1;
    Gn(ix,1) = Go(ix,1)+((dT/(dX^2))*(Go(ix-1,1)+Go(ix-1,1)+Go(ix,2)+Go(ix,2)-(4*Go(ix,1))));
    Gn(ix,jx) = Go(ix,jx)+((dT/(dX^2))*(Go(ix-1,jx)+Go(ix-1,jx)+Go(ix,jx-1)+Go(ix,jx-1)-(4*Go(ix,jx))));

    for i=51:ix-1
        j=1;
        Gn(i,j) = Go(i,j)+((dT/(dX^2))*(Go(i-1,j)+Go(i+1,j)+Go(i,j+1)+Go(i,j+1)-(4*Go(i,j))));
        j=jx;
        Gn(i,j) = Go(i,j)+((dT/(dX^2))*(Go(i-1,j)+Go(i+1,j)+Go(i,j-1)+Go(i,j-1)-(4*Go(i,j))));
    end
    
    for i=51:ix-1
        for j=2:jx-1
            Gn(i,j) = Go(i,j)+((dT/(dX^2))*(Go(i-1,j)+Go(i+1,j)+Go(i,j+1)+Go(i,j-1)-(4*Go(i,j)))) + ((dT/1500)*Go(i,j));
        end
    end
    Gn(51:56,1:41) = 0;
    Gn(51:56,61:101) = 0;
    Go = Gn;
end
surf(Go(:,:)','LineStyle','none'); hold on
patch([51 56 56 51 51],[1 1 41 41 1],[500 500 500 500 500],'k','LineWidth',2)
patch([51 56 56 51 51],[61 61 101 101 61],[500 500 500 500 500],'k','LineWidth',2);
view(2)
zlabel('Transgene Frequency');
axis([1 ix 1 jx]);
colormap(jet); clim([0 1]);
hold off
axis([1 101 1 101 0 500])
set(gca,'Color','k')
set(gcf,'Color','k')

end


      
    
    