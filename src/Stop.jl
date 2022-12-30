export shootuntilresult
"""
shootuntilresult is a structure containing the results of shootuntil function. It is intended to be reused 
    by another package to perform analysis. 
# Members
- γ::Float64
- Δ::Float64
- circuit::QuantumCircuit
- samplesize::Int64
- Proportions::Vector{Float64}
- funvalue::Float64
- variancefun::Float64
"""
struct shootuntilresult
    γ::Float64
    Δ::Float64
    circuit::QuantumCircuit
    samplesize::Int64
    Proportions::Vector{Float64}
    funvalue::Float64
    variancefun::Float64
end

export printshootresult
"""
    printshootresult(io::IO, shrslt::shootuntilresult)

Pretty print of the shootuntilresult structure.
"""
function printshootresult(io::IO, shrslt::shootuntilresult)
    println(io, "γ=", shrslt.γ)
    println(io, "Δ =", shrslt.Δ)
    print(io, "Circuit: ")
    printlightQC(io, shrslt.circuit)
    println(io, "Number of shots=", shrslt.samplesize)
    println(io, "Proportions:")
    println(io, shrslt.Proportions)
    println(io, "Estimated value of function=", shrslt.funvalue)
    println(io, "Variance of estimate=", shrslt.variancefun)
end

Base.show(io::IO, shrslt::shootuntilresult) = printshootresult(io, shrslt)

export shootuntil
"""
    shootuntil(fun::Function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose::Bool=false, estimate::Bool=false, ignorefun::Bool=false)::shootuntilresult
    
Runs a circuit until there is a probability 1-γ that the precision Δ is reached for each of the state measurements.
# Arguments
    - `fun::function : is a function you want to calculate on the resulting proportion estimate on the final state of the circuit. For instance "sqrt" to get |α| instead of |α|^2
    The function must take a Float64 as and input and return a Float64`
    - `circuit::QuantumCircuit`: a QuantumCircuit as defined by Snowflake
    - `Δ::Float64`: the difference between the real value and the estimation
    - `γ::Float64`: the probability that the estimator is more that Δ apart from the true value.
    - `linearcoef::Vector{Float64}`  : a vector of size 2^q, where q is the number of qubit in the circuit (q=circuit.qubit_count). It is a linear combination of the probabilities of the possible bit states after measurement. For more details please see [here](Stop/index.html).
    - `verbose::boolean`: println usefull information on screen if needed for estimating suitable for Δ and γ. 
    - `estimate::boolean` : this will prevent the fuction to run past the log(1-γ)/log(1-Δ) limit which is enough to get a rough estimation of the number of shots required 
    to reach the desired precision.

# Example
```julia-repl
julia> coeflin = [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0]
julia> result = shootuntil(sqrt, c1, 0.001, 0.05, coeflin, true)
julia> println(result)
```
"""
function shootuntil(fun::Function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose::Bool=false, estimate::Bool=false, ignorefun::Bool=false)::shootuntilresult
    NbOfStates = Int(2^circuit.qubit_count)
    absfreq = zeros(Int64, NbOfStates)
    relfreq = zeros(Float64, NbOfStates)
    iterationsmin = Int64(0)
    iterationsdone = Int64(0)
    iterationsLeft = Int64(0)
    funvalue = Float64(0.0)
    derivfun = Float64(0.0)
    innerproduct = Float64(0.0)
    σ = Float64(0.0)
    shootresult = shootuntilresult(γ, Δ, circuit, iterationsdone, relfreq, funvalue, derivfun * derivfun * σ )
    if verbose == true
        println("starting iterative process")
    end

    if ignorefun == false
        if hasmethod(fun, [Float64]) != true 
            error("Function $(fun) does not have the proper format fun(::Float64)")
            return shootresult
        end
        if typeof(fun(0.5)) != Float64
            error("Function $(fun) does not return a Float64")
            return shootresult
        end
    end
    if length(linearcoef) != NbOfStates
        error("The linear combinaison does not have the proper length")
        return shootresult
    end
    
    if estimate == true verbose = true end # seems logical to spit all info if this is just an estimate.

    # We now perform the minimal number of shots
    iterationsmin = Int64(ceil(log(1-γ)/log(1-Δ)))
    if verbose == true println("Minimal number of iteration = $(iterationsmin)") end
    CoefH = (quantile.(Normal(),(1-γ/2)) / Δ)^2 # i.e. H(γ,Δ)
    if verbose == true println("Coefficient H(γ,Δ) = $(CoefH)") end
    #=
    owner = ENV["USERNAME"]
    token = "token_bidon" # ENV["SNOWFLAKE_TOKEN"]
    host = "local" #ENV["SNOWFLAKE_HOST"]
    =#
    result = Snowflake.simulate_shots(circuit, iterationsmin)
    iterationsdone = iterationsmin
    # Now we build the resulting frequency table
    buildfreq!(absfreq, result, circuit.qubit_count)

    # We compute the functions on the observed frequencies and estimate the derivative
    for i in 1:NbOfStates 
        relfreq[i] = absfreq[i] / iterationsdone
    end
    # We compute the linear combinaison of the frequencies
    innerproduct = dot(relfreq, linearcoef)
    # Now the function of the linear combination
    if (ignorefun == true)
        funvalue = innerproduct
        derivfun = 1.0
    else
        funvalue = fun(innerproduct)
        derivfun = (fun(innerproduct + Δ) - fun(innerproduct - Δ)) / (2.0*Δ)
    end
    σ = sigmalin(relfreq, linearcoef)
    iterationsmin = Int64(ceil(derivfun * derivfun * σ * CoefH)) # this is the updated minimal value given what we have observed do far.
    
    if verbose == true
        println(iterationsdone, " iterations done. fun()=", funvalue)
        println("linear combinaison=", innerproduct, " fun(linear combinaison)=", funvalue, " derivative fun=", derivfun)
        println("The estimated required number of iterations is equal to ", iterationsmin)
        if estimate == false
            if iterationsdone >= iterationsmin
                println("So we can stop")
                shootresult = shootuntilresult(γ, Δ, circuit, iterationsdone, relfreq, funvalue, derivfun * derivfun * σ )
                return shootresult
            else
                println("We need to continue")
            end
        end
    end

    # If estimate is true, then we'll not go further.
    shootresult = shootuntilresult(γ, Δ, circuit, iterationsdone, relfreq, funvalue, derivfun * derivfun * σ )
    if estimate == true 
        return shootresult 
    end

    # We will now iterate until the stopping reached. At each step the criteria is reevaluated (increased).
    while iterationsdone < iterationsmin
        iterationsLeft = iterationsmin - iterationsdone
        # THe following line is to avoid overshooting. So instead of doing "iterationsLeft" we will do only half of them
        if (iterationsLeft > 2000) 
            iterationsLeft = iterationsLeft >> 1 
        end
        # The following line is a trick based on experience. At the end the process tends to run several time shots of size 1
        # By setting it to 10 as a minimal value, we may do a few extra sots but will get out of the loop faster.
        if iterationsLeft < 10 iterationsLeft = 10 end
        result = Snowflake.simulate_shots(circuit, iterationsLeft)
        iterationsdone = iterationsdone + iterationsLeft
        
        buildfreq!(absfreq, result, circuit.qubit_count)
        for i in 1:NbOfStates 
            relfreq[i] = absfreq[i] / iterationsdone
        end

        # We compute the linear combinaison of the frequencies
        innerproduct = dot(relfreq, linearcoef)
        # Now the function of the linear combination
        if (ignorefun == true)
            funvalue = innerproduct
            derivfun = 1.0
        else
            funvalue = fun(innerproduct)
            derivfun = (fun(innerproduct + Δ) - fun(innerproduct - Δ)) / (2.0*Δ)
        end
        σ = sigmalin(relfreq, linearcoef)
        iterationsmin = Int64(ceil(derivfun * derivfun * σ * CoefH)) # this is the updated minimal value given what we have observed do far.
           
        if verbose == true
            println(iterationsdone, " iterations done. fun()=", funvalue)
            println("linear combinaison=", innerproduct, " fun(linear combinaison)=", funvalue, " derivative fun=", derivfun)
            println("The estimated required number of iterations is equal to ", iterationsmin)
        end
    end
    
    if verbose == true
        println("We're done\n")
        println("Final number of iterations = $(iterationsdone)")
    end

    #ψ = Snowflake.simulate(circuit)
    #println(ψ)

    shootresult = shootuntilresult(γ, Δ, circuit, iterationsdone, relfreq, funvalue, derivfun * derivfun * σ )
    return shootresult
