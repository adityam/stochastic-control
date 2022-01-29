using Distributions, OffsetArrays

# Parameters
n, m  = 8, 3
λ = 0.5

μ = [0.2, 0.5, 0.8]
q = [1, 3, 8]

h = 1
R = 10
B = 15

# State spaces
S = 0:n
A = 1:m
W = 0:B
Z = 0:1

# Dynamics
f(s,z,w) = min( max(s-z, 0) + w, n)

# Arrival probability
Pw(w) = pdf(Poisson(λ),w)

# Departure probability
Pz(z,s,a) = (s == 0) ? convert(Int, z==0) : pdf(Bernoulli(μ[a]),z)

# Cost
c(s,z,a) = h*s + q[a] - R*z

# Dynamic programming
T = 50

V = [ OffsetArray(zeros(length(S)), S)               for t in 1:T+1] 
Q = [ OffsetArray(zeros(length(S),length(A)), S,A)   for t in 1:T]
π = [ OffsetArray(zeros(Int, length(S)), S)          for t in 1:T]

for t in T:-1:1
    @views Qt = Q[t]
    for s in S 
        for a in A
          Qt[s, a] = sum(Pw(w)*Pz(z,s,a)*( c(s,z,a) + V[t+1][f(s,z,w)] ) for w in W, z in Z)
        end
        idx = argmin(Qt[s,:])
        V[t][s] = Qt[s, idx]
        π[t][s] = idx 
    end
end

using PyPlot

# step(0:n, hcat(π[1], π[50], π[75], π[95]), where=:mid)
# legend(["v[1]", "v[50]", "v[75]", "v[95]"], loc="center left", bbox_to_anchor=(1,0.5)) 
# xlabel("State")
# title("Value function for different times")
# savefig("queueing.png", bbox_inches=:tight)
# 
# 
# @info "Optimal policy" [π[1], π[50], π[75], π[95]]
