using Snowflake
using Revise

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
    println("Circuit id: ", plg.circuit.id, "   qubit: ", plg.qubit)
end

Base.:(==)(plg1::Plug, plg2::Plug) = ((plg1.circuit == plg2.circuit && plg1.qubit == plg2.qubit) ? true : false)

Base.show(io::IO, plg::Plug) = printPlug(io, plg)


export Connector
"""
Connector is a structure containing two plugs: 1) the input plug which is when the qubit/circuit is coming from and 2) the output plug indicating
to which qubit/circuit it is going to.
Users can either create plugs and then a connector from them or directly create a connector by providing the circuit and the qubit.
The operator "==" is defined for connectors.
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
    if connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout 
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

export Wire
"""
structure Wire is a sequence of connector making a wire in the MQC.
"""
mutable struct Wire
    order::Int
    elements::Vector{Connector}
    Wire() = new(0, Vector{Connector}())
    Wire(i::Int) = new(i, Vector{Connector}())
end

function ismember(connec::Connector, wire::Wire)::Bool
    for con in wire.elements
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
    for connec in wire.elements
        printConnector(io, connec)
    end
end

Base.show(io::IO, wire::Wire) = printWire(io, wire)

function ismember(plg::Plug, wire::Wire)::Bool
    for con in wire.elements
        if plg == con.plugin || plg == con.plugout 
            return true 
        end
    end
    return false
end
mutable struct CircuitPosition
    circuit::QuantumCircuit
    stage::Int
    top::Int
    bottom::Int
    CircuitPosition(circuit::QuantumCircuit) = new(circuit, 0, 100000000, 0)
end

export MQC
"""
The structure MQC is the main element of the Meta Quantum Circuit utility.
After adding quantum circuits (or "circuits" for short) and connectors, a quantikz/LaTeX file can be produced.
Most importantly, a new circuit can be generated from the MQC. 
"""
struct MQC
    circuit_list::Vector{QuantumCircuit}
    connector_list::Vector{Connector}
    wire_list::Vector{Wire}
    circuitposi_list::Vector{CircuitPosition}
    MQC() = new(Vector{QuantumCircuit}(), Vector{Connector}(), Vector{Wire}(), Vector{CircuitPosition}())
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
    for c in mqc.circuit_list
        if c.id == connec.plugin.circuit.id
            if connec.plugin.qubit > c.qubit_count
                println(stderr, "the qubit of plugin in connector is out of reach")
                return false
            end
            infound = true 
        end
        if c.id == connec.plugout.circuit.id
            if connec.plugout.qubit > c.qubit_count
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
    for con in mqc.connector_list
        if connec.plugin == con.plugin
            println(stderr, "There is already a connector with the same plugin in the MQC")
            return false
        end
        if connec.plugout == con.plugout
            println(stderr, "There is already a connector with the same plugout in the MQC")
            return false
        end
    end

    # At this point the connector seems good but we have yet to validate circularity
    # We first copy all connectors in the augmented list.
    augmented_list = Vector{Connector}(undef,0)
    for con in mqc.connector_list
        push!(augmented_list, con)
    end
    # Now we will create bogus connector in the augmented list to have all plugs related in a wire.
    added = true
    while added == true
        added = false
        for i in 1:length(mqc.connector_list)-1
            connec1 = mqc.connector_list[i]
            for j in i:length(mqc.connector_list)
                connec2 = mqc.connector_list[j]
                if connec1.plugin == connec2.plugout # They are in the same wire
                    connec3 = Connector(connec2.plugin, connec1.plugout)
                    push!(augmented_list, connec3)
                    added = true
                end
                if connec1.plugout == connec2.plugin # They are in the same wire
                    connec3 = Connector(connec1.plugin, connec2.plugout)
                    push!(augmented_list, connec3)
                    added = true
                end
            end
        end
    end

    for con in augmented_list
        if isinverse(connec, con) == true
            println(stderr, "There is a circular definition")
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

    println("There are ", length(mqc.connector_list), " connectors in the MQC")
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
    println("There are ", nbwire, " wires in the MQC")
    totalqubit = 0
    for circuit in mqc.circuit_list
        totalqubit = totalqubit + circuit.qubit_count
    end
    println("While there is a total of ", totalqubit, " qubits (adding all qubits in all circuits of the MQC)")

    # We now create the temporary phi circuit as an origin of the MQC
    # and add the pseudo connector originating from phi.
    # These new connectors are at the begining of the wire
    phi = QuantumCircuit(qubit_count = nbwire, bit_count = 0)
    println("We have created the pseudo circuit phi with the following definition:")
    printlightQC(stdout, phi)
    println("\n\n")
    i = Int(1)
    for plg2 in pseudoplugin_list
        plg1 =Plug(phi, i)
        connec = Connector(plg1, plg2)
        push!(pseudoconnec_list, connec)
        wire = Wire(i)
        push!(wire.elements, connec)
        push!(mqc.wire_list, wire)
        i = i + 1
    end
    # We now have a list of wires with the first (pseudo)connector in it.
    for wire in mqc.wire_list
        printWire(stdout, wire)
    end

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
    println("We now have pseudoplugs in pseudoplugout_list:")

    # We now create the temporary psi circuit as exit circuit of the MQC
    # and add the pseudo connector ending to psi.
    psi = QuantumCircuit(qubit_count = nbwire, bit_count = 0)
    i = Int(1)
    for plg1 in pseudoplugout_list
        plg2 =Plug(psi, i)
        connec = Connector(plg1, plg2)
        push!(pseudoconnec_list, connec)
    end

    # We add the genuine connector to the pseudo connector list
    for connec in mqc.connector_list
        push!(pseudoconnec_list, connec)
    end
    println("ici3")
    # Now we start at the beginning of each wire and find the list of connector composing it.
    println("psi.id = ", psi.id)
    i = 0
    for wire in mqc.wire_list
        i = i + 1
        connec1 = wire.elements[end]
        println("Le wire numero ", i, " contient ", length(wire.elements), " connecteurs.")
        println("Le dernier connecteur a pour plugout.circuit.id : ", connec1.plugout.circuit.id, " et pour qubit: ", connec1.plugout.qubit)
    end
    #=
    for wire in mqc.wire_list
        terminated = false
        while terminated == false
            connec1 = wire.elements[end]
            for connec2 in pseudoconnec_list
                if connec1.plugout == connec2.plugin # connec2 is the nex member of the wire
                    push!(wire.elements, connec2)
                    if connec2.plugout.circuit == psi.id # we're done with the wire if we reached psi
                        terminated = true
                    end
                end
            end
        end
    end
    =#
    println("ici4")
    return nothing

end

function position!(mqc::MQC)
    for circuit in mqc.circuit_list
        circposi = CircuitPosition(circuit)
        push!(mqc.circuitposi_list, circposi)
    end

    # We find the stage of the circuit
    update = true
    while update == true
        update = false
        for connec in mqc.connector_list
            cirin = connec.plugin.circuit
            cirout = connec.plugout.circuit
            for circposi in mqc.circuitposi_list
                if cirin == circposi.circuit
                    circposiin = circposi
                end
                if cirout == circposi.circuit
                    circposiout = circposi
                end
            end
            if circposiout.stage < (circposiin + 1)
                circposiout.stage = circposiin + 1
                update = true
            end
        end
    end

    # We now find the overlay of the circuit
    for wire in mqc.wire_list
        for connec in wire.elements
            for circposi in mqc.circuitposi_list
                if circposi.circuit == connect.plugin.circuit
                    if circposi.top > wire.order
                        circposi.top = wire.order
                    end
                    if circposi.bottom < wire.order
                        circposi.bottom = wire.order
                    end
                end
            end
        end
    end
    # At this point the circuits are positionned both horizontally (stage) and vertically (top/bottom).

    return nothing

end

export sew

"""
sew(mqc::MQC)

