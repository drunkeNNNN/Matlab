function res = rescaleMatrix(matrix,newFloorValue,ceilingValue)
    matFloorValue=min(matrix(:),'omitnan');
    matCeilingValue=max(matrix(:),'omitnan');
    inputRange=matCeilingValue-matFloorValue;
    if inputRange>0
        matrix=(matrix-matFloorValue)./inputRange;
        newRange=ceilingValue-newFloorValue;
        res=(matrix*newRange)+newFloorValue;
    else
        res=ones(size(matrix)).*newFloorValue;
    end
end