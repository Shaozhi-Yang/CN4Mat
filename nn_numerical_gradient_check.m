%%�������ֵ�ݶȺ˶�
clear;clc;
%���綨��
cnn.layers = {
    struct('type', 'input') %input layer
    struct('type', 'conv', 'featuremaps', 2, 'kernelsize', [2,3], 'stride', 2, 'pad', 1) %convolution layer
    %struct('type', 'bn') %bn layer
    %struct('type', 'actfun','function','sigmoid') %actfun layer
    %struct('type', 'bn') %bn layer
    struct('type', 'pool', 'kernelsize',2, 'method', 'mean','weight',1) %pool layer
    struct('type', 'bn') %bn layer
    struct('type', 'deconv', 'featuremaps', 4, 'kernelsize', 2, 'stride',1 , 'pad', 0) %transpose convolution layer
    %struct('type', 'bn') %bn layer
    struct('type', 'fc', 'featuremaps', 2) %full connecting layer
    %struct('type', 'bn') %bn layer
    struct('type', 'actfun','function','tanh') %bn layer
    struct('type', 'bn') %bn layer
    struct('type', 'fc', 'featuremaps',4) %full connecting layer
    struct('type', 'loss','function','softmax') %loss layer
    };
%ע�⣺��������ʹ�õ���relu���������0�㲻�ɵ������������ڼ����������ֵ�ݶ�ʱ�����ܲ�׼ȷ
%��x<0,��f(x)=0��������ݶ�f'(x)=0;
%��h>0,������h>|x|,��f(x+h)=x+h>0��Խ�����ɵ���0��,����ֵ�ݶ�f'(x+h)=1>0,������ݶȲ�һ�£�f(x-h)ͬ��
%���ǣ��ڲ��ɵ��㸽����xֻ�����������sigmoid����tanh��������ݶȼ���ͨ������relu������Ĵ󲿷���ֵ�ݶȼ���ͨ������ʱ��ȫ��ͨ���������ݶȼ���û������

%ѵ����������
opts.alpha = 0.01;   %ѧϰ��
opts.momentum = 0.9;  %������Ȩֵ
opts.batchnum = 4; %����С
opts.numepochs = 20;  %��������

%ѵ������
data = rand(6,7,3);
label = eye(4,3);
inputSize = size(data);
outputSize = 4;

%����
cnn= nn_setup(cnn, inputSize, outputSize);
cnn = nn_forward(cnn,data);
cnn = nn_backward(cnn,label);
%nn_grad_check(cnn,data,label);
%һ��Ҫ����һ��Ȩ�ز���ȷ���ݶ��㷨������ȷ������żȻ��
cnn = nn_weight_update(cnn, opts);
cnn = nn_forward(cnn,data);
cnn = nn_backward(cnn,label);
nn_grad_check(cnn,data,label);
