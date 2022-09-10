function mask=removeLargeObjects(mask, maxObjectAreaPx)
    if ~isinf(maxObjectAreaPx)
        mask=bwareaopen(mask, maxObjectAreaPx)-mask;
    end
end

