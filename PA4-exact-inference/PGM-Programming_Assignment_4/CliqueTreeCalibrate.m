%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

if isMax == 1
	for i = 1:N
		P.cliqueList(i).val = log(P.cliqueList(i).val);
	end
end

cardinality = zeros(1,N);
for i = 1:N
	var = P.cliqueList(i).var;
	card = P.cliqueList(i).card;
	for j = 1:length(var)
		cardinality(var(j)) = card(j);
	endfor
endfor

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
messages = MESSAGES;

for i = 1:N
	for j = 1:N
		if P.edges(i,j) == 1
			messages(i,j).var = intersect(P.cliqueList(i).var,P.cliqueList(j).var);
			messages(i,j).card = cardinality(messages(i,j).var);
			messages(i,j).val = ones(1,prod(messages(i,j).card));
			if isMax == 1
				messages(i,j).val = zeros(1,prod(messages(i,j).card));
			endif
    else
			continue
		endif
	endfor
endfor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the sender and the receiver from GetNextCliques
[i,j] = GetNextCliques(P,MESSAGES);

% check if they're both 0. if yes we're done. if no,
while i != 0
  % Create the new message, and assign it to MESSAGES(sender, receiver)
  % Basically, you do this by multiplying out the cliques own factor with all the incoming messages 
  % that are not to the receiver
	if (isMax==0)
		messages(i,j) = FactorProduct(P.cliqueList(i),messages(i,j));
	else
		messages(i,j) = FactorSum(P.cliqueList(i),messages(i,j));
	endif

%i. Multiply everything that needs to be multiplied (ie. all IN messages and the factor)
	others = P.edges(:,i);
  others(j) = 0;    % Ignoring messages that cluster j (receiver) had sent cluster i (sender)
	for x = 1:N
		if others(x)==1
			if isMax == 0
				messages(i,j) = FactorProduct(messages(i,j),messages(x,i));
			else
				messages(i,j) = FactorSum(messages(i,j),messages(x,i));
			endif
		endif
	endfor

%ii. Marginalize to remove the set difference
  % you marginalize out all the variables that are not in common between the sending and receiving cliques)
	sepset = intersect(P.cliqueList(i).var,P.cliqueList(j).var);    % Variables that i,j choose to talk about
	summedout = setdiff(P.cliqueList(i).var,P.cliqueList(j).var);   % All other variables other than in sepset
	%MESSAGES(i,j) = ComputeMarginal(sepset,messages(i,j),[]);

	if isMax == 0
		messages(i,j) = FactorMarginalization(messages(i,j),summedout);
%iii. Normalize .val to sum to 1
	  total = sum(messages(i,j).val);
	  messages(i,j).val = messages(i,j).val/total;
	else
		messages(i,j) = FactorMaxMarginalization(messages(i,j),summedout);
	end
%iv. Store the message and get the next one. Repeat.
  % Store this back into MESSAGES(sender, receiver)
	MESSAGES(i,j) = messages(i,j);
	[i,j] = GetNextCliques(P,MESSAGES);
endwhile

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% you should not normalize the initial potentials, neither the final beliefs to conform with the grader.
for i=1:N
	edges = P.edges(i,:);
	for j = 1:N
		if edges(j)==1
			if isMax == 0
				P.cliqueList(i) = FactorProduct(P.cliqueList(i),MESSAGES(j,i));
			else
				P.cliqueList(i) = FactorSum(P.cliqueList(i),MESSAGES(j,i));
			endif
		endif
	endfor
endfor

% Verify if cliques are calibrated
%1 Calibration
%{
summedout1 = setdiff(P.cliqueList(4).var,P.cliqueList(7).var);
summedout2 = setdiff(P.cliqueList(7).var,P.cliqueList(4).var);
B4 = FactorMarginalization(P.cliqueList(4),summedout1);
B7 = FactorMarginalization(P.cliqueList(7),summedout2);
%}
%2 Convergence - Calculate messages 1-8 and 8-1. Product should be equal to beliefs of either cluster

%3 Reparameterization - prod(Beliefs)/prod(messages)= prod(initial potentials or factor list ?)
return;

endfunction
