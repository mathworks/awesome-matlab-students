animateFrames();
function animateFrames()
    animFilename = 'Open_The_Box.gif'; % Output file name
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

    % Hack to make a good 1st pic for the gallery
    f = mod(f-2,48)+1;

    %% Polyhedra Data so we can vectorize

    % The following polyhedra data can be downloaded from:
    % https://netlib.org/polyhedra/1
    % And was pre-processed into these compressed arrays.
    % 
    % For Positive Integers:
    % Convert to char, and offset into the printable character range by
    % Adding something like '0' to it.
    % 0 is convenient as you know what the first 10 #s are by sight.
    % 
    % Decoder
    D=@(v,c)reshape(v-'0',numel(v)/c,c);
    % Faces Array
    F=D('56249<45138;8947;=9:58<>',4);
    % Compress Doubles:
    % Identify # of unique values.  If that # is small, create reference
    % array with the unique values.  Then compress the indices into the
    % array of unique values to recreate the original array
    % If unique values can be represented as colonop easily, do that.
    % 
    % Vertex Array
    V=-1.5:0.5:2.5;
    V=V(D('113333555577993513571357353544444444444444',3));
    % Origin of faces so we can offset/fold
    O=-0.5:0.5:1;
    O=O(D('231134233112222222',3));
    % Rotation Axis
    R=-1:1;
    R=R(D('212322221233222222',3));
    % Angle of rotation for the solid
    A=[0
       1.5708];
    A=A(D('122222',1));
    % Children indices for each face to create the graph
    C=D('300060400000500000200000',4);
    
    
    %% Fold factor
    % 0 is wide open, 1 is fully solid
    ff=1-(mod(f-1,24)+1)/24; % Fold factor for this segment
    sc=(1-ff)*.8+.2;  % size of the cube inside the unfolding cube.

    %% Build child graph using
    persistent TX1 TX2 R1 R2
    if f==48
        axes('pos',[0 0 1 1],'clipping','off','Proj','p');
        TX = gobjects(0);

        %% Create the object tree using recursive fcn
        R1=hgtransform;
        coi=0;
        rP(1,R1,O(1,:));
        arrayfun(@(fi)xform(TX,ff,fi),1:size(F,1));
        TX1=TX;

        R2=hgtransform;
        coi=size(F,1);
        rP(1,R2,O(1,:));
        arrayfun(@(fi)xform(TX,1,fi),1:size(F,1));
        TX2=TX;
        
        %% Make axes nice
        set(gcf,'color','w');
        daspect([1 1 1]);
        axis([-1.5 2.5 -1.5 2.5 -1 2],'off')
        view(3)
        camzoom(1.5)
    end

    if f<=24
        % Mode 1
        ff1=ff;
        ff2=1;
        sc1=1;
        sc2=sc;
    else
        % Mode 2
        ff1=1;
        ff2=ff;
        sc1=sc;
        sc2=1;
    end

    % Configure the 2 cubes based on the mode
    arrayfun(@(fi)xform(TX1,ff1,fi),1:size(F,1));
    arrayfun(@(fi)xform(TX2,ff2,fi),1:size(F,1));
    set(findobj(TX1,'type','patch'),'FaceA',ff1^.5);
    set(findobj(TX2,'type','patch'),'FaceA',ff2^.5);
    rt1=(1-sc1)*pi*2;
    rt2=(1-sc2)*pi*2;
    set(R1,'Matrix',makehgtform('scale',sc1,'translate',[0 0 (1-sc1)*3],...
                                'zrotate',rt1,'xrotate',rt1));
    set(R2,'Matrix',makehgtform('scale',sc2,'translate',[0 0 (1-sc2)*3],...
                                'zrotate',pi/2-rt2,'yrotate',rt2));

    %% Helper Fcns
    function xform(tx,ff,fi)
        if A(fi)
            set(tx(fi),'Matrix',makehgtform('axisrotate',R(fi,:), ff*(A(fi)-pi)));
        end
    end
    
    function rP(fidx, parent, po)
        % Recursive function for creating the tree of gfx objects

        TXT=hgtransform(parent,'Matrix',makehgtform('translate',O(fidx,:)));
        TX(fidx)=hgtransform(TXT);
        % Total offset for vertices is local offset plus parent accum offset
        to=O(fidx,:)+po;

        % Colors to use
        co=orderedcolors('gem12');
        
        patch(TX(fidx),'Vertices',V(F(fidx,:),:)-to,'Faces',1:size(F,2),...
              'FaceC',co(fidx+coi,:),'EdgeC','w','LineW',2);

        % Create child nodes
        for i=1:size(C,2)
            if C(fidx,i)>0
                rP(C(fidx,i),TX(fidx),to);
            end
        end
    end

end


      
    
    