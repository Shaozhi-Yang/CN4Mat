close all;clear;clc;
%���綨��
cnn.layers = {
    struct('type', 'input') %input layer
    struct('type', 'conv', 'featuremaps', 6, 'kernelsize', [5,5], 'stride', 1) %convolution layer
    struct('type', 'actfun','function','relu') %activation function layer
    struct('type', 'bn') %batch-normalization layer
    struct('type', 'pool', 'kernelsize', 2, 'method', 'max','weight',0) %pool layer
    struct('type', 'conv', 'featuremaps', 16, 'kernelsize', [3,3], 'stride', 1) %convolution layer
    struct('type', 'actfun','function','relu') %activation function layer
    struct('type', 'bn') %batch-normalization layer
    struct('type', 'conv', 'featuremaps', 48, 'kernelsize', [3,3], 'stride', 1) %convolution layer
    struct('type', 'actfun','function','relu') %activation function layer
    struct('type', 'pool', 'kernelsize', 2, 'method', 'mean','weight',0) %pool layer
    struct('type', 'bn') %batch-normalization layer
    struct('type', 'conv', 'featuremaps', 120, 'kernelsize', [2,2], 'stride', 1) %convolution layer
    struct('type', 'actfun','function','relu') %activation function layer
    struct('type', 'bn') %batch-normalization layer
    struct('type', 'fc', 'featuremaps', 64) %full connecting layer
    struct('type', 'actfun','function','relu') %activation function layer
    struct('type', 'bn') %batch-normalization layer
    struct('type', 'fc', 'featuremaps', 10) %full connecting layer
    struct('type', 'loss','function', 'softmax') %loss layer
    };
%ѵ����������
opts.alpha = 0.5;   %��ʼѧϰ��
opts.momentum = 0.5;  %��ʼ������Ȩֵ
opts.batchnum = 1000; %����С
opts.numepochs = 40;  %��������

%�������ݺ����(one vs all)
load mnist_uint8.mat; %�������ݼ� 
train_data = double(reshape(train_x',28,28,60000))/255;
test_data = double(reshape(test_x',28,28,10000))/255;
train_label = double(train_y');
test_label = double(test_y');
numClasses = 10;
[height,width,datanum] = size(train_data);
batchsize = [height,width,opts.batchnum];
% ����CNN����
inputSize = batchsize; %����ͼƬ��С
outputSize = numClasses; %��������Ŀ
cnn= nn_setup(cnn, inputSize, outputSize);
% ѵ������
cnn = nn_train(cnn,train_data,train_label,opts);
% ��������
[accuracy, index] = nn_test(cnn,test_data,test_label);