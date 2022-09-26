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

plug1_1 = Plug(c1, 1);
plug1_2= Plug(c1, 2);
plug1_3= Plug(c1, 3);
plug1_4 = Plug(c1, 4);
@test typeof(plug1_1) == Plug

c2 = QuantumCircuit(qubit_count=6, bit_count=0);
push_gate!(c2, [hadamard(1)]);
push_gate!(c2, [hadamard(5)]);
push_gate!(c2, [hadamard(6)]);
push_gate!(c2, [control_x(1, 2)]);
push_gate!(c2, sigma_x(1));
push_gate!(c2, control_z(1,2));
push_gate!(c2, [hadamard(3)]);
push_gate!(c2, [hadamard(4)]);
push_gate!(c2, control_z(2,4));
push_gate!(c2, control_z(1,3));
push_gate!(c2, control_z(4,1));
push_gate!(c2, [control_x(5, 3)]);
push_gate!(c2, [control_x(6, 4)]);
push_gate!(c2, [control_x(2, 6)]);

plug2_1 = Plug(c2, 1);
plug2_2 = Plug(c2, 2);
plug2_3 = Plug(c2, 3);
plug2_4 = Plug(c2, 4);
plug2_5 = Plug(c2, 5);
plug2_6 = Plug(c2, 6);

connec1 = Connector(plug1_1, plug2_3);
@test typeof(connec1) == Connector
connec2 = Connector(plug2_3, plug1_1);
@test isinverse(connec1, connec2) == true
@test isbefore(connec1, connec2) == true
connec3 = Connector(plug1_1, plug2_3);
@test connec1 == connec3
connec4 = Connector(plug1_3, plug2_4);

mqc = MQC();
@test typeof(mqc) == MQC

@test MQCAddCircuit(mqc, c1) == true
@test MQCAddCircuit(mqc, c2) == true
@test MQCAddConnector(mqc, connec1) == true
@test MQCAddConnector(mqc, connec2) == false # connec2 is an inverse of connec1. It should fail.
@test MQCAddConnector(mqc, connec3) == false # connec3 is on the same plug as connec1
@test MQCAddConnector(mqc, connec4) == true

printMQC(stdout, mqc)

sew(mqc)
