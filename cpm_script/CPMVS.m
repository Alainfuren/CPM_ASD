% Set the working directory
workpath = 'E:\data\CPM\160\验证\ABIDE II\all';
cd(workpath);

% Define the model expression
a = 1.3564;
b = 5.2677;
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
disp('完成'); 
