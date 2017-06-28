function deconvlayer = deconv_backward(deconvlayer,postlayer)
%convlayer �����(����)
%postlayer ��һ�㣬����в�
switch postlayer.type
    case 'actfun' %�����actfun,��ǰ����������ͼ��Ŀ��ͬ��������������ֱ�Ӵ���
        deconvlayer.delta = postlayer.delta;
    case 'bn'  %�����bn����ǰ����������ͼ��Ŀ��ͬ������������������zscore�Ĳв�,��ֱ�Ӵ���
        batchnum = size(postlayer.a{1},3);
        for i = 1 : deconvlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            znorm_delta = 1 ./ repmat(postlayer.std{i,1},[1,1,batchnum]) .* (postlayer.delta{i,1} - repmat(mean(postlayer.delta{i,1},3),[1,1,batchnum])...
                - repmat(mean(postlayer.delta{i,1} .* postlayer.z_norm{i,1},3),[1,1,batchnum]) .* postlayer.z_norm{i,1});
            deconvlayer.delta{i,1} = znorm_delta;
        end
    case 'fc' %�����fc����ʾ��ǰ����������Ĺ�դ�㣬���Ƚ��з�ʸ������ֱ�Ӵ���
        [height, width, batchnum] = size(deconvlayer.a{1}); %ȡǰһ������map�ߴ�
        maparea = height * width;
        for i = 1 : deconvlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            deconvlayer.delta{i,1} = reshape(postlayer.delta((i - 1) * maparea + 1: i * maparea, :), height, width, batchnum); %��ʸ����
        end
    case 'pool' %�����pool����ǰ����������ͼ��Ŀ��ͬ�����������������ϲ�������ֱ�Ӵ���
        for i = 1 : deconvlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            deconvlayer.delta{i,1} = expand(postlayer.delta{i,1}, [postlayer.stride(1),postlayer.stride(2),1]) .* postlayer.maxPos{i,1}; %�ϲ���
        end
    case 'conv'  %����Ǿ���㣬���Ƚ��з��������ֱ�Ӵ���
        for i = 1 : deconvlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(deconvlayer.a{1}));
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                padMap = map_padding(postlayer.delta{j,1},postlayer.mapsize,postlayer.kernelsize,postlayer.pad,postlayer.stride); 
                %����mapsize,pad��stride����һ��������Ⱦ���
                z = z + convn(padMap,postlayer.w{j,i}, 'valid'); %�������͵õ���ǰ��Ĳв�
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            deconvlayer.delta{i,1} = z;  %ֱ�Ӵ���
        end
   case 'deconv'  %�����ת�þ���㣬��ֱ�ӷ����
         for i = 1 : deconvlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(deconvlayer.a{1}));  %��ʱ����
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                a = convn(padarray(postlayer.delta{j,1},[postlayer.pad,0]),postlayer.w{j,i},'valid'); %һ����������ξ����һ��ÿһ���в�delta(������貽��Ϊ1)
                z = z + a(1:postlayer.stride(1):end,1:postlayer.stride(2):end,:); %���ݲ�������,�����(Ȩֵ�������)
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            deconvlayer.delta{i,1} = z;  %ֱ�Ӵ���
        end
        
end