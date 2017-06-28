function bnlayer = bn_backward(bnlayer,postlayer)
%bnlayer batch normalization��(����)
%postlayer ��һ�㣬����в�
switch postlayer.type
    case 'fc' %�����fc��Ҫ�������������
        if bnlayer.flag  %��ʾBN�����ȫ���Ӳ��У�mapsize==[1,1]����ֱ�ӳ���gamma����
            batchnum = size(bnlayer.a,2);
            bnlayer.delta = repmat(bnlayer.gamma,[1,batchnum]) .* postlayer.delta; %�в�
            bnlayer.dgamma = sum(postlayer.delta .* bnlayer.z_norm,2) ./ batchnum;  %gammaƫ����
            bnlayer.dbeta = sum(postlayer.delta,2) ./ batchnum;  %betaƫ����
        else  %�����ʾBN����������Ĺ�դ���У�mapsize~=[1,1]�����Ƚ��з�ʸ�������ٳ���gamma����
            [height, width, batchnum] = size(bnlayer.a{1}); %ȡǰһ������map�ߴ�
            maparea = height * width;
            for i = 1 : bnlayer.featuremaps  %��ǰ�������ͼ�ĸ���
                z = reshape(postlayer.delta((i - 1) * maparea + 1: i * maparea, :), height, width, batchnum); %��ʸ����
                bnlayer.delta{i,1} =  bnlayer.gamma(i,1) .* z;   %�в�
                bnlayer.dgamma(i,1) = sum(sum(sum(z .* bnlayer.z_norm{i,1}))) ./ batchnum;  %gammaƫ����
                bnlayer.dbeta(i,1) = sum(z(:)) ./ batchnum;  %betaƫ����
            end
        end
    case'actfun' %�����actfun��ҲҪ�������������
        if bnlayer.flag  %��ʾBN�����ȫ���Ӳ��У�mapsize==[1,1]����ֱ�ӳ���gamma����
            batchnum = size(bnlayer.a,2);
            bnlayer.delta = repmat(bnlayer.gamma,[1,batchnum]) .* postlayer.delta; %�в�
            bnlayer.dgamma = sum(postlayer.delta .* bnlayer.z_norm,2) ./ batchnum;  %gammaƫ����
            bnlayer.dbeta = sum(postlayer.delta,2) ./ batchnum;  %betaƫ����
        else  %����BN����ھ�����У�mapsize~=[1,1]����ǰ����������ͼ��Ŀ��ͬ��������������ֱ�ӳ���gamma����
            batchnum = size(bnlayer.a{1},3);
            for i = 1 : bnlayer.featuremaps  %��ǰ�������ͼ�ĸ���
                bnlayer.delta{i,1} = bnlayer.gamma(i,1) .* postlayer.delta{i,1};    %�в�
                bnlayer.dgamma(i,1) = sum(sum(sum(postlayer.delta{i,1} .* bnlayer.z_norm{i,1}))) ./ batchnum;  %gammaƫ����
                bnlayer.dbeta(i,1) = sum(postlayer.delta{i,1}(:)) ./ batchnum;  %betaƫ����
            end
        end
    case 'pool' %����ǳػ��㣬��ǰ����������ͼ��Ŀ��ͬ�����������������Ƚ����ϲ������ٳ���gamma����
        batchnum = size(bnlayer.a{1},3);
        for i = 1 : bnlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = expand(postlayer.delta{i,1}, [postlayer.stride(1),postlayer.stride(2),1]) .* postlayer.maxPos{i,1}; %�ϲ���
            bnlayer.delta{i,1} = bnlayer.gamma(i,1) .* z;     %�в�
            bnlayer.dgamma(i,1) = sum(sum(sum(z .* bnlayer.z_norm{i,1}))) ./ batchnum;  %gammaƫ����
            bnlayer.dbeta(i,1) = sum(z(:)) ./ batchnum;  %betaƫ����
        end
    case 'conv' %����Ǿ���㣬���Ƚ��з�������ٳ���gamma����
        batchnum = size(bnlayer.a{1},3);
        for i = 1 : bnlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(bnlayer.a{1}));
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                padMap = map_padding(postlayer.delta{j,1},postlayer.mapsize,postlayer.kernelsize,postlayer.pad,postlayer.stride); %����mapsize,pad��stride����һ��������Ⱦ���
                z = z + convn(padMap,postlayer.w{j,i}, 'valid'); %�������͵õ���ǰ��Ĳв�
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            bnlayer.delta{i,1} = bnlayer.gamma(i,1) .* z ;     %�в�
            bnlayer.dgamma(i,1) = sum(sum(sum(z .* bnlayer.z_norm{i,1}))) ./ batchnum;  %gammaƫ����
            bnlayer.dbeta(i,1) = sum(z(:)) ./ batchnum;  %betaƫ����
        end
    case 'deconv'  %�����ת�þ���㣬���Ƚ��з�������ٳ���bn��ƫ����
         batchnum = size(bnlayer.a{1},3);
        for i = 1 : bnlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(bnlayer.a{1}));  %��ʱ����
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                a = convn(padarray(postlayer.delta{j,1},[postlayer.pad,0]),postlayer.w{j,i},'valid'); %һ����������ξ����һ��ÿһ���в�delta(������貽��Ϊ1)
                z = z + a(1:postlayer.stride(1):end,1:postlayer.stride(2):end,:); %���ݲ�������,�����(Ȩֵ�������)
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            bnlayer.delta{i,1} = bnlayer.gamma(i,1) .* z ;     %�в�
            bnlayer.dgamma(i,1) = sum(sum(sum(z .* bnlayer.z_norm{i,1}))) ./ batchnum;  %gammaƫ����
            bnlayer.dbeta(i,1) = sum(z(:)) ./ batchnum;  %betaƫ����
        end
end
