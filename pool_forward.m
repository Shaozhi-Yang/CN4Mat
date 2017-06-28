function poollayer = pool_forward(inputMap,poollayer)
%inputMap ����ͼcell��ʽ��cell(inputmaps), e.g. size(cell(1)) = [height*width*datanum]
%poollayer �ػ������
%ע��
%poollayer.z = downsample(prerlayer.a)
%poollayer.a =  poollayer.z OR poollayer.a = poollayer.w * poollayer.z + poollayer.b(if weight)

[height,width,batchnum] = size(inputMap{1});  %����inputmaps��С
stride = poollayer.stride;   %����Ĭ��[2,2]
poollayer.a = cell(poollayer.featuremaps,1); %Ԥ�ȿ��ٿռ䣬����ػ�������²�����
%poollayer.downsample = cell(poollayer.featuremaps,1); %%Ԥ�ȿ��ٿռ䣬�������²�����������ڳػ�����ȨֵʱȨֵ�ĸ��£�
poollayer.maxPos = cell(poollayer.featuremaps,1); %Ԥ�ȿ��ٿռ䣬���ֵλ�ü�¼���������򴫲�
%����poollayer.maxPos��Ƿ������ͳһ��������������ȼ���
if strcmp(poollayer.method, 'max') %��������ػ�
    for i = 1:poollayer.featuremaps
        poollayer.a{i,1} = zeros(height/stride(1),width/stride(2),batchnum); %��ʼ���ػ�����Ϊ0
        poollayer.maxPos{i,1} = zeros(height,width,batchnum); %��ʼ�����ֵλ�þ���Ϊ0
        for row = 1:stride(1):height
            for col = 1:stride(2):width
                patch = inputMap{i}(row:row+stride(1)-1,col:col+stride(2)-1,:); %patchsize:stride*stride*batchnum 
                [val,ind] = max(reshape(patch,[stride(1)*stride(2),batchnum]));  % �ҳ����ֵ����λ��
                %poollayer.downsample{i,1}((row+stride-1)/stride,(col+stride-1)/stride,:) = val; %�����²������
                poollayer.a{i,1}((row+stride(1)-1)/stride(1),(col+stride(2)-1)/stride(2),:) = val;  %�����²������
                if poollayer.weight %���ػ�����Ȩֵ
                    poollayer.a{i,1}((row+stride(1)-1)/stride(1),(col+stride(2)-1)/stride(2),:) = poollayer.w{i} .* val + poollayer.b{i};  % ��Ȩ�غ�ƫ��,max pooling,�޼�����������ԣ�
                end
                ind_row = rem(ind,stride(1)); %�ҵ����ֵ������Ӧ��������(��stride(1)*stride(2)��λ��)
                ind_row(ind_row==0) = stride(1); %stride�ı���ȡ���Ϊ0��Ӧ�ӻ�ȥ
                ind_col = ceil(ind/stride(1)); %�ҵ����ֵ������Ӧ��������
                for j = 1:batchnum
                    poollayer.maxPos{i,1}(row + ind_row(j) - 1, col + ind_col(j) - 1, j) = 1; %�Ƴ����ֵλ����ԭͼ�е���Ӧλ�ã���Ϊ1
                end
            end
        end
    end
elseif strcmp(poollayer.method, 'mean') %�����ƽ���ػ�
    for i = 1:poollayer.featuremaps
        z = convn(inputMap{i}, ones(stride) / (stride(1)*stride(2)), 'valid');   %��kron���ʵ��ƽ���ػ�
        z = z(1 : stride(1) : end, 1 : stride(2) : end, :); %���ݲ�����������ȡֵ
        %poollayer.downsample{i,1} = z; %�����²������
        poollayer.a{i,1} = z;  %�����²������
        if poollayer.weight %���ػ�����Ȩֵ
            poollayer.a{i,1} = poollayer.w{i} .* z + poollayer.b{i};  %��Ȩ��,�޼����
        end
        poollayer.maxPos{i,1} = 1/(stride(1)*stride(2)) .* ones(height,width,batchnum); %ƽ���ػ�ÿ��Ԫ�صĸ��ʶ���1/(poollayer.scale^2)
    end
else
    error('Undefined method of pool layer: %s!',poollayer.method);
end
end