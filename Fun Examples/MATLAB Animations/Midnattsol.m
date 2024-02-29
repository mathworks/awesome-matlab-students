animateFrames();
function animateFrames()
    animFilename = 'Midnattsol.gif'; % Output file name
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
g1=[45	129	191
64	148	195
135	178	210
158	196	215
170	207	216
210	219	218];
g2=[120	110	119
142	119	113
167	123	88
194	134	72
206	142	68
219	142	28];
z=linspace(1,6,100);
d=[linspace(10,30,24) linspace(30,10,24)];
x(:,:,1)=interp1(1:6,g1,z);
x(:,:,2)=interp1(1:6,g2,z);
x=permute(x,[3 1 2]);
x=permute(interp1([1,48],x,1:2:48),[2,3,1])./255;
x=cat(3,x,x(:,:,end:-1:1));
a=1000;
q=linspace(-235,235,48);
m=linspace(pi,-pi,48);
X=linspace(-255,255,a);

[t,r]=cart2pol(X-q(f),100+X'-100*cos(m(f)));
[x_i,y_i]=find(r<21);
[x_i2,y_i2]=find(r<3);
b=x(:,:,f);
j=[1 1 .9];
colormap([j;flipud(b)]);
r(r<20)=1;
for k=1:300
y(k,:)=circshift(r(min(x_i),:),randi(100)-50);
y(k,y_i2+round(randi(round(d(f)))-d(f)/2))=1;
end
imagesc([r(100:600,:);y])
axis equal
axis off
xlim([100 900]);

end



      
    
    