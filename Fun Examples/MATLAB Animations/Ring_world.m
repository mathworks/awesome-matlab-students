animateFrames();
function animateFrames()
    animFilename = 'Ring_world.gif'; % Output file name
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

% Ring world...

persistent H CS S3 U
if f==1
    rng(2,'v4')

    % % % % Make the ring % % % %
    r=6;                % Radius
    N=60;              % Number of edge-pixels on base unit
    U=8;                % Rotating by 1/8 of a circle

    % Add texture to ring. Make it tech-y
    R=zeros(N,N);
    R(randi(N^2, 3))=1;
    k1=ones(N/2)/10;
    k2=k1;
    k2(2:end-1,2:end-1)=0;      % Kernel for glowing lights
    RL=conv2(R,k2,'same');      % Glowing lights
    R=conv2(R,k1,'same');       % Surface

    % Tiling
    R=repmat(R,[1,U])+1;
    RL=repmat(RL,[1,U]);

    % Fix seams. Expendable code.
    R=s(R,N);
    RL=s(RL,N);
    RB=(R-1)/2;
    RL=RL./RL;

    % Notch to fit the land in...
    NH=N/2;
    NW=floor(N/6);
    R(NH-NW+1:NH+NW, :)=0;

    % Make our angles
    l=@(x)linspace(0,2*pi,x);
    ag1=l(N)';
    a=l(N*U);
    c=cos(a);
    v=sin(a);

    % Ring torus
    b=erf(R.*cos(ag1)*5)+RB;   % Make it square-ish
    z=R.*sin(ag1);
    x=b.*c+r*c;
    y=b.*v+r*v;

    % % % % Make the land inside.
    % Spectral noise shaping... land mass will be a noisy cylinder
    q=linspace(-1,1,N);
    rand(8);
    k=@()exp(6i*randn(N))./(q.^2+q'.^2+2e-4);
    oo=@(x)ifft2(x);

    B=rescale(abs(oo(k())))-.3;
    CS=k();
    C=rescale(abs(real(oo(CS.*exp(1i*.10)))))-.5;
    X=@(x)max(repmat(x,[1,U])',0);
    B=X(B)/2;    % Max makes the water
    C=X(C);      % Clouds

    % Assemble the cylinder   s 
    [xl,yl,zl]=cy(a',q,r-B/3-.6,N);      % Land
    [xc,yc,zc]=cy(a',q,r+0*B-1.1,N);     % Cloud
    [xa,ya,za]=cy(a',q,r+0*B-1,N);       % Atmosphere
    za=za*1.1;
    % Custom colormap: landscapey with low value = blue = water
    cmp=max(copper,summer);
    cmp(1,:)=[.1,.3,1]/2;

    % Now plot
    H=hgtransform();
    surf(x,z,y,'pa',H);          % Ring
    material([0,.1,.6,3]);
    hold on;
    surf(x,z,y,RL.*cat(3,0,1,1),'AmbientS',1,'pa',H);          % Light

    hold on;
    % Land, clouds, atmosph
    S=surf(xl,zl,yl,B,'pa',H);
    wn=sin(ag1/2); 
    alph =(1-wn).^3'.*ones(N*U, 1); 
    cp = rescale(alph, 0.7, 1);
    cp = cat(3, cp.^8, cp.^2.5, cp.^0.9);   
    mm=@(x,y)material(x,y);
    S3=surf(xc,zc,yc,0*xc+cat(3,1,1,1),'FaceAlpha','flat','AlphaData',erf(C*4),'pa',H);    
    S2=surf(xa,za,ya,cp,'FaceAlpha','flat','AlphaData',alph.^.7);
    mm(S3,[1,0,0,5]);
    mm(S2,[.6,1,0,5]);
    mm(S,[0,1,.3,20]);
    colormap(cmp);
    caxis([0,.3]);
    axis equal
    shading flat
    
    % Add stars
    x=randn(3,900);
    x=x./vecnorm(x)*20;
    scatter3(x(1,:),x(2,:),x(3,:),rand(900,1)*100,rand(900,1)*[1,1,1],'.');
    hold off;

    % Axis / camera etc.
    shading flat
    axis equal off
    light('position',[0,-20,0]);
    light('position',[10,10,5]);
    lighting('gouraud');
    shading flat
    set(gcf,'color','k');
    camproj('perspective')
    camva(30);
    campos([78, -40, -40]/6);
    camtarget([-1, 0, -1]);
    
end
    ags=linspace(0,2*pi,49);
    oo=@(x)ifft2(x);
    C=rescale(abs(real(oo(CS.*exp(1i*ags(f))))))-.5;
    X=@(x)max(repmat(x,[1,U])',0);
    C=X(C);      % Clouds
    
campos([78,-40+sin(ags(f))*2,-40]/6)
S3.AlphaData=erf(C*4);
set(H,'Ma', makehgtform('yrotate',(f-1)*pi/4/48));


end

% Extra functions:
% Make xyz cylinder coordinates
function [x,y,z]=cy(a,q,R,N)
    x=cos(a).*R;
    y=sin(a).*R;
    z=q.*ones(N*8,1)*.9;
end

% Seam joiner
function g=s(g,N)
d=g(N,:)/2+g(1,:)/2;
g(1:4, :) = d.*ones(4,1);
g(end-3:end,:) = d.*ones(4,1);
end


      
    
    