function anchors = helperEstimate3DAnchorBoxesForVoxelRCNN(trainDatastore,classNames)
% This function estimate anchor boxes for 3D bounding boxes.

% Initialize anchors.
anchors = cell(numel(classNames),1);
anchors = cellfun(@initAnchor,anchors,UniformOutput=false);

% Extract the label datastore.
trainbds = trainDatastore.UnderlyingDatastores{1,2};
reset(trainbds) % Ensure we start from the beginning.

% Initialize counts for each class.
classCounts = zeros(numel(classNames),1);

% Iterate over the datastore.
while hasdata(trainbds)
    out = read(trainbds);
    bbox = out{1};
    label = out{2};

    % Iterate over each class name.
    for ii = 1:numel(classNames) 
        clsIdx = classNames{ii}==label; % Find indices of the current class.
        if any(clsIdx)
            lwhSum = sum(bbox(clsIdx,4:6),1); % Sum LWH for the current class. (Used to be: lwhSum = sum(bbox(clsIdx,4:6));)
            anchors{ii}(:,1:3) = anchors{ii}(:,1:3) + lwhSum; % Accumulate sums.
            classCounts(ii) = classCounts(ii) + sum(clsIdx); % Count instances
        end
    end
end

% Average the LWH sums by the counts to get the mean dimensions.
for k = 1:numel(classNames)
    if classCounts(k) > 0
        anchors{k}(:,1:3) = anchors{k}(:,1:3) / classCounts(k);
    end
end
end

function x = initAnchor(x)
x = zeros(2,5);
x(:,4) = 3; % x(:,4) = -1.78;
x(2,5) = 90;
end