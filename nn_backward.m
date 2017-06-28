function net = nn_backward(net,label)
%%����в�����ȣ�
%ע����������⣬���������Ĳв����֮ǰһ��Ĳв�
layer_num = numel(net.layers); %������� 
for layer = layer_num : -1 : 2
    switch net.layers{layer}.type
        case 'loss' %��ʧ��
            net.layers{layer} = loss_backward(net.layers{layer},label,net.layers{layer-1}.w); %����loss��ǰһ��ȫ���Ӳ������Ȩֵ������Ȩ��˥��,����������ࣩ
            net.loss = net.layers{layer}.loss;
        case 'fc'  %ȫ���Ӳ�
            net.layers{layer} = fc_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
        case 'actfun' %�������
            net.layers{layer} = actfun_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
        case 'bn'  %batch normalization��
            net.layers{layer} = bn_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
        case 'pool' %�ػ���
            net.layers{layer} = pool_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
        case 'conv' %�����
            net.layers{layer} = conv_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
        case 'deconv' %ת�þ����
            net.layers{layer} = deconv_backward(net.layers{layer},net.layers{layer+1}); %��ǰ��ͺ�һ��
    end
end
%%�����ݶ�
net = nn_calc_weight(net);
end