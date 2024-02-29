animateFrames();
function animateFrames()
    animFilename = 'Happy_Sheep_on_Vacation_.gif'; % Output file name
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
% Happy Sheep on Vacation!
% By Victoria A. Sablina

% Handles
s = @sin;
c = @cos;
% Ellipse + Polar Rose
F = @(t,a,f) a(4)*f(t)+a(1)*s(a(2)*t).*f(t)+a(3);
% Angles
t = 0:.1:7;
% Parameters
% Head (1:2)
% Eyes (3:6)
% Hoofs (7:14)
% Body (15:16)
% Crown (17:18)
% Tail (19:20)
% Smile (21:22)
Z = zeros(1,6);
O = Z + 1;
B = [.1*O;.5*O];
G = -13;
P = [Z Z 1 1 O 0 -3;O O 0 0 8 8 12 12 4 3 1 1;-15 2 G...
    3 -17 3 -3 G 0 G 9 G 12 G...
    -15 10 4 3 20 7 -15 7.5;5 7 B(:)' 6 4 14 9 3 3 5 7];
d = abs(f - 24.5)/100;
% Tail Waving
P(2,20) = 2.8 + d;
e = 2*abs(mod(f,24) - 12.25)^2/100;
j = [10*d 0 10*d 0];
% Walking
if f < 25
   P(3,[7:8 11:12]) = P(3,[7:8 11:12]) + [10*d 3 - e 10*d 3 - e];
   P(3,[9:10 13:14]) = P(3,[9:10 13:14]) - j;
else
   P(3,[7:8 11:12]) = P(3,[7:8 11:12]) + j;
   P(3,[9:10 13:14]) = P(3,[9:10 13:14]) - [10*d e - 3 10*d e - 3];   
end
% Painting
figure;
hold on;
for i = [2:8 10]
   plot(F(t,P(:,2*i-1),c),F(t,P(:,2*i),s),'LineWidth',6,'Color','blue');
end
% Crown
t = 2.5:.1:7.2;
plot(F(t,P(:,1),c),F(t,P(:,2),s),'LineWidth',6,'Color','blue');
% Body
t = -2.9:.1:2.7;
plot(F(t,P(:,17),c),F(t,P(:,18),s),'LineWidth',6,'Color','blue');
% Smiling
t = (4.3 - d):.1:(5.2 + d);
plot(F(t,P(:,21),c),F(t,P(:,22),s),'LineWidth',6,'Color','blue');
axis off
axis equal

end


      
    
    