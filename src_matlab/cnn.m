%% Load Data
image_folder = 'FLIR Pilot Data/Categorized';

imds = imageDatastore(image_folder,'IncludeSubfolders',true,'LabelSource','foldernames');


%% Visualize data

% figure;
num_images = 20;
perm = randperm(100,num_images);
% for i = 1:num_images
%     subplot(4,5,i);
%     imshow(imds.Files{perm(i)});
% end

labelCount = countEachLabel(imds)
img = readimage(imds,1);


%% Specifying training and validation sets
% numTrainFiles = 73; % too few data
% [imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.1,'randomized');
trainLabelCount = countEachLabel(imdsTrain)
validLabelCount = countEachLabel(imdsValidation)
layers = [
    imageInputLayer(size(img))
    
    convolution2dLayer(3,8,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(128)
    reluLayer
    
    fullyConnectedLayer(6)
    softmaxLayer
    classificationLayer];

%% Hyperparams and Training
options = trainingOptions('sgdm', ...
    'MaxEpochs',20, ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);


%% Predictiion
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)
