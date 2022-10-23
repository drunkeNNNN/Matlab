classdef CoordinateSystemClusterTest < matlab.unittest.TestCase
    properties(Access=private)
        csc;
        t1;
        t2;
        startPoints;
        endPoints;

        START_END_POINT_DISPLACEMENT=5;
    end

    methods(TestClassSetup)
        function setup(obj)
            obj.csc=CoordinateSystemCluster();
            obj.csc.clear();
            obj.t2=Translation("System2","System3",[10;-10]);
            obj.t1=Rotation("System1","System2",20);
            obj.csc.addTransform(obj.t1);
            obj.csc.addTransform(obj.t2);
            [X,Y]=meshgrid(-3:3,-3:3);
            obj.startPoints=[X(:)';Y(:)'];
            obj.endPoints=obj.startPoints+obj.START_END_POINT_DISPLACEMENT;
        end
    end
    
    methods(TestMethodSetup)
    end
    
    methods(Test)
        function shouldGetCorrectUnitCellSize(obj)
            unitCellSize=obj.csc.getUnitCellSizeAt(obj.startPoints,of="System2",in="System3");
            obj.verifyEqual(unitCellSize,ones(size(unitCellSize)),'RelTol',1E-12);
        end

        function shouldMeasureDisplacement(obj)
            displacement=obj.csc.getDisplacementBetween(obj.startPoints,obj.endPoints,of="System2",in="System3");
            obj.verifyTrue(all(displacement(:)==obj.START_END_POINT_DISPLACEMENT));
        end

        function shouldMeasureDistance(obj)
            distance=obj.csc.getDistanceBetween(obj.startPoints,obj.endPoints,of="System1",in="System2");
            obj.verifyEqual(distance,vecnorm(obj.endPoints-obj.startPoints),'RelTol',1E-12);
        end

        function shouldIdentifyTransformPathBackward(obj)
            transformedFull=obj.csc.transform(obj.startPoints,from="System3",to="System1");
            transformed=obj.csc.transform(obj.startPoints,from="System3",to="System2");
            transformed2=obj.csc.transform(transformed,from="System2",to="System1");
            obj.verifyEqual(transformedFull,transformed2);
        end

        function shouldIdentifyTransformPathForward(obj)
            transformed=obj.csc.transform(obj.startPoints,from="System1",to="System2");
            transformed2=obj.csc.transform(transformed,from="System2",to="System3");
            transformedFull=obj.csc.transform(obj.startPoints,from="System1",to="System3");
            obj.verifyEqual(transformedFull,transformed2);
        end

        function shouldTransformBackward(obj)
            transformedForward=obj.csc.transform(obj.startPoints,from="System1",to="System3");
            regainedStartPoints=obj.csc.transform(transformedForward,from="System3",to="System1");
            obj.verifyEqual(obj.startPoints,regainedStartPoints,AbsTol=1E-10);
        end
    end
end