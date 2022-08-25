θ = 0.3
λ = 8.0
γ = 0.9

S = 1:3
A = 1:2
P = [ [1. 0. 0.; 1. 0. 0.; 1. 0. 0.], [ 1-θ θ 0; 0 1-θ θ; 0 0 1] ]
c = [ λ 0; λ 1; λ 5]

# Bellman update
function Bellman(v)
    P_concatenated = vcat(P...)
    Q = c + γ * reshape(P_concatenated * v, length(S), length(A))

    v₊ = zero(v)
    π  = zeros(Int, size(v))
    
    for s=S
        π[s], v₊[s] = 1, Q[s,1]
        for a=2:length(A)
            if Q[s,a] < v₊[s]
                π[s], v₊[s] = a, Q[s,a]
            end
        end
    end
    return (v₊,π)
end

K = 100
v = [zeros(length(S)) for k = 1:K+1 ]
π = [zeros(Int,length(S)) for k = 1:K+1 ]

for k = 1:K
    v[k+1], π[k+1] = Bellman(v[k])
end

@printf("\n-----------------------------------------\n")
@printf("The value function after %d iterations is:\n", K)
display(v[K+1])
@printf("The corresponding policy is:\n")
display(π[K+1])
