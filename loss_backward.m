function losslayer = loss_backward(losslayer,label,w)
%fclayer loss��(����)
%label ��ǩ
%w loss��ǰһ��ȫ���Ӳ������Ȩֵ������Ȩ��˥��,����������ࣩ
lambda = 1e-4; %softmax���Ȩ��˥��ϵ��
losslayer.error = losslayer.a - label; %ʵ��������������֮������
batchnum = size(losslayer.a, 2);
switch losslayer.function
    case 'sigmoid'
         losslayer.loss =  1/2* sum(losslayer.error(:) .^ 2) / batchnum;  %���ۺ��������þ���������Ϊ���ۺ���
         losslayer.delta = losslayer.error .* (losslayer.a .* (1 - losslayer.a)); %�����в�sigmoid���ݺ���
    case 'tanh'
        losslayer.loss =  1/2* sum(losslayer.error(:) .^ 2) / batchnum;  %���ۺ��������þ���������Ϊ���ۺ���
        losslayer.delta = losslayer.error .* (1 - (losslayer.a).^2); %�����в�tanh���ݺ���
    case 'relu'
        losslayer.loss =  1/2* sum(losslayer.error(:) .^ 2) / batchnum;  %���ۺ��������þ���������Ϊ���ۺ���
        losslayer.delta = losslayer.error .* double(losslayer.a>0.0); %�����в�relu���ݺ���������relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z��
    case 'softmax'
        losslayer.loss = -1/batchnum * label(:)' * log(losslayer.a(:)) + lambda/2 * sum(w(:) .^ 2);  %softmax��ʧ����������Ȩ��˥�������������(�ǵ���Ȩֵ�ݶ�ʱ������һ��)
        losslayer.delta = losslayer.error;  %softmax���������
end
end