animateFrames();
function animateFrames()
    animFilename = 'Glowing_Jellyfish.gif'; % Output file name
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
function drawframe(n)
Resolution = 27; %number of pillars per row
StepSize = n/48;

x = linspace(0,2,Resolution);
[X,Y] = meshgrid(x);
Distance = sqrt((X-1).^2 + (Y-1).^2); 
Height = 4*sin(pi*(Distance - StepSize)).^2;
Abyiss = -4*cos(pi*(Distance - StepSize)).^2;

clf
fig = gcf;
ax = axes(gcf); %separate axes necessary to match color for upper and lower bar3c() plot
ay = axes(gcf);

if 28*cos(n*2*pi/48)<=0
    bar3c(ax,Height)
    bar3c(ay,Abyiss)
else 
    bar3c(ax,Abyiss)
    bar3c(ay,Height)
end

colormap(hot)

camzoom(ax,1.3)
camzoom(ay,1.3)

Turn = -37.5 + n*90/48;
UpDown = 30*cos(n*2*pi/48);
ax.View = [Turn, UpDown];
ay.View = [Turn, UpDown];

ax.XLim = [0.5,Resolution+0.5];
ax.YLim = [0.5,Resolution+0.5];
ax.ZLim = [-ceil(Resolution/4),ceil(Resolution/4)];
ay.XLim = [0.5,Resolution+0.5];
ay.YLim = [0.5,Resolution+0.5];
ay.ZLim = [-ceil(Resolution/4),ceil(Resolution/4)];

ax.Visible = 'off';
ax.XTick = [];
ax.YTick = [];
ay.Visible = 'off';
ay.XTick = [];
ay.YTick = [];
fig.Color = 'k';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Not my code and dont know the source anymore. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hh = bar3c( varargin )
%BAR3C Extension of bar3, which sets the bar color corresponding to its
%height.
%
% Extra parameter: 'MaxColorVal', maxclr
% This will make the color/height of the bar absolute against this maximum
% value. Otherwise, the colors will be relative against the maximum zdata
% value of all bars on the graph.

	h = bar3(varargin{:},1);

	for ii = 1:numel(h)
        zdata = h(ii).ZData;
		cdata = makecdata(zdata(2:6:end,2),NaN);
		set(h(ii),'Cdata',cdata,'facecolor','flat');
	end

	if nargout>0 
		hh = h; 
	end
end

function cdata = makecdata(clrs,maxclr)
	cdata = NaN(6*numel(clrs),4);
	for ii=1:numel(clrs)
		cdata((ii-1)*6+(1:6),:)=makesingle_cdata(clrs(ii));
	end
	if nargin>=2
		% it doesn't matter that we put an extra value on cdata(1,1)
		% this vertex is NaN (serves as a separator
		cdata(1,1)=maxclr;
	end
end

function scdata = makesingle_cdata(clr)
	scdata = NaN(6,4);
	scdata(sub2ind(size(scdata),[3,2,2,1,2,4],[2,1,2,2,3,2]))=clr;
end
end


      
    
    