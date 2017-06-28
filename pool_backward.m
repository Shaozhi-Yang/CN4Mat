function poollayer = pool_backward(poollayer,postlayer) 
%poollayer �ػ���(����)
%postlayer ��һ�㣬����в�
switch postlayer.type
    case 'actfun' %�����actfun,��ǰ����������ͼ��Ŀ��ͬ��������������ֱ�Ӵ��ݣ����ػ�����Ȩֵ����Ҫ�ٳ���Ȩֵ��
        for i = 1 : poollayer.featuremaps  %��ǰ�������ͼ�ĸ���
            poollayer.delta{i,1} = postlayer.delta{i,1};
            if poollayer.weight %��Ȩֵ�������Ȩֵ
                poollayer.delta{i,1} = poollayer.delta{i,1} .* poollayer.w{i,1};
            end
        end
    case 'bn'  %�����bn����ǰ����������ͼ��Ŀ��ͬ������������������zscore�Ĳв�,��ֱ�Ӵ��ݣ����ػ�����Ȩֵ����Ҫ�ٳ���Ȩֵ��
        batchnum = size(postlayer.a{1},3);
        for i = 1 : poollayer.featuremaps  %��ǰ�������ͼ�ĸ���
            znorm_delta = 1 ./ repmat(postlayer.std{i,1},[1,1,batchnum]) .* (postlayer.delta{i,1} - repmat(mean(postlayer.delta{i,1},3),[1,1,batchnum])...
                - repmat(mean(postlayer.delta{i,1} .* postlayer.z_norm{i,1},3),[1,1,batchnum]) .* postlayer.z_norm{i,1});
            poollayer.delta{i,1} = znorm_delta;
            if poollayer.weight  %��Ȩֵ�������Ȩֵ
                poollayer.delta{i,1} = poollayer.delta{i,1} .* poollayer.w{i,1};
            end
        end
    case 'fc' %�����fc����ʾ��ǰ����������Ĺ�դ�㣬���Ƚ��з�ʸ��������ֱ�Ӵ��ݣ����ػ�����Ȩֵ����Ҫ�ٳ���Ȩֵ��
        [height, width, batchnum] = size(poollayer.a{1}); %ȡǰһ������map�ߴ�
        maparea = height * width;
        for i = 1 : poollayer.featuremaps  %��ǰ�������ͼ�ĸ���
            poollayer.delta{i,1} = reshape(postlayer.delta((i - 1) * maparea + 1: i * maparea, :), height, width, batchnum); %��ʸ����
            if poollayer.weight  %��Ȩֵ�������Ȩֵ
                poollayer.delta{i,1} = poollayer.delta{i,1} .* poollayer.w{i,1};
            end
        end     
    case 'conv'  %����Ǿ���㣬���Ƚ��з��������ֱ�Ӵ��ݣ����ػ�����Ȩֵ����Ҫ�ٳ���Ȩֵ��
        for i = 1 : poollayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(poollayer.a{1}));
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                padMap = map_padding(postlayer.delta{j,1},postlayer.mapsize,postlayer.kernelsize,postlayer.pad,postlayer.stride); %����mapsize,pad��stride����һ��������Ⱦ���
                z = z + convn(padMap,postlayer.w{j,i}, 'valid'); %�������͵õ���ǰ��Ĳв�
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            poollayer.delta{i,1} = z;  %ֱ�Ӵ���
            if poollayer.weight  %��Ȩֵ�������Ȩֵ
                poollayer.delta{i,1} = poollayer.delta{i,1} .* poollayer.w{i,1};
            end
        end
    case 'deconv'  %�����ת�þ���㣬���Ƚ��з��������ֱ�Ӵ��ݣ����ػ�����Ȩֵ����Ҫ�ٳ���Ȩֵ��
         for i = 1 : poollayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(poollayer.a{1}));  %��ʱ����
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                a = convn(padarray(postlayer.delta{j,1},[postlayer.pad,0]),postlayer.w{j,i},'valid'); %һ����������ξ����һ��ÿһ���в�delta(������貽��Ϊ1)
                z = z + a(1:postlayer.stride(1):end,1:postlayer.stride(2):end,:); %���ݲ�������,�����(Ȩֵ�������)
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            poollayer.delta{i,1} = z;  %ֱ�Ӵ���
            if poollayer.weight  %��Ȩֵ�������Ȩֵ
                poollayer.delta{i,1} = poollayer.delta{i,1} .* poollayer.w{i,1};
            end
        end
end