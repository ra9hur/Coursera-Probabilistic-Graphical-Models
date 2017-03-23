% CLUSTERGRAPHCALIBRATE Loopy belief propagation for cluster graph calibration.
%   P = CLUSTERGRAPHCALIBRATE(P, useSmart) calibrates a given cluster graph, G,
%   and set of of factors, F. The function returns the final potentials for
%   each cluster. 
%   The cluster graph data structure has the following fields:
%   - .clusterList: a list of the cluster beliefs in this graph. These entries
%                   have the following subfields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
%             and j share an edge.
%  
%   UseSmart is an indicator variable that tells us whether to use the Naive or Smart
%   implementation of GetNextClusters for our message ordering
%
%   See also FACTORPRODUCT, FACTORMARGINALIZATION
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function [P MESSAGES resid] = ClusterGraphCalibrate(P,useSmartMP)

if(~exist('useSmartMP','var'))
  useSmartMP = 0;
end

N = length(P.clusterList);

cardinality = zeros(1,N);
for i = 1:N
	var = P.clusterList(i).var;
	card = P.clusterList(i).card;
	for j = 1:length(var)
		cardinality(var(j)) = card(j);
	endfor
endfor

MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
[edgeFromIndx, edgeToIndx] = find(P.edges ~= 0);

resid = [];

for m = 1:length(edgeFromIndx),
    i = edgeFromIndx(m);
    j = edgeToIndx(m);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %
    %
    %
    % Set the initial message values
    % MESSAGES(i,j) should be set to the initial value for the
    % message from cluster i to cluster j
    %
    % The matlab/octave functions 'intersect' and 'find' may
    % be useful here (for making your code faster)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    MESSAGES(i,j).var = intersect(P.clusterList(i).var,P.clusterList(j).var);
    MESSAGES(i,j).card = cardinality(MESSAGES(i,j).var);
    MESSAGES(i,j).val = ones(1,prod(MESSAGES(i,j).card));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;



% perform loopy belief propagation
tic;
iteration = 0;

% lastMESSAGES = MESSAGES;
lastMESSAGES = MESSAGES;

while (1),
    iteration = iteration + 1;
    [i, j] = GetNextClusters(P, MESSAGES,lastMESSAGES, iteration, useSmartMP); 
    prevMessage = MESSAGES(i,j);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % We have already selected a message to pass, \delta_ij.
    % Compute the message from clique i to clique j and put it
    % in MESSAGES(i,j)
    % Finally, normalize the message to prevent overflow
    %
    % The function 'setdiff' may be useful to help you
    % obtain some speedup in this function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    messages(i,j) = FactorProduct(P.clusterList(i),messages(i,j));    
    MESSAGES(i,j) = P.clusterList(i);

%i. Multiply everything that needs to be multiplied (ie. all IN messages and the factor)
	  others = P.edges(:,i);
    others(j) = 0;    % Ignoring messages that cluster j (receiver) had sent cluster i (sender)
	  for x = 1:N
		  if others(x)==1
				MESSAGES(i,j) = FactorProduct(MESSAGES(i,j),MESSAGES(x,i));
		  endif
	  endfor

%ii. Marginalize to remove the set difference
    % you marginalize out all the variables that are not in common between the sending and receiving cliques)
	  summedout = setdiff(P.clusterList(i).var,P.clusterList(j).var);   % All other variables other than in sepset
		MESSAGES(i,j) = FactorMarginalization(MESSAGES(i,j),summedout);

%iii. Normalize .val to sum to 1
	  total = sum(MESSAGES(i,j).val);
	  MESSAGES(i,j).val = MESSAGES(i,j).val/total;

    m193 = MessageDelta(MESSAGES(19,3),lastMESSAGES(19,3));
    m1540 = MessageDelta(MESSAGES(15,40),lastMESSAGES(15,40));
    m172 = MessageDelta(MESSAGES(17,2),lastMESSAGES(17,2));
    resid = [resid;m193 m1540 m172];     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(useSmartMP==1)
      lastMESSAGES(i,j)=prevMessage;
    end
    
    % Check for convergence every m iterations
    if mod(iteration, length(edgeFromIndx)) == 0
        if (CheckConvergence(MESSAGES, lastMESSAGES))
            break;
        end
        disp(['LBP Messages Passed: ', int2str(iteration), '...']);
        if(useSmartMP~=1)
          lastMESSAGES=MESSAGES;
        end
    end
    
end;
toc;
disp(['Total number of messages passed: ', num2str(iteration)]);


% Compute final potentials and place them in P
for m = 1:length(edgeFromIndx),
    j = edgeFromIndx(m);
    i = edgeToIndx(m);
    P.clusterList(i) = FactorProduct(P.clusterList(i), MESSAGES(j, i));
end


% Get the max difference between the marginal entries of 2 messages -------
function delta = MessageDelta(Mes1, Mes2)
delta = max(abs(Mes1.val - Mes2.val));
return;


