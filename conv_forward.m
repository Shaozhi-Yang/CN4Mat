function outputMap = conv_forward(inputMap,convlayer)
%inputMap ����ͼcell��ʽ��cell(inputmaps), e.g. size(cell(1)) = [height*width*datanum]
%convlayer �����(����)
%outputMap ���������������cell��ʽ
%ע��
%convlayer.z = conv(convlayer.w,prerlayer.a)
%convlayer.a = convlayer.z

inputmaps = numel(inputMap); %����inputmaps��Ŀ
batchnum = size(inputMap{1},3);  %����inputmaps��С
outputsize = convlayer.mapsize ;  %featuremaps�ĳߴ�
outputMap = cell(convlayer.featuremaps,1);   %Ԥ�ȿ���featuremaps�Ĵ洢�ռ�
for i = 1 : convlayer.featuremaps   %����˵���Ŀ����featuremaps��Ŀ
    convtemp = zeros(outputsize(1),outputsize(2),batchnum);  %��ʱ����������һ��inputmap�����Ľ��featuremaps
    for j = 1:inputmaps
        z = convn(padarray(inputMap{j,1},[convlayer.pad,0]),rot180(convlayer.w{i,j}),'valid'); %һ����������ξ��ÿһ��inputmaps(������貽��Ϊ1)
        %����������еľ����ʵ����ѧ�����ϵ����corr����������������Ҫ�����Ƿ�ת����ˡ�
        %convn�������Զ���ת�����,����ҪԤ����תһ��
        convtemp = convtemp + z(1:convlayer.stride(1):end,1:convlayer.stride(2):end,:); %���ݲ�������,�����(Ȩֵ�������)
    end
    outputMap{i,1} = convtemp +convlayer.b{i,1}; %��ƫ�ã������ԣ�
end