function [mask] = convertROItoMask(Image,ROI, RangeBuffer)
%CONVERTROITOCUBOID Summary of this function goes here
%   Detailed explanation goes here

mask = false(size(Image));   

if ~isempty(ROI)
    inROI = false(size(Image));
    ROI = round(ROI);
    inROI(ROI(2) :min(128,ROI(2)+ROI(4)), ROI(1):min(128,ROI(1)+ROI(3))) = true;
    
    rangeWindow = fix(Image(inROI & Image~=0)/1000)*1000;
    midRange = mode(rangeWindow, "all"); 
    inRange = (Image > midRange-RangeBuffer) & (Image < midRange+RangeBuffer);

    mask = (inRange & inROI);

    % Fill holes
    mask = imfill(mask, 'holes');

    % Close mask
    radius = 9;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    mask = imclose(mask, se);
end

end

