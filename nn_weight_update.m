function net = nn_weight_update(net, opts)
%opts.alpha  ѧϰ��
%opts.momentum  ������Ȩֵ
%ֻ�к�Ȩֵ��ƫ�õ���������Ҫ����Ȩֵ
for layer = 2 : numel(net.layers)
    switch net.layers{layer}.type
        case  'conv' %�����Ȩֵ����
            for j = 1 : net.layers{layer}.featuremaps
                for i = 1: net.layers{layer-1}.featuremaps
                    %���������SGDȨ�ظ��¹�ʽ
                    net.layers{layer}.mw{j,i} = opts.momentum * net.layers{layer}.mw{j,i} - opts.alpha * net.layers{layer}.dw{j,i}; %���㶯����
                    net.layers{layer}.w{j,i} = net.layers{layer}.w{j,i} + net.layers{layer}.mw{j,i}; %Ȩֵ����
                    %��SGDȨֵ���µĹ�ʽ��W_new = W_old - alpha * de/dW��SGD����Ȩֵ������
                    %net.layers{layer}.w{outputmap,inputmap} = net.layers{layer}.w{outputmap,inputmap} - opts.alpha * net.layers{layer}.dw{outputmap,inputmap};
                end
                %���������SGDƫ�ø��¹�ʽ
                net.layers{layer}.mb{j} = opts.momentum * net.layers{layer}.mb{j} - opts.alpha * net.layers{layer}.db{j}; %���㶯����
                net.layers{layer}.b{j} = net.layers{layer}.b{j} + net.layers{layer}.mb{j}; %ƫ�ø���
                %��SGDƫ�ø��µĹ�ʽ��b_new = b_old - alpha * de/db��SGD����Ȩֵ������
                %net.layers{layer}.b{outputmap} = net.layers{layer}.b{outputmap} - opts.alpha * net.layers{layer}.db{outputmap};
            end
        case 'deconv' %ת�þ����Ȩֵ����
            for j = 1 : net.layers{layer}.featuremaps
                for i = 1: net.layers{layer-1}.featuremaps
                    %���������SGDȨ�ظ��¹�ʽ
                    net.layers{layer}.mw{j,i} = opts.momentum * net.layers{layer}.mw{j,i} - opts.alpha * net.layers{layer}.dw{j,i}; %���㶯����
                    net.layers{layer}.w{j,i} = net.layers{layer}.w{j,i} + net.layers{layer}.mw{j,i}; %Ȩֵ����
                    %��SGDȨֵ���µĹ�ʽ��W_new = W_old - alpha * de/dW��SGD����Ȩֵ������
                    %net.layers{layer}.w{outputmap,inputmap} = net.layers{layer}.w{outputmap,inputmap} - opts.alpha * net.layers{layer}.dw{outputmap,inputmap};
                end
                %���������SGDƫ�ø��¹�ʽ
                net.layers{layer}.mb{j} = opts.momentum * net.layers{layer}.mb{j} - opts.alpha * net.layers{layer}.db{j}; %���㶯����
                net.layers{layer}.b{j} = net.layers{layer}.b{j} + net.layers{layer}.mb{j}; %ƫ�ø���
                %��SGDƫ�ø��µĹ�ʽ��b_new = b_old - alpha * de/db��SGD����Ȩֵ������
                %net.layers{layer}.b{outputmap} = net.layers{layer}.b{outputmap} - opts.alpha * net.layers{layer}.db{outputmap};
            end
        case  'pool'%�ػ���Ȩֵ����
            if net.layers{layer}.weight
                for j = 1 : net.layers{layer}.featuremaps
                    net.layers{layer}.mw{j} = opts.momentum * net.layers{layer}.mw{j} - opts.alpha * net.layers{layer}.dw{j};
                    net.layers{layer}.w{j} = net.layers{layer}.w{j} + net.layers{layer}.mw{j};
                    net.layers{layer}.mb{j} = opts.momentum * net.layers{layer}.mb{j} - opts.alpha * net.layers{layer}.db{j};
                    net.layers{layer}.b{j} = net.layers{layer}.b{j} + net.layers{layer}.mb{j};
                    %��SGDƫ�ø��µĹ�ʽ
                    %net.layers{layer}.w{outputmap} = net.layers{layer}.w{outputmap} - opts.alpha * net.layers{layer}.dw{outputmap};
                    %net.layers{layer}.b{outputmap} = net.layers{layer}.b{outputmap} - opts.alpha * net.layers{layer}.db{outputmap};
                    
                end
            end
        case  'bn' %batch normalization��Ȩֵ����
            net.layers{layer}.mgamma = opts.momentum .* net.layers{layer}.mgamma - opts.alpha .* net.layers{layer}.dgamma;%���㶯����
            net.layers{layer}.gamma = net.layers{layer}.gamma + net.layers{layer}.mgamma; %gamma����
            net.layers{layer}.mbeta = opts.momentum .* net.layers{layer}.mbeta - opts.alpha * net.layers{layer}.dbeta;%���㶯����
            net.layers{layer}.beta = net.layers{layer}.beta + net.layers{layer}.mbeta; %beta����
        case 'fc' %ȫ���Ӳ�Ȩֵ����
            net.layers{layer}.mw = opts.momentum * net.layers{layer}.mw - opts.alpha * net.layers{layer}.dw;
            net.layers{layer}.w = net.layers{layer}.w + net.layers{layer}.mw ;
            net.layers{layer}.mb = opts.momentum * net.layers{layer}.mb - opts.alpha * net.layers{layer}.db;
            net.layers{layer}.b = net.layers{layer}.b + net.layers{layer}.mb;
             %��SGDƫ�ø��µĹ�ʽ
            %net.layers{layer}.w = net.layers{layer}.w - opts.alpha * net.layers{layer}.dw;
            %net.layers{layer}.b = net.layers{layer}.b - opts.alpha * net.layers{layer}.db;
    end
end
end