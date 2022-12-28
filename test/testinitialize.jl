using Test
using Snowflake
using Shovel

trialsize = Int64(1000)
csimple = QuantumCircuit(qubit_count=1, bit_count=0);
proba = 0.25;
theta = 2.0*acos(sqrt(proba));
push_gate!(csimple, rotation_y(1, theta));
simulate(csimple)
result = simulate_shots(csimple, trialsize);
absfreq = [0, 0]
Shovel.buildfreq!(absfreq, result, 1)
relfreq = Float64(absfreq[1])/length(result);
@test abs(relfreq - proba) < 0.1
