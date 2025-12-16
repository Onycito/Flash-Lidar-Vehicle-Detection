% Riccardo Consolo - Generate Dataset - Air Force
%%
dataFolder = "..\..\Data\Polaris\";
Dir = dir(dataFolder + "SequencesRaw\*.mat");
lowNoise = 50;
highNoise = 1500;
highInt = 3200;
sensorLen = 128;

for i = 1:length(Dir)
    i
    load(fullfile(Dir(i).folder,Dir(i).name))
    
    rangeClean = range;
    intensityClean = intensity;
    OutLog = range < lowNoise | range > highNoise | intensity > highInt;
    rangeClean(OutLog) = NaN;
    intensityClean(OutLog) = NaN;

    rangeScaled= im2uint16(rangeClean ./ highNoise);
    intensityScaled = im2uint16(intensityClean ./ highInt);

    rgb = uint16(zeros(sensorLen,sensorLen,3,size(range,3)));
    rgb(:,:,1,:) = rangeScaled;
    rgb(:,:,3,:) = intensityScaled;
    
    videoName = fullfile(dataFolder, "Videos", Dir(i).name(1:end-4));
    % MAT files
    save(videoName + ".mat", 'rgb');
    
    % Archival Videos
    % v = VideoWriter(videoName, "Archival"); % Convert to uint16 and use 'Archival'
    % open(v)
    % writeVideo(v,rgb)
    % close(v)
end


%% Check if video frame converts back to point cloud correctly
% Setup Parameters
fov = 3*[1 1]; % [az el] adjust this to match sensor FOV
sensorLen = 128;
highNoise = 1500;
highInt = 3200;

% rangeFrame = rangeClean(:,:,1); %ORIGINAL Range
% rangeFrame = im2double(rangeScaled(:,:,1)) .* highNoise; % UINT16 Range
% vr = VideoReader(videoName + ".mj2"); frame = readFrame(vr); rangeFrame = im2double(frame(:,:,1)) .* highNoise; % Archival Videos
load(videoName + ".mat"); frame = rgb(:,:,:,1); rangeFrame = im2double(frame(:,:,1)) .* highNoise; % MAT files

% Initialize matrices
azVec = linspace(-fov(1)/2,fov(1)/2,sensorLen);
elVec = linspace(-fov(2)/2,fov(2)/2,sensorLen);
az = repmat(azVec,[numel(elVec) 1]); %flip az as well to get same orientation as raw images
el = repmat(flip(elVec)',[1 numel(azVec)]);

[x_matrix,y_matrix,z_matrix] = sph2cart(az*pi/180,el*pi/180,rangeFrame);


% build pointcloud
xyzPoints = cat(3,x_matrix,y_matrix,z_matrix);
ptCloud = pointCloud(xyzPoints, 'Intensity',  im2double(frame(:,:,3)) .* highInt);
figure; pcshow(ptCloud)


%% Test mpg2000
% 
% dataFolder = "..\..\Data\Polaris\";
% Dir = dir(dataFolder + "SequencesRaw\*.mat");
% 
% for i =1% 1:length(Dir)
%     i
%     load(fullfile(Dir(i).folder,Dir(i).name))
% 
%     rangeClean = range;
%     intensityClean = intensity;
%     lowNoise = 300; 
%     highNoise = 1500;
%     OutLog = range < lowNoise | range > highNoise | intensity > highNoise;
%     rangeClean(OutLog) = NaN;
%     intensityClean(OutLog) = NaN;
%     rangeScaled= im2uint16(rangeClean ./ highNoise);
%     intensityScaled = im2uint16(intensityClean ./ highNoise);
% 
%     rgb = uint16(zeros(128,128,3,size(range,3)));
%     rgb(:,:,1,:) = rangeScaled;
%     rgb(:,:,3,:) = intensityScaled;
% 
%     videoName = 'test';
%     v = VideoWriter(videoName, 'Archival'); % C onvert to uint16 and use 'Motion JPEG 2000'
%     % v.LosslessCompression = true;
% 
%     open(v)
%     writeVideo(v,rgb)
%     close(v)
% end