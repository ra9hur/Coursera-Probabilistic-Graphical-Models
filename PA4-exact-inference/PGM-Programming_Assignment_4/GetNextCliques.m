%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j. 
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return 
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a 
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)
% p = INPUT1
% messages = INPUT2
% initialization
% you should set them to the correct values in your code
i = 0;
j = 0;

N = length(messages);
mess = ones(size(messages));


for k = 1:N
	for l = 1:N
		mess(k,l) = (length(messages(k,l).var));
	endfor
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:N
	for l = 1:N
		if P.edges(k,l)==0 || mess(k,l)!=0
			continue;
		endif
		kmess = mess(:,k)';
	 	edges = P.edges(:,k);
		edges(l) = 0;
		kmess(l) = 0;
		%if sum(kmess) == sum(P.edges(k,:))-1
    kmess' == edges;
    sum(kmess' == edges);
		if sum(kmess' == edges)==N
			i = k;
			j = l;
			return;
		endif
		if i!=0
			break;
		endif
	endfor
	if i!=0
		break;
	endif
endfor

return;

endfunction

%{
% Get the neighbors, the answer should be 4 and 8
find(GetNextC.INPUT1.edges(7,:))
% Check if 4 has already received a message from 7
GetNextC.INPUT2(7,4)
% Check if 7 has already received a message from 4
GetNextC.INPUT2(4.7)
% Check if 7 has already received a message from 8
GetNextC.INPUT2(8,7)
%}