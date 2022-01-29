using LinearAlgebra: dot, argmin

# The state spaces
S, A, W = 1:2, 1:3, 1:3

# Probability transition matrix
P = [0.25 0.15 0.05; 0.30 0.10 0.15]

# Cost function
C = zeros(length(S), length(A), length(W))
C[:,:,1] = [3 5 1; 2 3 1];
C[:,:,2] = [4 3 1; 1 2 8];
C[:,:,3] = [1 2 2; 4 1 3];

Q = zeros(length(S), length(A));
for s in S, a in A
    Q[s,a] = dot(P[s,:],C[s,a,:])
end

π = zeros(Int, length(S));
for s in S
    @views π[s] = argmin(Q[s,:])
end
@info "The optimal actions are" π
