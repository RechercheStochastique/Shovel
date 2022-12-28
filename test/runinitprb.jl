using Snowflake

Prob1 = 0.85
Prob2 = 0.55


println("On fait une rotation sur x un circuit de un seul qubit")
Theta1 = acos(sqrt(Prob1))
println("Prob1=[", Prob1, ", ", 1-Prob1, "]  Theta1=", Theta1)
Theta2 = acos(sqrt(Prob2))

c1 = QuantumCircuit(qubit_count = 1, bit_count = 0)
Snowflake.push_gate!(c1, rotation_x(1, 2.0*Theta1))
Psi1 = simulate(c1)
Psi1.data[1] = round(1000000*Psi1.data[1])/1000000
Psi1.data[2] = round(1000000*Psi1.data[2])/1000000
println("Psi1:\n", Psi1.data)
println("Attendu:\nComplex[", Complex(cos(Theta1), 0), ", ", Complex(0, sin(Theta1)), "]")
ss1 = abs2.(Psi1.data)
ss1[1] = round(100000*ss1[1])/100000
ss1[2] = round(100000*ss1[2])/100000
println("ss1 =  ", ss1)

println("\n\nOn fait la même chose mais la rotation est sur y")
c1 = QuantumCircuit(qubit_count = 1, bit_count = 0)
Snowflake.push_gate!(c1, rotation_y(1, 2.0*Theta1))
Psi1 = simulate(c1)
Psi1.data[1] = round(1000000*Psi1.data[1])/1000000
Psi1.data[2] = round(1000000*Psi1.data[2])/1000000
println("Psi1:\n", Psi1.data)
println("Attendu:\nComplex[", Complex(cos(Theta1), 0), ", ", Complex(sin(Theta1), 0), "]")
ss1 = abs2.(Psi1.data)
ss1[1] = round(100000*ss1[1])/100000
ss1[2] = round(100000*ss1[2])/100000
println("ss1 =  ", ss1)

println("\n\nOn fait la même chose mais la rotation est sur z")
c1 = QuantumCircuit(qubit_count = 1, bit_count = 0)
Snowflake.push_gate!(c1, rotation_z(1, 2.0*Theta1))
Psi1 = simulate(c1)
Psi1.data[1] = round(1000000*Psi1.data[1])/1000000
Psi1.data[2] = round(1000000*Psi1.data[2])/1000000
println("Psi1:\n", Psi1.data)
println("Attendu:\nComplex[", Complex(cos(Theta1), -sin(Theta1)), "]")
ss1 = abs2.(Psi1.data)
ss1[1] = round(100000*ss1[1])/100000
ss1[2] = round(100000*ss1[2])/100000
println("ss1 =  ", ss1)

println("\n\n\nMaintenant un prend un cicuit de 2 qubits et on fait une rotation sur chacun puis un cnot")
println("Prob1=[", Prob1, ", ", 1-Prob1, "]  Theta1=", Theta1)
println("Prob2=[", Prob2, ", ", 1-Prob2, "]  Theta2=", Theta2)
c2 = QuantumCircuit(qubit_count = 2, bit_count = 0)
Snowflake.push_gate!(c2, rotation_x(1, 2.0*Theta1))
println("Après la première rotation Theta1 sur le premier qubit on a:")
Psi2 = simulate(c2)
Psi2.data[1] = round(1000000*Psi2.data[1])/1000000
Psi2.data[2] = round(1000000*Psi2.data[2])/1000000
Psi2.data[3] = round(1000000*Psi2.data[3])/1000000
Psi2.data[4] = round(1000000*Psi2.data[4])/1000000
println("Psi2:\n", Psi2.data)
println("Attendu:\nComplex[", 
   Complex(cos(Theta1), 0), 
   Complex(0,0), 
   Complex(0, sin(Theta1)), 
   Complex(0,0),"]")
Snowflake.push_gate!(c2, rotation_x(2, 2.0*Theta2))
println("\nAprès la seconde rotation Theta2 sur le second qubit on a:")
Psi2 = simulate(c2)
Psi2.data[1] = round(1000000*Psi2.data[1])/1000000
Psi2.data[2] = round(1000000*Psi2.data[2])/1000000
Psi2.data[3] = round(1000000*Psi2.data[3])/1000000
Psi2.data[4] = round(1000000*Psi2.data[4])/1000000
println("Psi2:\n", Psi2.data)
println("Attendu:\nComplex[", 
   Complex(cos(Theta1)*cos(Theta2), 0), 
   Complex(0, cos(Theta1)*sin(Theta2)), 
   Complex(0, sin(Theta1)*cos(Theta2)),
   Complex(-sin(Theta1)*sin(Theta2), 0),"]")
println("\nAprès le CNOT on a:")
Snowflake.push_gate!(c2, control_x(1,2))
Psi2 = simulate(c2)
Psi2.data[1] = round(1000000*Psi2.data[1])/1000000
Psi2.data[2] = round(1000000*Psi2.data[2])/1000000
Psi2.data[3] = round(1000000*Psi2.data[3])/1000000
Psi2.data[4] = round(1000000*Psi2.data[4])/1000000
println("Psi2:\n", Psi2.data)
println("Attendu:\nComplex[",
Complex(cos(Theta1)*cos(Theta2), 0), 
Complex(0, cos(Theta1)*sin(Theta2)), 
Complex(-sin(Theta1)*sin(Theta2), 0),
Complex(0, sin(Theta1)*cos(Theta2)),"]")
ss2 = abs2.(Psi2.data)
ss2[1] = round(100000*ss2[1])/100000
ss2[2] = round(100000*ss2[2])/100000
ss2[3] = round(100000*ss2[3])/100000
ss2[4] = round(100000*ss2[4])/100000
println(ss2)

