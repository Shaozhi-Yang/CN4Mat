% B=flip(A,dim)
% previous version: flipdim
% A��ʾһ������dimָ����ת��ʽ��
% dimΪ1����ʾÿһ�н����������У�
% dimΪ2����ʾÿһ�н����������С�
function X = rot180(X)
X = flip(flip(X, 1), 2);
end