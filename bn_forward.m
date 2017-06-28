function bnlayer = bn_forward(inputMap,bnlayer,phase)
%inputMap ����ͼcell��ʽ��cell(inputmaps), e.g. size(cell(1)) = [height*width*datanum]
%bnlayer batch normalization��(����)
%phase  'train' or 'test'
%ע��
%bnlayer.z = z_score(prelayer.a)
%bnlayer.a = bnlayer.gamma * bnlayer.z + bnlayer.beta

switch phase
    case 'train' %����ǰ�򴫲��⣬��Ҫ��¼ÿһ��batch�ľ�ֵ�ͷ���
        if bnlayer.flag %��ʾBN����ȫ���Ӳ���
            bnlayer.mean = mean(inputMap,2); %����ͼ�ľ�ֵ(���м���,��������ʽ)
            bnlayer.z_decent = bsxfun(@minus,inputMap,bnlayer.mean); %����ͼ��ÿһ��ȥ���Ļ�
            bnlayer.var = mean((bnlayer.z_decent).^2,2);  %����ͼ�ķ���(��ƫ����,��������ʽ)
            bnlayer.std = sqrt(bnlayer.var + bnlayer.epsilion); %����ͼ�ı�׼���ƫ��epsilionƽ����
            bnlayer.z_norm = bsxfun(@rdivide,bnlayer.z_decent,bnlayer.std); % z-score��׼��
            %MATLAB������[z_norm,mean,std] = zscore(inputMap,1,2);
            %ӳ���ع�
            bnlayer.a = bsxfun(@times,bnlayer.z_norm,bnlayer.gamma);
            bnlayer.a = bsxfun(@plus,bnlayer.a,bnlayer.beta);
            %��¼ÿһ��batch�ľ�ֵ�ͷ���
            if isempty(bnlayer.all_mean)  %��һ��
                bnlayer.all_mean(:,1) = bnlayer.mean;
                bnlayer.all_var(:,1) = bnlayer.var;
            else
                bnlayer.all_mean(:,end+1) = bnlayer.mean;
                bnlayer.all_var(:,end+1) = bnlayer.var;
            end
        else %��ʾBN���ھ������
            for i = 1:bnlayer.featuremaps
                bnlayer.mean{i,1} = mean(inputMap{i,1},3); %����ͼ�ľ�ֵ(������ʽ)
                bnlayer.z_decent{i,1} = bsxfun(@minus,inputMap{i,1},bnlayer.mean{i,1}); %����ͼ��ÿ��sliceȥ���Ļ�
                bnlayer.var{i,1} = mean((bnlayer.z_decent{i,1}).^2,3);  %����ͼ�ķ���(��ƫ����,������ʽ)
                bnlayer.std{i,1} = sqrt(bnlayer.var{i,1}+bnlayer.epsilion); %����ͼ�ı�׼���ƫ��epsilionƽ����
                bnlayer.z_norm{i,1} = bsxfun(@rdivide, bnlayer.z_decent{i,1}, bnlayer.std{i,1}); % z-score��׼��
                %ӳ���ع�
                bnlayer.a{i,1} = bsxfun(@times, bnlayer.z_norm{i,1}, bnlayer.gamma(i,1));
                bnlayer.a{i,1} =  bsxfun(@plus, bnlayer.a{i,1}, bnlayer.beta(i,1)); 
                %��¼ÿһ��batch�ľ�ֵ�ͷ���
                if isempty(bnlayer.all_mean{i,1})  %��һ��
                    bnlayer.all_mean{i,1}(:,:,1) = bnlayer.mean{i,1};
                    bnlayer.all_var{i,1}(:,:,1) = bnlayer.var{i,1};
                else
                    bnlayer.all_mean{i,1}(:,:,end+1) = bnlayer.mean{i,1};
                    bnlayer.all_var{i,1}(:,:,end+1) = bnlayer.var{i,1};
                end
            end
        end
    case 'test'  %��������ѵ�����ݵľ�ֵ�ͷ���
        if bnlayer.flag %��ʾBN����ȫ���Ӳ���
            batchnum = size(inputMap,2);
            bnlayer.mean = mean(bnlayer.all_mean,2); %��������ѵ�����ݵľ�ֵ(���м���,��������ʽ)
            bnlayer.z_decent = bsxfun(@minus,inputMap,bnlayer.mean); %����ͼ��ÿһ��ȥ���Ļ�
            bnlayer.var = batchnum ./(batchnum-1) .* mean(bnlayer.all_var,2);  %��������ѵ�����ݵķ����ƫ���ƣ���������ʽ��
            bnlayer.std = sqrt(bnlayer.var + bnlayer.epsilion); %����ͼ�ı�׼���ƫ��epsilionƽ����
            bnlayer.z_norm = bsxfun(@rdivide,bnlayer.z_decent,bnlayer.std); % z-score��׼��
            bnlayer.a = bsxfun(@times,bnlayer.z_norm,bnlayer.gamma);  %ӳ���ع�
            bnlayer.a = bsxfun(@plus,bnlayer.a,bnlayer.beta);
        else %��ʾBN���ھ������
            batchnum = size(inputMap{1,1},3);
            for i = 1:bnlayer.featuremaps
                bnlayer.mean{i,1} = mean(bnlayer.all_mean{i,1},3); %%��������ѵ�����ݵľ�ֵ(������ʽ)
                bnlayer.z_decent{i,1} = bsxfun(@minus,inputMap{i,1},bnlayer.mean{i,1}); %����ͼ��ÿ��sliceȥ���Ļ�
                bnlayer.var{i,1} = batchnum ./(batchnum-1) .* mean(bnlayer.all_var{i,1},3);  %��������ѵ�����ݵķ���(��ƫ����,������ʽ)
                bnlayer.std{i,1} = sqrt(bnlayer.var{i,1}+bnlayer.epsilion); %����ͼ�ı�׼���ƫ��epsilionƽ����
                bnlayer.z_norm{i,1} = bsxfun(@rdivide, bnlayer.z_decent{i,1}, bnlayer.std{i,1}); % z-score��׼��
                bnlayer.a{i,1} = bsxfun(@times, bnlayer.z_norm{i,1}, bnlayer.gamma(i,1));
                bnlayer.a{i,1} =  bsxfun(@plus, bnlayer.a{i,1}, bnlayer.beta(i,1)); %ӳ���ع�
            end
        end
    otherwise
        error('Undefined phase of batch normalization layer: %s!',phase);
end
end