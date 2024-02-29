animateFrames();
function animateFrames()
    animFilename = 'Endless_tunnel.gif'; % Output file name
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
function drawframe(nn)

% This enables the same "random" texture to be created every time
rng default;

r=6;                            % Torus radius
N=80;                           % Texture resolution. Set to higher on your own computer for improvements.
                                % (Has longer rendering times!)
R=zeros(N, N*8);                % Initial torus radius
R(:,N/2:N:end)=-.02;            % Notches every bit

R=conv2(R,[1:4,3:-1:1],'same');                         % Fare the notches
R=R+conv2(randn(size(R))/500,ones(3)/9,'same')+1;       % Add some random noise. Probably doesn't do a whole
                                                        % lot for N = 80.
R(end, :)=R(1, :);                                      % Match endpoints to prevent a glitch

% Make angles for torus (radial and axial)
l=@(x)linspace(0,2*pi,x);
ag1=l(N)';
ag2=l(N*8);

% This will be the tunnel
b=R.*cos(ag1);
z=R.*sin(ag1);
x=b.*cos(ag2)+r*cos(ag2);
y=b.*sin(ag2)+r*sin(ag2);;

% This will be the algae growing on the pipe
R2=R*.99;
b=R2.*cos(ag1);
z2=R2.*sin(ag1);
x2=b.*cos(ag2)+r*cos(ag2);
y2=b.*sin(ag2)+r*sin(ag2);


% This will eventually be the water at the bottom
rd=linspace(4, 8, N)';
xd=rd.*cos(ag2);
yd=rd.*sin(ag2);

% Make camera positions
ag=linspace(0,2*pi,48*4);
cpx=r*cos(ag);
cpy=r*sin(ag);
cpz=zeros(size(cpx))-0.2;

% Texture: this will be the water. Making a complex random
% function. Noise generated spectrally like this has looping boundaries /
% can be tiled, so it is tiled for start/end consistency
[xx,yy]=meshgrid(linspace(-1,1,N*8),linspace(-1,1,N));
rd=sqrt(xx.^2+yy.^2);
sgnO=((randn(N, N*8)+1i*randn(N, N*8))./((ifftshift(rd.^2)+1e-5)));
sgnO=ifft2(sgnO(:,[1:N,end-N+1:end]));
sgnO=[sgnO,sgnO,sgnO,sgnO];

% This will be the algae on the side.
sg=(((randn(N,N*8)+1i*randn(N, N*8))./((ifftshift(rd.^2)+1e-6))));
sg=real(ifft2(sg(:, 1:N*2)));
sg=[sg,sg,sg,sg];

sg=erf(sg*2)+1;
sg=-sg.*(1-erf(sin(ag1)+1));

% This will be our phase looper. Since the water phase noise is complex, we
% can loop over 2*pi to get a splashing effect
ags=linspace(0, pi/4, 49);
ags=ags(1:48);

clf             % Lights seem to accumulate without this...

% Algae color
clrF      = permute([0.3, 0.5, 0.3]*0.4, [1, 3, 2]);

% Faster if we limit the number of faces generated each frame... this
% truncates the rendered portion of the torus to what is visible
[~, ci]   = min(abs(ag2-ag(nn)));
rgv       = (1:N*2) + ci;

% Update water noise using a phase rotation
sgn      = real(sgnO.*exp(1i*ags(nn)*16));
sgn      = sgn - mean(sgn(:));
sgn      = erf(1*sgn/std(sgn(:)));

% Truncate
sgn     = sgn(:, rgv);
sg      = sg(:, rgv);
idz     = N*8;

% Begin plotting
clr     = (conv2(rand(N, N*8), ones(5)/25, 'same')*0.3+0.7).*ones(N, N*8, 3)*0.5;
surf(x(:, rgv), y(:, rgv), z(:, rgv), clr(:, rgv, :), 'SpecularStrength', 1, 'AmbientStrength', 0);
hold on;
surf(x2(:, rgv), y2(:, rgv), z2(:, rgv), (rand(size(sgn))*0.2+0.8).*clrF, 'FaceAlpha', 'flat', 'AlphaData', erf(rescale(1-sg)*2+0.5)*1, 'SpecularStrength', 0, 'AmbientStrength', 0);    
surf(xd(:, rgv), yd(:, rgv), rand(size(sgn))*0.002 + sgn/20-0.8, 'FaceAlpha', 0.9, 'AmbientStrength', 0, 'DiffuseStrength', 0.35, 'SpecularStrength', 1);

% Appearance and camera settings
shading interp
axis equal
camproj('Perspective');
camva(50);
campos([cpx(nn), cpy(nn), cpz(1)+sin(ags(nn)*16)/6 - 0.2]);
camtarget([cpx(nn+18), cpy(nn+18), cpz(nn+18)-0.4]);

% Headlight: one doesn't seem strong enough
camlight;
camlight
D = camlight;
D.Color = [0.6, 0.8, 1];

% This is inefficient, should just directly set water color in the call to
% surf but you can pick a different colormap to alter the water color here
cmp = copper + summer;
colormap(cmp/2);
caxis([-1, 1]);

% S.D.G.
end



      
    
    