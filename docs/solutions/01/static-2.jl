using LinearAlgebra: dot, argmin

# The state spaces
X, Y, Y, W = 1:2, 1:2, 1:3, 1:3

# The transition matrix is called Q in the
# question. We call it P for convenience

P = zeros(length(X), length(W), length(Y));

P[:,:,1] = [0.15 0.1 0.0; 0.15 0.05 0.1];
P[:,:,2] = [0.1 0.05 0.05; 0.15 0.05 0.05];

# Cost
C = zeros(length(X), length(U), length(W));
C[:,:,1] = [3 5 1; 2 3 1];
C[:,:,2] = [4 3 1; 1 2 8];
C[:,:,3] = [1 2 2; 4 1 3];

Q = zeros(length(X), length(Y), length(U));
for x in X, y in Y, u in U
    Q[x,y,u] = dot(P[x,:,y], C[x,u,:])
end

g = zeros(Int, length(X), length(Y));
for x in X, y in Y
    g[x,y] = argmin(Q[x,y,:])
end

@info "The optimal actions are" g 
