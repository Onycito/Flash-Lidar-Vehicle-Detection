folderDir = "D:\OneDrive - MathWorks\Documents\MATLAB\AE_CustomerProjects\AirForce\MathWorks_AirForce_SharedFolder_New\Data\Polaris";
vehicles = ["ATV", "JeepGreen", "MultiVehicle", "PickupWhite", "Plane", "SedanBlack", "SportsCarYellow", "SUVBlack", "VanWhite"];

%%
vehicleNum = 2;
pcD = dir(fullfile(folderDir, "PointClouds", vehicles(vehicleNum),"*.pcd"));
pcplay = pcplayer([400 1000], [-25 25], [-25 25]);
show(pcplay)

ii = 560;
while ii < length(pcD) && isOpen(pcplay)
    pc = pcread(fullfile(pcD(ii).folder, pcD(ii).name));
    ii = ii + 1;
    pcplay.view(pc.Location, repmat(rescale(pc.Intensity, "InputMax", 1000),1,1,3));
end

%%
vehicleNum = 2;
maskD = dir(fullfile(folderDir, "Masks", vehicles(vehicleNum),"*.png"));

for ii = 1:length(maskD)
    mask = imread(fullfile(maskD(ii).folder,maskD(ii).name));
    imshow(mask, [])
    pause(0.01)
end

%%
vehicleNum = 2;
pcD = dir(fullfile(folderDir, "PointClouds", vehicles(vehicleNum),"*.pcd"));
maskD = dir(fullfile(folderDir, "Masks", vehicles(vehicleNum),"*.png"));

pcplay = pcplayer([400 1000], [-25 25], [-25 25]);
show(pcplay)

ii = 560;
while ii < length(pcD) && isOpen(pcplay)
    pc = pcread(fullfile(pcD(ii).folder, pcD(ii).name));
    mask = imread(fullfile(maskD(ii-559).folder,maskD(ii-559).name));
    ii = ii + 1;

    ind = find(mask==3); %4 = Pickup
    pcCrop = select(pc,ind, outputSize="full");
    pcplay.view(pcCrop.Location, repmat(rescale(pcCrop.Intensity, "InputMax", 1000),1,1,3));
end



%% Main
cropD = dir("PointCloudCrops_Dense\*.pcd");
pcPrev = pcread(fullfile(cropD(1).folder, cropD(1).name));
pcPrev = pcdenoise(pcPrev, PreserveStructure=true);
pcCombo = pcPrev;
tformCombo = rigidtform3d;

% for ii = 2:1:30
for ii = 2:20:length(cropD)
    pcNext = pcread(fullfile(cropD(ii).folder, cropD(ii).name));
    pcNext = pcdenoise(pcNext, PreserveStructure=true);
    tformNext= pcregistercpd(pcNext,pcPrev,"Transform","Rigid", MaxIterations=50);
    % tformNext = pcregisterloam(pcNext,pcPrev,0.1, InitialTransform=tformNext);
    tformNext = pcregistericp(pcNext,pcPrev,Metric="pointToPoint",InlierDistance=0.2,MaxIterations=50, InitialTransform=tformNext);
    tformCombo = rigidtform3d(tformCombo.A * tformNext.A);
    pcCombo = pcmerge(pcCombo, pctransform(pcNext, tformCombo), 0.1);

    pcPrev = pcNext;
end

pcshow(pcCombo.Location)
c4 = pcCombo;
% LOOP CLOSURE?