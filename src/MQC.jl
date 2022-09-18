using Snowflake

export Plug
"""
Plug is a structure containing the UUID of a circuit and a qubit number. It is the basic element of a Connector.
The only validation done is that the qubit number of the circuit is valid (>0 and <=qubit_count).
The operator "==" is defined for plugs.
"""
struct Plug
    circuit::Base.UUID
    qubit::Int
    Plug(c::QuantumCircuit, qb::Int) = ((qb < 1 || qb > c.qubit_count) ? nothing : new(c.id, qb))
end

Base.:(==)(plg1::Plug, plg2::Plug) = ((plg1.circuit == plg2.circuit && plg1.qubit == plg2.qubit) ? true : false)

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

Base.:(==)(connec1::Connector, connec2::Connector) = (if connec1.plugin == connec2.plugin && connec1.plugout == connec2.plugout return true else return false end)

export isinverse
"""
isinverse(connec1::Connector, connec2::Connector)::Boolean 

A function to checks if a given connector is the inverse of another one.
    The function is used for internal consistency when a connector is added to an MQC. it will return true if 
        "connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout"
        and false otherwise.
"""
function isinverse(connec1::Connector, connec2::Connector)::Boolean
    if connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout 
        return true 
    else 
        return false
    end
end

export isbefore
"""
isbefore(connec1::Connector, connec2::Connector)::Boolean 

A function to checks if the output plug of connec1 is the same as the input plug of connec2.
    if true, it means that connec1 is just before connec2 and they are connected together in the same wire.
"""
function isbefore(connec1::Connector, connec2::Connector)::Boolean
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
end

function ismember(connec::Connector, wire::Wire)::Boolean
    for con in wire.elements
        if connec == con return true end
    end
    return false
end

function ismember(plg::Plug, wire::Wire)::Boolean
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
    MQC() = new(Vector{QuantumCircuit}(), Vector{Connector}(), Vector{Wire}())
end

export MQCAddCircuit
"""
MQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Boolean 

This function is used to add a Snowflake QuantumCircuit to an MQC.
    A given circuit cannot be add twice ot the MQC. However, two distinct circuits with identical circuitry can.
    The function will retrun true if the addition was successful.
"""
function MQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Boolean
    # check if circuit is already there
    for c in mqc.circuit_list
        if newc.id == c.id
            error("Circuit already there, can't add")
            return false
        end
    end

    push!(mqc.CircuitList, newc)
    return true
end

export MQCAddConnector
"""
MQCAddConnector(mqc::MQC, connec::Connector)::Boolean 

This function is used to add a connector to an MQC. It has some consistancy checks and will return
    false if the proposed connector creates inconsistencies such as circular circuitry or duplicate plugs.
"""
function MQCAddConnector(mqc::MQC, connec::Connector)::Boolean
    # Check if Plug is acceptable.
    # Firstly, are the circuits and plugs existant.

    infound = false
    outfound = false
    for c in mqc.circuit_list
        if c.id == connec.plugin.circuit
            if connec.plugin.qubit > c.qubit_count
                error("the qubit of plugin in connector is out of reach")
                return flase
            end
            infound = true 
        end
        if c.id == connec.plugout.circuit
            if connec.plugout.qubit > c.qubit_count
                error("out port of wire is out of qbit reach")
                return false
            end
            outfound = true
        end
    end

    if infoud == false || outfound == false
        error("At least one circuits defined in the plugs of the connector are not in the circuit list of the MQC. Noting to connect to")
        return false
    end

    # Now, is there a duplicate
    for con in mqc.connector_list
        if connec.plugin == con.plugin
            error("There is already a connector with the same plugin in the MQC")
            return false
        end
        if connec.plugout == con.plugout
            error("There is already a connector with the same plugout in the MQC")
            return false
        end
    end

    # At this point the connector seems good but we have yet to validate circularity
    augmented_list = Vector{Connector}(undef,0)
    for con in mqc.connector_list
        push!(augmented_list, con)
    end
    for i in 1:length(mqc.connector_list)-1
        connec1 = mqc.connector_list[i]
        for j in i:length(mqc.connector_list)
            connec2 = mqc.connector_list[j]
            if connec1.plugin == connec2.plugout
                connec3 = Connector(connec2.plugin, connec1.plugout)
                push!(augmented_list, connec3)
            end
            if connec1.plugout == connec2.plugin
                connec3 = Connector(connec1.plugin, connec2.plugout)
                push!(augmented_list, connec3)
            end
        end
    end
    for con in augmented_list
        if isinverse(connec, con) == true
            error("There is a circular definition")
            return false
        end
    end
    return true

end

#= 
export sew
"""
sew(mqc::MQC)

This is the main function of an MQC. It will output a valide Snowflake QuantumCircuit made up of the different circuits
    in it and according to the connector provided.
"""
function sew(mqc::MQC)
    if length(mqc.CircuitList) == 1 return end # nothing to do with only 1 circuit.
    if length(mqc.QPortList) == 0 return end # nothing to do with no connecting wire.

    # We are in this function because either a QuantumCircuit was added or a QPlug

    # Case for an added QuantumCircuit
    # There can't be any QPlug associated to this circuit since it is new in the MQC. So it has rank=2
    # All 

    # we first rank the circuits from left to right
    nochange = false
    while nochange == false
        nochange = true
        for cwrout in mqc.CircuitList
            for qport in mqc.QPortList
                if cwrout.qc.id == qport.PortOut.QCid # The circuit is at the  end of at least one wire.
                    for cwrin in mqc.CircuitList
                        if cwrin.qc.id == qport.PortIn.QCid # This circuit is outputing to the other one
                            if cwrout.qc.rank < cwrin.qc.rank+1
                                cwrout.qc.rank = cwrin.qc.rank+1
                                nochange = false
                            end
                        end
                    end
                end
            end
        end
    end
    # at this point all circuits should have a rank . No?
    mqc.maxrank = 0
    for cwr in mqc.CircuitList
        if cwr.rank > mqc.maxrank  mqc.maxrank = cwr.rank end
    end

    # We now order the wires from top to buttom.
    # The total number of wires is equal to the total number of ports connecting to nothing.
    mqc.nbwire = 0
    for cwr in mqc.CircuitList
        found = false
        for wire in 1:cwr.qc.qubit_count
            for qport in mqc.QPortList
                if cwr.qc.id == qport.PortIn.QCid
                    found = true
                    break
                end
            end
            if found == false
                mqc.nbwire = mqc.nbwire + 1
            end
        end
    end

    # We now know how many wires we're working with.
    # We clear all QPorts order and restart.
    for port in mqc.QPortList
        port.QPlug.order = 0
    end
    for cwr in mqc.CircuitList
        if cwr.rank == 1
            for 
    mqc.diagram = Matrix{Base.UUID}(undef, mqc.nbwire, mqc.maxrank)
    # For each wire we need to "run" through it and see what is thare a reach rank.
    for rank in 1:mqc.maxrank
        for cwr in mqc.CircuitList
            if cwr.rank == rank # The qbits of that circuit have to be assigned to a wire order.
            end
        end

                
end =#