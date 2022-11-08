export Plug
"""
Plug is a structure containing the UUID of a circuit and a qubit number. It is the basic element of a Connector.
The only validation done is that the qubit number of the circuit is valid (>0 and <=qubit_count).
The operator "==" is defined for plugs.
"""
struct Plug
    circuit::QuantumCircuit
    qubit::Int
    Plug(c::QuantumCircuit, qb::Int) = ((qb < 1 || qb > c.qubit_count) ? nothing : new(c, qb))
end

function printPlug(io::IO, plg::Plug)
    println(io, "Circuit id: ", plg.circuit.id, "   qubit: ", plg.qubit)
end

Base.:(==)(plg1::Plug, plg2::Plug) = ((plg1.circuit == plg2.circuit && plg1.qubit == plg2.qubit) ? true : false)

Base.show(io::IO, plg::Plug) = printPlug(io, plg)


export Connector
"""
Connector is a structure containing two plugs: 1) the input plug which is when the qubit/circuit is coming from and 2) the output plug indicating
to which qubit/circuit it is going to.
Users can either create plugs and then a connector from them or directly create a connector by providing the circuit and the qubit.
The operator "==" is defined for connector_list.
"""
mutable struct Connector
    plugin::Plug
    plugout::Plug
    stage::Int
    wire::Int
    Connector(plg1::Plug, plg2::Plug) = new(plg1, plg2, 0, 0)
    Connector(c1::QuantumCircuit, qb1::Int, c2::QuantumCircuit, qb2::Int) = (
        plg1=Plug(c1,qb1); plg2=Plug(c2,qb2); new(plg1, plg2, 0, 0))
end

function printConnector(io::IO, connec::Connector)
    print(io, "Plugin  = ")
    printPlug(io, connec.plugin)
    print(io, "Plugout = ")
    printPlug(io, connec.plugout)
end

Base.:(==)(connec1::Connector, connec2::Connector) = (if connec1.plugin == connec2.plugin && connec1.plugout == connec2.plugout return true else return false end)

Base.show(io::IO, connec::Connector) = printConnector(io, connec)

export isinverse
"""
isinverse(connec1::Connector, connec2::Connector)::Bool 

A function to checks if a given connector is the inverse of another one.
    The function is used for internal consistency when a connector is added to an MQC. it will return true if 
        "connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout"
        and false otherwise.
"""
function isinverse(connec1::Connector, connec2::Connector)::Bool
    if connec1.plugin == connec2.plugout && connec1.plugout == connec2.plugin
        return true 
    else 
        return false
    end
end

export isbefore
"""
isbefore(connec1::Connector, connec2::Connector)::Bool 

A function to checks if the output plug of connec1 is the same as the input plug of connec2.
    if true, it means that connec1 is just before connec2 and they are connected together in the same wire.
"""
function isbefore(connec1::Connector, connec2::Connector)::Bool
    if connec1.plugout == connec2.plugin
        return true
    else
        return false
    end
end

"""
structure Wire is a sequence of connector making a wire in the MQC.
"""
mutable struct Wire
    order::Int
    connector_list::Vector{Connector}
    Wire() = new(0, Vector{Connector}())
    Wire(i::Int) = new(i, Vector{Connector}())
end

function ismember(connec::Connector, wire::Wire)::Bool
    for con in wire.connector_list
        if connec == con return true end
    end
    return false
end

function printWire(io::IO, wire::Wire)
    if wire.order == 0
        println("wire order not yet determined. Use function \"sew\" with a MQC")
    else
        println("Wire order = ", wire.order)
    end
    for connec in wire.connector_list
        printConnector(io, connec)
    end
end

Base.show(io::IO, wire::Wire) = printWire(io, wire)

function ismember(plg::Plug, wire::Wire)::Bool
    for con in wire.connector_list
        if plg == con.plugin || plg == con.plugout 
            return true 
        end
    end
    return false
