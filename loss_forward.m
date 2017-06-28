function losslayer = loss_forward(prelayer,losslayer)
%prelayer loss��֮ǰһ��(һ����ȫ����fc�㣩
%losslayer loss��(����)
%ע��
%losslayer.z = prerlayer.a
%losslayer.a = losslayer.function(losslayer.z)

losslayer.input = prelayer.a; %����ǰһ�㣨�����ڶ��㣩������������������ʽ��
switch losslayer.function
    case 'sigmoid'
        losslayer.a = 1./(1+exp(-losslayer.input)); %����sigmoid���
    case 'tanh'
        losslayer.a = tanh(losslayer.input); %����tanh���(build-in)
    case 'relu'
        losslayer.a = losslayer.input.*(losslayer.input>0.0); %����relu���(������)
    case  'softmax'
        M = bsxfun(@minus,losslayer.input,max(losslayer.input, [], 1)); %max(input, [], 1)������е����ֵ�����һ��������
        M = exp(M);
        losslayer.a = bsxfun(@rdivide, M, sum(M));  %�������label
    otherwise
        error('Undefined type of loss layer: %s!',losslayer.function);
end
end