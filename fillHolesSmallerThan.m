function bwSmallHolesFilled= fillHolesSmallerThan(bwImage, minimumHoleSize)
    bwHoles=imfill(bwImage,'holes') & ~ bwImage;
    bwTooSmallHoles=bwHoles & ~bwareaopen(bwHoles,minimumHoleSize);
    bwSmallHolesFilled=bwImage|bwTooSmallHoles;
end