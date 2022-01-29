using Distributions

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
Z = 0:1

# Dynamics
f(s,z,w) = min( max(s-z, 0) + w, n)

# Arrival probability
W = Poisson(λ)
Pw(w) = pdf(W,w)

# Departure probability
Z = [Bernoulli(μ[a]) for a in A]
Pz(z,a) = pdf(Z[a],z)

# Per-step cost. We use $E[c(S,Y,A) | S, A]$ as our cost function
c̃ = zeros(n+1,m)
for a in A, s in S
    if s == 0
        c̃[s+1,a] = q[a]
    else
        c̃[s+1,a] = q[a] + h*s - R*μ[a]
    end
end


# Dynamic programming
T = 50

V = [ zeros(n+1)        for t in 1:T+1] 
Q = [ zeros(n+1,m)      for t in 1:T]
π = [ zeros(Int, n+1)   for t in 1:T]

for t in T:-1:1
    @views Qt = Q[t]
    for s in S 
        for a in A
          Qt[s+1, a] = c̃[s+1,a] + sum(Pw(w)*Pz(z,a)*V[t+1][f(s,z,w) + 1] for w in 0:B, z in 0:1)
        end
        idx = argmin(Qt[s+1,:])
        V[t][s+1] = Qt[s+1, idx]
        π[t][s+1] = idx 
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
