%% Configure Pretrained SalsaNext Network for Transfer Learning

%% Load Pretrained Model
model = load('model\trainedSalsaNext.mat'); 
net = model.net;

%% Load Datastores
% labelsFolder = "labels";
% imagesFolder = "images";
labelsFolder = "..\..\Data\Polaris\Masks_Small";
imagesFolder = "..\..\Data\Polaris\Images5Ch_Small";
% addpath(genpath(imagesFolder))
% load("ImgNameList.mat")

imds = imageDatastore(imagesFolder, ...
    'FileExtensions', '.mat', ...
    'ReadFcn', @helper.imageMatReader);
 

classNames = ["unlabelled"
              "ATV"
              "JeepGreen"
              "PickupWhite"
              "SUVBlack"
              "VanWhite"
              "Plane"
              "SedanBlack"
              "SportsCarYellow"];

numClasses = numel(classNames);

% Specify label IDs from 1 to the number of classes.
labelIDs = 1 : numClasses;

pxds = pixelLabelDatastore(labelsFolder, classNames, labelIDs);

%% Prepare Training, Validation, and Test Sets
% Use the partitionLidarData helper function to split the data into
% training, images, respectively.

[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = helper.partitionLidarData(imds, pxds);

dsTrain = combine(imdsTrain,pxdsTrain);
dsVal = combine(imdsVal,pxdsVal);

%% Data Augmentation
% Data augmentation is used to improve network accuracy by randomly
% transforming the original data during training. By using data
% augmentation, you can add more variety to the training data without
% actually having to increase the number of labeled training samples.
% 
% Augment the training data by using the transform function with custom
% preprocessing operations specified by the augmentData helper function.
% This function randomly flips the multichannel 2-D image and associated
% labels in the horizontal direction. Apply data augmentation to only the
% training data set.

augmentedTrainingData = transform(dsTrain, @(x) helper.augmentData(x));
% augmentedTrainingData = dsTrain;

%% Configure Pretrained Network

% Changing output size to required number of classes.
inputSize = [128, 128, 5];
net = replaceLayer(net, 'Input_input.1', imageInputLayer(inputSize, 'Name', 'Input_input.1', 'Normalization', 'none'));
net = replaceLayer(net, 'Conv_191', convolution2dLayer([1,1], numClasses, 'Name', 'Conv_191'));

%% % Define training options. 
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',dsVal,...
    'MaxEpochs',30, ...  
    'MiniBatchSize',40, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',2,...
    'Plots','training-progress',...
    'ValidationPatience', 4, ...
    'ValidationFrequency', 30);

% The learning rate uses a piecewise schedule. The learning rate is reduced 
% by a factor of 0.3 every 10 epochs. This allows the network to learn quickly 
% with a higher initial learning rate, while being able to find a solution 
% close to the local optimum once the learning rate drops.
%
% The network is tested against the validation data every epoch by setting 
% the 'ValidationData' parameter. The 'ValidationPatience' is set to 4 to 
% stop training early when the validation accuracy converges. This prevents 
% the network from overfitting on the training dataset.
%
% A mini-batch size of 16 is used for training. You can increase or decrease 
% this value based on the amount of GPU memory you have on your system.
%
% In addition, 'CheckpointPath' is set to a temporary location. This name-value 
% pair enables the saving of network checkpoints at the end of every training 
% epoch. If training is interrupted due to a system failure or power outage, 
% you can resume training from the saved checkpoint. Make sure that the location 
% specified by 'CheckpointPath' has enough space to store the network checkpoints.

% Now, you can pass the 'dsTrain', 'lgraph' and 'options' to trainNetwork
% as shown in 'Train Network' section of the example 'Lidar Point Cloud
% Semantic Segmentation Using SqueezeSegV2 Deep Learning Network Example'
% (https://www.mathworks.com/help/lidar/ug/semantic-segmentation-using-squeezesegv2-network.html)to
% obtain salsaNext model trained on the custom dataset.
%
% You can follow the sections 'Test Network on One Image' for inference using 
% the trained model and 'Evaluate Trained Network' for evaluating metrics.

%% Train the network

doTraining = false;
if doTraining
    [trainedNet,info] = trainnet(augmentedTrainingData,net,"crossentropy",options);
    save('SalsaNext_v2.mat', 'trainedNet');
else
    load("SalsaNext_v2.mat","trainedNet");
end

%% Test on new data
figure('Position', [50 50 1800 900])

while hasdata(imdsTest)
    testImg = read(imdsTest);
    testLabels = read(pxdsTest);
    predictedResult = semanticseg(testImg,trainedNet); %,"Classes",classNames
    
    
    tiledlayout(1, 2);
    % Display Ground Truth 
    nexttile
    helper.displayLidarOverlayImage(testImg, testLabels{1}, classNames);
    title('Semantic Segmentation Ground Truth');
    % Display Predicted Output 
    nexttile
    helper.displayLidarOverlayImage(testImg, predictedResult, classNames);
    title('Semantic Segmentation Result');

    drawnow
end


% % Display in point cloud format.
% cmap = helper.lidarColorMap();
% colormap = cmap(single(predictedResult),:);
% ptCloudMod = pointCloud(reshape(I(:,:,1:3),[],3),"Color",colormap);
% figure
% ax = pcshow(ptCloudMod);
% zoom(ax,3);

%% References

% [1] Cortinhal, Tiago, George Tzelepis, and Eren Erdal Aksoy. "SalsaNext: Fast, 
% Uncertainty-Aware Semantic Segmentation of LiDAR Point Clouds for Autonomous 
% Driving." ArXiv:2003.03653 [Cs], July 9, 2020. http://arxiv.org/abs/2003.03653 
% http://arxiv.org/abs/2003.03653.
% 
% [2] https://scale.com/open-datasets/pandaset https://scale.com/open-datasets/pandaset
% 
% Copyright 2020 The MathWorks, Inc.