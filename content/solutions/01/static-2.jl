using LinearAlgebra: dot, argmin

# The state spaces
S, Y, A, W = 1:2, 1:2, 1:3, 1:3

# The transition matrix is called Q in the
# question. We call it P for convenience

P = zeros(length(S), length(W), length(Y));

P[:,:,1] = [0.15 0.1 0.0; 0.15 0.05 0.1];
P[:,:,2] = [0.1 0.05 0.05; 0.15 0.05 0.05];

# Cost
C = zeros(length(S), length(A), length(W));
C[:,:,1] = [3 5 1; 2 3 1];
C[:,:,2] = [4 3 1; 1 2 8];
C[:,:,3] = [1 2 2; 4 1 3];

Q = zeros(length(S), length(Y), length(A));
for s in S, y in Y, a in A
    Q[s,y,a] = dot(P[s,:,y], C[s,a,:])
end

π = zeros(Int, length(S), length(Y));
for s in S, y in Y
    π[s,y] = argmin(Q[s,y,:])
end

@info "The optimal actions are" π 
