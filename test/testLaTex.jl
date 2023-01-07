using Test
using Snowflake
using Shovel

c = QuantumCircuit(qubit_count=4, bit_count=0);

push_gate!(c, hadamard(1));
push_gate!(c, rotation_y(1, 1.2));
push_gate!(c, sigma_x(1));
push_gate!(c, rotation_x(2, 0.70));
push_gate!(c, rotation_z(2, 0.10));
push_gate!(c, sigma_y(2));
push_gate!(c, sigma_z(2));
push_gate!(c, phase(2));
push_gate!(c, rotation_y(3, 1.70));
push_gate!(c, rotation_z(3, 1.10));
push_gate!(c, pi_8(3));
push_gate!(c, x_90(4));
push_gate!(c, rotation(4, 1.1, 0.6));
push_gate!(c, phase_shift(4, 2.5));
push_gate!(c, control_x(1, 2));
push_gate!(c, control_z(2, 4));
push_gate!(c, iswap(2,4));
push_gate!(c, toffoli(3, 1, 2));
push_gate!(c, universal(4, 0.8, 1.4, 2.4));
println(c)
simulate(c)
#shoperator(c)
shLaTeX(c, "R:/test.tex")
