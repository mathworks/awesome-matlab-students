animateFrames();
function animateFrames()
    animFilename = 'Rolling_fog.gif'; % Output file name
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

    % Moon over rolling fog.  
    % Comments below,
    
    % Persistent variables -> keep you from having to recompute these
    % variables at each iteration / save computation time
    persistent enz ags x d c mx my mn cmp
    if nn == 1        
        % Everything is precomputed so we don't really need this -> undo to
        % get different clouds each time
        rng default
        
        % Base vector for pixels
        x = linspace(-1, 1, 240);
        
        % Make complex 3D noise spectrum -> spectrally shaping using
        % distance. This is expensive so only do once.
        b=length(x);
        d=x(1:2:end)/2;
        c=length(d);
        r = ifftshift(sqrt((x*2).^2 + d'.^2 + permute(x.^2, [1, 3, 2])));
        ags = linspace(0, 2*pi, 49);
        enz = exp(6i*randn(c, b, b))./max(r.^2.4,2e-5);
        
        % Make moon
        [mx, my] = meshgrid(x);
        rd = (mx-0.6).^2 + (my+0.2).^2;
        mn = 1 - erf(max(rd - 0.3, 0)*3);
        
        % Custom colormap for clouds
        cmp = linspace(0, 1, 256)'.*[1, 1, 1];
        cmp(:, 1) = cmp(:, 1).^1.6;
        cmp(:, 2) = cmp(:, 2).^1.6*0.97;
        cmp(:, 3) = tanh(cmp(:, 3))*1.1;
    end

    % Compute current noise realization. Linear phase causes a looping
    % shift and offset creates the cloud morphing.
    dt = abs(ifftn(exp(1i*(x.*ags(nn)/2 - ags(nn)/2)).*enz));
    
    % Tapering the noise
    dt = 5*dt.*(d-d(1))'.*permute(erf((x - 0.1)*2)+1, [1, 3, 2]);
    dt = dt(:, :, 1:end);
    
    % Thresholding for transparency
    ap = dt>0.08;

    % Making it look like clouds / adding glint
    c_alp = cumsum(ap, 3);
    CLS = (1.1 - erf(c_alp/5)).*ap.*dt;
    ALP = ap.*rescale(dt);
    
    % Alpha blend across volume
    [AI, AS] = P(ALP, CLS);
    
    % Loop spatially / keeps formations in roughly same spot. Turn off to
    % see a different cloud movement effect.
    AI = circshift(squeeze(AI)', [0, -5*nn]);
    AS = circshift(squeeze(AS)', [0, -5*nn]);
    
    % Web Matlab's 3D rendering is so slow that this fails to execute if
    % you use surf to blend the images, so let's use the alpha-blender used
    % to flatten the clouds for the RGB background, moon and cloud layers
    
    % Convert clouds to RGB image using custom colormap
    C = round(min(AI*40, 1)*255+1);
    C = double(ind2rgb(C, cmp));
      
    % Permuter to work with alpha blending function convention
    PP = @(x)permute(x, [3, 2, 1]);
    
    % This is a mess, but, it computes the alpha then applies the alpha
    % blender to each channel and combines to form an image.
    A = PP(cat(3, AS, mn, ones(size(mn))));    
    IG = PP([P(A, PP(cat(3, C(:, :, 1), mn, 0*mn))); P(A, PP(cat(3, C(:, :, 2), mn, 0*mn))); P(A, PP(cat(3, C(:, :, 3), mn*0.9, 0*mn)))]);

    % Now, show.
    image(IG); 
    axis equal; 
    camva(5.8);
    
    %S.D.G.

    % Alphablend function
    function [AIf, ASf] = P(ATf, CLSf)
        ASf = ATf(1, :, :);
        AIf = CLSf(1, :, :);

        % Have alpha, have intensity, compress onto single plane using alpha
        % blending formula
        for nf = 2:size(ATf, 1)
            APf = ASf;
            ASf = APf + ATf(nf, :, :).*(1-APf);
            AIf = (AIf.*APf + CLSf(nf, :, :).*ATf(nf, :, :).*(1-APf))./(eps + ASf);
        end
    end
end


      
    
    