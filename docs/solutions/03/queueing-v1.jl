# State spaces
n, m  = 8, 3
S = 1:n+1
A = 1:m+1

# Transition probability
q = 0.6
p = [0.0,0.25,0.5,0.8]

P = [ zeros(n+1,n+1) for a in A ]

# We are using 1-indexed arrays, so need to be careful with the indices
for a in A
    @views Pa = P[a]
    for s in S
        if s == 1
            Pa[s,s]   = 1 - q
            Pa[s,s+1] = q
        elseif s == n+1
            Pa[s,s-1] = (1-q)*p[a]
            Pa[s,s  ] = 1 - (1-q)*p[a]
        else
            Pa[s,s-1] = (1-q)*p[a]
            Pa[s,s  ] = (1-q)*(1-p[a]) + q*p[a]
            Pa[s,s+1] = q*(1-p[a])
        end
    end
end

P_concat = vcat(P...)

# Costs
R = 6 
h = 1
c = [0, 1, 4, 12]

r = zeros(n+1,m+1)
for a in A, s in S
    if s == 1
        r[s,a] = -c[a]
    else
        r[s,a] = p[a]*R - h*s - c[a]
    end
end

# Dynamic programming

T = 100

v = [ zeros(n+1)        for t in 1:T+1] 
π = [ zeros(Int, n+1)   for t in 1:T]

for t in T:-1:1
    Q = r + reshape(P_concat * v[t+1], n+1, m+1)
    for s in S 
        idx = argmax(Q[s,:])
        v[t][s] = Q[s, idx]
        π[t][s] = idx - 1 # To revert back to natural indices
    end
end

using PyPlot

step(0:n, hcat(v[1], v[50], v[75], v[95]), where=:mid)
legend(["v[1]", "v[50]", "v[75]", "v[95]"], loc="center left", bbox_to_anchor=(1,0.5)) 
xlabel("State")
title("Value function for different times")
savefig("queueing.png", bbox_inches=:tight)


@info "Optimal policy" [π[1], π[50], π[75], π[95]]




