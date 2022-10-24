export shootuntil
"""
shootuntil(fun::function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, verbose=false)

Runs a circuit until there is a probability 1-γ that the precision Δ is reached
for each of the state measurements.
# Arguments
- `fun::function : is a function you want to calculate on the resulting proportion estimate on the final state of the circuit.`
`The function must take an array of Float64 as and input and return a Float64`
- `circuit::QuantumCircuit`: a QuantumCircuit as defined by Snowflake
- `Δ::Float64`: the difference between the real value and the estimation
- `γ::Float64`: the probability that the estimator is more that Δ apart from the true value. 
For more details please see [here](Stop/index.html).
- `verbose::boolean`: println usefull information on screen if needed for estimating suitable for Δ and γ. 
# Example
```julia-repl
julia> shootuntil(fun, circuit, 0.001, 0.10, sqrt)
1
```
"""
function shootuntil(fun::Function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, verbose=false)
    iterations = Int64(0)
    NbOfStates = Int(2^circuit.qubit_count)
    S_n = zeros(Int64, NbOfStates)
    S_ntemp = zeros(Float64, NbOfStates)
    worst = Int64(0)
    minimaliteration = Int64(0)
    iterationsDone = Int64(0)
    iterationsLeft = Int64(0)
    totalderiv = Float64(0.0)

    if hasmethod(fun, [Vector{Float64}, Int64]) != true 
        error("The function $(fun) does not have the proper format fun(::Vector{Float64}, ::Int64)::Float64")
        return nothing
    end
    test = Vector{Float64}(undef, NbOfStates)
    test[1:end] .= 1.0/NbOfStates
    if typeof(fun(test, 0)) != Float64
        error("The provided function does not return a Float64")
        return nothing
    end

    minimaliteration = Int64(ceil(log(1-γ)/log(1-Δ)))
    if verbose println("Minimal number of iteration = $(minimaliteration)") end
    CoefH = H(γ,Δ)
    if verbose println("Coefficient H(γ,Δ) = $(CoefH)") end
    worst = Int64(ceil(CoefH/4.0))
    if verbose println("Worst case, we do $(worst) iterations") end
    #=
    owner = ENV["USERNAME"]
    token = "token_bidon" # ENV["SNOWFLAKE_TOKEN"]
    host = "local" #ENV["SNOWFLAKE_HOST"]
    =#
    FinalProp = Float64(0)
    
    # We first do the minimal number of iteration
    result = Snowflake.simulate_shots(circuit, minimaliteration)
    # Now we build the resulting frequency table
    buildfreq!(S_n, result, circuit.qubit_count)
    iterationsDone = minimaliteration

    # We now compute the functions on the observed frequencies and estimate the derivative
    for i in 1:NbOfStates 
        S_ntemp[i] = S_n[i] / iterationsDone
    end
    valuefun = fun(S_ntemp, iterationsDone)
    totalderiv = totalderivative(fun, S_ntemp, Δ, iterationsDone)
    println("totalderiv= ", totalderiv)
    minimaliteration = Int64(ceil(totalderiv * CoefH)) # this is the updated minimal value given what we have observed do far.
    
    if verbose
        println(iterationsDone, " iterations done. fun()=", valuefun, 
            " whereas the minimal required number of iterations is equal to ", minimaliteration)
        if iterationsDone >= minimaliteration
            println("So we can stop")
        else
            println("We need to continue")
        end
    end

    # We will now iterate until the stopping T_n is reached. At each step, T_n is reevaluated (increased).
    while iterationsDone < minimaliteration
        iterationsLeft = minimaliteration - iterationsDone
        # The following line is a trick based on experience. At the end the process tends to run several time shots of size 1
        # By setting it to 10 as a minimal value, we may do a few extra sots but will get out of the loop faster.
        if iterationsLeft < 10 iterationsLeft = 10 end  
        result = Snowflake.simulate_shots(circuit, iterationsLeft)
        buildfreq!(S_n, result, circuit.qubit_count)

        iterationsDone = minimaliteration
        for i in 1:NbOfStates 
            S_ntemp[i] = S_n[i] / iterationsDone
        end
        valuefun = fun(S_ntemp, iterationsDone)
        totalderiv = totalderivative(fun, S_ntemp, Δ, iterationsDone)
        minimaliteration = Int64(ceil(totalderiv * CoefH))
            
        if verbose
            println(iterationsDone, " iterations done. fun()=", valuefun, 
            " whereas the minimal required number of iterations is equal to ", minimaliteration)
        end
    end
    
    if verbose
        println("We're done\n")
        println("Final number of iterations = $(iterationsDone)")
    end

    ψ = Snowflake.simulate(circuit)
    println(ψ)
    return(S_n, iterationsDone)
