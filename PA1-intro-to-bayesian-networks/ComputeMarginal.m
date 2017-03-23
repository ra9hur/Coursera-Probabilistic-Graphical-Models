%ComputeMarginal Computes the marginal over a set of given variables
%   M = ComputeMarginal(V, F, E) computes the marginal over variables V
%   in the distribution induced by the set of factors F, given evidence E
%
%   M is a factor containing the marginal over variables V
%   V is a vector containing the variables in the marginal e.g. [1 2 3] for
%     X_1, X_2 and X_3.
%   F is a vector of factors (struct array) containing the factors 
%     defining the distribution
%   E is an N-by-2 matrix, each row being a variable/value pair. 
%     Variables are in the first column and values are in the second column.
%     If there is no evidence, pass in the empty matrix [] for E.


function M = ComputeMarginal(V, F, E)

% Check for empty factor list
if (numel(F) == 0)
      warning('Warning: empty factor list');
      M = struct('var', [], 'card', [], 'val', []);      
      return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE:
% M should be a factor
% Remember to renormalize the entries of M!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = struct('var', [], 'card', [], 'val', []); % Returns empty factor. Change this.
Joint = ComputeJointDistribution(F);

# To eliminate all possible assignments, but they're not consistent, with my observations
# Reduces no. of independent parameters in the joint distribution, given the conditioning
ObEvi = ObserveEvidence(Joint, E);
# can be re-normalized after this step as well

FacMar = FactorMarginalization(ObEvi, setdiff(ObEvi.var,V));

FacMar.val = FacMar.val/(sum(FacMar.val));
M = FacMar;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = StandardizeFactors(M);

end