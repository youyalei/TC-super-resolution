clc
clear
close all
tic

save_loc='/storage/cms/youy_lab/youy/super-reso/mat-data-v3-td-ts/';
%******************************************************
networkDepth=10;
maxEpochs=50;
patchesPerImage = 25;

ND=networkDepth;
patchSize=[2*ND+1,2*ND+1];
%******************************************************

addpath('/storage/cms/youy_lab/youy/super-reso/VeryDeepSuperResolutionUsingDeepLearningExample/');
% this is low-reso
upsampledDirName='/storage/cms/youy_lab/youy/super-reso/data_v3_td_ts/ssmis/ssmis-train/';
residualDirName='/storage/cms/youy_lab/youy/super-reso/data_v3_td_ts/ssmis/gmi-ssmis-train/';

upsampledImages = imageDatastore(upsampledDirName,FileExtensions=".mat",ReadFcn=@matRead);
residualImages = imageDatastore(residualDirName,FileExtensions=".mat",ReadFcn=@matRead);

augmenter = imageDataAugmenter( ...
    RandRotatio=@()randi([0,1],1)*90, ...
    RandXReflection=true);

dsTrain = randomPatchExtractionDatastore(upsampledImages,residualImages,patchSize, ...
    DataAugmentation=augmenter,PatchesPerImage=patchesPerImage);

firstLayer = imageInputLayer([2*networkDepth+1 2*networkDepth+1 1],Name="InputLayer",Normalization="none");

convLayer = convolution2dLayer(3,64,Padding=1, ...
    WeightsInitializer="he",BiasInitializer="zeros",Name="Conv1");

relLayer = reluLayer(Name="ReLU");

middleLayers = [convLayer relLayer];
for layerNumber = 2:networkDepth-1
    convLayer = convolution2dLayer(3,64,Padding=[1 1], ...
        WeightsInitializer="he",BiasInitializer="zeros", ...
        Name="Conv"+num2str(layerNumber));

    relLayer = reluLayer(Name="ReLU"+num2str(layerNumber));
    middleLayers = [middleLayers convLayer relLayer];
end

finalLayer = convolution2dLayer(3,1,Padding=[1 1], ...
    WeightsInitializer="he",BiasInitializer="zeros", ...
    NumChannels=64,Name="Conv"+num2str(networkDepth));

layers = [firstLayer middleLayers finalLayer];

net = dlnetwork(layers);

maxEpochs = 50;%100;
epochIntervals = 1;
initLearningRate = 0.1;
learningRateFactor = 0.1;
l2reg = 0.0001;
miniBatchSize = 64;
options = trainingOptions("sgdm", ...
    Momentum=0.9, ...
    InitialLearnRate=initLearningRate, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=10, ...
    LearnRateDropFactor=learningRateFactor, ...
    L2Regularization=l2reg, ...
    MaxEpochs=maxEpochs, ...
    MiniBatchSize=miniBatchSize, ...
    GradientThresholdMethod="l2norm", ...
    GradientThreshold=0.01);

[net,info] = trainnet(dsTrain,net,"mse",options);

%********************************************************
% networkDepth=10;
% patchSize=[2*ND+1,2*ND+1];
% maxEpochs=20;
% patchesPerImage = 25;
file_net_name=['trainedVDSR-v3-',...
    'epoch',num2str(maxEpochs),'-',...
    'ND',num2str(networkDepth),'-',...
    'patchesPerImage',num2str(patchesPerImage),'-ssmis.mat'];

file_info_name=['trainedVDSR-v3-',...
    'epoch',num2str(maxEpochs),'-',...
    'ND',num2str(networkDepth),'-',...
    'patchesPerImage',num2str(patchesPerImage),'-info-ssmis.mat'];

save([save_loc,file_net_name],"net");
save([save_loc,file_info_name],"info");

toc
