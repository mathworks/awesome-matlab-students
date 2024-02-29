animateFrames();
function animateFrames()
    animFilename = 'Propeller_Wake.gif'; % Output file name
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

% Number of frames
frames = 48;

% Number of blades
nblades = 3;

% Propeller azimuth angle
az = (f-1)/(frames-1)*2*pi;

% Draw propeller
draw_prop(az,nblades)

% Draw wake
draw_wake(az,nblades)

% Equal axis scaling
daspect([1 1 1])

% Set axes limits
xlim([-1.5 0.5])
ylim([-1 1])
zlim([-1 1])

set ( gca, 'xdir', 'reverse' ) 
set ( gca, 'ydir', 'reverse' ) 
grid on
hold off
end

function draw_prop(az, nblades)
% Discretization along the blade span
y = linspace(0,1,100);

% Leading edge equation
LE_z = (sqrt(y) - y)*0.3;

% Trailing edge equation
TE_z = -(sqrt(y) - y)*0.5;

% XYZ coordinates matrix
prop_xyz = [y*0, y*0;
            y, y(end:-1:1);
            LE_z, TE_z(end:-1:1)];
        
% Pitch of the blade
pitch = 5*pi/180;

% Apply pitch
yrot = y_rot(pitch);
prop_xyz = yrot'*prop_xyz;

% Loop over number of blades and create plot
for ii = 1:nblades
    
    % Blade relative angle
    az_rel = ii * 2*pi/(nblades);
    
    % Rotate blade about x-axis
    xrot = x_rot(az + az_rel);
    prop_xyz_ii = xrot'*prop_xyz;
    
    % Plot
    fill3(prop_xyz_ii(1,:), prop_xyz_ii(2,:), prop_xyz_ii(3,:), 'r')
    hold on
end
end

function draw_wake(az, nblades)

% Create straight wake
y = linspace(0.2,1,5);
x = linspace(-0.05,-2,50);
[x,y] = meshgrid(x,y);
z = x*0;

for kk = 1:nblades
    
    % Blade relative angle
    az_rel = kk * 2*pi/(nblades);
    
    % Initialize blade ii wake
    x_kk = x*0;
    y_kk = y*0;
    z_kk = z*0;
    
    % Rotate wake ii
    for ii = 1:length(x)
        
        % Relative angle w.r.t x
        wake_rot = (ii-1) * -5*pi/180;
        
        % Get rotation matrix
        xrot = x_rot(az + az_rel + wake_rot);
        
        % Get wake points at x(ii)
        xyz_ii = [x(:,ii)'; y(:,ii)'; z(:,ii)'];
        
        % Rotate points
        xyz_rot = xrot'*xyz_ii;
        
        % Assign coordinates to wake kk
        x_kk(:,ii) = xyz_rot(1,:);
        y_kk(:,ii) = xyz_rot(2,:);
        z_kk(:,ii) = xyz_rot(3,:);

    end
    
    % Plot
    surf(x_kk,y_kk,z_kk,'facecolor','w')
end

end

function x = x_rot(phi_rad)
% Outputs rotation matrix about x-axis
x = [   1,      0,      0
    	0,  cos(phi_rad), sin(phi_rad)
        0, -sin(phi_rad), cos(phi_rad)];

end
function y = y_rot(the_rad)
% Outputs rotation matrix about y-axis
y = [   cos(the_rad), 0, -sin(the_rad)
            0       , 1,        0
        sin(the_rad), 0,  cos(the_rad)];
end


      
    
    