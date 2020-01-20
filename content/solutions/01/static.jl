using LinearAlgebra: dot, argmin

# The state spaces
X, U, W = 1:2, 1:3, 1:3

# Probability transition matrix
P = [0.25 0.15 0.05; 0.30 0.10 0.15]

# Cost function
C = zeros(length(X), length(U), length(W))
C[:,:,1] = [3 5 1; 2 3 1];
C[:,:,2] = [4 3 1; 1 2 8];
C[:,:,3] = [1 2 2; 4 1 3];

Q = zeros(length(X), length(U));
for x in X, u in U
    Q[x,u] = dot(P[x,:],C[x,u,:])
end

g = zeros(Int, length(X));
for x in X
    @views g[x] = argmin(Q[x,:])
end
@info "The optimal actions are" g 