end
mutable struct CircuitPosition
    circuit::QuantumCircuit
    stage::Int
    CircuitPosition(circuit::QuantumCircuit) = new(circuit, 1)
end

export MQC
"""
The structure MQC is the main element of the Meta Quantum Circuit utility.
After adding quantum circuits (or "circuits" for short) and connector_list, a quantikz/LaTeX file can be produced.
Most importantly, a new circuit can be generated from the MQC. 
"""
struct MQC
    circuit_list::Vector{QuantumCircuit}
    connector_list::Vector{Connector}
    wire_list::Vector{Wire}
    MQC() = new(Vector{QuantumCircuit}(), Vector{Connector}(), Vector{Wire}())
end

export printlightQC
"""
printlightQC(io::IO, circuit::QuantumCircuit)
A quick display of basic info on a QuantumCircuit
"""
function printlightQC(io::IO, circuit::QuantumCircuit)
    println(io, "circuit id: ", circuit.id, "  qubit_count = ", circuit.qubit_count, "  pipeline size = ", length(circuit.pipeline))
end

export printMQC
"""
printMQC(io::IO, mqc::MQC)
Summary print of what's inside a MQC
"""
function printMQC(io::IO, mqc::MQC)
    println(io, "\nThe MQC is made of these circuits:")
    for circuit in mqc.circuit_list
        printlightQC(io, circuit)
    end
    println(io, "\nAnd these connector")
    i = 0
    for connec in mqc.connector_list
        i = i + 1
        println(io, "Connector ", i)
        printConnector(io, connec)
    end
    print(io, "\n\n")
end


Base.show(io::IO, mqc::MQC) = printMQC(io, mqc)

export MQCAddCircuit
"""
MQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Bool 

This function is used to add a Snowflake QuantumCircuit to an MQC.
    A given circuit cannot be add twice ot the MQC. However, two distinct circuits with identical circuitry can.
    The function will retrun true if the addition was successful.
"""
function MQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Bool
    # check if circuit is already there
    for c in mqc.circuit_list
        if newc.id == c.id
            println(stderr, "Circuit already there, can't add")
            return false
        end
    end

    push!(mqc.circuit_list, newc)
    return true
end

export MQCAddConnector
"""
MQCAddConnector(mqc::MQC, connec::Connector)::Bool 

This function is used to add a connector to an MQC. It has some consistancy checks and will return
    false if the proposed connector creates inconsistencies such as circular circuitry or duplicate plugs.
"""
function MQCAddConnector(mqc::MQC, connec::Connector)::Bool
    # Check if Plug is acceptable.
    # Firstly, are the circuits and plugs existant.

    infound = false
    outfound = false
    for circuit in mqc.circuit_list
        if circuit.id == connec.plugin.circuit.id
            if connec.plugin.qubit > circuit.qubit_count
                println(stderr, "the qubit of plugin in connector is out of reach")
                return false
            end
            infound = true 
        end
        if circuit.id == connec.plugout.circuit.id
            if connec.plugout.qubit > circuit.qubit_count
                println(stderr, "out port of wire is out of qbit reach")
                return false
            end
            outfound = true
        end
    end

    if infound == false || outfound == false
        println(stderr, "At least one circuits defined in the plugs of the connector are not in the circuit list of the MQC. Noting to connect to")
        return false
    end

    # Now, is there a duplicate
    for connec2 in mqc.connector_list
        if connec.plugin == connec2.plugin
            println(stderr, "There is already a connector with the same plugin in the MQC")
            return false
        end
        if connec.plugout == connec2.plugout
            println(stderr, "There is already a connector with the same plugout in the MQC")
            return false
        end
    end

    # At this point the connector seems good but we have yet to validate circularity
    # We first copy all connector_list in the augmented list.
    augmented_list = Vector{Connector}(undef,0)
    for con in mqc.connector_list
        push!(augmented_list, con)
    end
    # Now we will create bogus connectors in the augmented list to have all plugs related in a wire.
    added = true
    while added == true
        added = false
        for i in 1:length(mqc.connector_list)-1
            connec1 = mqc.connector_list[i]
            for j in (i+1):length(mqc.connector_list)
                connec2 = mqc.connector_list[j]
                if connec1.plugin == connec2.plugout # They are in the same wire
                    connec3 = Connector(connec2.plugin, connec1.plugout)
                    # We now check id connec3 is not already in the augmented list
                    alreadythere = false
                    for connec4 in augmented_list
                        if connec4 == connec3
                            alreadythere = true
                        end
                    end
                    if alreadythere == false
                        push!(augmented_list, connec3)
                        added = true
                    end
                end
                if connec1.plugout == connec2.plugin # They are in the same wire
                    connec3 = Connector(connec1.plugin, connec2.plugout)
                    # We now check id connec3 is not already in the augmented list
                    # If it is a genuine new connector we add it to the augmented list
                    alreadythere = false
                    for connec4 in augmented_list
                        if connec4 == connec3
                            alreadythere = true
                        end
                    end
                    if alreadythere == false
                        push!(augmented_list, connec3)
                        added = true
                    end
                end
            end
        end
    end

    for connec2 in augmented_list
        if isinverse(connec, connec2) == true
            println(stderr, "\n\n\nThere is a circular definition")
            println(stdout, connec)
            println(stdout, connec2)
            return false
        end
    end

    # OK, no circularity we can add the connector
    push!(mqc.connector_list, connec)

    return true

