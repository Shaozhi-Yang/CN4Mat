function actfunlayer = actfun_backward(actfunlayer,postlayer)
%actfunlayer �������(����)
%postlayer ��һ�㣬����в�
switch postlayer.type
    case'fc' %�����fc��Ҫ�������������
        if actfunlayer.flag %��ʾ�ü���������ȫ���Ӳ㣨mapsize==[1,1]����ֱ�ӳ��Լ������ƫ��������
            switch actfunlayer.function
                case 'sigmoid'
                    actfunlayer.delta = postlayer.delta .* actfunlayer.a .* (1 - actfunlayer.a); %����sigmoid��ƫ����
                case 'tanh'
                    actfunlayer.delta = postlayer.delta .* (1 - (actfunlayer.a).^2); %����tanh��ƫ����
                case 'relu'
                    actfunlayer.delta = postlayer.delta .* double(actfunlayer.a>0.0); %����relu��ƫ����
                    %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
            end
        else  %�����ʾ�ü��������������Ĺ�դ�㣨mapsize~=[1,1]�����Ƚ��з�ʸ�������ٳ��Լ������ƫ����
            [height, width, batchnum] = size(actfunlayer.a{1}); %ȡǰһ������map�ߴ�
            maparea = height * width;
            for i = 1 : actfunlayer.featuremaps  %��ǰ�������ͼ�ĸ���
                z = reshape(postlayer.delta((i - 1) * maparea + 1: i * maparea, :), height, width, batchnum); %��ʸ����
                switch actfunlayer.function
                    case 'sigmoid'
                        actfunlayer.delta{i,1} = z .* actfunlayer.a{i,1} .* (1 - actfunlayer.a{i,1}); %����sigmoid��ƫ����
                    case 'tanh'
                        actfunlayer.delta{i,1} = z .* (1 - (actfunlayer.a{i,1}).^2); %����tanh��ƫ����
                    case 'relu'
                        actfunlayer.delta{i,1} = z .* double(actfunlayer.a{i,1}>0.0); %����relu��ƫ����
                        %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
                end
            end
        end
    case 'bn' %�����bn����ǰ����������ͼ��Ŀ��ͬ����������������ҲҪ�������������  
        if actfunlayer.flag   %��ʾ�ü���������ȫ���Ӳ��У�mapsize==[1,1]��������zscore�Ĳв�ٳ��Լ������ƫ��������
            batchnum = size(postlayer.a,2);
            znorm_delta = 1 ./ repmat(postlayer.std,[1,batchnum]) .* (postlayer.delta - repmat(mean(postlayer.delta,2),[1,batchnum])...
                - repmat(mean(postlayer.delta .* postlayer.z_norm,2),[1,batchnum]) .* postlayer.z_norm);
            switch actfunlayer.function
                case 'sigmoid'
                    actfunlayer.delta = znorm_delta .* actfunlayer.a .* (1 - actfunlayer.a); %����sigmoid��ƫ����
                case 'tanh'
                    actfunlayer.delta = znorm_delta .* (1 - (actfunlayer.a).^2); %����tanh��ƫ����
                case 'relu'
                    actfunlayer.delta = znorm_delta .* double(actfunlayer.a>0.0); %����relu��ƫ����
                    %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
            end
        else  %��ʾ�ü��������ھ�����У�mapsize~=[1,1]��
            batchnum = size(postlayer.a{1},3);
            for i = 1 : actfunlayer.featuremaps  %��ǰ�������ͼ�ĸ�����ǰ����������ͼ��Ŀ��ͬ��
                znorm_delta = 1 ./ repmat(postlayer.std{i,1},[1,1,batchnum]) .* (postlayer.delta{i,1} - repmat(mean(postlayer.delta{i,1},3),[1,1,batchnum])...
                - repmat(mean(postlayer.delta{i,1} .* postlayer.z_norm{i,1},3),[1,1,batchnum]) .* postlayer.z_norm{i,1});
                switch actfunlayer.function
                    case 'sigmoid'
                        actfunlayer.delta{i,1} = znorm_delta .* actfunlayer.a{i,1} .* (1 - actfunlayer.a{i,1}); %����sigmoid��ƫ����
                    case 'tanh'
                        actfunlayer.delta{i,1} = znorm_delta.* (1 - (actfunlayer.a{i,1}).^2); %����tanh��ƫ����
                    case 'relu'
                        actfunlayer.delta{i,1} = znorm_delta .* double(actfunlayer.a{i,1}>0.0); %����relu��ƫ����
                        %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
                end
            end
        end
    case 'pool' %����ǳػ��㣬��ǰ����������ͼ��Ŀ��ͬ�����������������Ƚ����ϲ������ٳ��Լ������ƫ����
        for i = 1 : actfunlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = expand(postlayer.delta{i,1}, [postlayer.stride(1),postlayer.stride(2),1]) .* postlayer.maxPos{i,1}; %�ϲ���
            switch actfunlayer.function
                case 'sigmoid'
                    actfunlayer.delta{i,1} = z .* actfunlayer.a{i,1} .* (1 - actfunlayer.a{i,1}); %����sigmoid��ƫ����
                case 'tanh'
                    actfunlayer.delta{i,1} = z .* (1 - (actfunlayer.a{i,1}).^2); %����tanh��ƫ����
                case 'relu'
                    actfunlayer.delta{i,1} = z .* double(actfunlayer.a{i,1}>0.0); %����relu��ƫ����
                    %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
            end
        end
    case 'conv' %����Ǿ���㣬���Ƚ��з�������ٳ��Լ������ƫ����
        for i = 1 : actfunlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(actfunlayer.a{1}));
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                padMap = map_padding(postlayer.delta{j,1},postlayer.mapsize,postlayer.kernelsize,postlayer.pad,postlayer.stride); 
                %����mapsize,pad��stride����һ��������Ⱦ���
                z = z + convn(padMap,postlayer.w{j,i}, 'valid'); %�������͵õ���ǰ��Ĳв�
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            switch actfunlayer.function
                case 'sigmoid'
                    actfunlayer.delta{i,1} = z .* actfunlayer.a{i,1} .* (1 - actfunlayer.a{i,1}); %����sigmoid��ƫ����
                case 'tanh'
                    actfunlayer.delta{i,1} = z .* (1 - (actfunlayer.a{i,1}).^2); %����tanh��ƫ����
                case 'relu'
                    actfunlayer.delta{i,1} = z .* double(actfunlayer.a{i,1}>0.0); %����relu��ƫ����
                    %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
            end
        end
    case 'deconv'  %�����ת�þ���㣬���Ƚ��з�������ٳ��Լ������ƫ����
         for i = 1 : actfunlayer.featuremaps  %��ǰ�������ͼ�ĸ���
            z = zeros(size(actfunlayer.a{1}));  %��ʱ����
            for j = 1 : postlayer.featuremaps %��һ������ͼ�ĸ���
                a = convn(padarray(postlayer.delta{j,1},[postlayer.pad,0]),postlayer.w{j,i},'valid'); %һ����������ξ����һ��ÿһ���в�delta(������貽��Ϊ1)
                z = z + a(1:postlayer.stride(1):end,1:postlayer.stride(2):end,:); %���ݲ�������,�����(Ȩֵ�������)
                %����convn���Զ���ת����ˣ������ﲻ����ת
            end
            switch actfunlayer.function
                case 'sigmoid'
                    actfunlayer.delta{i,1} = z .* actfunlayer.a{i,1} .* (1 - actfunlayer.a{i,1}); %����sigmoid��ƫ����
                case 'tanh'
                    actfunlayer.delta{i,1} = z .* (1 - (actfunlayer.a{i,1}).^2); %����tanh��ƫ����
                case 'relu'
                    actfunlayer.delta{i,1} = z .* double(actfunlayer.a{i,1}>0.0); %����relu��ƫ����
                    %����relu�������ԣ�a=relu(z),a��z����ͬ�ķ��ţ������Դ���z
            end
         end
end


