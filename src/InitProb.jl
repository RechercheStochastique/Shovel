using Snowflurry
using Distributions
using Random
using Bits
using Plots
using DataFrames
using GLM
using Revise
using Plots
using Printf
using HypothesisTests

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

    c = QuantumCircuit(qubit_count = 1)
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

#=
sign(freqbits::Vector{<:Number}) = freqbits[32]
exp31(freqbits::Vector{<:Number}) = freqbits[31]
exp30(freqbits::Vector{<:Number}) = freqbits[30]
exp29(freqbits::Vector{<:Number}) = freqbits[29]
exp28(freqbits::Vector{<:Number}) = freqbits[28]
exp27(freqbits::Vector{<:Number}) = freqbits[27]
exp26(freqbits::Vector{<:Number}) = freqbits[26]
exp25(freqbits::Vector{<:Number}) = freqbits[25]
exp24(freqbits::Vector{<:Number}) = freqbits[24]
frac23(freqbits::Vector{<:Number}) = freqbits[23]
frac22(freqbits::Vector{<:Number}) = freqbits[22]
frac21(freqbits::Vector{<:Number}) = freqbits[21]
frac20(freqbits::Vector{<:Number}) = freqbits[20]
frac19(freqbits::Vector{<:Number}) = freqbits[19]
frac18(freqbits::Vector{<:Number}) = freqbits[18]
frac17(freqbits::Vector{<:Number}) = freqbits[17]
frac16(freqbits::Vector{<:Number}) = freqbits[16]
frac15(freqbits::Vector{<:Number}) = freqbits[15]
frac14(freqbits::Vector{<:Number}) = freqbits[14]
frac13(freqbits::Vector{<:Number}) = freqbits[13]
frac12(freqbits::Vector{<:Number}) = freqbits[12]
frac11(freqbits::Vector{<:Number}) = freqbits[11]
frac10(freqbits::Vector{<:Number}) = freqbits[10]
frac9(freqbits::Vector{<:Number}) = freqbits[9]
frac8(freqbits::Vector{<:Number}) = freqbits[8]
frac7(freqbits::Vector{<:Number}) = freqbits[7]
frac6(freqbits::Vector{<:Number}) = freqbits[6]
frac5(freqbits::Vector{<:Number}) = freqbits[5]
frac4(freqbits::Vector{<:Number}) = freqbits[4]
frac3(freqbits::Vector{<:Number}) = freqbits[3]
frac2(freqbits::Vector{<:Number}) = freqbits[2]
frac1(freqbits::Vector{<:Number}) = freqbits[1]
=#

