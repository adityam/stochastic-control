using Distributions
using PyPlot


const T = 4 
const λ = 1

# We first truncate the state space to [-B, B] and then discretize it into
# 2N + 1 points. 

const N = 500
const B = 5
const X = range(-B, B, length=2N+1)

# Next we create the voronoi boundaries of these grid points.
# Note that there are 2N+1 grid points, so there will be 2N+2 boundaries.
# We follow the convention that the lower boundary of grid point n indexed by
# n and the upper boundary is indexed by n+1

boundary = zeros(2N+2)

boundary[1]    = -Inf
boundary[2N+2] = Inf

for n = 2:2N+1
    boundary[n] = (X[n-1]+X[n])/2
end

# The action space is binary. 0 means don't transmit and 1 means transmit
const U0 = 1
const U1 = 2
const U = [U0, U1]

# Now, we discretize the probability distribution. For every grid point x[i],
# we calculate the probability that the transition takes us to the interval
# (boundary[j], boundary[j+1])

const W = Normal(0, 1)

P = [zeros(2N+1, 2N+1) for u in U]

for i in 1:2N+1, j in 1:2N+1
    P[U0][i,j] = cdf(W, boundary[j+1] - X[i]) - cdf(W, boundary[j] - X[i])
    P[U1][i,j] = (cdf(W, boundary[j+1]) - cdf(W, boundary[j])) 
end

# Per-step cost cost (note that action is stored as as u+1. So we subtract one)
cost(x,u) = λ*(u-1) + (1 - (u-1))*x*x
C = zeros(2N+1, length(U))

for u in U, n in 1:2N+1
  C[n,u] = cost(X[n], u)
end

Q = [ C for t in 1:T ]

V = [ zeros(2N+1)      for t in 1:T ]
g = [ zeros(Int, 2N+1) for t in 1:T ]

function find_optimal(t) 
  for n in 1:2N+1
    idx = Q[t][n,U0] <= Q[t][n,U1] ? U0 : U1
    g[t][n] = idx - 1
    V[t][n] = Q[t][n,idx]
  end
end

find_optimal(T)

for t in T-1:-1:1
  for u in U, n in 1:2N+1
    for m in 1:2N+1
      Q[t][n,u] += P[u][n,m]*V[t+1][m]
    end
  end
  find_optimal(t)
end

plot(X, hcat(V[1], V[2], V[3], V[4]))
legend(["V[1]", "V[2]", "V[3]", "V[4]"], loc="center left", bbox_to_anchor=(1,0.5))
xlabel("State")
title("Value function for different times")
savefig("iot.png", bbox_inches=:tight)

