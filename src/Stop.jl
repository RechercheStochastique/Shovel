"""
FinalResult is a structure containing the statistical result of the shots
"""
struct FinalResult
    Probability::Float64
    TransProbability::Float64
    Iterations::Int64
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

export stop
"""
stop(fun::function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, verbose=false)

Runs a circuit until there is a probability 1-γ that the precision Δ is reached
for each of the state measurements.
# Arguments
- `fun::function : is a function you want to calculate on the resulting proportion estimate on the final state of the circuit.`
`The function must take an array of Float64 as and input and return a Float64`
- `circuit::QuantumCircuit`: a QuantumCircuit as defined by Snowflake
- `Δ::Float64`: the difference between the real value and the estimation
- `γ::Float64`: the probability that the estimator is more that Δ apart from the true value. 
For more details please see [here](optimalstopingexpl/index.html).
- `verbose::boolean`: println usefull information on screen if needed for estimating suitable for Δ and γ. 
# Example
```julia-repl
julia> stop(fun, circuit, 0.001, 0.10, sqrt)
1
```
"""
function stop(fun::Function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, verbose=false)
    iterations = Int64(0)
    NbOfStates = Int(2^circuit.qubit_count)
    S_n = zeros(Float64, NbOfStates)
    T_n = Float64(0.0)
    worst = Int64(0)
    minimaliteration = Int64(0)
    iterationsDone = Int64(0)
    iterationsLeft = Int64(0)

    if hasmethod(fun, [Vector{Float64}]) != true 
        error("The function does not have the proper format fun(result::Vector{Float64})::Float64")
        return nothing
    end
    test = Vector{Float64}(NbOfStates)
    test[1:end] = 1.0/NbOfStates
    if Typeof(fun(test)) != Float64
        error("The provided function does not return a Float64")
        return nothing
    end

    minimaliteration = Int64(ceil(log(1-γ)/log(1-Δ)))
    if verbose println("Minimal number of iteration = $(minimaliteration)") end
    CoefH = H(γ,Δ)
    if verbose println("Coefficient H(γ,Δ) = $(CoefH)") end
    worst = Int64(ceil(CoefH/4.0))
    if verbose println("Worst case, we do $(worst) iterations") end
    owner = ENV["USERNAME"]
    token = "token_bidon" # ENV["SNOWFLAKE_TOKEN"]
    host = "local" #ENV["SNOWFLAKE_HOST"]
    FinalProp = Float64(0)
    
    # We first do the minimal number of iteration
    Result = Snowflake.simulate_shots(circuit, minimaliteration)
    # Now we build the resulting frequency table
    for iter ∈ 1:minimaliteration
        value = 0
        n = 1<<(circuit.qubit_count-1)
        for ch in Result[iter]
            if ch == '1' 
                value = value + n 
            end
        n = n>>1
        end
        S_n[value+1] = S_n[value+1] + 1
    end

    iterationsDone = minimaliteration
    T_n = 0.0
    for i in 1:NbOfStates
        tmp = ((S_n[i] * ((iterationsDone - S_n[i]))) * CoefH)^(1/3)
        if T_n < tmp 
            T_n = tmp 
        end 
    end
    minimaliteration = Int64(ceil(T_n)) # this is the updated minimal value given what we have observed do far.
    
    if verbose
        println("$(iterationsDone) iterations done, whereas max(T_n) is equal to $(minimaliteration).")
        if iterationsDone >= minimaliteration
            println("So we can stop")
        else
            println("We need to continue")
        end
    end

    # We will now iterate until the stopping T_n is reached. At each step, T_n is reevaluated (increased).
    while iterationsDone < minimaliteration
        iterationsLeft = minimaliteration - iterationsDone
        Result = Snowflake.simulate_shots(circuit, iterationsLeft)
        for iter ∈ 1:iterationsLeft
            value = 0
            n = 1<<(circuit.qubit_count-1)
            for ch in Result[iter]
                if ch == '1' 
                    value = value + n 
                end
                n = n>>1
            end
            S_n[value-1] = S_n[value-1] + 1
        end

        iterationsDone = minimaliteration
        for i in 1:NbOfStates
            tmp = ((S_n[i] * ((iterationsDone - S_n[i]))) * CoefH)^(1/3)
            if T_n < tmp 
                T_n = tmp 
            end 
        end

        iterationsDone = minimaliteration
        minimaliteration = Int64(ceil(T_n))
            
        if verbose
            println("$(iterationsDone) done, whereas T_n is equal to $(Int64(ceil(T_n))).")
        end
    end
    
    if verbose
        println("We're done\n")
        println("Final number of iterations = $(iterationsDone)")
        println("Finalproportions = $(S_n)")
    end

    for i in 1:NbOfStates
        S_n[i] = S_n[i] / Float64(iterationsDone)
    end
    
    if verbose
        println("Final relative proportions = $(S_n)")
    end

    ψ = Snowflake.simulate(circuit)
    println(ψ)
    return(S_n)
end
