function [true_predict_r_pos, true_predict_r_neg, consensus_feature] = predict_behavior_fit(all_mats,all_behav,thresh)
warning off;

function [true_predict_r_pos, true_predict_r_neg, consensus_feature] = predict_behavior_fit(all_mats,all_behav,thresh)
warning off;

%求得被试数量、节点数量
no_sub = size(all_mats,3);
no_node = size(all_mats,1);

%声明空数组（值为0），后续用来存储模型在测试集上的预测结果、以及除留一样本外所有样本内都显著的连边
behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);
consensus_feature = zeros(no_node,no_node,no_sub);

%利用留一交叉验证法估计模型精度
for leftout = 1:no_sub
    
    %打印出留一的样本
    fprintf('\n Leaving out subj # %f', leftout);
    %得到训练集并将留一的样本剔除
    train_mats = all_mats;
    train_mats(:,:,leftout) = []; 
    %重排训练集，将FC矩阵展开成一行特征向量；对于实例数据，最终尺寸为8100*77
    train_vcts = reshape(train_mats,[],size(train_mats,3));  
    %得到量表得分（即“标签”），并将留一样本的得分删除；对于实例数据，最终尺寸为77*1
    train_behav = all_behav; 
    train_behav(leftout) = [];
    
    %计算每条连边与量表得分的相关值
    [r_mat,p_mat] = corr(train_vcts',train_behav);
    %重排计算相关得到的r值和p值；对于实例数据，重排为90*90
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    %声明两个空数组，后续用来表示显著的正连接和负连接
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    %找到FC>0且与量表显著正相关的连边
    pos_edges = find(r_mat > 0 & p_mat < thresh); 
    %找到FC<0且与量表显著负相关的连边
    neg_edges = find(r_mat < 0 & p_mat < thresh);  
    %二值化，与量表显著相关的连边置1，其他置0,得到正、负连边的mask
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    
    %对于本次fold，得到的正、负显著连边mask的并集
    consensus_feature(:,:,leftout) = 1*pos_mask + (-1)*neg_mask;
    
    %声明两个空数组，后续用来存储正、负显著连边FC的和
    train_sumpos = zeros(no_sub-1,1);
    train_sumneg = zeros(no_sub-1,1);
    %对于留一之外的其他样本，求得每一个样本的正、负显著连边FC的和，除以2是因为矩阵是对称的
    for ss=1:size(train_sumpos)
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end
    %使用polyfit函数（一次多项式模型）对训练特征和量表得分进行拟合，求得系数
    %在本示例代码中，分别使用正、负显著连边FC的和来进行拟合
    fit_pos = polyfit(train_sumpos, train_behav,1);
    fit_neg = polyfit(train_sumneg, train_behav,1);

    %取出留一的测试样本，并求其正、负显著连边数量之和
    test_mat = all_mats(:,:,leftout);
    test_sumpos = sum(sum(test_mat.*pos_mask))/2;
    test_sumneg = sum(sum(test_mat.*neg_mask))/2;
    
    %使用拟合出来的线性模型预测行为得分
    behav_pred_pos(leftout) = fit_pos(1)*test_sumpos+fit_pos(2);
    behav_pred_neg(leftout) = fit_neg(1)*test_sumneg+fit_neg(2);
end


%在所有样本内都显著的连边，最终才保存为mask
consensus_feature = double(mean(consensus_feature,3)==1) + (-1)*double(mean(consensus_feature,3)==-1);

%评估模型预测的精度，同样使用Pearson Correlation来评估
true_predict_r_pos = corr(behav_pred_pos, all_behav);
true_predict_r_neg = corr(behav_pred_neg, all_behav);

figure(1); plot(behav_pred_pos, all_behav,'r*');lsline;
figure(2); plot(behav_pred_neg, all_behav,'b*'); lsline;
end