end
"""
    shootuntil(circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose=false, estimate=false)::shootuntilresult

Same as above but no function is provided.
"""
function shootuntil(circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose=false, estimate=false)::shootuntilresult
    # The function "x->x" below is bogus bacause the last argument has value "true", so shootuntil will ignore it
    return shootuntil(x -> x, circuit, Δ, γ, linearcoef, verbose, estimate, true) 
end

function sigmalin(relfreq::Vector{Float64}, linearcoef::Vector{Float64})::Float64
    σ = 0.0
    innerproduct = Float64(0.0)

    if (length(relfreq) != length(linearcoef))
        error("relfreq and linearcoef are not of the same size")
        return nothing
    end
    innerproduct = dot(relfreq, linearcoef)

    for i in 1:length(relfreq)
        σ = σ + linearcoef[i] * relfreq[i] * linearcoef[i]
    end
    σ = σ - (innerproduct * innerproduct)

    return(σ)
end

export buildfreq!
function buildfreq!(absfreq::Vector{Int64}, result::Vector{String}, qubit_count::Int)
    for resultat in result
        value = Int64(0)
        n = 1<<(qubit_count-1)
        for ch in resultat
            if ch == '1' 
                value = value + n 
            end
            n = n>>1
        end
        absfreq[value+1] = absfreq[value+1] + 1
    end

    return nothing
end

# Ajusting factor for the stopping rule
function H(::Float64, Δ::Float64)::Float64
    return (quantile.(Normal(),(1-γ/2)) / Δ)^2
end
