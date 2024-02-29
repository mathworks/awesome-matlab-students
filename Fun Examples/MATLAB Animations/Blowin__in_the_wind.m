animateFrames();
function animateFrames()
    animFilename = 'Blowin__in_the_wind.gif'; % Output file name
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
%declare some functions and variables to save characters
persistent u n b q S X1 X M a t r l1 l2 l3 i1 i2 z a2
if f==1
u=@linspace;
n=@rescale;
b=@circshift;
q=400;
%%make a sky gradient
S=[0 .42 .85
    .88 .92 .95];
X1=u(1,255,200); %vector for colourmap
M=repmat(X1,q,1); %sky matrix (gradient)
a=1.60;
X=u(-1,1,q); %create linear r matrix
[t,r]=cart2pol(X,X'); %create polar coord matrices of r and theta
l1=d(r,a); %generate 3 cloud layers using function
l2=d(r,a);
l3=d(r,a);
i1=round(u(1,q,48)); %create 2 sets of indices for slow and fast moving cloud layers
i2=round(u(1,800,48));
z=256*ones(q,q); %white sky colour)
m=0;
for k=1:48
    a1(:,:,1)=n(l1,-2,2.5); %first cloud layer doesn't move
    a1(:,:,2)=n(b(l2,i2(k),2),-2,4); %second cloud layer traverses the image once
    a1(:,:,3)=n(b(l3,i1(k),2),-2,2.5); %third cloud layer traverses the image twice
    a2(:,:,k)=min(a1,[],3); %blend 3 cloud layers using a max function
end
a2=n(a2,0,3);
end
%generate colourmap by interpolating between 2 colour points in R, G and B,
%white in position 256. black in 257
colormap([interp1([0 255], S, [0:1:255]); 1 1 1; 0 0 0]);
M2=M'.*(a2(201:400,:,f))+(1-a2(201:400,:,f)).*z(201:400,:); %blend alpha cloud layer with sky layer
MS=flipud(M2);
D=flip(M2);
for k1=1:200
M2=[M2;circshift(D(k1,:,:),round(8*randn),2)];
end
image(M2)
axis equal
axis off
camva(4)
function c=d(r,a)
c=rescale(abs(ifft2(fftshift(fft2(rand(400))).*(r.^-a))),0,1).^1.1; %function to create clouds
end
end


      
    
    