println("\nOn fait une rotation additionnelle Teta3 sur le deuxième qubit et on a")
Prob3 = 0.30
Theta3 = acos(sqrt(Prob3))
println("Prob3=[", Prob3, ", ", 1-Prob3, "]  Theta3=", Theta3)
Snowflake.push_gate!(c2, rotation_x(2, 2.0*Theta3))
Psi2 = simulate(c2)
Psi2.data[1] = round(1000000*Psi2.data[1])/1000000
Psi2.data[2] = round(1000000*Psi2.data[2])/1000000
Psi2.data[3] = round(1000000*Psi2.data[3])/1000000
Psi2.data[4] = round(1000000*Psi2.data[4])/1000000
println("Psi2:\n", Psi2.data)
println("Attendu:\nComplex[", 
   Complex((cos(Theta3)*cos(Theta1)*cos(Theta2))+(sin(Theta3)*cos(Theta1)*sin(Theta2)), 0), 
	Complex(0, (sin(Theta3)*cos(Theta1)*cos(Theta2))+(cos(Theta3)*cos(Theta1)*sin(Theta2))),
	Complex(-(cos(Theta3)*sin(Theta1)*sin(Theta2))+(sin(Theta3)*sin(Theta1)*cos(Theta2))),
	Complex(0,(sin(Theta3)*sin(Theta1)*sin(Theta2))-(cos(Theta3)*sin(Theta1)*cos(Theta2))), "]")
ss2 = abs2.(Psi2.data)
ss2[1] = round(100000*ss2[1])/100000
ss2[2] = round(100000*ss2[2])/100000
ss2[3] = round(100000*ss2[3])/100000
ss2[4] = round(100000*ss2[4])/100000
println(ss2)


c3 = QuantumCircuit(qubit_count = 2, bit_count = 0)
Snowflake.push_gate!(c3, rotation_y(1, pi/2.0))
Snowflake.push_gate!(c3, rotation_y(2, pi/2.0))
println("\nNouveau circuit de 2 qubits")
println("Après 2 rotation y de pi/2")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)

c3 = QuantumCircuit(qubit_count = 2, bit_count = 0)
Snowflake.push_gate!(c3, rotation_x(1, pi/2.0))
Snowflake.push_gate!(c3, rotation_x(2, pi/2.0))
println("\nNouveau circuit de 2 qubits")
println("Après 2 rotation x de pi/2")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)

c3 = QuantumCircuit(qubit_count = 2, bit_count = 0)
Snowflake.push_gate!(c3, hadamard(1))
Snowflake.push_gate!(c3, hadamard(2))

println("\nNouveau circuit de 2 qubits")
println("Après 2 hadamard")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)

Phi1 = (Theta1 + Theta2)/2.0
Phi2 = (Theta1 - Theta2)/2.0

Snowflake.push_gate!(c3, rotation_x(2, 2.0*Phi1))
println("Après une rotation Phi1 du deuxième qubit")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)
Snowflake.push_gate!(c3, control_x(1,2))
println("Après un cnot du premier controlant le second")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)
Snowflake.push_gate!(c3, rotation_x(2, 2.0*Phi2))
println("Après une seconde rotation Phi2 du deuxième qubit")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)
Snowflake.push_gate!(c3, control_x(1,2))
println("Après un dernier cnot")
Psi4 = simulate(c3)
ss4 = abs2.(Psi4.data)
println(Psi4.data)
println(ss4)

print("\n\n\n\n\nMaintenant le vrai stuff!\n\n")
p1 = 0.1
p2 = 0.25
p3 = 0.5
p4 = round(1000000*(1 - p1 - p2 - p3))/1000000
proba = [p1 p2 p3 p4]
sproba = sqrt.(proba)
theta1 = 2.0*atan(sproba[2]/sproba[1])
theta2 = 2.0*atan(sproba[4]/sproba[3])
alpha = cos(theta1/2)*sproba[1] + sin(theta1/2)*sproba[2]
beta = cos(theta2/2)*sproba[3] + sin(theta2/2)*sproba[4]
theta3 = 2.0*atan(beta/alpha)
c4 = QuantumCircuit(qubit_count = 2, bit_count = 0)
Snowflake.push_gate!(c4, rotation_y(1, theta3))
Snowflake.push_gate!(c4, control_x(1, 2))
Snowflake.push_gate!(c4, rotation_y(2, (theta1-theta2)/2.0))
Snowflake.push_gate!(c4, control_x(1, 2))
Snowflake.push_gate!(c4, rotation_y(2, (theta1+theta2)/2.0))
sim = simulate(c4)
sim.data[1] = round(1000000*sim.data[1])/1000000
sim.data[2] = round(1000000*sim.data[2])/1000000
sim.data[3] = round(1000000*sim.data[3])/1000000
sim.data[4] = round(1000000*sim.data[4])/1000000
resultat = abs2.(sim)
resultat[1] = round(100000*resultat[1])/100000
resultat[2] = round(100000*resultat[2])/100000
resultat[3] = round(100000*resultat[3])/100000
resultat[4] = round(100000*resultat[4])/100000
println("Vecteur de probabilité: ", proba)
println("Carré de la fonction d'onde: ", resultat)