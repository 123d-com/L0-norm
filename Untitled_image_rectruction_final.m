close all;                        % �������ռ�
clear;  
tic
[I_noise,map] = imread('lena1.bmp');
I_noise=rgb2gray(I_noise);
[LoD,HiD] = wfilters('bior3.7','d');%С���˲���
[cA,cH,cV,cD] = dwt2(I_noise,LoD,HiD,'mode','symh');
figure, imshow(I_noise);
m=350;
n=400;%��dwt��Ľ��ƾ���ϡ��
k=135;
cA=round(cA./10);
ox=zeros(k,n);
out=zeros(k,n);
final_out=zeros(k,k);
index_all=zeros(k,k);
A=normrnd(0,1,m,n);%����(0,1)��̫�ֲ���ϵ������A
mse = zeros(1,k);
for i=1:k
index=randperm(n,k);%����һ�д�1��n�������е�k����������k����Ҳ�ǲ���ͬ��
index_all(i,:)=index;
for count=1:k
  ox(i,index(count))=cA(i,count);
end
    b=A*ox(i,:)';
    tend=0.01;
    x=rand(n,1);%����n*1���������
    f0=x;
    P=A'*inv(A*A')*A;
    [mp,np]=size(P);
    I=eye(mp);
    Q=A'*inv(A*A')*b;
    [f_result,iteration]=rnn(A,P,Q,I,m,n,f0);
%     [ox(i,:)',f_result(1:n,iteration-1)];
     out(i,:)=f_result(1:n,iteration-1);
     for kk=1:k
     final_out(i,kk)=out(i,index(kk));
     end
toc
end
mse = sum((final_out-cA).^2)./(n^2);
MSE = sum(mse);
PSNR = 10*log10(255^2/MSE);
error = norm(final_out-cA,2)/norm(cA,2);
figure(3)
Y=idwt2(round(final_out)*10,cH,cV,cD,'bior3.7');%���߶ȶ�ά��ɢС���ع�(��任)
imshow(Y,map)
function [df,count]=rnn(A,P,Q,I,m,n,f0)
iteration=60001;
x(:,1)=f0(1:n);
step=0.01;
count=1;
for i=1:iteration
    dx=(2.0*exp(abs(x(:,i))).*sign(x(:,i)))./(exp(abs(x(:,i))) + 1.0).^2;%sigmoid delta=0.1
    x(:,i+1)=x(:,i)+step*(-P*x(:,i)-(I-P)*dx+Q);
    xxx(:,count)=x(:,i+1);
    count=count+1;
end
df=xxx;
end





