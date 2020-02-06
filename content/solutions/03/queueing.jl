# State spaces
n, m  = 8, 3
X = 1:n+1
U = 1:m+1

# Transition probability
q = 0.6
p = [0.0,0.25,0.5,0.8]

P = [ zeros(n+1,n+1) for u in U ]

# We are using 1-indexed arrays, so need to be careful with the indices
for u in U
    @views Pu = P[u]
    for x in X
        if x == 1
            Pu[x,x]   = 1 - q
            Pu[x,x+1] = q
        elseif x == n+1
            Pu[x,x-1] = (1-q)*p[u]
            Pu[x,x  ] = 1 - (1-q)*p[u]
        else
            Pu[x,x-1] = (1-q)*p[u]
            Pu[x,x  ] = (1-q)*(1-p[u]) + q*p[u]
            Pu[x,x+1] = q*(1-p[u])
        end
    end
end

P_concat = vcat(P...)

# Costs
R = 6 
h = 1
c = [0, 1, 4, 12]

r = zeros(n+1,m+1)
for u in U, x in X
    if x == 1
        r[x,u] = -c[u]
    else
        r[x,u] = p[u]*R - h*x - c[u]
    end
end

# Dynamic programming

T = 100

v = [ zeros(n+1)        for t in 1:T+1] 
g = [ zeros(Int, n+1)   for t in 1:T]

for t in T:-1:1
    Q = r + reshape(P_concat * v[t+1], n+1, m+1)
    for x in X 
        idx = argmax(Q[x,:])
        v[t][x] = Q[x, idx]
        g[t][x] = idx - 1 # To revert back to natural indices
    end
end

using PyPlot

step(0:n, hcat(v[1], v[50], v[75], v[95]), where=:mid)
legend(["v[1]", "v[50]", "v[75]", "v[95]"])
xlabel("State")
title("Value function for different times")
savefig("queueing.png")


@info "Optimal policy" [g[1], g[50], g[75], g[95]]




