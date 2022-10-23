classdef AffineTForm<CoordinateSystemTransform
    % AffineTForm
    % Convention of forward transform is:
    % 1. Scale
    % 2. Direction
    % 3. Rotation
    % 4. Translation
    properties(Access=private)
        tform;
        isBuilt;
        rotationAngleDeg;
        xTranslation;
        yTranslation;
        xScale;
        yScale;
        xDirection;
        yDirection;
    end
    
    methods(Access=public)
        function obj = AffineTForm(system1Tag,system2Tag)
            obj=obj@CoordinateSystemTransform(system1Tag,system2Tag);
            obj.reset();
        end

        function reset(obj)
            obj.setTranslation([0,0]);
            obj.setRotationAngle(0);
            obj.setScale([1,1]);
            obj.setXDir("NORMAL");
            obj.setYDir("NORMAL");
        end

        function setTranslationX(obj,translation)
            arguments
                obj
                translation (1,1) {mustBeNumeric,mustBeReal}
            end
            obj.xTranslation=translation;
            obj.isBuilt=false;
        end

        function setTranslationY(obj,translation)
            arguments
                obj
                translation (1,1) {mustBeNumeric,mustBeReal}
            end
            obj.yTranslation=translation;
            obj.isBuilt=false;
        end

        function setTranslation(obj,distance)
            obj.setTranslationX(distance(1));
            obj.setTranslationY(distance(2));
        end

        function setRotationAngle(obj,rotationAngleDeg)
            obj.rotationAngleDeg=rotationAngleDeg;
            obj.isBuilt=false;
        end

        function setXDir(obj,direction)
            arguments
                obj
                direction {mustBeMember(direction,["NORMAL","INVERTED"])}
            end
            obj.xDirection=direction;
            obj.isBuilt=false;
        end

        function setYDir(obj,direction)
            arguments
                obj
                direction {mustBeMember(direction,["NORMAL","INVERTED"])}
            end
            obj.yDirection=direction;
            obj.isBuilt=false;
        end

        function setScale(obj,scale)
            obj.setScaleX(scale(1));
            obj.setScaleY(scale(2));
        end

        function setScaleX(obj,scale)
            arguments
                obj
                scale (1,1) {mustBeNumeric,mustBeReal}
            end
            obj.xScale=scale;
        end

        function setScaleY(obj,scale)
            arguments
                obj
                scale (1,1) {mustBeNumeric,mustBeReal}
            end
            obj.yScale=scale;
        end
        
        function transformedPoints=transform1To2(obj,points)
            if ~obj.isBuilt
                obj.build();
            end
            transformedPoints=obj.tform.transformPointsForward(points')';
        end

        function transformedPoints=transform2To1(obj,points)
            if ~obj.isBuilt
                obj.build();
            end
            transformedPoints=obj.tform.transformPointsInverse(points')';
        end
    end

    methods(Access=private)
        function dir=dirStringToDir(~,dirString)
            if dirString=="NORMAL"
                dir=1;
            elseif dirString=="INVERTED"
                dir=-1;
            else
                error('Internal class error.');
            end
        end

        function build(obj)
            obj.tform=affine2d();
            innerMat=[obj.dirStringToDir(obj.xDirection)*obj.xScale*cosd(obj.rotationAngleDeg),obj.dirStringToDir(obj.xDirection)*obj.xScale*sind(obj.rotationAngleDeg);...
                     -obj.dirStringToDir(obj.yDirection)*obj.yScale*sind(obj.rotationAngleDeg),obj.dirStringToDir(obj.yDirection)*obj.yScale*cosd(obj.rotationAngleDeg)];
            obj.tform.T(1:2,1:2)=innerMat;
            obj.tform.T(3,1)=obj.xTranslation;
            obj.tform.T(3,2)=obj.yTranslation;
            obj.isBuilt=true;
        end
    end
end

