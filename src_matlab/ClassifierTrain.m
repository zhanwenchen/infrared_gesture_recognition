% ClassifierTrain.m
% QUESTION: 1. How are diff frames labeled? How can I extract the labels?
% QUESTION: 2.
%
% Matlab script to learn and test classification of the Fall Detection FLIR Pilot Data
%
% This function depends on a specific folder hierarchary:
%
%   'FallDetection\FLIR Pilot Data\nnn\Frames'
%
% where nnn is a 3-digit decimal number.
% The function file itself should be in folder 'FallDetection'.
% It should be run from folder 'FallDetection'.
%
% That is, this script and it's codependent routines should be in the parent
% folder of the folder, 'FLIR Pilot Data'
%
% The training data comprises a subset of video frames (images) from the Pilot
% Data that have been manually identified and sorted into 6 classes or categories.
% All the manually classified images are placed in a subfolder of 'FLIR Pilot Data'
% called 'Categorized'. There are 6 subfolders in 'Categorized', one for each class.
% They are:
%
% Against_Rail
% Exit
% Limb_Out
% Lying
% Sit_Bedside
% Sit_In_Bed
%
% Each subfolder contains images that were manually classified as belonging
% to the eponymous class.

% Replace the path in the next statement as appropriate to your filesystem
% and uncomment it.
cd 'FLIR Pilot Data'

% Turn off the myriad unuseful and annoying warnings
w = warning ('off','all');

% CREATE AN IMAGE DATASTORE
%
% From the help file for imageDtaStore() [Note the lowercase first letter in the name]:
%
% imds = imageDatastore(location) creates a datastore from the collection of image
% data specified by location. A datastore is a repository for collections of data
% that are too large to fit in memory. After creating an ImageDatastore object,
% you can read and process the data in various ways.
%
% An ImageDatastore [Note the uppercase first letter in the name] object manages
% a collection of image files, where each individual image fits in memory, but the
% entire collection of images does not necessarily fit. To create an ImageDatastore
% object, use either the imageDatastore function or the datastore function. Once
% the object is created, you can specify ImageDatastore properties using dot notation
% and use functions that access and manage the data.

% imds = imageDatastore('Categorized','IncludeSubfolders',true,'LabelSource','foldernames');
imds = imageDatastore('Bad_Lines_Diff','IncludeSubfolders',true,'LabelSource','foldernames');

% Generate and print a table of the class labels and number of images in each class
% The table is used later.
tbl = countEachLabel(imds) %#ok
% get the categories as a structure conainting the labels
categories = tbl.Label;

% For visualization only: (can be skipped by commenting out)
%
% Create a new datastore from the files in 'imds' by randomly drawing from each
% label. The 'visImds' datastore will contain 1 random image file from each category.
visImds = splitEachLabel(imds,1,'randomize');
% The 'sample' datastore will contain 16 random image files from each category.
sample = splitEachLabel(imds,16);
% Generate a montage by taking every 16th image from the 96 in the sample -- one
% from each category in this case
montage(sample.Files(1:16:96));
title('One image from each category');
% End of 'For visualization only'

% Randomly select images from each category for a training set and a testing set:
%
% Determine the smallest number of images in a single category
minSetCount = min(tbl{:,2});
% use the splitEachLabel method to trim the set into an equal number of images in
% each category
eqImds = splitEachLabel(imds, minSetCount, 'randomize');
% verify that each set now has exactly the same number of images.
countEachLabel(eqImds)
% split the set at random into a training set with 2/3 of the images
% and a test set with 1/3 of the images
nTrain = round(2*minSetCount/3);
nTest = minSetCount - nTrain;
[training_set, test_set] = eqImds.splitEachLabel(nTrain,nTest,'randomize',true);

% The 'bagOfFeatures' function extracts an equal number of the strongest features
% from the images contained in the training-set imds object. The classifaction
% learning algorithm (run subsequently) will use the measurable differences between
% the extracted image features in differently labeled categories and the similarities
% among features in images from the same category to estimate class boundaries in
% the feature space. Those boundaries are used to classifiy images in the test set.
%
% In the next line, 'bag' will comprise a "vocabulary" of "visual words". The
% argument pair, 'PointSelection','Detector', instruct 'bagOfFeatures' to perform
% a SURF (Speeded Up Robust Feature) detection. It then selects the 250 strongest
% of those features from each image.
bag = bagOfFeatures(imageSet(training_set.Files),'VocabularySize',250,'PointSelection','Detector');
% One can choose to supply a different or custom-designed feature detecture.
% Matlab provids the function, 'exampleBagOfFeaturesExtractor', as an example of
% a custom detector.  It implements essentialy the same SURF detection as above.
% It is only intended to show how to write a custom extractor function for bagOfFeatures.
% this how it should be called:
% bag = bagOfFeatures(imageSet(training_set.Files),'CustomExtractor',@exampleBagOfFeaturesExtractor);

