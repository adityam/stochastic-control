using LinearAlgebra

θ = 0.3
λ = 8.0
γ = 0.9

S = 1:3
A = 1:2
P = [ [1. 0. 0.; 1. 0. 0.; 1. 0. 0.], [ 1-θ θ 0; 0 1-θ θ; 0 0 1] ]
c = [ λ 0; λ 1; λ 5]

π₀ = [2 2 2]
π₁ = [2 2 1]
π₂ = [2 1 1]
π₃ = [1 1 1]

# Policy evalation
function evaluate(π)
    c_π = [ c[s, π[s]] for s in S ]
    P_π = reduce(hcat, [ P[π[s]][s,:] for s in S ])
    V_π = (I - γ*P_π)\c_π
end

# Bellman update
function update!(v, π)
    P_concatenated = vcat(P...)
    vOld = copy(v)
    Q = c + γ * reshape(P_concatenated * vOld, length(S), length(A))
    
    for s=S
        π[s], v[s] = 1, Q[s,1]
        for a=2:length(A)
            if Q[s,a] < v[s]
                π[s], v[s] = a, Q[s,a]
            end
        end
    end
end
