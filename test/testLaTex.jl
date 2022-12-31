using Test
using Snowflake
using Shovel

c = QuantumCircuit(qubit_count=3, bit_count=0);
@test typeof(c1) == QuantumCircuit
@test uuid_version(c1.id) == 1

push_gate!(c, hadamard(1));
push_gate!(c, rotation_y(1, 1.2));
push_gate!(c, rotation_x(3, 0.69));
push_gate!(c, control_x(1,2));
push_gate!(c, control_x(1,3));
push_gate!(c, control_x(1,2));
push_gate!(c, rotation_y(3, 1.99));
push_gate!(c, control_x(1,2));
push_gate!(c, control_x(1,3));
push_gate!(c, rotation_y(3, 1.99));
push_gate!(c, rotation_x(2, -0.29));

simulate(c)

shoperator(c)
