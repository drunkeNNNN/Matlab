classdef CoordinateSystemCluster<handle
    properties(Access=private)
        transformGraph;

        lastTransformSystems;
        lastTransformedPoints;
        lastTransformEdgePath;
    end

    methods(Access=public)
        function clear(obj)
            obj.transformGraph=digraph();
        end

        function addTransform(obj,transform)
            arguments
                obj
                transform CoordinateSystemTransform
            end
            obj.transformGraph=obj.transformGraph.addedge(table(...
                [...
                    transform.getSystem1Tag(),transform.getSystem2Tag();...
                    transform.getSystem2Tag(),transform.getSystem1Tag()...
                ],...
                {...
                    @transform.transform1To2;...
                    @transform.transform2To1...
                },...
                {...
                    transform.getDisplayString1To2();...
                    transform.getDisplayString2To1()...
                },'VariableNames',...
                {...
                    'EndNodes',...
                    'TransformFunction',...
                    'DisplayString'...
                }));
        end

        function transformedPoints=transform(obj,points,systemTags)
            arguments
                obj 
                points
                systemTags.from (1,1) string
                systemTags.to (1,1) string
            end
            if iscell(points)
                transformedPoints=cellfun(@(x)obj.transformVector(x,'from',systemTags.from,'to',systemTags.to),points,'UniformOutput',false);
            elseif isnumeric(points)
                transformedPoints=obj.transformVector(points,'from',systemTags.from,'to',systemTags.to);
            else
                error('Invalid input. Input must be a (2,:) numeric vector or a cell array of such vectors.');
            end
        end

        function h=plotCoordinateSystems(obj,figureHandle)
            clf(figureHandle);
            tg=uitabgroup(figureHandle);
            ax1=axes(uitab(tg,"Title","Transformations"));
            h=plot(obj.transformGraph,'EdgeLabel',obj.transformGraph.Edges.DisplayString,'NodeColor','r','Parent',ax1);
            
            edgeTable=dfsearch(obj.transformGraph,1,'edgetonew',Restart=true);
            independentGraphStartPoints=unique(edgeTable(:,1));
            independentGraphCount=size(independentGraphStartPoints,1);
            t=uitab(tg,"Title","Unit vectors");
            tl=tiledlayout(t,"flow");
            for startCoSystem=independentGraphStartPoints'
                targetCoSystems=edgeTable(edgeTable(:,1)==startCoSystem,2);
                ax=nexttile(tl);
                hold(ax,"on");
                q1=quiver(0,0,1,0,'DisplayName',strcat(obj.transformGraph.Nodes{startCoSystem,1}{1,1}," x"),'Parent',ax);
                q2=quiver(0,0,0,1,'DisplayName',strcat(obj.transformGraph.Nodes{startCoSystem,1}{1,1}," y"),'Parent',ax,'Color',get(q1,'Color'));
                for targetCoSystem=targetCoSystems
                    currentVectX=diff(obj.transform([0,1;0,0],...
                                              from=obj.transformGraph.Nodes{startCoSystem,1}{1,1},...
                                              to=obj.transformGraph.Nodes{targetCoSystem,1}{1,1}),1,2);
                    currentVectY=diff(obj.transform([0,0;0,1],...
                                              from=obj.transformGraph.Nodes{startCoSystem,1}{1,1},...
                                              to=obj.transformGraph.Nodes{targetCoSystem,1}{1,1}),1,2);
                    currentUnitVectX=currentVectX./norm(currentVectX,1);
                    currentUnitVectY=currentVectY./norm(currentVectY,1);
                    q1=quiver(0,0,currentUnitVectX(1,1),currentUnitVectX(2,1),'DisplayName',strcat(obj.transformGraph.Nodes{targetCoSystem,1}{1,1}," x"),'Parent',ax);
                    q2=quiver(0,0,currentUnitVectY(1,1),currentUnitVectY(2,1),'DisplayName',strcat(obj.transformGraph.Nodes{targetCoSystem,1}{1,1}," y"),'Parent',ax,'Color',get(q1,'Color'));
                end
                legend(ax);
                axis(ax,'equal','image');
                xlim(ax,[-1,1]);
                ylim(ax,[-1,1]);
            end
        end

        function plotLastTransformation(obj,figureHandle)
            clf(figureHandle);
            tg=uitabgroup(figureHandle);
            ax1=axes(uitab(tg,'Title','Transformations'));
            h=obj.plotCoordinateSystems(ax1);
            h.highlight(obj.lastTransformSystems,'EdgeColor','green','NodeColor','green');
            ax2=axes(uitab(tg,'Title','Transformed Positions'));
            hold on;
            for i=1:size(obj.lastTransformedPoints,1)
                plot(ax2,obj.lastTransformedPoints{i,1}(1,:),obj.lastTransformedPoints{i,1}(2,:),'+',DisplayName=obj.lastTransformSystems(i));
            end
            legend;
        end

        function transformedDisplacement=getDisplacementBetween(obj,startCoordinates,endCorrdinates,systemTags)
            arguments
                obj
                startCoordinates
                endCorrdinates
                systemTags.of (1,1) string
                systemTags.in (1,1) string
            end
            transformedStartCoordinates=obj.transform(startCoordinates,from=systemTags.of,to=systemTags.in);
            transformedEndCoordinates=obj.transform(endCorrdinates, from=systemTags.of,to=systemTags.in);
            if iscell(transformedStartCoordinates)
                transformedDisplacement=cellfun(@(x,y)(x-y),transformedEndCoordinates,transformedStartCoordinates,'UniformOutput',false);
            elseif isnumeric(transformedEndCoordinates)
                transformedDisplacement=transformedEndCoordinates-transformedStartCoordinates;
            end
        end
        
        function system1Distance=getDistanceBetween(obj,startCoordinates,endCoordinates,systemTags)
            arguments
                obj
                startCoordinates
                endCoordinates
                systemTags.of
                systemTags.in
            end
            transformedDisplacement=obj.getDisplacementBetween(startCoordinates,endCoordinates,of=systemTags.of,in=systemTags.in);
            if iscell(transformedDisplacement)
                system1Distance=cellfun(@vecnorm,transformedDisplacement);
            elseif isnumeric(transformedDisplacement)
                system1Distance=vecnorm(transformedDisplacement);
            end
        end

        function unitCellSize=getUnitCellSizeAt(obj,coordinates,systemTags)
            arguments
                obj
                coordinates
                systemTags.of 
                systemTags.in
            end
            warning('Output is different than what is expected for rotated co-systems')
            unitCellSize=obj.getDisplacementBetween(coordinates-0.5,coordinates+0.5,of=systemTags.of,in=systemTags.in);
        end
    end

    methods(Access=private)
        function transformedPoints=transformVector(obj,points,systemTags)
            arguments
                obj
                points (2,:) {mustBeNumeric}
                systemTags.from (1,1) string
                systemTags.to (1,1) string
            end
            [obj.lastTransformSystems,~,obj.lastTransformEdgePath]=obj.transformGraph.shortestpath(systemTags.from,systemTags.to);
            obj.lastTransformedPoints=cell(size(obj.lastTransformSystems,2),1);
            obj.lastTransformedPoints{1,1}=points;
            for i=1:size(obj.lastTransformEdgePath,2)
                currentTransform=obj.transformGraph.Edges.TransformFunction{obj.lastTransformEdgePath(i)};
                obj.lastTransformedPoints{i+1,1}=currentTransform(obj.lastTransformedPoints{i,1});
            end
            transformedPoints=obj.lastTransformedPoints{end,1};
        end
    end
end