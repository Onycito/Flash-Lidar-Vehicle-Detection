function CM = ObjectDetectorConfusionChart(detectionResults,testData, includeFN, includeFP, overlapThresold)
    % Inputs:
    % detectionResults: table (nFrames x 3), output of the 'detect' function
    % testData: combined datastore, used in the 'detect' function
    % includeFN: boolean, whether to include False Positives in the chart
    % includeFP: boolean, whether to include False Negatives in the chart
    % overlapThreshold: float, minimum percentage of overlap to classify prediction as TRUE


    % Outputs:
    % h: handle to ConfusionMatrixChart object

    % Set overlapping threshold
    threshold = overlapThresold;

    % Extract the Boxes, Scores and Labels from the detection results table
    bboxArray = detectionResults.Boxes;
    scoresArray = detectionResults.Scores;
    labelArray = detectionResults.Labels;

    % Extract the ground truth boxes and labels from the combined datastore
    groundTruthCell = readall(testData);
    groundTruthBoxesArray = groundTruthCell(:,2);
    groundTruthLabelArray = groundTruthCell(:,3);
    
    % Initialize true and predicted labels categorical arrays
    trueLabels = categorical([]);
    predictedLabels = categorical([]);
    
    
    for ii = 1: height(bboxArray)
        % For each frame in the test datastore assign gtruth bboxes to
        % predicted bboxes based on score and overlapping area
        bbox = bboxArray{ii};
        scores = scoresArray{ii};
        groundTruthBoxes = groundTruthBoxesArray{ii};

        [labels, falseNegative, assignment] = vision.internal.detector.assignDetectionsToGroundTruth(bbox, groundTruthBoxes, threshold, scores);
        
        % Output 'labels' is true for each matched predicted bbox
        predLog = labels == 1; % transform to logical array
        
        % Output 'assignment' contains indices of matched gtrouth bboxes
        trueInd = assignment(assignment~=0); % remove unmatched
        
        % Append matched predicted bboxes
        predictedLabels = [predictedLabels; labelArray{ii}(predLog)]; %#ok<AGROW>
        % Append matched gtruth bboxes sorted by matching order
        trueLabels = [trueLabels; groundTruthLabelArray{ii}(trueInd)]; %#ok<AGROW>
        
        % If you want to include the False Negative instances
        if includeFN
            % Append a 'NA' instance to predicted labels for each false negative 
            predLab = repmat(categorical({'NA'}), falseNegative, 1);
            predictedLabels = [predictedLabels; predLab]; %#ok<AGROW>
            % Append unmatched gtruth bboxes (Order does not matter here)
            trueInd = setdiff(1:length(groundTruthLabelArray{ii}), trueInd);
            trueLabels = [trueLabels; groundTruthLabelArray{ii}(trueInd)]; %#ok<AGROW>
        end
        
        % If you want to include the False Positives instances
        if includeFP
            % Append unmatched predicted bboxes
            predLog = labels ~= 1;
            predictedLabels = [predictedLabels; labelArray{ii}(predLog)]; %#ok<AGROW>
            % Append a 'NA' instance to true labels for each false positive
            trueLab = repmat(categorical({'NA'}), nnz(predLog), 1);
            trueLabels = [trueLabels; trueLab]; %#ok<AGROW>
        end

    end
    
    % Generate confusion matrix with arrays
    CM = confusionmat(trueLabels, predictedLabels);
end