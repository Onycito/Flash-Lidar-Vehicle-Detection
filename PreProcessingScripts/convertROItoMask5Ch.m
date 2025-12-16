function [mask, cuboid] = convertROItoMask5Ch(Img5ch,maskSize, ROI, RangeBuffer, bgRange)

RangeImg = Img5ch(:,:,5);   

inROI = false(maskSize);
ROI = round(ROI);
inROI(ROI(2) :min(128,ROI(2)+ROI(4)), ROI(1):min(128,ROI(1)+ROI(3))) = true;

% rangeWindow = fix(RangeImg(inROI & (RangeImg < 1.11e3))./10).*10;
rangeWindow = fix(RangeImg(inROI & (RangeImg < bgRange))./10).*10;

midRange = mode(rangeWindow, "all");
inRange = (RangeImg > midRange-RangeBuffer) & (RangeImg < midRange+RangeBuffer);

mask = (inRange & inROI);

% % Fill holes
% mask = imfill(mask, 'holes');
% 
% % Close mask
% radius = 3;
% decomposition = 0;
% se = strel('disk', radius, decomposition);
% mask = imclose(mask, se);

XYZ = Img5ch(:,:,1:3);

pCloud = pointCloud(XYZ);
groundPtsIdx = segmentGroundSMRF(pCloud, ElevationThreshold=0.001);
mask(groundPtsIdx) = false; 

if nnz(mask) ~= 0
    goodIdx = find(mask);
    pCloudCrop = select(pCloud,goodIdx);
    [~,~,outlierIndices] = pcdenoise(pCloudCrop, "NumNeighbors",10, "Threshold",2);
    mask(goodIdx(outlierIndices)) = false;
    
    goodIdx = find(mask);
    pCloudCrop = select(pCloud,goodIdx);
    labels = pcsegdist(pCloudCrop,5);
    outlierIndices = find(labels ~= mode(labels));
    mask(goodIdx(outlierIndices)) = false;
end

goodIdx = find(mask);
pCloudCrop = select(pCloud,goodIdx);
cuboid = pcfitcuboid(pCloudCrop);
end