end

"""
findwire!(mqc::MQC)

Builds the wires of the MQC. Provided for sake of completeness. Users should not need it in normal circumstances. Returns nothing
The "sew" function uses it.
"""
function findwire!(mqc::MQC)
    nbwire = Int(0)
    pseudoplugin_list = Vector{Plug}()
    pseudoplugout_list = Vector{Plug}()
    pseudoconnec_list = Vector{Connector}()

    for circuit in mqc.circuit_list
        for qubit in 1:circuit.qubit_count
            plg = Plug(circuit, qubit)
            found = false
            for connec in mqc.connector_list
                if plg == connec.plugout
                    found = true
                end
            end
            if found == false
                nbwire = nbwire + 1
                push!(pseudoplugin_list, plg)
            end
        end
    end

    totalqubit = 0
    for circuit in mqc.circuit_list
        totalqubit = totalqubit + circuit.qubit_count
    end

    # We now create the temporary phi circuit as an origin of the MQC
    # and add the pseudo connector originating from phi.
    # These new connector_list are at the begining of the wire
    phi = QuantumCircuit(qubit_count = nbwire, bit_count = 0)

    i = Int(0)
    for plg2 in pseudoplugin_list
        i = i + 1
        plg1 =Plug(phi, i)
        connec = Connector(plg1, plg2)
        push!(pseudoconnec_list, connec)
        wire = Wire(i)
        push!(wire.connector_list, connec)
        push!(mqc.wire_list, wire)
    end
    # We now have a list of wires with the first (pseudo in) connector in it.

    for circuit in mqc.circuit_list
        for qubit in 1:circuit.qubit_count
            plg = Plug(circuit, qubit)
            found = false
            for connec in mqc.connector_list
                if plg == connec.plugin
                    found = true
                end
            end
            if found == false
                push!(pseudoplugout_list, plg)
            end
        end
    end

    # We now create the temporary psi circuit as exit circuit of the MQC
    # and add the pseudo connector ending to psi.
    psi = QuantumCircuit(qubit_count = nbwire, bit_count = 0)

    i = 0
    for plg1 in pseudoplugout_list
        i = i + 1
        plg2 =Plug(psi, i)
        connec = Connector(plg1, plg2)
        push!(pseudoconnec_list, connec)
    end

    # We add the genuine connector to the pseudo connector list
    for connec in mqc.connector_list
        push!(pseudoconnec_list, connec)
    end

    # Now we start at the beginning of each wire and find the list of connector composing it.

    for wire in mqc.wire_list
        terminated = false
        while terminated == false
            terminated = true
            connec1 = wire.connector_list[end]
            for connec2 in pseudoconnec_list
                if connec1.plugout == connec2.plugin # connec2 is the next member of the wire
                    push!(wire.connector_list, connec2)
                    if connec2.plugout.circuit != psi.id # we're done with the wire if we reached psi
                        terminated = false
                    end
                end
            end
        end
    end

    return nothing
