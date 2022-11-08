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

coeflin = [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0]

result = shootuntil(c1, 0.001, 0.05, coeflin, true)
println(result)

result = shootuntil(sqrt, c1, 0.001, 0.05, coeflin, true)
println(result)