end

function buildfreq!(S_n::Vector{Int64}, result::Vector{String}, qubit_count::Int)
    for iter ∈ 1:length(result)
        value = Int64(0)
        n = 1<<(qubit_count-1)
        for ch in result[iter]
            if ch == '1' 
                value = value + n 
            end
            n = n>>1
        end
        S_n[value+1] = S_n[value+1] + 1
    end
    
    for iter ∈ 1:length(S_n)
        println("S_n[", iter, "]=",S_n[iter])
    end
    return nothing
end

function totalderivative(fun::Function, S_ntemp::Vector{Float64}, Δ::Float64, iterationsDone::Int64)::Float64
    totalderiv = Float64(0.0)
    for i in 1:length(S_ntemp)
        h0 = S_ntemp[i]
        b1 = max(0, S_ntemp[i]-Δ)
        S_ntemp[i] = b1
        fmin = fun(S_ntemp, iterationsDone)
        b2 = min(1, S_ntemp[i]+Δ)
        S_ntemp[i] = b2
        fmax = fun(S_ntemp, iterationsDone)
        S_ntemp[i] = h0   # reset frequency to correct value
        deriv = (fmax - fmin) /(b2 - b1)
        S_n = S_ntemp[i] * iterationsDone
        deriv = deriv^2 * (S_n * (iterationsDone - S_n))
        println("b1=", b1, " b2=", b2, " fmin=", fmin, " fmax=", fmax, " deriv=", deriv, " S_n=", S_n)
        totalderiv += deriv
    end
    return totalderiv
end

# This function is only a wrapper for qubitprop((histo::Array{Float64}, iterations::Int, qubit::Int)::Float64
# the value of "qubit" in the first line needs to be adjusted. The variable "iterations" is also droped because 
# it is not used in this case.
export qubitprop
function qubitprop(histo::Vector{Float64}, iterations::Int64)::Float64
    bidon = iterations
    qubit = Int64(1)
    return qubitpropV2(histo, qubit)
end

# This is a simple example of a function that can be calles with shootuntil.
# It simply returns the observed relative frequency that qubit number "qubit" was equal to 1.
function qubitpropV2(histo::Vector{Float64}, qubit::Int64)::Float64
    prop = Float64(0.0)
    n = 1 << (qubit-1)
    println("qubit=", qubit, " n=", n)
    for i in 1:length(histo)
        if (i & n) == true
            print(i, " ")
            prop = prop + histo[i]
        end
    end
    print("\n")
    return prop 
end

export SampleSize
"""
SampleSize(c::QuantumCircuit)::Int64

Calculate the sample size (number of shots) required to reach, with probability 1-γ, a difference not exceeding Δ between
``|\\alpha_i|^2|`` and the observed proportion ``p_i`` for all possible states in the sample.

# Arguments
- `c::QuantumCircuit`: is a Snowflake cirquit.

The function return a positive integer
"""
function SampleSize(c::QuantumCircuit, Δ::Float64, γ::Float64)::Int64
    worst = Int64(0)

    CoefH = H(γ,Δ)
    ψ = Snowflake.simulate(c)
    for α in ψ
        p = abs(α)^2
        n = Int64(ceil(p*(1-p) * CoefH))
        if worst < n worst = n end
    end
    return worst
end

export StatesProportions
"""
StatesProportions is a structure containing the description and actual proportions of each state after a simulation 
"""
struct StatesProportions
    Value::String
    Proportion::Float64
end

" Ajusting factor for the stopping rule"
function H(γ, Δ)::Float64
    X = Normal()
    ϕ =quantile.(Normal(),(1-γ/2))
    ϕ = Float64((ϕ/Δ)^2.0)
    return ϕ
end