end

function position!(mqc::MQC)::Vector{CircuitPosition}
    
    circuitposi_list = Vector{CircuitPosition}()

    for circuit in mqc.circuit_list
        circposi = CircuitPosition(circuit)
        push!(circuitposi_list, circposi)
    end

    # We find the stage of the circuit
    circposiin = nothing
    circposiout = nothing
    update = true
    while update == true
        update = false
        for connec in mqc.connector_list
            for circposi in circuitposi_list
                if connec.plugin.circuit.id == circposi.circuit.id
                    circposiin = circposi
                end
                if connec.plugout.circuit.id == circposi.circuit.id
                    circposiout = circposi
                end
            end
            if circposiout.stage < (circposiin.stage + 1)
                circposiout.stage = circposiin.stage + 1
                update = true
            end
        end
    end

    # Several circuits may have the same stage at this point. An arbitrary choice must be done to
    # to push some circuit further right keeping the sequance intact.
    for stage in 1:length(circuitposi_list)
        first = false
        for circ in circuitposi_list
            if circ.stage == stage 
                if first == false
                    first = true
                else
                    circ.stage = circ.stage + 1
                end
            end
        end
    end
    # At this point the circuits are positionned both horizontally (stage).

    return circuitposi_list

end

function safecopy(oldpipe)::Vector{Gate}
    newpipe = Vector{Gate}()
    newdispsym = copy(oldpipe[1].display_symbol)
    newinstsymb = string(oldpipe[1].instruction_symbol)
    newoperator = Operator(oldpipe[1].operator.data)
    newtarget = copy(oldpipe[1].target)
    newparam = copy(oldpipe[1].parameters)
    newgate = Gate(newdispsym, newinstsymb, newoperator, newtarget, newparam)
    push!(newpipe, newgate)
        
    return newpipe
end

export sew
"""
sew(mqc::MQC)

This function turns an MQC into a standard Snowflake QuantumCircuit
"""
function sew(mqc::MQC)::QuantumCircuit
    findwire!(mqc)
    circuitposi_list = position!(mqc)

    newcircuit = QuantumCircuit(qubit_count = length(mqc.wire_list), bit_count = 0)

    # We first establish an equivalence table betwwen qubit/circuit and wire
    equiv = Dict{Plug, Int}()
    for wire in mqc.wire_list
        for i in 1:length(wire.connector_list)-1
            connec = wire.connector_list[i]
            equiv2 = Dict{Plug, Int}(connec.plugout => wire.order)
            equiv = merge(equiv, equiv2)
        end
    end

    for stage in 1:length(mqc.circuit_list)
        for circposi in circuitposi_list
            if circposi.stage == stage
                circuit = circposi.circuit
                for i in 1:length(circuit.pipeline)
                    pipe = safecopy(circuit.pipeline[i])
                    for j in 1:lastindex(pipe)
                        gate = pipe[j]
                        for k in 1:length(gate.target)
                            qubit1 = gate.target[k]
                            plug = Plug(circposi.circuit, qubit1)
                            qubit2 = get(equiv, plug, 0)
                            gate.target[k] = qubit2
                        end
                        push!(newcircuit.pipeline, pipe)
                    end
                end
                # All Vector{Array{Gate}} of the circuit are done
            end
        end
        # All circuits at stage i are done
    end

    # All circuits in the MQC are done and newpipeline contains all info with proper qubit numbering

    return newcircuit
end
