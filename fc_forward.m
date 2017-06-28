function fclayer = fc_forward(prelayer,fclayer)
%prelayer ȫ���Ӳ�֮ǰһ��(����)
%fclayer ȫ���Ӳ�(����)
%ע��
%fclayer.z = prerlayer.a
%fclayer.a = fclayer.w * fclayer.z + fclayer.b

fc_in = [];
if strcmp(prelayer.type, 'conv') || strcmp(prelayer.type, 'deconv') || strcmp(prelayer.type, 'pool') || ...
   (strcmp(prelayer.type, 'bn') && ~(prelayer.flag)) || (strcmp(prelayer.type, 'actfun') && ~(prelayer.flag))
%���ȫ���Ӳ��ǰһ���Ǿ����/�ػ���/batch normalization��/������㣨mapsize��С����[1,1]����Ҫ��������ʸ������
    for i = 1:numel(prelayer.a) %ǰһ���featuremaps��Ŀ����ȫ���Ӳ��inputmaps��Ŀ
        [height,width,batchnum] = size(prelayer.a{i});
        fc_in = [fc_in; reshape(prelayer.a{i},height*width,batchnum)]; %��ǰһ������mapsչ��������
    end
else
    fc_in = prelayer.a; %���ȫ���Ӳ��ǰһ����ȫ���Ӳ㣨mapsize��С��[1,1]�������ý�ǰһ���outputmapչ������
    batchnum = size(prelayer.a,2);
end
fclayer.input = fc_in; %����ǰһ�������������������ʽ��
fclayer.a = fclayer.w * fc_in + repmat(fclayer.b,[1,batchnum]); %�����������������ԣ�
end