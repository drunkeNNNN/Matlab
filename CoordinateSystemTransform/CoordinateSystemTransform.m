classdef CoordinateSystemTransform<handle
    properties(Access=private)
       system1Tag;
       system2Tag;
    end

    methods(Abstract,Access=public)
        transformedPoints=transform1To2(obj,points);
        transformedPoints=transform2To1(obj,points);
    end
    
    methods(Access=public)
        function obj=CoordinateSystemTransform(system1Tag,system2Tag)
            obj.system1Tag=system1Tag;
            obj.system2Tag=system2Tag;
        end

        function string=getDisplayString1To2(obj)
            string=class(obj);
        end

        function string=getDisplayString2To1(obj)
            string=class(obj);
        end

        function tag=getSystem1Tag(obj)
            tag=obj.system1Tag;
        end

        function tag=getSystem2Tag(obj)
            tag=obj.system2Tag;
        end
    end
end

