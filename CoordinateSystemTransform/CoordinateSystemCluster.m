classdef CoordinateSystemCluster<handle
    properties(Access=private)
        transformGraph;
        registeredPoints;

        lastTransformSystems;
        lastTransformedPoints;
        lastTransformEdgePath;
    end

    methods(Access=public)
        function obj=clear(obj)
            obj.transformGraph=digraph();
            obj.registeredPoints=containers.Map();
        end

        function registerPoints(obj,points,pointTag,systemTag)
            arguments
                obj
                points
                pointTag (1,1) string
                systemTag.in (1,1) string
            end
            pointStruct.points=points;
            pointStruct.systemTag=systemTag.in;
            if obj.coSystemIsDefined(systemTag.in)
                obj.registeredPoints(pointTag)=pointStruct;
            else
                error(strcat("Coordinate system ",systemTag.in," is not defined."));
            end
        end

        function pointTable=getRegisteredPoints(obj)
            pointTag=convertCharsToStrings(obj.registeredPoints.keys');
            systemTag=cellfun(@(x)(x.systemTag),obj.registeredPoints.values)';

            points=cellfun(@(x)(x.points),obj.registeredPoints.values,'UniformOutput',false)';
            pointTable=table(pointTag,systemTag,points);
        end

        function obj=addTransform(obj,transform)
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

        function transformedPoints=get(obj,pointTag,systemTag)
            arguments
                obj
                pointTag
                systemTag.in (1,1) string
            end
            transformedPoints=obj.transform(obj.registeredPoints(pointTag).points,...
                                            from=obj.registeredPoints(pointTag).systemTag,...
                                            to=systemTag.in);
        end

        function transformedPoints=transform(obj,points,systemTags)
            arguments
                obj 
                points
                systemTags.from (1,1) string
                systemTags.to (1,1) string
                systemTags.via (1,1) string=""
            end
            if strlength(systemTags.via)>0
                transformedPointsVia=obj.transform(points,...
                                                   from=systemTags.from,...
                                                   to=systemTags.via);
                transformedPoints=obj.transform(transformedPointsVia,...
                                                from=systemTags.via,...
                                                to=systemTags.to);
            elseif systemTags.from==systemTags.to
                transformedPoints=points;
            else
                if iscell(points)
                    transformedPoints=cellfun(@(x)obj.transformVector(x,'from',systemTags.from,'to',systemTags.to),points,'UniformOutput',false);
                elseif isnumeric(points)
                    transformedPoints=obj.transformVector(points,'from',systemTags.from,'to',systemTags.to);
                else
                    error('Invalid input. Input must be a (2,:) numeric vector or a cell array of such vectors.');
                end
            end
        end

        function defined=coSystemIsDefined(obj,systemTag)
            defined=any(contains(obj.transformGraph.Nodes.Name,systemTag));
        end

        function h=plotCoordinateSystems(obj,figureHandle)
            clf(figureHandle);
            tg=uitabgroup(figureHandle);
            ax1=axes(uitab(tg,"Title","Transformations"));
            h=plot(obj.transformGraph,'EdgeLabel',obj.transformGraph.Edges.DisplayString,'NodeColor','r','Parent',ax1);
            
            edgeTable=conncomp(obj.transformGraph);
            independentGraphStartPoints=unique(edgeTable);
            t=uitab(tg,"Title","Unit vectors");
            tl=tiledlayout(t,"flow");
            for startCoSystemId=independentGraphStartPoints
                targetCoSystems=obj.transformGraph.Nodes.Name(edgeTable==startCoSystemId,1);
                lineWidth=size(targetCoSystems,1):-1:1;
                ax=nexttile(tl);
                hold(ax,"on");
                q(1)=quiver(0,0,1,0,'DisplayName',targetCoSystems{1,1},'Parent',ax,'AutoScale','off');
                text(1+0.05*randn(1),+0.05*randn(1),'x','Color',get(q(1),'Color'));
                q2=quiver(0,0,0,1,'DisplayName','','Parent',ax,'Color',get(q(1),'Color'),'AutoScale','off');
                text(0.05*randn(1),1-+0.05*randn(1),'y','Color',get(q(1),'Color'));
                for i=2:size(targetCoSystems,1)
                    targetCoSystem=targetCoSystems{i,1};
                    currentVectX=diff(obj.transform([0,1;0,0],...
                                              from=targetCoSystems{1,1},...
                                              to=targetCoSystem),1,2);
                    currentVectY=diff(obj.transform([0,0;0,1],...
                                              from=targetCoSystems{1,1},...
                                              to=targetCoSystem),1,2);
                    currentUnitVectX=currentVectX./norm(currentVectX,1);
                    currentUnitVectY=currentVectY./norm(currentVectY,1);
                    offset=lineWidth(i)*0.0;
                    q(i)=quiver(offset,offset,currentUnitVectX(1,1),currentUnitVectX(2,1),'DisplayName',targetCoSystem,'Parent',ax,'AutoScale','off');
                    text(currentUnitVectX(1,1)+0.05*randn(1),currentUnitVectX(2,1)+0.05*randn(1),'x','Color',get(q(i),'Color'));
                    quiver(offset,offset,currentUnitVectY(1,1),currentUnitVectY(2,1),'DisplayName','','Parent',ax,'Color',get(q(i),'Color'),'AutoScale','off');
                    text(currentUnitVectY(1,1)+0.05*randn(1),currentUnitVectY(2,1)+0.05*randn(1),'y','Color',get(q(i),'Color'));
                end
                legend(ax,q);
                axis(ax,'equal','image');
                xlim(ax,[-1.2,1.2]);
                ylim(ax,[-1.2,1.2]);
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

        function unitCellSize=getScaleAt(obj,coordinates,systemTags)
            arguments
                obj
                coordinates
                systemTags.of 
                systemTags.in
            end
            warning('Output is different than what is expected for rotated co-systems');
            STEP=1E-9;
            unitCellSize=1./STEP*obj.getDisplacementBetween(coordinates-STEP/2,coordinates+STEP/2,of=systemTags.of,in=systemTags.in);
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