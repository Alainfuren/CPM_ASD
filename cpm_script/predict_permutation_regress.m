clear all;

path1      = spm_select(1,'dir','please data dir');
file1         = dir([path1,filesep, '*.mat']);
for i=1:length(file1)
    load([path1,filesep,file1(i).name]);
    Z(isnan(Z)) = 0;
    Z(Z==Inf)    = 0;
    Z(Z==-Inf)   = 0;
    all_mats(:,:,i) = Z; clear Z
end
load panas_score.txt; all_behav = panas_score(:,1);

no_sub = size(all_mats,3);
thresh = 0.001;

%同时用正、负连边的FC之和来预测量表得分
[true_prediction_r, consensus_feature] = predict_behavior_regress(all_mats, all_behav,thresh);

no_iteration = 1000;
prediction_r = zeros(no_iteration,2);
prediction_r(1) = true_prediction_r;
h = waitbar(0,'please wait..');
for it=2:no_iteration
    waitbar(it/no_iteration,h,[num2str(it),'/',num2str(no_iteration)]);
    fprintf('\n Performing iteration %d out of %d',it, no_iteration);
    new_behav = all_behav(randperm(no_sub));
    prediction_r(it) = predict_behavior_regress(all_mats, new_behav,thresh);
end
close(h);

pval_pred = mean(prediction_r >= true_prediction_r);

