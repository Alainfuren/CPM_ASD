% Set the working directory
workpath = '/yourpath';
cd(workpath);

% Define the model expression
a = -0.0082;
b = 5.0721;
model_expression = @(x) a * x + b;

% Read the consensus features matrix
consensus_features = csvread('consensus features.csv');

% Read the actual_value column data
actual_value = load('actual.txt');

% Create an array to store predictive values
predictive_value = zeros(221, 1); 

% Iterate through all CSV files starting with "z_Subject"
csvFileList = dir('z_Subject*.csv');
for i = 1:length(csvFileList)
    % Read the CSV file
    data = csvread(csvFileList(i).name);

    % Use consensus features matrix as a mask, find all "1" positions
    mask = (consensus_features == 1);

    % Extract values at corresponding positions based on the mask and sum them
    x = sum(data(mask));

    % Calculate y
    y = model_expression(x);

    % Store y in predictive_value as a column
    predictive_value(i) = y;
end
disp('Completed');

cov = readtable('cov.csv'); 
all_sex = cov.sex;
all_age = cov.age;
all_mfd = cov.mFD;

% Calculate the correlation between actual_value and predictive_value and uncorrected p-values
[correlation, uncorrected_p_value] = partialcorr(actual_value, predictive_value, [all_sex, all_age, all_mfd]);

% Perform FDR correction
p_adj = mafdr(uncorrected_p_value, 'BHFDR', 0.05);

% Display the correlation, FDR-corrected p-values, and related information
fprintf('Correlation between actual_value and predictive_value: %.4f\n', correlation);
fprintf('FDR-corrected p-values: %.4f\n', p_adj);
