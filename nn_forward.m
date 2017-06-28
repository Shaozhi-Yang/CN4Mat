function net = nn_forward(net, data, phase)
%����ǰ�򴫲�
if nargin == 2
    phase = 'train'; %Ĭ�ϵ�ǰ״̬��ѵ��
end
for layer = 1 : numel(net.layers)   %����ÿ��
    switch net.layers{layer}.type
        case 'input'  %�����
            net.layers{layer}.a{1} = data; %����ĵ�һ������������ݣ������˶��ѵ��ͼ�񣬵�ֻ��һ������ͼ
        case 'conv'  %�����
            net.layers{layer}.a = conv_forward(net.layers{layer-1}.a,net.layers{layer}); %���ﲻ���Ǿֲ��������
        case 'deconv'  %ת�þ����
            net.layers{layer}.a = deconv_forward(net.layers{layer-1}.a,net.layers{layer}); %���ﲻ���Ǿֲ��������
        case 'pool'  %�ػ���
            net.layers{layer} = pool_forward(net.layers{layer-1}.a,net.layers{layer});
        case 'bn' %batch normalization��
            net.layers{layer} = bn_forward(net.layers{layer-1}.a,net.layers{layer},phase); %phase: train/test
        case 'actfun'  %�������
            net.layers{layer}.a = actfun_forward(net.layers{layer-1}.a,net.layers{layer});
        case 'fc'  %ȫ���Ӳ�
            net.layers{layer} = fc_forward(net.layers{layer-1},net.layers{layer});
        case 'loss' %��ʧ��,�����һ��
            net.layers{layer} = loss_forward(net.layers{layer-1},net.layers{layer});
    end
end
