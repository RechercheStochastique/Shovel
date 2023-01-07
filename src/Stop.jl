export shootuntilresult
"""
shootuntilresult is a structure containing the results of [`shootuntil`](@ref) function. It is intended to be reused by another package to perform analysis. 
# Members
- `gamma::Float64` the probability that the estimated parameter is farther than Delta from the true value.
- `Delta::Float64` the disired distance between estimator and true value.
- `circuit::QuantumCircuit` the circuit being analysed.
- `samplesize::Int64` the resulting sample size.
- `Proportions::Vector{Float64}` the relative frequencies of each possilble measurements of the circuit.
- `funvalue::Float64` the value of the function of the linear combinaison measured.
- `variancefun::Float64` the variance of the function of the linear combinaison.

After running several shots of a quantum circuit using [`shootuntil`](@ref) the output is summarized into this structure and can be reused for further statistical analysis. Only the final frequency
table of the shots are available since this constitute an exhaustive statistics for the results.
"""
struct shootuntilresult
    gamma::Float64
    Delta::Float64
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
    println(io, "γ=", shrslt.gamma)
    println(io, "Δ =", shrslt.Delta)
    print(io, "Circuit: ")
    println(io, shrslt.circuit)
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
    shootuntil(circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose=false, estimate=false)::shootuntilresult
    
Runs a circuit until there is a probability 1-γ that the precision Δ is reached for each of the state measurements.
# Arguments
- `fun::function`: is a function you want to calculate on the resulting proportion estimate on the final state of the circuit. For instance "sqrt" to get |α| instead of |α|^2. The function must take a Float64 as and input and return a Float64
- `circuit::QuantumCircuit`: a QuantumCircuit as defined by Snowflake
- `Δ::Float64`: the difference between the real value and the estimation
- `γ::Float64`: the probability that the estimator is more that Δ apart from the true value.
- `linearcoef::Vector{Float64}`: a vector of size 2^q, where q is the number of qubit in the circuit (q=circuit.qubit_count). It is a linear combination of the probabilities of the possible bit states after measurement. For more details please see [here](Stop/index.html).
- `verbose::boolean`: println usefull information on screen if needed for estimating suitable for Δ and γ. 
- `estimate::boolean`: this will prevent the fuction to run past the log(1-γ)/log(1-Δ) limit which is enough to get a rough estimation of the number of shots required to reach the desired precision.

The second version  is the same but without the function.
# Example
```
julia> c = QuantumCircuit(qubit_count = 3, bit_count=0);
... ( a bunch of "push_gate!() to define the circuit c goes here)
julia> linear_coefficient = [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0];
julia> result = Shovel.shootuntil(sqrt, c, 0.001, 0.05, linear_coefficient, true);
starting iterative process
Minimal number of iteration = 52
Coefficient H(γ,Δ) = 3.8414588206941388e6
52 iterations done. fun()=0.970725343394151
linear combinaison=0.9423076923076923 fun(linear combinaison)=0.970725343394151 derivative fun=0.5150788261477635
The estimated required number of iterations is equal to 55406
We need to continue
27729 iterations done. fun()=0.9364186034730589
linear combinaison=0.8768798009304339 fun(linear combinaison)=0.9364186034730589 derivative fun=0.5339493250440253
The estimated required number of iterations is equal to 118241
72985 iterations done. fun()=0.9355470798948244
linear combinaison=0.875248338699733 fun(linear combinaison)=0.9355470798948244 derivative fun=0.5344467342494053
The estimated required number of iterations is equal to 119808
96396 iterations done. fun()=0.9358606183038087
linear combinaison=0.8758350968919872 fun(linear combinaison)=0.9358606183038087 derivative fun=0.5342676801416424
The estimated required number of iterations is equal to 119244
107820 iterations done. fun()=0.9358083885129101
linear combinaison=0.8757373400111297 fun(linear combinaison)=0.9358083885129101 derivative fun=0.5342974989674953
The estimated required number of iterations is equal to 119338
113579 iterations done. fun()=0.9357784160216117
linear combinaison=0.8756812438919167 fun(linear combinaison)=0.9357784160216117 derivative fun=0.534314612247011
The estimated required number of iterations is equal to 119392
116485 iterations done. fun()=0.9357934167306433
linear combinaison=0.8757093187964116 fun(linear combinaison)=0.9357934167306433 derivative fun=0.534306047212163
The estimated required number of iterations is equal to 119365
117925 iterations done. fun()=0.9358295661561952
linear combinaison=0.8757769768920924 fun(linear combinaison)=0.9358295661561952 derivative fun=0.5342854079098958
The estimated required number of iterations is equal to 119300
119300 iterations done. fun()=0.9358466141219156
linear combinaison=0.8758088851634536 fun(linear combinaison)=0.9358466141219156 derivative fun=0.5342756750272848
The estimated required number of iterations is equal to 119269
We're done

Final number of iterations = 119300

julia> println(result)
γ=0.05
Δ =0.001
Circuit: Quantum Circuit Object:
   id: 65e73d60-87e4-11ed-15b5-e3057c69e742
   qubit_count: 3
   bit_count: 0
q[1]:--Ry(0.1)--------------------------*----*-------------------------------*--
                                        |    |                               |
q[2]:-------------Ry(0.2)---------------X----|---------------*----Ry(0.5)----X--
                                             |               |
q[3]:------------------------Ry(0.3)---------X----Ry(0.4)----X------------------

Number of shots=119300
Proportions:
[0.804777870913663, 0.0942246437552389, 0.06854149203688181, 0.02992455993294216, 0.002321877619446773, 0.0, 0.00016764459346186087, 4.191114836546522e-5]
Estimated value of function=0.9358466141219156
Variance of estimate=0.031047788828476044
```
Details of the circuit does not matter but, since it is a 3-qubits circuit, it has 8 possible outcomes for which the relative proportions are given.
The linear combinaison is such that the proportion of the first qubit being equal to 0 is used and the square root of that proportion is used for the stopping rule.
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
    σ = shsigmalin(relfreq, linearcoef)
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
        σ = shsigmalin(relfreq, linearcoef)
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

function shootuntil(circuit::QuantumCircuit, Δ::Float64, γ::Float64, linearcoef::Vector{Float64}, verbose=false, estimate=false)::shootuntilresult
    # The function "x->x" below is bogus bacause the last argument has value "true", so shootuntil will ignore it
    return shootuntil(x -> x, circuit, Δ, γ, linearcoef, verbose, estimate, true) 
end

"""
    shsigmalin(relfreq::Vector{Float64}, linearcoef::Vector{Float64})::Float64

A function to evaluate the variance of a linear function of the possible outcomes. This is used by shshootuntil.
"""
function shsigmalin(relfreq::Vector{Float64}, linearcoef::Vector{Float64})::Float64
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

"""
    buildfreq!(absfreq::Vector{Int64}, result::Vector{String}, qubit_count::Int)

Updates the frequancy table of the outcomes.
"""
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

export H
"""
    H(::Float64, Δ::Float64)::Float64

Ajusting factor for the stopping rule based on a normal approximation of the distribution of a proportion.
"""
function H(::Float64, Δ::Float64)::Float64
    return (quantile.(Normal(),(1-γ/2)) / Δ)^2
end
