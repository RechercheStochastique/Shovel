using Test
using Snowflake
using Shovel
using UUIDs

c1 = QuantumCircuit(qubit_count=4, bit_count=0);
@test typeof(c1) == QuantumCircuit
@test uuid_version(c1.id) == 1

push_gate!(c1, [hadamard(1)]);
push_gate!(c1, [control_x(1, 2)]);
push_gate!(c1, sigma_x(1));
push_gate!(c1, control_z(1,2));
push_gate!(c1, [hadamard(3)]);
push_gate!(c1, [hadamard(4)]);
push_gate!(c1, control_z(2,4));
push_gate!(c1, control_z(1,3));
push_gate!(c1, control_z(4,1));

c2 = QuantumCircuit(qubit_count=4, bit_count=0);

push_gate!(c2, [hadamard(1)]);
push_gate!(c2, [control_x(1, 2)]);
push_gate!(c2, sigma_x(1));
push_gate!(c2, control_z(1,2));
push_gate!(c2, [hadamard(3)]);
push_gate!(c2, [hadamard(4)]);
push_gate!(c2, control_z(2,4));
push_gate!(c2, control_z(1,3));
push_gate!(c2, control_z(4,1));

c3 = QuantumCircuit(qubit_count=4, bit_count=0);

push_gate!(c3, [hadamard(1)]);
push_gate!(c3, [control_x(1, 2)]);
push_gate!(c3, sigma_x(1));
push_gate!(c3, control_z(1,2));
push_gate!(c3, [hadamard(3)]);
push_gate!(c3, [hadamard(4)]);
push_gate!(c3, control_z(2,4));
push_gate!(c3, control_z(1,3));
push_gate!(c3, control_z(4,1));

c4 = QuantumCircuit(qubit_count=4, bit_count=0);

push_gate!(c4, [hadamard(1)]);
push_gate!(c4, [control_x(1, 2)]);
push_gate!(c4, sigma_x(1));
push_gate!(c4, control_z(1,2));
push_gate!(c4, [hadamard(3)]);
push_gate!(c4, [hadamard(4)]);
push_gate!(c4, control_z(2,4));
push_gate!(c4, control_z(1,3));
push_gate!(c4, control_z(4,1));

c5 = QuantumCircuit(qubit_count=6, bit_count=0);
push_gate!(c5, [hadamard(1)]);
push_gate!(c5, [hadamard(5)]);
push_gate!(c5, [hadamard(6)]);
push_gate!(c5, [control_x(1, 2)]);
push_gate!(c5, sigma_x(1));
push_gate!(c5, control_z(1,2));
push_gate!(c5, [hadamard(3)]);
push_gate!(c5, [hadamard(4)]);
push_gate!(c5, control_z(2,4));
push_gate!(c5, control_z(1,3));
push_gate!(c5, control_z(4,1));
push_gate!(c5, [control_x(5, 3)]);
push_gate!(c5, [control_x(6, 4)]);
push_gate!(c5, [control_x(2, 6)]);

#=printlightQC(stdout, c1)
printlightQC(stdout, c2)
printlightQC(stdout, c3)
printlightQC(stdout, c4)
printlightQC(stdout, c5)=#

mqc = MQC();
@test typeof(mqc) == MQC

con1_1 = Connector(c1, 2, c2, 1) ; #println(con1_1);
con1_2 = Connector(c1, 3, c2, 2) ; #println(con1_2);
con1_3 = Connector(c1, 4, c2, 3) ; #println(con1_3);
con2_1 = Connector(c2, 2, c3, 1) ; #println(con2_1);
con2_2 = Connector(c2, 3, c3, 2) ; #println(con2_2);
con2_3 = Connector(c2, 4, c3, 3) ; #println(con2_3);
con3_1 = Connector(c3, 2, c4, 1) ; #println(con3_1);
con3_2 = Connector(c3, 3, c4, 2) ; #println(con3_2);
con3_3 = Connector(c3, 4, c4, 3) ; #println(con3_3);
con4_1 = Connector(c4, 1, c5, 3) ; #println(con4_1);
con4_2 = Connector(c4, 3, c5, 2) ; #println(con4_2);
con4_3 = Connector(c4, 4, c5, 5) ; #println(con4_3);

@test MQCAddCircuit(mqc, c1) == true
@test MQCAddCircuit(mqc, c2) == true
@test MQCAddCircuit(mqc, c3) == true
@test MQCAddCircuit(mqc, c4) == true
@test MQCAddCircuit(mqc, c5) == true
@test MQCAddConnector(mqc, con1_1) == true
@test MQCAddConnector(mqc, con1_2) == true
@test MQCAddConnector(mqc, con1_3) == true
@test MQCAddConnector(mqc, con2_1) == true
@test MQCAddConnector(mqc, con2_2) == true
@test MQCAddConnector(mqc, con2_3) == true
@test MQCAddConnector(mqc, con3_1) == true
@test MQCAddConnector(mqc, con3_2) == true
@test MQCAddConnector(mqc, con3_3) == true
@test MQCAddConnector(mqc, con4_1) == true
@test MQCAddConnector(mqc, con4_2) == true
@test MQCAddConnector(mqc, con4_3) == true

newc = sew(mqc)
@test ToLaTeX(mqc, "testMQCTeX.tex") == true

@test ToLaTeX(newc, "testMQCTeX2.tex") == true
