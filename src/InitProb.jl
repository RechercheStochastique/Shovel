using Snowflake
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
	ZYZdecomposition(U::Matrix{ComplexF64})::Vector{Float64}
	ZYZdecomposition(U::Matrix{Float64})::Vector{Float64}
	
Returns the ZyZ decomposition of a 2x2 unitary matrix: e^α R_z(β) R_y(γ) R_z(δ). 
The result is a 4 elements vector where the first is alpha, 
the second is beta, the third is gamma and the last is delta.
The second version can be used if U is made of real numbers only.

Returns a vector of #undef if U is not 2x2, or not unitary.
"""
function ZYZdecomposition(U::Matrix{ComplexF64})::Vector{Float64}
	params = Vector{Float64}(undef, 4)
	sz = size(U)
	if (sz[1] != 2) || (sz[2] != 2 )
		return(params)
	end
	V = adjoint(U)
	I = V*U
    if !(isapprox(I[1,1], Complex(1.0,0.0), rtol=0.001)) || !(isapprox(I[1,2], Complex(0.0,0.0), rtol=0.001)) ||
            !(isapprox(I[2,1], Complex(0.0,0.0), rtol=0.001)) || !(isapprox(I[2,2], Complex(1.0,0.0), rtol=0.001))
		return(params)
	end
	
	params[3] = 2.0*atan(abs(U[1,2])/abs(U[1,1]))
    if isapprox(params[3], 0.0, rtol=0.00001)
        params[3] = 0.0
        params[2] = 0.0
        params[4] = angle(U[2,2]) - angle(U[1,1])
    else
	    params[2] = angle(U[2,1]) - angle(U[1,1])
	    params[4] = angle(U[1,1]) - angle(-U[1,2]) 
    end

	if (U[1,1] == Complex(0.0,0.0))
		params[1] = angle(U[2,1]) - (params[2]/2.0) + (params[4]/2.0)
	else
		params[1] = angle(U[1,1]) + (params[2]/2.0) + (params[4]/2.0)
	end

    return(params)
end

function ZYZdecomposition(U::Matrix{Float64})::Vector{Float64}
	params = Vector{Float64}(undef, 4)
	sz = size(U)
	if (sz[1] != 2) || (sz[2] != 2 )
		return(params)
	end
	V = transpose(U)
	I = V*U
	if !(isapprox(I[1,1], Complex(1.0,0.0), rtol=0.001)) || !(isapprox(I[1,2], Complex(0.0,0.0), rtol=0.001)) ||
            !(isapprox(I[2,1], Complex(0.0,0.0), rtol=0.001)) || !(isapprox(I[2,2], Complex(1.0,0.0), rtol=0.001))
		return(params)
	end
	
	params[3] = 2.0*atan(abs(U[1,2])/abs(U[1,1]))
    if isapprox(params[3], 0.0, rtol=0.00001)
        params[3] = 0.0
        params[2] = 0.0
        params[4] = angle(U[2,2]) - angle(U[1,1])
    else
	    params[2] = angle(U[2,1]) - angle(U[1,1])
	    params[4] = angle(U[1,1]) - angle(-U[1,2]) 
    end

	if (U[1,1] == Complex(0.0,0.0))
		params[1] = angle(U[2,1]) - (params[2]/2.0) + (params[4]/2.0)
	else
		params[1] = angle(U[1,1]) + (params[2]/2.0) + (params[4]/2.0)
	end

    return(params)
end