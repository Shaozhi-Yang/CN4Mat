function net = nn_calc_weight(net)
%%�����ݶ� 
%loss���actfun��û��Ȩֵ���ʲ���Ҫ����
%bn����ݶ����ڷ��򴫲������м�����ˣ���Ҳ�����ڴ˼���
lambda = 1e-4; %softmax���Ȩ��˥��ϵ��
layer_num = numel(net.layers); %������� 
batchnum= size(net.layers{1}.a{1},3);
for layer = layer_num : -1 : 2
    switch net.layers{layer}.type
        case 'conv'  %�����
            for j = 1:net.layers{layer}.featuremaps
                for i = 1:net.layers{layer-1}.featuremaps
                    padMap = map_padding(net.layers{layer}.delta{j},net.layers{layer}.mapsize,[1,1],[0,0],net.layers{layer}.stride);
                    %���Ǿ����Ĳ�����Ҫ�������������ȸ��ݾ�����������ڲ����䣨��ʵ��һ�������ڰ����������ϲ�������0��䣻���ڲ��ý����ⲿ��䣬���Խ�kernelsize��pad����Ϊ[1,1]��[0,0]��
                    z = convn(padarray(net.layers{layer-1}.a{i},[net.layers{layer}.pad,0]),flipall(padMap), 'valid');  %���ⲿ���㣨�˿��Ժ���һ��map_paddingͬ�������پ��
                    %convn���Զ���ת�����,����Ҫ����ת����,flipall�����������ÿһά��(����������ά��)����ת��180��
                    net.layers{layer}.dw{j,i} = z./batchnum;
                end
                net.layers{layer}.db{j,1} = sum(net.layers{layer}.delta{j}(:)) / batchnum;
            end
        case 'deconv'  %ת�þ����
            for j = 1:net.layers{layer}.featuremaps
                for i = 1:net.layers{layer-1}.featuremaps
                    padMap = map_padding(net.layers{layer-1}.a{i},net.layers{layer-1}.mapsize,[1,1],[0,0],net.layers{layer}.stride);
                    %���Ǿ����Ĳ�����Ҫ�������������ȸ��ݾ�����������ڲ����䣨��ʵ��һ�������ڰ����������ϲ�������0��䣻���ڲ��ý����ⲿ��䣬���Խ�kernelsize��pad����Ϊ[1,1]��[0,0]��
                    %z = rot180(convn(padarray(net.layers{layer}.delta{j},[net.layers{layer}.pad,0]),flipall(padMap), 'valid')); %���ⲿ���㣨�˿��Ժ���һ��map_paddingͬ�������پ��
                    %convn���Զ���ת�����,����Ҫ����ת����,flipall�����������ÿһά��(����������ά��)����ת��180��
                    z = convn(rot180(padarray(net.layers{layer}.delta{j},[net.layers{layer}.pad,0])),flip(padMap,3), 'valid');
                    %��һ��ʵ�ַ�ʽ,���ٷ�ת����
                    net.layers{layer}.dw{j,i} = z./batchnum;
                end
                net.layers{layer}.db{j,1} = sum(net.layers{layer}.delta{j}(:)) / batchnum;
            end
        case 'pool' %�ػ���
            if net.layers{layer}.weight  %����ػ�����Ȩֵ
                for j = 1:net.layers{layer}.featuremaps
                     %���ڳ�������⣬���������Ĳв����֮ǰһ��Ĳв������layer+1��Ĳв���������˸�С���ɣ��Ƚ�poolǰ������֮��в�Ĺ�ϵ
                    delta_no_weight = net.layers{layer}.delta{j,1} ./ net.layers{layer}.w{j,1}; %�ɷ��򴫲�����õ��ĳػ���û��Ȩֵʱ�������ȣ�����Ȩֵʱ�������ȳ���Ȩֵ���ɣ�
                    downsample_no_weight = (net.layers{layer}.a{j,1} - net.layers{layer}.b{j,1}) ./ net.layers{layer}.w{j,1}; %�ػ���û��Ȩֵʱ���²������(����input)��downsample = (��Ȩֵʱ���²��������a-ƫ�ã�b)./Ȩֵ��w
                    net.layers{layer}.dw{j,1} = sum(delta_no_weight(:) .* downsample_no_weight(:)) ./ batchnum; %Ȩֵ�ݶ�
                    net.layers{layer}.db{j,1} = sum(delta_no_weight(:)) ./ batchnum;  %ƫ���ݶ�
                end
            end
        case 'fc' %ȫ���Ӳ�
            %���ڳ�������⣬���������Ĳв����֮ǰһ��Ĳв������layer+1��Ĳв�
            if strcmp(net.layers{layer+1}.type,'bn') 
                 net.layers{layer}.dw =  net.layers{layer}.znorm_delta * (net.layers{layer}.input)'/ batchnum;  %Ȩֵ�ݶ� 
                 net.layers{layer}.db = mean(net.layers{layer}.znorm_delta, 2);  %ƫ���ݶ�
            else
                net.layers{layer}.dw = net.layers{layer+1}.delta * (net.layers{layer}.input)' / batchnum; %Ȩֵ�ݶ� 
                net.layers{layer}.db = mean(net.layers{layer+1}.delta, 2);  %ƫ���ݶ�
            end
            if strcmp(net.layers{layer+1}.type,'loss') && strcmp(net.layers{layer+1}.function,'softmax') %,�����softmax��ʧ�����������Ȩֵ˥����
                net.layers{layer}.dw = net.layers{layer}.dw + lambda * net.layers{layer}.w;
            end
    end
end