% Create histogram of visual word occurrences
% In this case a 2D array with one row per image and 250 "bagged" values associated
% with each image.
scenedata = double(encode(bag, imageSet(training_set.Files)));
% convert the histogram array to a matlab table structure
SceneImageData = array2table(scenedata);
% append to the table a column with the label for each image
SceneImageData.sceneType = training_set.Labels;

% Intiate the classification learner. This spawns a GUI that requires user
% interaction.
%  1: Click on the '+' in the UL corner of the GUI; it spawns a new window
%  2: Under Step 1: select SceneImageData
%  3: Under Step 2: left click on scene1data and hit <ctlr>-A (i.e. select
%     everything in the table)
%  4: Under Step 3: Do nothing; leave it as is
%  5: Click on the button at the LR labeled, 'Start Session'; new window goes away
%  6: In the main window click on the icon labeled 'All'
%  7: Then click on the green arrowhead labeled 'Train'
%  8: After some 10 seconds or so, things will start happening in the window
%     under "History".
%  9: After about a minute (or less, on my computer) the list of classifiers in
%     the history window will each show an "Accuracy" measurement. The classifier
%     with the highest accuracy is marked with a box around its result. Note that
%     every time you run 'ClassifierTrain' different images are selected for the
%     training set and the test set. The best classifier may be different each time.
% 10: Select the row in the history window that has the best classifier marked
% 11: Optional: click on "Confusion Matrix", "ROC Curve", and "Parallel cdts
%     plot". just FYI
% 12: Click on the green check mark labeled "Export Model"; a requester box appears.
% 13: Click on OK; this will save a structure called "trainedModel" to the workspace.
% 14: Click in the Matlab "Command Window"
% 15: Press any key
classificationLearner % this outputs structure "trainedModel"
% at this pause follow the instructions above
pause
% 16: Move or minimize, but do not yet dismiss the "classificationLearner" GUI

% Create histogram of visual word occurrences
testSceneData = double(encode(bag, imageSet(test_set.Files)));
% convert the histogram array to a matlab table structure
testSceneData = array2table(testSceneData,'VariableNames',trainedModel.RequiredVariables);
% append to the table a column with the label for each image in the test set
actualSceneType = test_set.Labels;
% generate a list of labels that correspond to the best estimate of of the class
% of each image in the test set
predictedOutcome = trainedModel.predictFcn(testSceneData);
% generate a truth-table (a logical array) to compare the predicted classes to
% the actual classes of the images in the test set
correctPredictions = (predictedOutcome == actualSceneType);
% compute a measure of the accuracy of the predictopns
validationAccuracy = 100*sum(correctPredictions)/length(predictedOutcome) %#ok
% compare this number to the accuracy of the chosen classifier in the
% "classificationLearner" GUI

% Display an example from the test set
figure(2);
random_num = randi(length(test_set.Labels));
img = test_set.readimage(random_num);
imshow(img)
% invoke the trained classifier
imagefeatures = double(encode(bag, img));
% Find closest matches for each feature
% [bestGuess, score] = predict(trainedModel.ClassificationEnsemble,imagefeatures);
trainedModelCell = struct2cell(trainedModel);
[bestGuess, score] = predict(trainedModelCell{3,1},imagefeatures);
% Display the string label for img
if bestGuess == test_set.Labels(random_num)
	titleColor = [0 0.8 0];
else
	titleColor = 'r';
end
h=title(sprintf('Best Guess: %s; Actual: %s',...
	char(bestGuess),test_set.Labels(random_num)),...
	'color',titleColor);
set(h,'interpreter','none') % Make underscore not a subscript prefix

% To show the best guess classes of all the image frames from a single video
% run 'DisplayClasses.m' which also must be in folder 'FallDetection'.


cd ..
