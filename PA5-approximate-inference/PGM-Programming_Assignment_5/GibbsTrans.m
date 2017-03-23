% GIBBSTRANS
%
%  MCMC transition function that performs Gibbs sampling.
%  A - The current joint assignment.  This should be
%      updated to be the next assignment
%  G - The network
%  F - List of all factors
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function A = GibbsTrans(A, G, F)

for i = 1:length(G.names)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % For each variable in the network sample a new value for it given everything
    % else consistent with A.  Then update A with this new value for the
    % variable.  NOTE: Your code should call BlockLogDistribution().
    % IMPORTANT: you should call the function randsample() exactly once
    % here, and it should be the only random function you call.
    %
    % Also, note that randsample() requires arguments in raw probability space
    % be sure that the arguments you pass to it meet that criteria
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1. generate a distribution using BlockLogDistribution
    LogBS = BlockLogDistribution(i, G, F, A);
    
% 2. change this distribution back to the raw probability space.
    dist = exp(LogBS)/sum(exp(LogBS));
    
% 3. sample a new variable using randsample.
    %numSamp = 1;
    %replace = true;
    %update A with the result of randsample
    A(i) = randsample(G.card(i),1,true,dist);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endfor

endfunction

%{
Algorithm: 
For all variables i : 
  1. compute BlockLogDistribution
    In the loop, I used the given G,F,A and variable (the index of i) to find the distribution LogBS
  2. Go back to probability space before you call randsample
    For that you have to 1st inverse the log values and 2nd normalize them
  3. call randsample 
    I used the cardinity of the current variable i, the current LogBS to generate one sample v with replacement,
  4. update A with the result of randsample on the right field
    I updated A with index i to be v. That's it. The results are always 2....2, 1....1

Simply iterate over all V=i
V = i
  compute BlockLogDistribution() with V, and A
  taking the exponent to move out of the log space
  normalize by dividing by the summation of the exponent
  sampling (with replacements) with  the provided randsample() , n=1 with cardinality (V) = number of elements in the distribution (expBS),
  updating A(i) with the sampling result and moving to next i
    
%}