using Snowflurry
using Distributions
using Random
using Bits
using Plots
using Revise

export shinit1qubit!
"""
    shinit1qubit!(probability::Float64)::QuantumCircuit

Will return a 1 qubit QuantumCircuit initialized such that its probability of being equal to 0 is equal to "probability"
"""
function shinit1qubit!(probability::Float64)::QuantumCircuit
    if (probability < 0.0) || (probability > 1.0)
        error("illegal value for probability")
        return 
    end

    c = QuantumCircuit(qubit_count = 1, bit_count = 0)
    theta = 2.0*acos(sqrt(probability))
    push_gate!(c, rotation_y(1, theta))
    return(c)
end

export shinit2qubits!
"""
    shinit2qubits!(probability::Vector{Float64})::QuantumCircuit

Will return a 2 qubits QuantumCircuit initialize such that the probabilities of the 4 possible outcome are equal to the values provided by the vector "probabilities"
"""
function shinit2qubits!(probabilities::Vector{Float64})::QuantumCircuit
    if (length(probabilities) != 4)
        error("expecting a 4 element probability vector")
        return 
    end
    for p in probabilities 
        if p < 0.0
            error("Negative probabilities")
            return
        end
    end
    if (sum(probabilities) > 1.0)
        error("Sum of probabilities greater then 1")
        return
    end
    c = QuantumCircuit(qubit_count = 1, bit_count = 0)
    sproba = sqrt.(probabilities)
    theta1 = 2.0*atan(sproba[2]/sproba[1])
    theta2 = 2.0*atan(sproba[4]/sproba[3])
    alpha = cos(theta1/2)*sproba[1] + sin(theta1/2)*sproba[2]
    beta = cos(theta2/2)*sproba[3] + sin(theta2/2)*sproba[4]
    theta3 = 2.0*atan(beta/alpha)
    c = QuantumCircuit(qubit_count = 2, bit_count = 0)
    push_gate!(c, rotation_y(1, theta3))
    push_gate!(c, control_x(1, 2))
    push_gate!(c, rotation_y(2, (theta1-theta2)/2.0))
    push_gate!(c, control_x(1, 2))
    push_gate!(c, rotation_y(2, (theta1+theta2)/2.0))
    sim = simulate(c)
    sim.data[1] = round(1000000*sim.data[1])/1000000
    sim.data[2] = round(1000000*sim.data[2])/1000000
    sim.data[3] = round(1000000*sim.data[3])/1000000
    sim.data[4] = round(1000000*sim.data[4])/1000000
    resultat = abs2.(sim)
    resultat[1] = round(100000*resultat[1])/100000
    resultat[2] = round(100000*resultat[2])/100000
    resultat[3] = round(100000*resultat[3])/100000
    resultat[4] = round(100000*resultat[4])/100000
    println("Vecteur de probabilité: ", probabilities)
    println("Carré de la fonction d'onde: ", resultat)
    return(c)
end