export bitsDF
function bitsDF(distri::Distribution, taille::Int, selection::Int...)

    dfbits = DataFrame(b32=Int8[], b31=Int[], b30=Int8[], b29=Int8[], b28=Int8[], b27=Int8[], b26=Int8[], b25=Int8[], b24=Int8[],
        b23=Int8[], b22=Int8[], b21=Int8[], b20=Int8[], b19=Int8[], b18=Int8[], b17=Int8[], b16=Int8[], b15=Int8[],
        b14=Int8[], b13=Int8[], b12=Int8[], b11=Int8[], b10=Int8[], b9=Int8[], b8=Int8[], b7=Int8[], b6=Int8[],
        b5=Int8[], b4=Int8[], b3=Int8[], b2=Int8[], b1=Int8[],
        compte=Int32[])

    for sel in selection
        if sel < 1 || sel > 32
            error("selected bits must be between 1 and 32 (Julia is base 1)")
            return df
        end
    end
    if (distri isa Distribution{Univariate,Continuous}) == false && distri isa Distribution{Univariate,Discrete} == false
        error("distri is not Univariate Continuous or Univariate Discrete")
        return df
    end

    dico = Dict{UInt32, Int32}()
    # We put in base 1 nottation  because it is easier to manipulate in Julia.
    selected = zeros(UInt8, 32)
    for sel in selection
        selected[sel] = 1
    end
    freqbits = zeros(Int32, 32)
    x = Float32(0.0)
    z = Float32(0.0)

    # We first generate a 32 bits random number according to the disired Distribution.
    for i in 1:taille
        if distri isa Distribution{Univariate,Continuous}
            x = rand(Float32)
            z = Float32(quantile(distri, x))
        elseif distri isa Distribution{Univariate,Discrete}
            x = rand(Int32)
            z = quantile(distri, x)
        end
        # Then we take the bit representation of the number.
        bitti = bits(z)

        # We now codify the 32 bits number into a UInt32 to use in the dictionary below.
        # The value corresponding to a key in the dictionary is the count of the number
        # occurence of the key.
        s = UInt32(0)
        for i in 1:32
            s += bitti[i]*selected[i]*2^(i-1)
            freqbits[i] += bitti[i]
        end
        # Now we check if this code is already present in the dictionary.
        compte = Int32(0)
        if haskey(dico, s) == false
            merge!(dico, Dict(s => 1)) # first occurence, count = 1.
        else
            compte = get(dico, s, 0)
            merge!(dico, Dict{Int64}{Int64}(s => compte+1)) # not new, count is increased.
        end
    end

    for (s, nombre) in pairs(dico)
        push!(dfbits, (bit(s,32), bit(s, 31), bit(s, 30), bit(s, 29), bit(s, 28), bit(s, 27), bit(s, 26), bit(s, 25), bit(s, 24), bit(s, 23), 
            bit(s, 22), bit(s, 21), bit(s, 20), bit(s, 19), bit(s, 18), bit(s, 17), bit(s, 16), bit(s, 15), bit(s, 14), 
            bit(s, 13), bit(s, 12), bit(s, 11), bit(s, 10), bit(s, 9), bit(s, 8), bit(s, 7), bit(s, 6), bit(s, 5), bit(s, 4), 
            bit(s, 3), bit(s, 2), bit(s, 1), nombre) )
    end

    return (; dfbits, freqbits)
end

export graphbits
function graphbits(distro::Distribution, freqbits::Vector{Int32}, taille::Int)::Plots.Plot{Plots.GRBackend}
    rfreqbits = Float64.(freqbits) ./ Float64(taille)
    frac = Vector{Int64}(undef,23)
    frac .= 1:23
    vfrac = Vector{Float64}(undef,23)
    vfrac = rfreqbits[1:23]
    exp = Vector{Int64}(undef,8)
    exp .= 24:31
    vexp = Vector{Float64}(undef,8)
    vexp .= rfreqbits[24:31]
    s = [32]
    vs = Vector{Float64}(undef,1)
    vs[1] = rfreqbits[32]
    titre = @sprintf("%s", distro)
    titreg = titre[1: findfirst("{", titre)[1]-1]
    titred = titre[findfirst("}",titre)[1]+1:end]
    titre = titreg*titred
    graphe = plot(frac, vfrac, seriestype=:scatter, label="bits de fraction", title=titre, 
        ylims=(-0.02,1.2), color=:green)
        
    plot!(graphe, exp, vexp, seriestype=:scatter, label="bits d'exposent", color=:red)
    plot!(graphe, s, vs, seriestype=:scatter, label="bit de signe", color=:blue)
    return graphe
end

export printfreq
function printfreq(freq::Vector{Float64}, compte::Vector{Int})
    relfreq = zeros(Float64, size(freq)[1])
    cumul = zeros(Float64, size(freq)[1])
    totalfreq = sum(freq)
    totalcompte = sum(compte)
    for i in 1:size(freq)[1]
        println(freq[i], " \t ", compte[i])
    end
    println("Compte total = ", totalcompte, "   Total tableau freq = ", totalfreq, "\n\n")
    for i in 1:size(freq)[1]
        relfreq[i] = freq[i] / totalfreq
        if i == 1 cumul[i] = relfreq[i]
        else cumul[i] = cumul[i-1] + relfreq[i]
        end
        println(relfreq[i], " & ", cumul[i], " \\\\")
    end
end

export validatemodel
function validatemodel(prediction::Vector{float}, compte::Vector{Int})
    return(PowerDivergenceTest(compte, lambda=1.0, theta0=prediction))
