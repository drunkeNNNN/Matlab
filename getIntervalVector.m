function intervalVector = getIntervalVector(totalVectorSize,intervalStartIndices,intervalEndIndices)
    intervalVector=false(1,totalVectorSize);
    if length(intervalStartIndices)~=length(intervalEndIndices)
        error('Start and end index count have to be identical.');
    end
    for i=1:length(intervalStartIndices)
        intervalVector(intervalStartIndices(i):intervalEndIndices(i))=true;
    end
end