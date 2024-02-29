animateFrames();
function animateFrames()
    animFilename = 'Ocean_Simulator.gif'; % Output file name
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
    rng(13); % setting seed for random numbers
    i=meshgrid(1:129);
    x=linspace(-10,10,129);
    X=meshgrid(x);
    a=meshgrid(linspace(-1,1,129)*pi*129/200) ;
    W= sqrt(hypot(a,a')*10);
    K=a.^2+a'.^2;
    k=sqrt(K);
    w=a./k*cosd(30)+a'./k*sind(30);
    P=1e-7./K.^2.*exp(-1e-6./K).*w.^2;
    P(K==0|w<0)=0 ;
    h=sqrt(P/2).*(randn(129)+1i*randn(129));
    w=exp(1i*W*f/2);
    Z=real(ifft2(h.*w+conj(rot90(h,2)).*conj(w)).*(2*(mod(i+i',2)==0)-1));
    surf(X,X',Z); hold on;
    m=-2e-4; 
    patch([10 -10 x],-10+[0 0 0*x],[m m Z(1,:)],[m m Z(1,:)]);
    patch([0 0 0*x]-10,[10 -10 x],[m;m;Z(:,1)],[m;m;Z(:,1)]);
    colormap(linspace(0.4,1,25)'*[0 0 1]);
    shading interp;
    axis square off;
    axis([-10 10 -10 10 m -m]);
    lightangle(-45,30);
    hold off;rng(13); % setting seed for random numbers
    i=meshgrid(1:129);
    x=linspace(-10,10,129);
    X=meshgrid(x);
    a=meshgrid(linspace(-1,1,129)*pi*129/200) ;
    W= sqrt(hypot(a,a')*10);
    K=a.^2+a'.^2;
    k=sqrt(K);
    w=a./k*cosd(30)+a'./k*sind(30);
    P=1e-7./K.^2.*exp(-1e-6./K).*w.^2;
    P(K==0|w<0)=0 ;
    h=sqrt(P/2).*(randn(129)+1i*randn(129));
    w=exp(1i*W*f/2);
    Z=real(ifft2(h.*w+conj(rot90(h,2)).*conj(w)).*(2*(mod(i+i',2)==0)-1));
    surf(X,X',Z); hold on;
    m=-2e-4; 
    patch([10 -10 x],-10+[0 0 0*x],[m m Z(1,:)],[m m Z(1,:)]);
    patch([0 0 0*x]-10,[10 -10 x],[m;m;Z(:,1)],[m;m;Z(:,1)]);
    colormap(linspace(0.5,1,25)'*[0 0.2 1]);
    shading interp;
    axis square off;
    axis([-10 10 -10 10 m -m]);
    lightangle(-45,30);
    hold off;
end


      
    
    