end

export generetableau
function generetableau(prediction::Vector{Float64}, taille::Int)::Vector{Float64}
    freq = zeros(Int64, size(prediction)[1])
    freqrel = zeros(Float64, size(prediction)[1])
    cumul = zeros(Float64, size(prediction)[1])
    cumul[1] = prediction[1]
    for i in 2:size(prediction)[1]
        cumul[i] = cumul[i-1] + prediction[i]
    end

    for i in 1:taille
        u = rand(Float32)
        for i = 1:(size(cumul)[1])
            if u < cumul[i] 
                freq[i]+=1
                break
            end
        end
    end

    freqrel = freq ./ sum(freq)

    return freqrel
end

export prediction2cumul
function prediction2cumul(prediction::Vector{Float64})::Vector{Float64}
    cumul = zeros(Float64, size(prediction)[1])
    cumul[1] = prediction[1]
    for i in 2:size(prediction)[1]
        cumul[i] = cumul[i-1] + prediction[i]
    end
    return cumul
end

export genereducumul
function genereducumul(freqrelbits::Vector{Float64}, cumul::Vector{Float64}, taille::Int, verbose=false, selection::Int...)::Vector{Float32}
    # En premier on s'occupe du tableau
    simulation = zeros(Float32, taille)
    for t in 1:taille
        u1 = rand(Float32)
        posit = Int32(1)
        bittbl = zeros(Bool, 32)

        posit = 1
        for i in 1:size(cumul)[1]
            if u1 > cumul[i] 
                posit = i
            else
                break
            end
        end
        nombre = Int32(posit - 1)
        bitti = bits(nombre) # <- ça ne met pas les bit à la bonne place. Mais bittbl sera bon.
        i = 1
        for sel in selection
            if bitti[i] == true 
                bittbl[sel] = true 
            else 
                bittbl[sel] = false 
            end
            i +=1
        end

        signe = 1.0
        if freqrelbits[32] != -1.0
            u2 = rand(Float32)
            if u2 < freqrelbits[32]
                signe = -1.0 
            end 
        else
            if bittbl[32] == true 
                signe = -1.0
            end 
        end

        exp = Int32(0)
        for i in 1:7 # ATTENTION on a retiré le bit 31 car on avait des "Inf" comme output
            if freqrelbits[23+i] != -1.0
                u3 = rand(Float32)
                if u3 < freqrelbits[23+i] 
                    exp += 2^(i-1) 
                end
            else
                if bittbl[23+i] == true 
                    exp += 2^(i-1)
                end
            end
        end
        # on traite le bit 31 à part ici
        #=
        if freqrelbits[31] != -1.0
            u = rand(Float32)
            if u < freqrelbits[31] 
                exp += 2^7
                exp -= 2^6 # on enlève le bit 30 dans ce cas
            end
        else
            if bittbl[31] == true
                exp += 2^7
                exp -= 2^6 # on enlève le bit 30 dans ce cas
            end
        end
        =#
        exp = exp - Int32(127)

        frac = Float32(1.0)
        for i in 1:23
            if freqrelbits[24-i] != -1.0
                u4 = rand(Float32)
                if u4 < freqrelbits[24-i] 
                    frac += 2.0^(-i)
                end
            else
                if bittbl[24-i] == true 
                    frac += 2.0^(-i)
                end
            end
        end

        infini = false
        #expo = Float32(2.0^exp) # <- pourquoi on a mis ça? C'est pas déjà un exposant?
        valeur = Float32(exp * frac)
        if valeur == Inf
            infini = true
        end
        valeur = signe * valeur
        simulation[t] = valeur

        if verbose == true || infini == true
            @show u1
            @show nombre
            @show posit
            @show bitti
            @show bittbl
            @show signe
            @show exp
            @show frac
            @show valeur
        end
    end
    return simulation
end

