animateFrames();
function animateFrames()
    animFilename = 'Time_lapse_of_Lake_view_to_the_West.gif'; % Output file name
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
persistent u n b M2 a2 a2_a r2
if f==1
u=@linspace;
n=@rescale;
b=@circshift;
q=400;
a=1.65;
m=0;
%sets up the colormap
g=[0.5373    0.1529    0.0824
    0.6745    0.2353    0.1176
    0.8706    0.3412    0.1647
    0.9176    0.6353    0.2471
    0.9843    0.9922    0.9725];
g=interp1(u(0,100,5),g,u(0,100,255));
g2=g-.15;
g2(g2<0)=0;
colormap([g;g2]);
% for the sunset have 2 different colourmaps for the background and the
% clouds then blend within each channel
%declare some functions and variables to save characters
X=u(1,255,200); %vector ranging between 1 and 255 200 long
X2=u(-1,1,400); %vector ranging between -1 and 1 400 long
[t2,r2]=cart2pol(X2,X2'+.1);%make radial gradient for the sun
M=n(-r2(1:200,:),1,280);%or for sun
X=u(-1,1,q);
[t,r]=cart2pol(X,X'); %create r matrix for filter in fourier transform
l1=d(r,a); %generate 3 cloud layers using filtered noise function
l2=-d(r,a);
l3=d(r,a);
i1=round(u(1,q,48)); %create 2 sets of indices for slow and fast moving cloud layers
i2=round(u(1,800,48));
[x,y] = meshgrid(0:399);
%smaller first constant creates wider cloud band (line below).
M3 = exp(-.007*(y-290).^2/4^2); % gaussian envelope in matrix to keep clouds in a specified band. 
%pregenerate frames so all frames can be rescaled together
for k=1:48
    %pairs of matrices define the pixelmap and the alpha
    a1(:,:,1)=n(l1,-6,8); %first cloud layer doesn't move
    a1_a(:,:,1)=n(l1,-6,8);
    a1(:,:,2)=n(b(l2,i2(k),2),-6,8); %second cloud layer traverses the image once
    a1_a(:,:,2)=n(b(l2,i2(k),2),-6,8);
    a1(:,:,3)=n(b(-l3,i1(k),2),-6,8); %third cloud layer traverses the image twice
    a1_a(:,:,3)=n(b(l3,i1(k),2),-6,8);
    a2(:,:,k)=(max(a1,[],3)).*M3; %blend 3 cloud layers using a max function
    a2_a(:,:,k)=(max(a1_a,[],3)).*M3; %blend 3 cloud layers using a max function
end
a2=n(abs(a2),-80,255);
a2_a=n(a2_a,0,1);
for k=1:48
    M2(:,:,k)=M.*(1-(a2_a(201:400,:,k)))+(a2_a(201:400,:,k)).*a2(201:400,:,k); %blend alpha cloud layer with sky layer
end
%flip matrix and create sea currents using circshift
M2=n(M2,0,255);
end
        D=flip(M2(:,:,f))+255;
         % reflection from water
        M4=M2(:,:,f);
        M4(r2(1:200,:)<0.045)=255;%set sun colour
        for k1=30:200
            D(k1,197:203)=255+255-randi(80);
            M4=[M4;b(D(k1,:),round(4*randn),2)];
        end
        image(M4)
        axis equal
        axis off
        camva(4)
function c=d(r,a)
c=rescale(abs(ifft2(fftshift(fft2(randn(400))).*(r.^-a))),0,1).^1; %function to create clouds
end
end


      
    
    