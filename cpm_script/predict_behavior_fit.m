function [true_predict_r_pos, true_predict_r_neg, consensus_feature] = predict_behavior_fit(all_mats,all_behav,thresh)
warning off;

function [true_predict_r_pos, true_predict_r_neg, consensus_feature] = predict_behavior_fit(all_mats,all_behav,thresh)
warning off;

%��ñ����������ڵ�����
no_sub = size(all_mats,3);
no_node = size(all_mats,1);

%���������飨ֵΪ0�������������洢ģ���ڲ��Լ��ϵ�Ԥ�������Լ�����һ���������������ڶ�����������
behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);
consensus_feature = zeros(no_node,no_node,no_sub);

%������һ������֤������ģ�;���
for leftout = 1:no_sub
    
    %��ӡ����һ������
    fprintf('\n Leaving out subj # %f', leftout);
    %�õ�ѵ����������һ�������޳�
    train_mats = all_mats;
    train_mats(:,:,leftout) = []; 
    %����ѵ��������FC����չ����һ����������������ʵ�����ݣ����ճߴ�Ϊ8100*77
    train_vcts = reshape(train_mats,[],size(train_mats,3));  
    %�õ�����÷֣�������ǩ������������һ�����ĵ÷�ɾ��������ʵ�����ݣ����ճߴ�Ϊ77*1
    train_behav = all_behav; 
    train_behav(leftout) = [];
    
    %����ÿ������������÷ֵ����ֵ
    [r_mat,p_mat] = corr(train_vcts',train_behav);
    %���ż�����صõ���rֵ��pֵ������ʵ�����ݣ�����Ϊ90*90
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    %�������������飬����������ʾ�����������Ӻ͸�����
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    %�ҵ�FC>0����������������ص�����
    pos_edges = find(r_mat > 0 & p_mat < thresh); 
    %�ҵ�FC<0����������������ص�����
    neg_edges = find(r_mat < 0 & p_mat < thresh);  
    %��ֵ����������������ص�������1��������0,�õ����������ߵ�mask
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    
    %���ڱ���fold���õ�����������������mask�Ĳ���
    consensus_feature(:,:,leftout) = 1*pos_mask + (-1)*neg_mask;
    
    %�������������飬���������洢��������������FC�ĺ�
    train_sumpos = zeros(no_sub-1,1);
    train_sumneg = zeros(no_sub-1,1);
    %������һ֮����������������ÿһ����������������������FC�ĺͣ�����2����Ϊ�����ǶԳƵ�
    for ss=1:size(train_sumpos)
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end
    %ʹ��polyfit������һ�ζ���ʽģ�ͣ���ѵ������������÷ֽ�����ϣ����ϵ��
    %�ڱ�ʾ�������У��ֱ�ʹ����������������FC�ĺ����������
    fit_pos = polyfit(train_sumpos, train_behav,1);
    fit_neg = polyfit(train_sumneg, train_behav,1);

    %ȡ����һ�Ĳ���������������������������������֮��
    test_mat = all_mats(:,:,leftout);
    test_sumpos = sum(sum(test_mat.*pos_mask))/2;
    test_sumneg = sum(sum(test_mat.*neg_mask))/2;
    
    %ʹ����ϳ���������ģ��Ԥ����Ϊ�÷�
    behav_pred_pos(leftout) = fit_pos(1)*test_sumpos+fit_pos(2);
    behav_pred_neg(leftout) = fit_neg(1)*test_sumneg+fit_neg(2);
end


%�����������ڶ����������ߣ����ղű���Ϊmask
consensus_feature = double(mean(consensus_feature,3)==1) + (-1)*double(mean(consensus_feature,3)==-1);

%����ģ��Ԥ��ľ��ȣ�ͬ��ʹ��Pearson Correlation������
true_predict_r_pos = corr(behav_pred_pos, all_behav);
true_predict_r_neg = corr(behav_pred_neg, all_behav);

figure(1); plot(behav_pred_pos, all_behav,'r*');lsline;
figure(2); plot(behav_pred_neg, all_behav,'b*'); lsline;
end