#=
import Pkg; Pkg.activate(".")
using Distributions, DataFrames, Plots, GLM, HypothesisTests, Bits
using Shovel
distro = Normal(0.0, 1.0);
taille = 1000000;
#
# Option 1
#
dfbits, freqbits = bitsDF(distro, taille, 26,25,24,23,22,21,20); 
graphe = graphbits(distro, freqbits, taille)
savefig(graphe, "bits_normal(0.0,1.0).png")
#
# frequences relatives pour chaque bit
#
freqrelbits = Vector{float}(undef, size(freqbits)[1])
for i = 1:size(freqrelbits)[1] freqrelbits[i] = freqbits[i] / sum(freqbits) end
freqrelbits[26] = -1.0
freqrelbits[25] = -1.0
freqrelbits[24] = -1.0
freqrelbits[23] = -1.0
freqrelbits[22] = -1.0
freqrelbits[21] = -1.0
freqrelbits[20] = -1.0

sort!(dfbits, [:b26, :b25, :b24, :b23, :b22, :b21, :b20]);
viewbits = view(dfbits, :, [:compte, :b26, :b25, :b24, :b23, :b22, :b21, :b20]);
compte = Vector{Int}(undef, size(viewbits)[1]);
for i in 1:size(viewbits)[1] compte[i] = viewbits.compte[i] end
# Modèle saturé
#gm1 = fit(GeneralizedLinearModel, @formula(compte ~ b26*b25*b24*b23*b22*b21*b20), viewbits, Poisson())
# modèle simplifié
gm1 = fit(GeneralizedLinearModel, @formula(compte ~ 1+ b26*b25*b24*b23 + b26*b25*b24*b22 + b26*b25*b24*b21 + b26*b25*b24*b20), viewbits, Poisson())
#coeff = gm1.model.pp.beta0 .- gm1.model.pp.delbeta # contient les paramètres
prediction = predict(gm1); # donne les valeurs prédites. A comparer avec viewbits qu'il faut trier
prediction = prediction ./ sum(prediction);
PowerDivergenceTest(compte, lambda=1.0, theta0=prediction) # test du chi-deux
compterel = compte ./ sum(compte);
plot(prediction, seriestype=:sticks, label="modèle", title="fréquences observées versus fréquences du modèle")
plot!(compterel, seriestype=:line, label="fréquences observées")
#
# Option 2
#
dfbits, freqbits = bitsDF(distro, taille, 26,25,24,23,22,21);
graphe = graphbits(distro, freqbits, taille)
savefig(graphe, "bits_normal(0.0,1.0).png")
freqrelbits = Vector{Float64}(undef, size(freqbits)[1]);
for i = 1:size(freqrelbits)[1] freqrelbits[i] = freqbits[i] / taille end
freqrelbits[26] = -1.0;
freqrelbits[25] = -1.0;
freqrelbits[24] = -1.0;
freqrelbits[23] = -1.0;
freqrelbits[22] = -1.0;
freqrelbits[21] = -1.0;

sort!(dfbits, [:b26, :b25, :b24, :b23, :b22, :b21]);
viewbits = view(dfbits, :, [:compte, :b26, :b25, :b24, :b23, :b22, :b21]);
compte = Vector{Int}(undef, size(viewbits)[1]);
for i in 1:size(viewbits)[1] compte[i] = viewbits.compte[i] end
# Modèle saturé
#gm1 = fit(GeneralizedLinearModel, @formula(compte ~ b26*b25*b24*b23*b22*b21), viewbits, Poisson())
# modèle simplifié
gm1 = fit(GeneralizedLinearModel, @formula(compte ~ 1+ b26*b25*b24*b23 + b26*b25*b24*b22 + b26*b25*b24*b21), viewbits, Poisson())
prediction = predict(gm1);
prediction = prediction ./ sum(prediction);
PowerDivergenceTest(compte, lambda=1.0, theta0=prediction)
compterel = compte ./ sum(compte);
plot(compterel, seriestype=:sticks, label="observé")
plot!(prediction, seriestype=:line, label="modèle")
savefig("modèle simplifié.png")
#
#
#
cumul = prediction2cumul(prediction);
simulation = genereducumul(freqrelbits,cumul, 10000, 26,25,24,23,22,21);
plot(simulation, seriestype=:histogram, label="simulé")
=#