This function turns an MQC into a standard Snowflake QuantumCircuit
"""
function sew(mqc::MQC)
    findwire!(mqc)
    println("findwire! is done")
    position!(mqc)
    println("position! is done")

    newcircuit = QuantumCircuit(qubit_count = length(mqc.wire_list), bit_count = 0)

    # We first establish an equivalence table betwwen qubit/circuit and wire
    equiv = Dict{Plug, Int}()
    for wire in mqc.wire_list
        for i in 1:length(wire.elements)-1
            connec = wire.elements[i]
            merge!(equiv, Dict(connec.plugout, wire.order))
        end
    end

    nbstage = 0
    for circposi in mqc.circuitposi_list
        if nbstage < circposi.stage
            nbstage = circposi.stage
        end
    end

    newpipeline = Vector{Array{Gate}}
    for i in 1:nbstage
        for circposi in mqc.circuitposi_list
            if circposi == i
                circuit = circposi.circuit
                for Vgate1 in circuit.pipeline
                    Vgate2 = copy(Vgate1)
                    for Agate2 in Vgate2
                        for gate in Agate2
                            for target in gate
                                for qubit1 in target
                                    plug = Plug(circposi.circuit, qubit1)
                                    qubit2 = get(equiv, plug, 0)
                                    qubit1 = qubit2
                                end
                            end
                            # At this point Agate2 is an adapted version of Agate1
                            # It can be pushed to the metacircuit.
                            push_gate!(newcircuit, Agate2)
                        end
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
