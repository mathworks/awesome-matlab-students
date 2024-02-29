animateFrames();
function animateFrames()
    animFilename = 'The_Empty_Boat.gif'; % Output file name
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
nframes = 48;

% Compute the trajectory "phase" based on the current frame
phase_rad = f/nframes * 2*pi;

% Draw the sea
draw_sea(phase_rad)

% Draw boat
draw_boat(phase_rad)

% Set axes limits
xlim([-1 1])
ylim([ 0 2])

% Equal axes scaling
daspect([1, 1, 1])

set(gca,'XTick',[], 'YTick', [])
hold off
end

function draw_sea(phase_rad)
% Use [-1 +1] to fill entire plot
x = linspace(-1, 1, 50);

% Evaluate sea equation with the phase to create the moving illusion
[y, ~] = eval_sea_eq(x + phase_rad);

% Plot area under curve
area(x,y)
hold on
end

function draw_boat(phase_rad)
% Define some boat size parameters
body_height = 0.1;
body_span   = 0.4;
sail_height = 0.2;

% Boat "body"
b_xy(1,:) = [-body_span/2 -body_span/2*1.2 body_span/2*1.2 body_span/2 ];
b_xy(2,:) = [      0       body_height     body_height         0       ];

% Boat "body" fold
f_xy(1,:) = [b_xy(1,1)      0           b_xy(1,end)];
f_xy(2,:) = [b_xy(2,1)  body_height     b_xy(2,end)];

% Sail
s_xy(1,:) = [  -0.1            0                       0.1         ];
s_xy(2,:) = [body_height (body_height + sail_height) body_height   ];

% Get the boat y position and inclination angle
[y, psi_rad] = eval_sea_eq(phase_rad);

% Get rotation matrix
z_rot = get_z_rot(psi_rad);

% Rotate boat parts
b_xy = z_rot'*b_xy;
f_xy = z_rot'*f_xy;
s_xy = z_rot'*s_xy;

% Move boat parts
b_xy(2,:) = b_xy(2,:) + y;
f_xy(2,:) = f_xy(2,:) + y;
s_xy(2,:) = s_xy(2,:) + y;

% Plot the boat
fill(b_xy(1,:), b_xy(2,:), 'r')
fill(f_xy(1,:), f_xy(2,:), 'r')
fill(s_xy(1,:), s_xy(2,:), 'r')
end

function [y, dydx] = eval_sea_eq(x)
% Outputs sea coordinates and slope

% Scale factor
c = 0.5;

% Use only harmonics (x, 2*x, 3*x, etc.) to create the infinity loop illusion 
y       = (sin(x)*0.5 +   0.4*sin(2*x + pi/6) +   0.3*sin(3*x + pi/3) +   0.1*sin(5*x) + 2) * c;
dydx    = (cos(x)*0.5 + 2*0.4*cos(2*x + pi/6) + 3*0.3*cos(3*x + pi/3) + 5*0.1*cos(5*x) + 0) * c; % Derivative
end

function z = get_z_rot(psi_rad)
% Outputs rotation matrix about z-axis
z = [cos(psi_rad), sin(psi_rad)
    -sin(psi_rad), cos(psi_rad)];
end


      
    
    