function nextStateChangeIds=getNextStateChangeIndices(searchStartIndexVector,statusVector)
    nextStateChangeIds=nan(size(searchStartIndexVector));
    for i=1:length(searchStartIndexVector)
        k=0;
        while searchStartIndexVector(i)+k<length(statusVector) && statusVector(searchStartIndexVector(i))==statusVector(searchStartIndexVector(i)+k)
            k=k+1;
        end
        if searchStartIndexVector(i)+k<length(statusVector)
            nextStateChangeIds(i)=searchStartIndexVector(i)+k;
        else
            nextStateChangeIds(i)=NaN;
        end
    end
end