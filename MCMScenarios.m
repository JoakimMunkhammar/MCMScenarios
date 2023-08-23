%                       MCMScenarios.m
%---------------------------------------------------------------
%                 Dr. Joakim Munkhammar, PhD
%
% This function generates output scenarios from 
% the MCM ECDF model given inputs.
%
% InData = The input data 
% M = Number of states (>0)
% N = Number of scenarios (>0)
% K = Number of forecasts ahead (>0)
% A is setting 'ECDF' or 'Uniform' for choice of emission 
% distribution
%
% Setting N=1 gives Climatology scenarios (random sampling)

function [Scenarios] = MCMScenarios(InData,ForecastPoint,M,N,K,A)

% Failsafe if not having properly formatted type of distribution A
if ~(strcmp(A,'Uniform')||strcmp(A,'ECDF'))
    disp('Warning, use setting Uniform or ECDF, ECDF is default')
    A = 'ECDF';
end

% NaN-warning on input data
if sum(isnan(InData)>0)
    disp('Input data contains NaN')
end

% Initial settings 
Prob=0.0000000001;% P_b, base probability in transition matrix
ScenNum = N; % The number of scenarios
ForecastNum = K; % The number of steps ahead to forecast

% Discretize data to states
State=floor(M*InData/max(InData))+1; % Make State the discrete "state" time-series
State(State<1)=20;
State(State>M)=M;

% Set the observation point
ObsState=floor(M*ForecastPoint/max(InData))+1;
if ObsState>M
    ObsState = M;
    disp('Observation point > max of training data')
end
if ObsState<1
    ObsState = 1;
    disp('Observation point < min of training data')
end

% Calculate the transition matrix P
P=zeros(M,M);
for t=1:size(InData,2)-1 % Train the transition matrix P
    P(State(t),State(t+1)) = P(State(t),State(t+1))+1;
end
% Adding the carpet of transition probabilities
P=P+Prob*ones(M,M);

% Create the ECDF random generator in each step.
T = K*N;% Number of time-steps

if strcmp(A,'ECDF')
    RandAll = zeros(M,T); 
    for i=1:M % The code for generating random ECDF samples
        if size(InData(find(State==i)),2)>1 % Failsafe for empty bins
            RandAll(i,:) = randsample(InData(find(State==i)),T,true);
        else % If bins are empty, then use regular N-state
            RandAll(i,:) = min(InData)+(max(InData)-min(InData))*rand(T,1);
        end
    end
end
    
% The main loop for generating scenarios
NewDistScenarios = zeros(ScenNum,K);
for j=1:ScenNum            
    position = ObsState;
    for t=1:ForecastNum  % The loop for creating output time-series NewDist
        Pnew2 = squeeze(P(position,:))./sum(sum(squeeze(P(position,:))));
        Prow = zeros(M,1);
        for i=1:M % Define the CDF of the transition matrix
            Prow(i+1) = sum(Pnew2(1:i));
        end  
        position = find(Prow(:)<rand(1),1,'last');  % Sample from the CDF
        if strcmp(A,'ECDF')
            NewDistScenario(j,t) = RandAll(position,t*j);            
        else
            NewDistScenario(j,t) = min(All) + (max(All)-min(All))*(position-1)/M+(1/M)*(max(All)-min(All))*rand(1,1); 
        end
    end                  
end

% Returning the scenarios
Scenarios = NewDistScenario;