% the code for 
% Zheng Hui 
% 20200622 23:18:48 
% zh.dmtr@gmail.com
% ShanghaiMentalHealth,

%% create the data martix
f= dir('z*.mat');% get the mat in this field
flist={f.name};% the mat name
subj  = size(f,1);% number of subjects
load(f(1).name); % load mat
a=Z;
b=size(a,1);% get the martix size

data=zeros(b,b,subj);
cpmr={};
for i=1:subj
    load(f(i).name);
    data(:,:,i)=Z;
    split{i}   = strsplit(flist{i},'_');%split by _
    cpmr{i,1}  = split{i}{1,2}(8:10);%the subject number is the 1st cell(1,1), name(1:4)exp 1001. 
end

%% load mask
load('G:\ÑéÖ¤\ABIDE II\total\matlab.mat', 'consensus_feature');
cf= consensus_feature;

%% calcuate the sum for each condition

for j = 1:subj
    temp=data(:,:,j);
    temp1=temp(cf==1);
    temp11=temp1(temp1>0);
    temp12=temp1(temp1<0);
    temp2=temp(cf==-1);
    temp21=temp2(temp2>0);
    temp22=temp2(temp2<0);
    
    cpmr{j,2}=sum(sum(temp11));%mask= 1, the data is postive
    cpmr{j,3}=sum(sum(temp12));%mask= 1, the data is negative
    cpmr{j,4}=sum(sum(temp21));%mask= 2, the data is postive
    cpmr{j,5}=sum(sum(temp22));%mask= 2, the data is negative
    cpmr{j,6}=sum(temp1>0);% the number of mask= 1, the data is postive
    cpmr{j,7}=sum(temp1<0);% the number of mask= 1, the data is negative
    cpmr{j,8}=sum(temp2>0);% the number of mask= 2, the data is postive
    cpmr{j,9}=sum(temp2<0);% the number of mask= 2, the data is negative
end

save('cpm_rest.mat','cpmr')