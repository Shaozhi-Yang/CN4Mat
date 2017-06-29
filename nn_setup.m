function net = nn_setup(net, inputSize, outputSize)
%net ���綨��
%inputSize ����map�ĳߴ�(height * width * batchnum);
%ע��ÿ������ͼfeaturemap = map * batchnum�� ÿ��map��С��height * width
%outputSize ��ǩ(one of c��ʽ)�ĳߴ磬��c��Ҳ�����������Ԫ�ĸ������ֶ��ٸ��࣬��Ȼ���ж��ٸ������Ԫ
%shape format:[featuremaps,height,width,batchnum]

mapsize = inputSize(1:2); batchnum = inputSize(3);
for layer = 1 : numel(net.layers)   % ��ÿһ������жϲ�����
    switch net.layers{layer}.type
        case 'input' %�����
            net.layers{layer}.featuremaps = 1;   %����������ͼ��1������ԭʼͼ��
            net.layers{layer}.mapsize = mapsize; %����������ͼ��ÿ��slice��С([height,width])
            fprintf('layer:%d-%s\n',layer,'input');
            fprintf('\tshape: [%d, %d, %d, %d]\n',1,inputSize);
        case 'conv' %�����
            if ~isfield(net.layers{layer},'stride')%���δ���岽����Ĭ��Ϊ1
                net.layers{layer}.stride = [1,1];
            elseif size(net.layers{layer}.stride) == 1 %����ֻ������һά����������ά�������
                net.layers{layer}.stride = [net.layers{layer}.stride,net.layers{layer}.stride]; 
            end
            if ~isfield(net.layers{layer},'pad')%���δ�����ⲿ�����Ŀ��Ĭ��Ϊ0
                net.layers{layer}.pad = [0,0];
            elseif size(net.layers{layer}.pad) == 1 %����ֻ������һά�����Ŀ������ά�����Ŀ���
                net.layers{layer}.pad = [net.layers{layer}.pad,net.layers{layer}.pad]; 
            end
            if size(net.layers{layer}.kernelsize) == 1 %����ֻ������һά����ߴ磬�����˿�͸����
                net.layers{layer}.kernelsize = [net.layers{layer}.kernelsize,net.layers{layer}.kernelsize]; 
            end
            pre_judge = net.layers{layer-1}.mapsize + net.layers{layer}.pad - net.layers{layer}.kernelsize; 
            %��ǰһ������ͼֻ�ܽ���һ�ξ����������ͼ+pad�;����ͬ�ߴ磩�����䲽��ֻ���޶�Ϊ1
            if sum(pre_judge) == 0 && (net.layers{layer}.stride(1) > 1 || net.layers{layer}.stride(2) > 1)
                warning('%d-%s -> %d-%s : the convolutional outputmap just has only one element => the stride should less than 1',layer-1,net.layers{layer-1}.type,layer,'conv');
                net.layers{layer}.stride = [1,1];  %����ǿ����1
            end
            net.layers{layer}.mapsize = (net.layers{layer-1}.mapsize + 2 .* net.layers{layer}.pad - net.layers{layer}.kernelsize) ./ net.layers{layer}.stride + 1; 
            %���¾��������ͼ��ÿ��slice��С([height,width])
            assert(all(floor(net.layers{layer}.mapsize)==net.layers{layer}.mapsize), ['Layer ' num2str(layer) ' mapsize must be an integer. Actual: ' num2str(net.layers{layer}.mapsize)]);
            %��������ʱ���������������˴�С
            kernelarea = prod(net.layers{layer}.kernelsize); %����˵������prod������������˻�, eg. prod([1,2,3]) = 1*2*3 = 6;
            fan_out = net.layers{layer}.featuremaps * kernelarea;  %���ӵ���һ�����˵�ȨֵW��������
            fan_in = net.layers{layer-1}.featuremaps * kernelarea;  %���ӵ�ǰһ�����˵�ȨֵW��������
            for i = 1 : net.layers{layer}.featuremaps  %���ھ�����ÿһ��outputmap(���ھ���˵ĸ���)
                for j = 1: net.layers{layer-1}.featuremaps %���ھ����ÿһ��inputmaps(����ǰһ���featuremaps)
                    net.layers{layer}.w{i,j} = (rand(net.layers{layer}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out)); %��ʼ�������Ȩֵ(Xavier����)
                    net.layers{layer}.mw{i,j} = zeros(net.layers{layer}.kernelsize);  %Ȩֵ���µĶ����Ȩֵ������ʼ��Ϊ0
                end
                net.layers{layer}.b{i,1} = 0;  %��ʼ�������ƫ��Ϊ��,ÿ������ͼһ��bias,����ÿ�������һ��bias
                net.layers{layer}.mb{i,1}=0;   %Ȩֵ���µĶ����ƫ�ã�����ʼ��Ϊ0
            end
            fprintf('layer:%d-%s\n',layer,'conv');
            fprintf('\tfeaturemaps: %d\n',net.layers{layer}.featuremaps);
            fprintf('\tkernelsize: [%d, %d]\n',net.layers{layer}.kernelsize);
            fprintf('\tpad: [%d, %d]\n',net.layers{layer}.pad);
            fprintf('\tstride: [%d, %d]\n',net.layers{layer}.stride);
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'deconv' %ת�þ����
             if ~isfield(net.layers{layer},'stride')%���δ���岽����Ĭ��Ϊ1
                net.layers{layer}.stride = [1,1];
            elseif size(net.layers{layer}.stride) == 1 %����ֻ������һά����������ά�������
                net.layers{layer}.stride = [net.layers{layer}.stride,net.layers{layer}.stride]; 
            end
            if ~isfield(net.layers{layer},'pad')%���δ�����ⲿ�����Ŀ��Ĭ��Ϊ0
                net.layers{layer}.pad = [0,0];
            elseif size(net.layers{layer}.pad) == 1 %����ֻ������һά�����Ŀ������ά�����Ŀ���
                net.layers{layer}.pad = [net.layers{layer}.pad,net.layers{layer}.pad]; 
            end
            if size(net.layers{layer}.kernelsize) == 1 %����ֻ������һά����ߴ磬�����˿�͸����
                net.layers{layer}.kernelsize = [net.layers{layer}.kernelsize,net.layers{layer}.kernelsize]; 
            end
            net.layers{layer}.mapsize = (net.layers{layer-1}.mapsize - 1) .* net.layers{layer}.stride + net.layers{layer}.kernelsize - 2 .* net.layers{layer}.pad; 
            %���¾��������ͼ��ÿ��slice��С([height,width])
            assert(all(floor(net.layers{layer}.mapsize)==net.layers{layer}.mapsize), ['Layer ' num2str(layer) ' mapsize must be an integer. Actual: ' num2str(net.layers{layer}.mapsize)]);
            %��������ʱ���������������˴�С
            kernelarea = prod(net.layers{layer}.kernelsize); %����˵������prod������������˻�, eg. prod([1,2,3]) = 1*2*3 = 6;
            fan_out = net.layers{layer}.featuremaps * kernelarea;  %���ӵ���һ�����˵�ȨֵW��������
            fan_in = net.layers{layer-1}.featuremaps * kernelarea;  %���ӵ�ǰһ�����˵�ȨֵW��������
            for i = 1 : net.layers{layer}.featuremaps  %����ת�þ�����ÿһ��outputmap(���ھ���˵ĸ���)
                for j = 1: net.layers{layer-1}.featuremaps %����ת�þ����ÿһ��inputmaps(����ǰһ���featuremaps)
                    net.layers{layer}.w{i,j} = (rand(net.layers{layer}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out)); %��ʼ�������Ȩֵ(Xavier����)
                    net.layers{layer}.mw{i,j} = zeros(net.layers{layer}.kernelsize);  %Ȩֵ���µĶ����Ȩֵ������ʼ��Ϊ0
                end
                net.layers{layer}.b{i,1} = 0;  %��ʼ�������ƫ��Ϊ��,ÿ������ͼһ��bias,����ÿ�������һ��bias
                net.layers{layer}.mb{i,1}=0;   %Ȩֵ���µĶ����ƫ�ã�����ʼ��Ϊ0
            end
            fprintf('layer:%d-%s\n',layer,'deconv');
            fprintf('\tfeaturemaps: %d\n',net.layers{layer}.featuremaps);
            fprintf('\tkernelsize: [%d, %d]\n',net.layers{layer}.kernelsize);
            fprintf('\tpad: [%d, %d]\n',net.layers{layer}.pad);
            fprintf('\tstride: [%d, %d]\n',net.layers{layer}.stride);
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'pool' %�ػ���
            if strcmp(net.layers{layer-1}.type,'pool')
                error('%s -> %s connection is not supported!','pool','pool');%�ػ�����治֧���ٽ�һ���ػ���
            end
            if ~isfield(net.layers{layer},'kernelsize')%���δ����ػ��߶ȣ�����ȫ�������˼�룬������˴�С����Ĭ��Ϊ2
                net.layers{layer}.kernelsize = [2,2];
            elseif size(net.layers{layer}.kernelsize) == 1 %���ֻ������һά�߶ȣ��򲽳���ά���
                net.layers{layer}.kernelsize = [net.layers{layer}.kernelsize,net.layers{layer}.kernelsize]; 
            end
            if sum(net.layers{layer}.kernelsize(:)) <= 2
                error('Pooling Layer %d stride should greater than [1,1] for non-overlapping convoluton!',layer);%�ػ�����治֧���ٽ�һ���ػ���
            end
            net.layers{layer}.stride = net.layers{layer}.kernelsize;  %����˳ߴ缴������non-overlapping��
            net.layers{layer}.featuremaps = net.layers{layer-1}.featuremaps;  %�ػ��������ͼ����featuremaps��ǰһ��һ��
            net.layers{layer}.mapsize = net.layers{layer-1}.mapsize ./ net.layers{layer}.stride;   %���³ػ����featuremaps��ÿ��slice��С
            assert(all(floor(net.layers{layer}.mapsize)==net.layers{layer}.mapsize), ['Layer ' num2str(layer) ' mapsize must be integer. Actual: ' num2str(net.layers{layer}.mapsize)]);
            %��������ʱ���������������
            %ע���ػ������������3�������(1)û�в���(2)��Ȩֵ(Ĭ�ϰ���ƫ��)
            for i = 1 : net.layers{layer}.featuremaps   %���ڲ��ڵ�ÿ������ͼ
                if net.layers{layer}.weight %���ػ�����Ȩֵ
                    net.layers{layer}.w{i,1} = 1;  %��ʼ���ػ����Ȩ��Ϊ1
                    net.layers{layer}.mw{i,1} = 0; %Ȩֵ���µĶ����Ȩֵ������ʼ��Ϊ0
                    net.layers{layer}.b{i,1} = 0;  %��ʼ���ػ����ƫ��Ϊ��
                    net.layers{layer}.mb{i,1} = 0;  %Ȩֵ���µĶ����ƫ�ã�����ʼ��Ϊ0
                end
            end
            fprintf('layer:%d-%s\n',layer,'pool');
            fprintf('\tfeaturemaps: %d\n',net.layers{layer}.featuremaps);
            fprintf('\tkernelsize: [%d, %d]\n',net.layers{layer}.kernelsize);
            fprintf('\tstride: [%d, %d]\n',net.layers{layer}.stride);
            fprintf('\tmethod: %s\n',net.layers{layer}.method);
            fprintf('\tweight: %d\n',net.layers{layer}.weight);
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'bn' %batch normalization��
            if strcmp(net.layers{layer-1}.type,'bn')
                error('%s -> %s connection is not supported!','bn','bn');%bn����治֧���ٽ�һ��bn��
            end
            net.layers{layer}.featuremaps = net.layers{layer-1}.featuremaps;  %BN�������ͼ����featuremaps��ǰһ��һ��
            net.layers{layer}.mapsize = net.layers{layer-1}.mapsize;   %����ͼÿ��slice�Ĵ�СҲһ��
            net.layers{layer}.gamma = ones(net.layers{layer}.featuremaps,1);   %��ʼ��ӳ���ع�ȨֵgammaΪ1
            net.layers{layer}.mgamma = zeros(net.layers{layer}.featuremaps,1);  %��ʼ��ӳ���ع�Ȩֵ��Ķ�����Ϊ0
            net.layers{layer}.beta = zeros(net.layers{layer}.featuremaps,1);    %��ʼ��ӳ���ع�ƫ��betaΪ0
            net.layers{layer}.mbeta = zeros(net.layers{layer}.featuremaps,1);   %��ʼ��ӳ���ع�Ȩֵ�Ķ�����Ϊ0
            net.layers{layer}.epsilion = 1e-10; %��׼��ƽ����
            %��־λflag������Ǽ�bn���ھ���㣨0���У�������ȫ���Ӳ㣨1����
            if sum(net.layers{layer}.mapsize) == 2
                %������bn���ھ�����У�����mapsizeҲ��[1,1]
                if strcmp(net.layers{layer-1}.type,'conv') 
                    net.layers{layer}.flag = 0;
                elseif strcmp(net.layers{layer-1}.type,'pool')
                    net.layers{layer}.flag = 0;
                elseif strcmp(net.layers{layer-1}.type,'actfun') && net.layers{layer-1}.flag == 0
                    net.layers{layer}.flag = 0;
                else
                    net.layers{layer}.flag = 1; %��ȫ���Ӳ���
                end
            else
                net.layers{layer}.flag = 0;
            end
            if net.layers{layer}.flag
                net.layers{layer}.all_mean = []; %��¼ÿһ��batch�ľ�ֵ
                net.layers{layer}.all_var = [];  %��¼ÿһ��batch�ķ���
            else
                 for i=1:net.layers{layer}.featuremaps
                      net.layers{layer}.all_mean{i,1} =[];  %��¼ÿһ��batch�ľ�ֵ
                      net.layers{layer}.all_var{i,1} =[];   %��¼ÿһ��batch�ķ���
                 end
            end
            fprintf('layer:%d-%s\n',layer,'bn');
            fprintf('\tflag: %d\n',net.layers{layer}.flag);
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'actfun' %�������
            if strcmp(net.layers{layer-1}.type,'actfun')
                error('%s -> %s connection is not supported!','actfun','actfun');%���������治֧���ٽ�һ���������
            end
            if ~isfield(net.layers{layer},'function')%���δ���弤�����Ĭ��Ϊsigmoid
                net.layers{layer}.function = 'sigmoid';
            end
            net.layers{layer}.featuremaps = net.layers{layer-1}.featuremaps;  %������������ͼ����featuremaps��ǰһ��һ��
            net.layers{layer}.mapsize = net.layers{layer-1}.mapsize;   %����ͼÿ��slice�Ĵ�СҲһ��
            %��־λflag������Ǽ�actfun���ھ���㣨0���У�������ȫ���Ӳ㣨1����
            if sum(net.layers{layer}.mapsize) == 2
                %������actfun���ھ�����У�����mapsizeҲ��[1,1]
                if strcmp(net.layers{layer-1}.type,'conv') 
                    net.layers{layer}.flag = 0;
                elseif strcmp(net.layers{layer-1}.type,'pool')
                    net.layers{layer}.flag = 0;
                elseif strcmp(net.layers{layer-1}.type,'bn') && net.layers{layer-1}.flag == 0
                    net.layers{layer}.flag = 0;
                else
                    net.layers{layer}.flag = 1; %��ȫ���Ӳ���
                end
            else
                net.layers{layer}.flag = 0;
            end
            fprintf('layer:%d-%s\n',layer,'actfun');
            fprintf('\tflag: %d\n',net.layers{layer}.flag);
            fprintf('\tfunction: %s\n',net.layers{layer}.function);
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'fc'  %ȫ���Ӳ�
            fcnum = prod(net.layers{layer-1}.mapsize) * net.layers{layer-1}.featuremaps;
            %fcnum ��ǰ��һ�����Ԫ����,��һ�����һ������Ǿ���㡢�ػ����BN�㣬������net.layers{layer-1}.featuremaps������ͼ,ÿ������ͼ�Ĵ�С��net.layers{layer-1}.mapsize
            %���ԣ��ò����Ԫ������ ����map��Ŀ * ÿ������map�Ĵ�С���ߺͿ�->��ȫ���Ӳ��ǰһ���Ǿ���㡢�ػ����BN�㣬�򳤺Ϳ���ܴ���1������ȫ���Ӳ㣬�򳤺Ϳ��Ϊ1��
            %�˲����ֳ�ʸ�����������Ĺ�դ�㣩
            net.layers{layer}.mapsize = [1,1];  %ȫ���Ӳ�ÿ����Ԫ�ĳߴ��Ϊ1*1
            net.layers{layer}.w= (rand(net.layers{layer}.featuremaps, fcnum) - 0.5) * 2 * sqrt(6 / (net.layers{layer}.featuremaps + fcnum));   %��ʼ��ȫ���Ӳ�Ȩֵ(Xavier����)
            net.layers{layer}.mw = zeros(net.layers{layer}.featuremaps, fcnum);  %Ȩֵ���µĶ������ʼ��Ϊ0
            net.layers{layer}.b= zeros(net.layers{layer}.featuremaps, 1);  %��ʼ��ȫ���Ӳ�ƫ��Ϊ0
            net.layers{layer}.mb = zeros(net.layers{layer}.featuremaps, 1);  %ƫ�ø��µĶ������ʼ��Ϊ0
            fprintf('layer:%d-%s\n',layer,'fc');
            fprintf('\tweight_size: [%d, %d]\n',size(net.layers{layer}.w));
            fprintf('\tshape: [%d, %d, %d, %d]\n',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        case 'loss'  %��ʧ��,�����һ��,ֻ��һ���������ǰһ�������ȫ���Ӳ�
            if ~strcmp(net.layers{layer-1}.type,'fc')
                error('a fc layer with outputsize of %d is required before loss layer, please add it!',outputSize);
            end
            if net.layers{layer-1}.featuremaps ~= outputSize
                error('the fc layer before loss layer should have the ''featuremaps'' of ''outputSize'', please fix it!');
            end
            if ~isfield(net.layers{layer},'function')%���δ���弤�����Ĭ��Ϊsigmoid
                net.layers{layer}.function = 'sigmoid';
            end
            net.layers{layer}.featuremaps = 1;  %����������ͼ��1������label
            net.layers{layer}.mapsize = [outputSize,1]; %������ÿ��slice��С,[height = outputSize, width =1]
            fprintf('layer:%d-%s\n',layer,'loss');
            fprintf('\tshape: [%d, %d, %d, %d]\n ',net.layers{layer}.featuremaps,net.layers{layer}.mapsize,batchnum);
        otherwise
            error('undefined type of layer!');
    end
end