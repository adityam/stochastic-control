using LinearAlgebra, Printf

θ = 0.3
λ = 8.0
γ = 0.9

S = 1:3
A = 1:2
P = [ [1. 0. 0.; 1. 0. 0.; 1. 0. 0.], [ 1-θ θ 0; 0 1-θ θ; 0 0 1] ]
c = [ λ 0; λ 1; λ 5]

π₁ = [2 2 2]
π₂ = [2 2 1]
π₃ = [2 1 1]
π₄ = [1 1 1]

# Policy evalation
function evaluate(π)
    c_π = [ c[s, π[s]] for s in S ]
    # See the following post for the need for using a range s:s :
    # https://discourse.julialang.org/t/problem-extracting-a-row-from-an-array-returns-a-column/37331/14 
    P_π = reduce(vcat, [ P[π[s]][ s:s,:] for s in S ])
    V_π = (I - γ*P_π)\c_π
end

display.(evaluate.([π₁, π₂, π₃, π₄]))

# Bellman update
function update!(v, π)
    P_concatenated = vcat(P...)
    Q = c + γ * reshape(P_concatenated * v, length(S), length(A))
    
    for s=S
        π[s], v[s] = 1, Q[s,1]
        for a=2:length(A)
            if Q[s,a] < v[s]
                π[s], v[s] = a, Q[s,a]
            end
        end
    end
end
v = zeros(length(S))
π = zeros(Int, length(S))

K = 100
for k = 1:K 
    update!(v,π)
end

@printf("\n-----------------------------------------\n")
@printf("The value function after %d iterations is:\n", K)
display(v)
@printf("The corresponding policy is:\n")
display(π)
