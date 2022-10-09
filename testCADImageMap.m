clear;
clc;

sourceCadXMm=-10:5:10;
sourceCadYMm=-10:1:10;

[sourceCadXMm,sourceCadYMm]=meshgrid(sourceCadXMm,sourceCadYMm);
sourceCadMm=[sourceCadXMm(:),sourceCadYMm(:)]';

sourceImageXPx=(0:5:20)*50;
sourceImageYPx=(0:1:20)*50;

[sourceImageXPx,sourceImageYPx]=meshgrid(sourceImageXPx,sourceImageYPx);
sourceImagePx=[sourceImageXPx(:),sourceImageYPx(:)]';
sourceImagePx=sourceImagePx+3*randn(size(sourceImagePx));

vzc=CADImageMap();
vzc.setSourceCoordinates(sourceCadMm,sourceImagePx);
vzc.initTransforms();
vzc.showRelativeError();

imageCalcPx=vzc.getImagePx(sourceCadMm);
cadCalcMm=vzc.getCadMm(sourceImagePx);

