% this code is used for perform combat for ABIDE datasets
% Li-Xia Yuan, 20210408

%% initilization
clear all;close all;clc;
metrics={'GretnaSFCMatrixZ'}; % change it accordingly
[xlsfile,xlspath,FILTERINDEX]=uigetfile('*.xlsx','information xlsx');%['J:\XIUQIN\排除被试名单（分中心）\']
Path=uigetdir('E:\data\116\FC_No_Combat','choose folder contains all the centers');%
pathout=uigetdir('E:\data\116\FC_Combat','choose output folder');%
centers=dir(Path); centers=centers(3:end,:);
dim=[116 116];
ind_l=ones(dim);ind_l=tril(ind_l,-1);ind_l=find(ind_l>0); % Extract lower triangular part

%% get the total number of subjects, diagnosis, and batch information
count=0;ba






\\\
dbv cb  



wv 
/d/. \[wrk09j-0wiovldacsZ>vs;s]vpsfv

for j=1:size(centers,1)
    [num,txt,raw]=xlsread([xlspath,filesep,xlsfile],centers(j).name);%sheet
    subname=raw(:,3); % subject name
    group=cell2mat(raw(:,3));
    batch=cat(1,batch,j*ones(size(subname,1),1));
    cov=cat(1,cov,raw);
    count=count+size(raw,1);
end
cov=cell2mat(cov(:,3:8));
% dummyvar diag, sex
diag=cov(:,1);diag=dummyvar(diag);cov(:,1)=diag(:,2);
sex=cov(:,3);sex=dummyvar(sex);cov(:,3)=sex(:,2);
cov=cov(:,[1 2 3 5 6]);
data=zeros(length(ind_l),count,size(metrics,1));

%% read all the metrics
for i=1:size(metrics,1);
    count=0;
    % read all the  metrics files from all the centers
    for j=1:size(centers,1)
        [num,txt,raw]=xlsread([xlspath,filesep,xlsfile],centers(j).name);%sheet
        subname=raw(:,2); % subject name
        metricpath=[Path,filesep,centers(j).name,filesep,metrics{i}];
        mkdir([pathout,filesep,centers(j).name,filesep,metrics{i}]);
        subject=dir([metricpath,filesep,'*.txt']);
        for k=1:size(subname,1)
            count=count+1;
            namenumber =num2str(subname{k,1});
            tf=strfind({subject.name},namenumber);%cell
            filedelete=cellfun('isempty',tf);%logical
            ind=find( filedelete<1);
            subimage=[metricpath,filesep,subject(ind).name];
            [PATHSTR,NAME,EXT] =fileparts(subject(ind).name);
            subnewname{count,i}=[pathout,filesep,centers(j).name,filesep,metrics{i},filesep,NAME,'.mat'];
            temp =textread(subimage);
            size(temp)
            temp=temp(:,1:dim(2));
            data(:,count,i)=temp(ind_l);
        end
    end
end
data(find(isinf(data)))=0;
data(find(isnan(data)))=0;
%%
% save('combat_data_0504.mat','data','count','maskind','subnewname','metrics','head','cov','batach');
%% do combat on the metric and write into text file
% load combat_data1.mat;
% data=data2;
for i=1:size(metrics,1);
    temp1=squeeze(data(:,:,i));
    datacom = combat(temp1, batch, cov,0);
    % write all the data into text file
    for m=1:count
        temp=datacom(:,m);
        temp2=zeros(dim);
        temp2(ind_l)=temp;
        temp2=temp2+temp2';
        Z=temp2;
        save (subnewname{m,i},'Z') ;
    end
end



