%                   Example.m
%---------------------------------------------------
%
%          Dr. Joakim Munkhammar, PhD 2023
%
% This program is an example program for generating
% scenario forecasts using the MCM scenario model
%

% Importing a data set for training
Train = importdata('Train.txt');

% Calculate scenarios based on training data 'Train', 
% observation point 'Obs' observation, set 
M = 30; % Number of states
N = 40; % Number of scenarios
K = 1000; % Number of points to forecast
Obs = 0.9; % The data point to forecast from
Scenarios = MCMScenarios(Train,Obs,M,N,K,'ECDF'); % The main routine

% Adding the observation point for plotting
Scenarios2 = ones(N,K+1);
Scenarios2(:,1) = Obs;
Scenarios2(:,2:K+1) = Scenarios;

% Plot the results
figure(1)
for i=1:N
    plot(1:K+1,Scenarios2(i,:),'LineWidth',2)
    hold on
end
p = plot(1,Obs,'o','color','k','linewidth',5)
p.MarkerFaceColor = [1 0.5 0];
p.MarkerSize = 10;
xlim([1 K])
xlabel('Time steps')
ylabel('Values')