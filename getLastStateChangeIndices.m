function lastStatusChangeIds=getLastStateChangeIndices(searchStartIndexVector,statusVector)
    lastStatusChangeIds=nan(size(searchStartIndexVector));
    for i=1:length(searchStartIndexVector)
        k=0;
        while searchStartIndexVector(i)+k>0 && statusVector(searchStartIndexVector(i))==statusVector(searchStartIndexVector(i)+k)
            k=k-1;
        end
        if searchStartIndexVector(i)+k==1 && statusVector(searchStartIndexVector(i))==statusVector(searchStartIndexVector(i)+k)
            lastStatusChangeIds(i)=searchStartIndexVector(i)+k;
        else
            lastStatusChangeIds(i)=NaN;
        end
    end
end