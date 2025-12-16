% Riccardo Consolo - Generate 5 Channel Images - Air Force

imgDataFolder = "..\..\Data\Polaris\Images";
img5ChDataFolder = "..\..\Data\Polaris\Images5Ch";

foldersDir = dir(imgDataFolder);
%%
for ii = 8:length(foldersDir)
    ii
    currImgFolder = fullfile(imgDataFolder, foldersDir(ii).name);
    currImg5ChFolder =  fullfile(img5ChDataFolder, foldersDir(ii).name);
    generateFiveChanImages(currImgFolder,currImg5ChFolder);
end
