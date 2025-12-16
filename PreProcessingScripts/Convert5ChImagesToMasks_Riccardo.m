% Riccardo Consolo - Generate Masks - Air Force
data = load("..\YOLOX\TrainingTable_NoStill.mat");
TrainingTable = data.TrainingTable;
load("ImgNameList_NoStill.mat")
imgDataFolder = "..\..\Data\Polaris\Images5Ch";

addpath(genpath(imgDataFolder))
maskDataFolder = "..\..\Data\Polaris\Masks";

% For Visualization
doVisualize = false;
if doVisualize
    vp = vision.VideoPlayer;
end

% For Saving Files
doSave = true;

%% Run through all images in training table
PointPillarTable = cell2table({"", {double.empty()}, {double.empty()}, {double.empty()}, {double.empty()}, {double.empty()}, {double.empty()}, {double.empty()}, {double.empty()}});
PointPillarTable.Properties.VariableNames = TrainingTable.Properties.VariableNames;
nFiles = length(ImgNameList);
PointPillarTable = repmat(PointPillarTable, nFiles, 1);
for imageIdx = 1:1:2212 %1:100:nFiles 
    imageIdx

    if imageIdx < 2212
        bgRange = 650;
    else
        bgRange = 1.11e3;
    end

    fileName = char(ImgNameList(imageIdx));
    filePath = which(fileName);
    splitPath = split(filePath, "\"); 
    parentName = splitPath{end-1};

    file = load(fileName);
    Img5ch = file.Img5ch;

    imgSize = size(Img5ch, [1,2]);
    mask = uint8(ones(imgSize));
    
    PointPillarTable(imageIdx, 1) = {string([fileName(1:end-3), 'pcd'])};
    for classIdx = 2:9 % starting classIdx = 2;

    classROI = cell2mat(TrainingTable{imageIdx,classIdx});
        if ~isempty(classROI)
            classROI = classROI(1,:);
            RangeBuffer = 30;
            [classMask, cuboid] = convertROItoMask5Ch(Img5ch,imgSize, classROI, RangeBuffer, bgRange);
            mask(classMask) = classIdx;
            PointPillarTable(imageIdx, classIdx) = {{cuboid.Parameters}};
        end
    end
    
    intImg = Img5ch(:,:,4);
    mask(isnan(intImg)) = NaN; 

    if doVisualize
        imOverlay = labeloverlay(rescale(intImg), mask, "Transparency",0.6);
        step(vp, imOverlay)
    end

    if doSave
        imwrite(mask, fullfile(maskDataFolder,parentName,[fileName(1:end-3), 'png']))
    end
end

