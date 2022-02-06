using OffsetArrays

# State Spaces
const L = 5
S = 0:L
A = 0:L
W = 0:2

# Dynamics
clip(x) = max( min(x,L), 0)
f(s,a,w) = clip(s + a - w)
Pw = OffsetArray([0.1, 0.7, 0.2], W)

# Cost
c(s,a,w) = (s + a - w)^2

# Dynamic Program
T = 10

V = [ OffsetArray(zeros(length(S)), S) for t in 1:T+1 ]
π = [ OffsetArray(zeros(Int, length(S)), S) for t in 1:T ]
Q = [ OffsetArray(zeros(length(S), length(A)), S,A) for t in 1:T ]


for t in T:-1:1
    @views Qt = Q[t]
    for s in S 
        for a in A
            Qt[s, a] = sum(Pw[w] * (c(s,a,w) + V[t+1][f(s,a,w)]) for w in W)
        end
        idx = argmin(Qt[s,:])
        V[t][s] = Qt[s, idx]
        π[t][s] = idx 
    end
end

display([V[1] V[2]])
display([π[1] π[2]])
