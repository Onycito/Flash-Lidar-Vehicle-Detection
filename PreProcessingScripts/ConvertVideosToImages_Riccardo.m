% Riccardo Consolo - Generate Dataset - Air Force
%% Archival Videos
dataFolder = "..\..\Data\Polaris\";
Dir = dir(dataFolder + "Videos\*.mj2");
ImFolders = ["ATV", "JeepGreen", "MultiVehicle", "PickupWhite", "Plane", "SUVBlack", "SedanBlack", "SportsCarYellow", "VanWhite"];
VidIdx = [repmat(1,5,1)
    repmat(2,5,1)
    repmat(3,2,1)
    repmat(4,6,1)
    repmat(5,1,1)
    repmat(6,5,1)
    repmat(7,5,1)
    repmat(8,5,1)
    repmat(9,5,1)];


vidCount = 0;
for ii = 1:length(Dir)
    vidCount = vidCount+1
    vRead = VideoReader(fullfile(Dir(ii).folder,Dir(ii).name));
    imgCount = 0;
    while hasFrame(vRead)
        imgCount = imgCount + 1;
        frame = readFrame(vRead);
        frameName = string(Dir(ii).name(1:end-4)) + "_" + num2str(imgCount, '%04d') + ".png";
        imwrite(frame, fullfile(dataFolder, "Images", ImFolders(VidIdx(vidCount)), frameName));
    end
end


%% MAT files
dataFolder = "..\..\Data\Polaris\";
Dir = dir(dataFolder + "Videos\*.mat");
ImFolders = ["ATV", "JeepGreen", "MultiVehicle", "PickupWhite", "Plane", "SUVBlack", "SedanBlack", "SportsCarYellow", "VanWhite"];
VidIdx = [repmat(1,5,1)
    repmat(2,5,1)
    repmat(3,2,1)
    repmat(4,6,1)
    repmat(5,1,1)
    repmat(6,5,1)
    repmat(7,5,1)
    repmat(8,5,1)
    repmat(9,5,1)];


vidCount = 0;
for ii = 1:length(Dir)
    vidCount = vidCount+1
    load(fullfile(Dir(ii).folder,Dir(ii).name));
    nFrames = size(rgb, 4);
    for imgCount = 1:nFrames
        frame = rgb(:,:,:,imgCount);
        frameName = string(Dir(ii).name(1:end-4)) + "_" + num2str(imgCount, '%04d') + ".png";
        imwrite(frame, fullfile(dataFolder, "Images", ImFolders(VidIdx(vidCount)), frameName));
    end
end