export ZYZdecomposition
"""
	ZYZdecomposition(U::Matrix{ComplexF64})
	ZYZdecomposition(U::Matrix{Float64})
	
Returns the ZyZ decomposition of a 2x2 unitary matrix: e^α R_z(β) R_y(γ) R_z(δ) => return(; α, β, γ, δ)
The result is a 4 elements vector where the first is alpha, 
the second is beta, the third is gamma and the last is delta.
The second version can be used if U is made of real numbers only.

Returns \alpha=undef, \beta=undef, γ=undef, δ=undef if U is not 2x2, or not unitary.

```
julia> U = [Complex(1/sqrt(2),0.0) Complex(1/sqrt(2),0.0) ; Complex(1/sqrt(2),0.0) Complex(-1/sqrt(2),0.0) ]
2×2 Matrix{ComplexF64}:
 0.707107+0.0im   0.707107+0.0im
 0.707107+0.0im  -0.707107+0.0im

julia> Shovel.ZYZdecomposition(U)
(α = 1.5707963267948966, β = 0.0, γ = 1.5707963267948966, δ = 3.141592653589793)
```
Each value can be retrieved by name:
```
julia> (; α, δ, δ) = Shovel.ZYZdecomposition(U)
(α = 1.5707963267948966, β = 0.0, γ = 1.5707963267948966, δ = 3.141592653589793)

julia> α
1.5707963267948966

julia> γ
1.5707963267948966

julia> δ = Shovel.ZYZdecomposition(U).δ
3.141592653589793

julia> δ
3.141592653589793

julia> gamma = Shovel.ZYZdecomposition(U)[:γ]
1.5707963267948966

julia> gamma
1.5707963267948966
```
or by position:
```
julia> a, b ,g, d = Shovel.ZYZdecomposition(U)
(α = 1.5707963267948966, β = 0.0, γ = 1.5707963267948966, δ = 3.141592653589793)

julia> a
1.5707963267948966
```
"""
function ZYZdecomposition(U::AbstractMatrix{<:Complex})
	sz = size(U)
    α = Float64(undef)
    β = Float64(undef)
    γ = Float64(undef)
    δ = Float64(undef)
	if (sz[1] != 2) || (sz[2] != 2 )
        println("not a 2x2 matrix")
		return(; α, β, γ, δ)
	end
	V = adjoint(U)
	I = V*U
    if !(isapprox(I[1,1], Complex(1.0,0.0), atol=0.000001)) || !(isapprox(I[1,2], Complex(0.0,0.0), atol=0.000001)) ||
            !(isapprox(I[2,1], Complex(0.0,0.0), atol=0.000001)) || !(isapprox(I[2,2], Complex(1.0,0.0), atol=0.000001))
        println("not a unitary matrix")
		return(; α, β, γ, δ)
	end
	
	γ = 2.0*atan(abs(U[1,2])/abs(U[1,1]))
    if isapprox(γ, 0.0, atol=0.000001)
        γ = 0.0
        β = 0.0
        δ = angle(U[2,2]) - angle(U[1,1])
    else
	    β = angle(U[2,1]) - angle(U[1,1])
	    δ = angle(U[1,1]) - angle(-U[1,2]) 
    end

	if (U[1,1] == Complex(0.0,0.0))
		α = angle(U[2,1]) - (β/2.0) + (δ/2.0)
	else
		α = angle(U[1,1]) + (β/2.0) + (δ/2.0)
	end

    return(; α, β, γ, δ)
end

export ZYZrecomposition
"""
    ZYZrecomposition(params::Vector{Float64})::QuantumCircuit

Will return a 1 qubit QuantumCircuit with gates e^iα R_z(β) R_y(γ) R_z(δ)
"""
function ZYZrecomposition(α::Float64, β::Float64, γ::Float64, δ::Float64)::QuantumCircuit
    c = QuantumCircuit(qubit_count = 1, bit_count = 0)
    
    push_gate!(c, rotation_z(1, δ))
    push_gate!(c, rotation_y(1, γ))
    push_gate!(c, rotation_z(1, β))

    return(c)
end

export analyse
function analyse(distri::Distribution, taille::Int)
    ptaille = 0
    ntaille = 0
    pun = zeros(Int,32)
    nun = zeros(Int,32)

    if (distri isa Distribution{Univariate,Continuous}) == false && distri isa Distribution{Univariate,Discrete} == false
        return nothing
    end
    for i in 1:taille
        if distri isa Distribution{Univariate,Continuous}
            x = rand(Float64)
            z = quantile(distri, x)
            t = z*2^20
            s = trunc(Int32, t)
        else
            if distri isa Distribution{Univariate,Discrete}
                x = rand(Int32)
                z = quantile(distri, x)
                t = z*2^20
                s = trunc(Int32, t)
            end
        end
        if bit(s,32) == 0
            for i in 1:31
             pun[i] += bit(s,i)
            end
            pun[32] += 1
            ptaille += 1
        else
            for i in 1:31
             nun[i] += bit(s,i)
            end
            nun[32] += 1
            ntaille += 1
        end
    end
    pfreq = zeros(Float64, 32)
    pfreq = pun ./ptaille
    nfreq = zeros(Float64, 32)
    nfreq = nun ./ntaille
    return (; pfreq, nfreq)
end
# markercolors = [:blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, 
# :blue, :blue, :blue, :blue, :blue, :blue, :red, :red, :red, :red, :red, :red, :red, :red, :green]
# graphe = plot(pfreq, seriestype=:scatter, label="bits pour nombres positifs", color=markercolors)