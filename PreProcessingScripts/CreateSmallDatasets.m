% Go to the data folder and addpath the correct folders
for ii = 1:height(ImgNameList)
    ii
    fileName = char(ImgNameList{ii, 1});
    % fileName = string([fileName(1:end-3), 'pcd']);
    copyfile(which(fileName), "Masks_Small\" + fileName)
end