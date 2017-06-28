function outputMap = actfun_forward(inputMap,actfunlayer)
%inputMap ����ͼcell��ʽ��cell(inputmaps), e.g. size(cell(1)) = [height*width*datanum]
%actfunlayer �������(����)
%outputMap �����ݺ���������������cell��ʽ
%ע��
%actfunlayer.z = prerlayer.a
%actfunlayer.a = actfunlayer.function(actfunlayer.z)
if actfunlayer.flag %��ʾ�ü���������ȫ���Ӳ��У�mapsize==[1,1]����ֱ�Ӽ��㼤���
    switch actfunlayer.function
            case 'sigmoid'
                outputMap = 1./(1+exp(-inputMap)); %����sigmoid���
            case 'tanh'
                outputMap = tanh(inputMap); %����tanh���
            case 'relu'
                outputMap = inputMap .* (inputMap>0.0); %����relu���
            otherwise
                error('Unknown function of actfun layer: %s!',actfunlayer.function);
    end
else %��ʾ�ü��������ھ�����У�mapsize~=[1,1]��
    outputMap = cell(actfunlayer.featuremaps,1);   %Ԥ�ȿ��ٴ洢�ռ�
    for i = 1 : actfunlayer.featuremaps   %featuremaps��Ŀ
        switch actfunlayer.function
            case 'sigmoid'
                outputMap{i,1} = 1./(1+exp(-inputMap{i,1})); %����sigmoid���
            case 'tanh'
                outputMap{i,1} = tanh(inputMap{i,1}); %����tanh���
            case 'relu'
                outputMap{i,1} = inputMap{i,1} .* (inputMap{i,1}>0.0); %����relu���
            otherwise
                error('Unknown function of actfun layer: %s!',actfunlayer.function);
        end
    end
end
end