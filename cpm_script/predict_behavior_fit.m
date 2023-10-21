function [true_predict_r_pos, true_predict_r_neg, consensus_feature] = predict_behavior_fit(all_mats, all_behav, thresh)
    warning off;

    % Get the number of subjects and the number of nodes
    no_sub = size(all_mats, 3);
    no_node = size(all_mats, 1);

    % Declare empty arrays (initialized with 0) to store model predictions on the test set and edges significantly present in all samples except one
    behav_pred_pos = zeros(no_sub, 1);
    behav_pred_neg = zeros(no_sub, 1);
    consensus_feature = zeros(no_node, no_node, no_sub);

    % Estimate model accuracy using leave-one-out cross-validation
    for leftout = 1:no_sub

        % Print the left-out subject
        fprintf('\n Leaving out subj # %f', leftout);

        % Obtain the training set and remove the left-out subject
        train_mats = all_mats;
        train_mats(:, :, leftout) = [];

        % Reshape the training set, flattening FC matrices into feature vectors; for the example data, the final size is 8100x77
        train_vcts = reshape(train_mats, [], size(train_mats, 3));

        % Get the behavioral scores ("labels") and remove the score of the left-out subject; for the example data, the final size is 77x1
        train_behav = all_behav;
        train_behav(leftout) = [];

        % Calculate the correlation of each edge with the behavioral score
        [r_mat, p_mat] = corr(train_vcts', train_behav);

        % Reshape the correlation results (r values and p values); for the example data, reshape to 90x90
        r_mat = reshape(r_mat, no_node, no_node);
        p_mat = reshape(p_mat, no_node, no_node);

        % Declare two empty arrays to represent significant positive and negative connections
        pos_mask = zeros(no_node, no_node);
        neg_mask = zeros(no_node, no_node);

        % Find edges with FC>0 and significantly positively correlated with the behavioral score
        pos_edges = find(r_mat > 0 & p_mat < thresh);

        % Find edges with FC<0 and significantly negatively correlated with the behavioral score
        neg_edges = find(r_mat < 0 & p_mat < thresh);

        % Binarize, setting edges significantly correlated with the behavioral score to 1 and others to 0, to obtain positive and negative edge masks
        pos_mask(pos_edges) = 1;
        neg_mask(neg_edges) = 1;

        % For this fold, obtain the sums of positive and negative significant edge FC
        train_sumpos = zeros(no_sub - 1, 1);
        train_sumneg = zeros(no_sub - 1, 1);

        % For all subjects except the left-out one, calculate the sums of positive and negative significant edge FC and divide by 2 since the matrix is symmetric
        for ss = 1:size(train_sumpos)
            train_sumpos(ss) = sum(sum(train_mats(:, :, ss) .* pos_mask)) / 2;
            train_sumneg(ss) = sum(sum(train_mats(:, :, ss) .* neg_mask)) / 2;
        end

        % Use polyfit function (linear model) to fit the training features and behavioral scores, obtaining coefficients
        % In this example, we use the sums of positive and negative significant edge FC for fitting
        fit_pos = polyfit(train_sumpos, train_behav, 1);
        fit_neg = polyfit(train_sumneg, train_behav, 1);

        % Retrieve the test sample left out, and calculate the sums of positive and negative significant edges
        test_mat = all_mats(:, :, leftout);
        test_sumpos = sum(sum(test_mat .* pos_mask)) / 2;
        test_sumneg = sum(sum(test_mat .* neg_mask)) / 2;

        % Use the fitted linear model to predict the behavioral score
        behav_pred_pos(leftout) = fit_pos(1) * test_sumpos + fit_pos(2);
        behav_pred_neg(leftout) = fit_neg(1) * test_sumneg + fit_neg(2);
    end

    % For edges significantly present in all samples, save as a mask
    consensus_feature = double(mean(consensus_feature, 3) == 1) + (-1) * double(mean(consensus_feature, 3) == -1);

    % Evaluate the predictive accuracy of the model, using Pearson Correlation
    true_predict_r_pos = corr(behav_pred_pos, all_behav);
    true_predict_r_neg = corr(behav_pred_neg, all_behav);
end
