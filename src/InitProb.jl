using Snowflake

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