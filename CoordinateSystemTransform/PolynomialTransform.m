classdef PolynomialTransform < CoordinateSystemTransform
    properties(Access=private)
        system1sourceCoordinates;
        system2sourceCoordinates;

        transformFunc1to2X;
        polyX12;
        transformFunc1to2Y;
        polyY12;

        transformFunc2to1X;
        polyX21;
        transformFunc2to1Y;
        polyY21;
    end

    methods(Access=public)
        function obj = PolynomialTransform(system1Tag,system1SourceCoordinates,system2Tag,system2SourceCoordinates)
            arguments
                system1Tag (1,1) string
                system1SourceCoordinates (2,:) {mustBeNumeric,mustBeReal}
                system2Tag (1,1) string
                system2SourceCoordinates (2,:) {mustBeNumeric,mustBeReal}
            end
            obj=obj@CoordinateSystemTransform(system1Tag,system2Tag);
            obj.setSourceCoordinates(system1SourceCoordinates,system2SourceCoordinates);
        end

        function setSourceCoordinates(obj,system1SourceCoordinates,system2SourceCoordinates)
            arguments
                obj
                system1SourceCoordinates (2,:) {mustBeNumeric,mustBeReal}
                system2SourceCoordinates (2,:) {mustBeNumeric,mustBeReal}
            end
            obj.system1sourceCoordinates=system1SourceCoordinates;
            obj.system2sourceCoordinates=system2SourceCoordinates;
            obj.clearTransforms();
        end

        function clearTransforms(obj)
            obj.transformFunc1to2X=[];
            obj.transformFunc1to2Y=[];
    
            obj.transformFunc2to1X=[];
            obj.transformFunc2to1Y=[];
        end

        function initTransforms(obj,polyX12,polyY12,polyX21,polyY21)
            arguments
                obj
                polyX12 char = 'poly33'
                polyY12 char = polyX12
                polyX21 char = polyX12
                polyY21 char = polyX12
            end
            obj.initTransforms1to2(polyX12,polyY12);
            obj.initTransforms2to1(polyX21,polyY21);
        end

        function initTransforms1to2(obj,polyX12,polyY12)
            arguments
                obj
                polyX12 char = 'poly33'
                polyY12 char = polyX12
            end
            obj.polyX12=polyX12;
            obj.polyY12=polyY12;
            obj.transformFunc1to2X=fit([obj.system1sourceCoordinates(1,:)',obj.system1sourceCoordinates(2,:)'],obj.system2sourceCoordinates(1,:)',polyX12);
            obj.transformFunc1to2Y=fit([obj.system1sourceCoordinates(1,:)',obj.system1sourceCoordinates(2,:)'],obj.system2sourceCoordinates(2,:)',polyY12);
        end
        
        function initTransforms2to1(obj,polyX21,polyY21)
            arguments
                obj
                polyX21 char = 'poly33'
                polyY21 char = polyX21
            end
            obj.polyX21=polyX21;
            obj.polyY21=polyY21;
            obj.transformFunc2to1X=fit([obj.system2sourceCoordinates(1,:)',obj.system2sourceCoordinates(2,:)'],obj.system1sourceCoordinates(1,:)',polyX21);
            obj.transformFunc2to1Y=fit([obj.system2sourceCoordinates(1,:)',obj.system2sourceCoordinates(2,:)'],obj.system1sourceCoordinates(2,:)',polyY21);
        end

        function system2Coordinates=transform1To2(obj,system1Coordinates)
            arguments
                obj
                system1Coordinates (2,:) {mustBeNumeric,mustBeReal}
            end
            system2Coordinates=[obj.transformFunc1to2X([system1Coordinates(1,:)',system1Coordinates(2,:)']),obj.transformFunc1to2Y([system1Coordinates(1,:)',system1Coordinates(2,:)'])]';
        end

        function system1Coordinates=transform2To1(obj,system2Coordinates)
            arguments
                obj,
                system2Coordinates (2,:) {mustBeNumeric,mustBeReal}
            end
            system1Coordinates=[obj.transformFunc2to1X([system2Coordinates(1,:)',system2Coordinates(2,:)']),obj.transformFunc2to1Y([system2Coordinates(1,:)',system2Coordinates(2,:)'])]';
        end

        function ret=getDisplayString1To2(obj)
            ret=[getDisplayString1To2@CoordinateSystemTransform(obj),' x: ',obj.polyX12, ' y: ',obj.polyY12];
        end

        function ret=getDisplayString2To1(obj)
            ret=[getDisplayString2To1@CoordinateSystemTransform(obj),' x: ',obj.polyX21, ' y: ',obj.polyY21];
        end

        function showRelativeError(obj)
            system2CoordinatesCalculated=obj.transform1To2(obj.system1sourceCoordinates);
            system1CoordinatesCalculated=obj.transform2To1(obj.system2sourceCoordinates);

            disp(['Average Error System 1 x / mm: ',num2str(mean(abs(system1CoordinatesCalculated(1,:)-obj.system1sourceCoordinates(1,:))))]);
            disp(['Average Error Image2Cad y / mm: ',num2str(mean(abs(system1CoordinatesCalculated(2,:)-obj.system1sourceCoordinates(2,:))))]);
            disp(['Average Error Cad2Image x / px: ',num2str(mean(abs(system2CoordinatesCalculated(1,:)-obj.system2sourceCoordinates(1,:))))]);
            disp(['Average Error Cad2Image y / px: ',num2str(mean(abs(system2CoordinatesCalculated(2,:)-obj.system2sourceCoordinates(2,:))))]);
        end
    end
end
