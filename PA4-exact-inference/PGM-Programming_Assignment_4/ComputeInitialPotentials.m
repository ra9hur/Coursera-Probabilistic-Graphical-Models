%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

card = cell();
for i = 1:length(C.factorList)
	var = C.factorList(i).var;
	cardf = C.factorList(i).card;
	for j = 1:length(var)
		card{var(j)} = cardf(j);
	endfor
endfor

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N,1);
P.edges = zeros(N);
for i = 1:N
	P.cliqueList(i).var = C.nodes{i};
	P.cliqueList(i).card = ones(1,length(P.cliqueList(i).var));
	for j = 1:length(P.cliqueList(i).var)
		P.cliqueList(i).card(j) = card{P.cliqueList(i).var(j)};
	endfor
	P.cliqueList(i).val = ones(1,prod(P.cliqueList(i).card));
endfor

% Assign edges
P.edges = C.edges;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

%{
C.factorList.var
1
2   1   3
3
4   1   3
5   2   6
6
7   1
8   2
9
10    4
11    5
12    6

                            Factors assignment to cliques
C.nodes                     clique{i}
[1,1] = 1   7               7   1    length(facts)=2
[1,2] =  2   8              8
[1,3] =  3   9              9   3
[1,4] =  4   10             10
[1,5] =  5   11             11
[1,6] =  6   12             12  6
[1,7] =  1   3   4          4
[1,8] =  1   2   3          2
[1,9] =  2   5   6          5
%}

clique = cell();
clique{N}=[];
for i = 1:length(C.factorList);
	for j = 1:N
    if length(setdiff(C.factorList(i).var,C.nodes{j}))==0
      clique{j} = [i,clique{j}];
			break
		endif
	endfor
endfor

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Factor product of all factors assigned to a clique
for i = 1:N
	facts = clique{i};
	for j = 1:length(facts)
		P.cliqueList(i) = FactorProduct(P.cliqueList(i),C.factorList(facts(j)));
	endfor
endfor

endfunction





