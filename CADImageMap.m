classdef CADImageMap<handle
    properties(Access=private)
        sourceCadCoordinatesMm;
        sourceImageCoordinatesPx;

        transformCadImageX;
        transformCadImageY;

        transformImageCadX;
        transformImageCadY;
    end

    methods(Access=public)
        function setSourceCoordinates(obj,sourceCadCoordinates,sourceImageCoordinatesPx)
            obj.sourceCadCoordinatesMm=sourceCadCoordinates;
            obj.sourceImageCoordinatesPx=sourceImageCoordinatesPx;
        end

        function initTransforms(obj)
            obj.initTransformsCadImage();
            obj.initTransformsImageCad();
        end

        function initTransformsCadImage(obj)
            obj.transformCadImageX=fit([obj.sourceCadCoordinatesMm(1,:)',obj.sourceCadCoordinatesMm(2,:)'],obj.sourceImageCoordinatesPx(1,:)','poly33');
            obj.transformCadImageY=fit([obj.sourceCadCoordinatesMm(1,:)',obj.sourceCadCoordinatesMm(2,:)'],obj.sourceImageCoordinatesPx(2,:)','poly33');
        end
        
        function initTransformsImageCad(obj)
            obj.transformImageCadX=fit([obj.sourceImageCoordinatesPx(1,:)',obj.sourceImageCoordinatesPx(2,:)'],obj.sourceCadCoordinatesMm(1,:)','poly33');
            obj.transformImageCadY=fit([obj.sourceImageCoordinatesPx(1,:)',obj.sourceImageCoordinatesPx(2,:)'],obj.sourceCadCoordinatesMm(2,:)','poly33');
        end

        function distance=getDistanceCadMm(obj,imageStartPx,imageEndPx)
            if all(size(imageStartPx)==size(imageEndPx))
                error('Size of image start is not equal to image end');
            end
            cadStartMm=obj.getCadMm(imageStartPx);
            cadEndMm=obj.getCadMm(imageEndPx);
            difference=cadEndMm-cadStartMm;
            distance=sqrt(difference(1,:).^2+difference(2,:).^2);
        end

        function distancePx=getDistanceImagePx(obj,cadStartMm,cadEndMm)
            if all(size(cadStartMm)==size(cadEndMm))
                error('Size of image start is not equal to image end');
            end
            cadStartPx=obj.getImagePx(cadStartMm);
            cadEndPx=obj.getImagePx(cadEndMm);
            differencePx=cadEndPx-cadStartPx;
            distancePx=sqrt(differencePx(1,:).^2+differencePx(2,:).^2);
        end

        function imagePx=getImagePx(obj,cadMm)
            imagePx=[obj.transformCadImageX([cadMm(1,:)',cadMm(2,:)']),obj.transformCadImageY([cadMm(1,:)',cadMm(2,:)'])]';
        end

        function cadMm=getCadMm(obj,imagePx)
            cadMm=[obj.transformImageCadX([imagePx(1,:)',imagePx(2,:)']),obj.transformImageCadY([imagePx(1,:)',imagePx(2,:)'])]';
        end

        function showRelativeError(obj)
            imageCalcPx=obj.getImagePx(obj.sourceCadCoordinatesMm);
            cadCalcMm=obj.getCadMm(obj.sourceImageCoordinatesPx);

            disp(['Average Error Image2Cad x / mm: ',num2str(mean(abs(cadCalcMm(1,:)-obj.sourceCadCoordinatesMm(1,:))))]);
            disp(['Average Error Image2Cad y / mm: ',num2str(mean(abs(cadCalcMm(2,:)-obj.sourceCadCoordinatesMm(2,:))))]);
            disp(['Average Error Cad2Image x / px: ',num2str(mean(abs(imageCalcPx(1,:)-obj.sourceImageCoordinatesPx(1,:))))]);
            disp(['Average Error Cad2Image y / px: ',num2str(mean(abs(imageCalcPx(2,:)-obj.sourceImageCoordinatesPx(2,:))))]);
        end
    end
end

