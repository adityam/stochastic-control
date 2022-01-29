using Distributions, OffsetArrays
using PyPlot

Pw(w) = (abs(w) <= 5) ? 1/5 - abs(w)/25 : 0 
λ = 100
B = 50

# State spaces
S = -B:B
A =  0:1
W = -5:5

# Dynamics
f(s,a,w) = clip(s*(a==0) + w, -B, B) 
clip(x,L,U) = max( min(x,U), L)

# cost
c(s,a) = λ * a + (1 - a)*s^2

T = 20

V = [ OffsetArray(zeros(length(S)), S) for t in 1:T+1 ]
π = [ OffsetArray(zeros(Int, length(S)), S) for t in 1:T ]
Q = [ OffsetArray(zeros(length(S), length(A)), S,A) for t in 1:T ]

for t in T:-1:1
    @views Qt = Q[t]
    for s in S 
        for a in A
          Qt[s, a] = c(s,a) + sum(Pw(w) * V[t+1][f(s,a,w)] for w in W)
        end
        idx = argmin(Qt[s,:])
        V[t][s] = Qt[s, idx]
        π[t][s] = idx 
    end
end

