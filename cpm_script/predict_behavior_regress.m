function [true_predict_r, consensus_feature] = predict_behavior_regress(all_mats,all_behav,thresh)
warning off;
no_sub = size(all_mats,3);
no_node = size(all_mats,1);
behav_pred = zeros(no_sub,1);
consensus_feature = zeros(no_node,no_node,no_sub);
for leftout = 1:no_sub
    fprintf('\n Leaving out subj # %f', leftout);
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    train_behav = all_behav;
    train_behav(leftout) = [];
    
    [r_mat,p_mat] = corr(train_vcts',train_behav);
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    pos_edges = find(r_mat > 0 & p_mat < thresh);
    neg_edges = find(r_mat < 0 & p_mat < thresh);
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    consensus_feature(:,:,leftout) = 1*pos_mask + (-1)*neg_mask;
    
    train_sumpos = zeros(no_sub-1,1);
    train_sumneg = zeros(no_sub-1,1);
    for ss=1:size(train_sumpos)
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end

    b = regress(train_behav,[train_sumpos, train_sumneg, ones(no_sub-1,1)]);
    
    test_mat = all_mats(:,:,leftout);
    test_sumpos = sum(sum(test_mat.*pos_mask))/2;
    test_sumneg = sum(sum(test_mat.*neg_mask))/2;
    
    behav_pred(leftout) = b(1)*test_sumpos + b(2)*test_sumneg + b(3);
end
consensus_feature = double(mean(consensus_feature,3)==1) + (-1)*double(mean(consensus_feature,3)==-1);

true_predict_r = corr(behav_pred, all_behav);

end
