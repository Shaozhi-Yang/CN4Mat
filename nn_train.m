function net = nn_train(net, data, label, opts)
% net: ����ṹ
% data��ѵ������
% label��ѵ�����ݶ�Ӧ��ǩ
% opts������ѵ��������������
% opts.batchnum ����С
% opts.numepochs ��������
% opts.alpha ѧϰ��
% opts.momentum ������

datanum = size(data, 3);  %ѵ����������
disp(['num of data = ' num2str(datanum)]);
batch_itr = floor(datanum / opts.batchnum);  
interval = ceil(opts.numepochs/3) + 1;
inc = 1;
momentum = [0.9,0.95,0.99]; %������ÿ����interval����ʱ����һ��
time = zeros(opts.numepochs,1);  %��������ʱ��
cost = zeros(opts.numepochs*batch_itr,1); %��ʾ��ѵ�����
loss = zeros(opts.numepochs*batch_itr,1); %��ʵ��¼ѵ�����
for epoch = 1 : opts.numepochs  %����ÿ�ε���
    disp(['>>>epoch ' num2str(epoch) '/' num2str(opts.numepochs) ':']);
    fprintf('learning rate = %f \n',opts.alpha);
    fprintf('momentum = %f \n',opts.momentum);
    tic;  % ��ʱ
    if rem(epoch,interval)==0
        opts.momentum = momentum(inc); %ÿinterval�ε�������һ�ζ�����
        inc= inc + 1;
    end
    if rem(epoch,10)==0
        opts.alpha = opts.alpha * 0.2; %ÿ10�ε�������һ��ѧϰ����
    end
    index = randperm(datanum);  %��������
    for itr = 1 : batch_itr
        %����ȡ��ÿһ��ѵ���õ�����
        batch_x = data(:, :, index((itr - 1) * opts.batchnum + 1 : itr * opts.batchnum));
        batch_y = label(:,index((itr - 1) * opts.batchnum + 1 : itr * opts.batchnum));
        %ǰ�����
        net = nn_forward(net, batch_x, 'train');
        %���򴫲�
        net = nn_backward(net, batch_y);
        %����Ȩֵ����
        net = nn_weight_update(net, opts);
        %���ۺ���ֵ�������ۼ�
        loss((epoch-1)*batch_itr + itr) = net.loss; %��ʵ��¼ÿһ�ε���ʧ
        cost((epoch-1)*batch_itr + itr) = 0.99*cost(end) + 0.01*net.loss; %��ʾ�ã���loss���߸�ƽ��
    end
    time(epoch,1) = toc;
    fprintf('cost = %f \n',cost(end));
    disp(['runing time��',num2str(toc),'s']);
end
plot(cost);title('loss function');
save('training_procedure.mat','loss','time','net','opts');
end