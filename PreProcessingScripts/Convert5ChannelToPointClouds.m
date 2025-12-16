% Riccardo

pcDataFolder = "..\..\Data\Polaris\PointClouds";
img5ChDataFolder = "..\..\Data\Polaris\Images5Ch";

foldersDir = dir(img5ChDataFolder);
%%
for ii = 6:length(foldersDir)
    classDir = dir(fullfile(foldersDir(ii).folder, foldersDir(ii).name, "*.mat"));
    ii
    for jj = 1:length(classDir)
        jj
        load(fullfile(classDir(jj).folder, classDir(jj).name))
        pCloud = pointCloud(Img5ch(:,:,1:3));
        pCloud.Intensity = Img5ch(:,:,4);
        pcName = fullfile(pcDataFolder, foldersDir(ii).name, [classDir(jj).name(1:end-3), 'pcd']);
        pcwrite(pCloud, pcName)
    end
end