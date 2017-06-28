function outputMap = deconv_forward(inputMap,deconvlayer)
%inputMap ����ͼcell��ʽ��cell(inputmaps), e.g. size(cell(1)) = [height*width*datanum]
%deconvlayer ת�þ����(����)
%outputMap ת�þ��������������cell��ʽ
%ע��
%deconvlayer.z = deconv(deconvlayer.w,prerlayer.a)
%deconvlayer.a = deconvlayer.z

inputmaps = numel(inputMap); %����inputmaps��Ŀ
inputsize = size(inputMap{1});  %����inputmaps��С
mapsize = inputsize(1:2);
batchnum = inputsize(3);
outputsize = deconvlayer.mapsize ;  %featuremaps�ĳߴ�
outputMap = cell(deconvlayer.featuremaps,1);   %Ԥ�ȿ���featuremaps�Ĵ洢�ռ�
for i = 1 : deconvlayer.featuremaps   %����˵���Ŀ����featuremaps��Ŀ
    convtemp = zeros(outputsize(1),outputsize(2),batchnum);  %��ʱ����������һ��inputmap�����Ľ��featuremaps
    for j = 1:inputmaps %����ͨ����
        padMap = map_padding(inputMap{j,1},mapsize,deconvlayer.kernelsize,deconvlayer.pad,deconvlayer.stride);
        %����mapsize,pad��stride���ǰһ�������featuremaps
        convtemp = convtemp + convn(padMap,rot180(deconvlayer.w{i,j}), 'valid'); %һ����������ξ��ÿһ��inputmaps(����Ϊ1)
        %convn�������Զ���ת�����,����ҪԤ����תһ��
    end
    outputMap{i,1} = convtemp + deconvlayer.b{i,1}; %��ƫ�ã������ԣ�
end
