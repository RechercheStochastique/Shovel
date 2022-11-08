# Converting a QuantumCircuit into a Quantikz/LaTeX output

The ToLaTeX function is used to produce a \LaTeX output from either a Snowflake QuantumCircuit or a MQC (Meta Quantum Circuit). The output invokes for the Quantikz package.

The output for a QuantumCircuit is a literral transcription of the circuit as displayed in Julia with the Snowflake package. It can be send to a file or display in stdout for cut&paste into a scientific document.

The output for the MQC is more symbolic. Each circuit composing the MQC are displayed along all wires (qubit) used. A wire going over a circuit implies that the wire does not enter the circuit and simply cotinues to the next. If a wire enters a circuit, it is shown which qubit "relative to the circuit" is used.
