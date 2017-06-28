function fclayer = fc_backward(fclayer,postlayer)
%fclayer ȫ���Ӳ�(����)
%postlayer ��һ�㣬����в�
%�в�򴫲������㵱ǰȫ���Ӳ��������
switch postlayer.type
    case 'fc'
        fclayer.delta = fclayer.w' * postlayer.delta;
    case 'actfun'
        fclayer.delta = fclayer.w' * postlayer.delta;
    case 'loss'
        fclayer.delta = fclayer.w' * postlayer.delta;
    case 'bn'  %��ʾBN�����ȫ���Ӳ��У�mapsize==[1,1]��,ǰ����������ͼ��Ŀ��ͬ������������
        batchnum = size(postlayer.a,2);
        fclayer.znorm_delta = 1 ./ repmat(postlayer.std,[1,batchnum]) .* (postlayer.delta - repmat(mean(postlayer.delta,2),[1,batchnum])...
            - repmat(mean(postlayer.delta .* postlayer.z_norm,2),[1,batchnum]) .* postlayer.z_norm); %����zscore�Ĳв�
        fclayer.delta = fclayer.w' * fclayer.znorm_delta;  %�ٳ���ȫ���Ӳ�����Ȩֵ
end