struct Plug
    circuit::Base.UUID
    qbit::Int
    Plug(c::QuantumCircuit, qb::Int) = new(c.id, qb)
end

mutable struct Connector
    plugin::Plug
    plugout::Plug
    stage::Int = 0
    wire::Int = 0
    Connector(plg1::Plug, plg2::Plug) = new(plg1, plg2, 0, 0)
    Connector(c1::QuantumCircuit, qb1::Int, c2::QuantumCircuit, qb2::Int) = (
        plg1=Plug(c1,qb1); plg2=Plug(c2,qb2); new(plg1, plg2, 0, 0))
end

mutable struct Wire
    order::Int
    elements::Vector{Connector}
end

mutable struct CircuitPosition
    circuit::QuantumCircuit
    stage::Int
    top::Int
    bottom::Int
end

struct MQC
    circuit_list::Vector{Snowflake.QuantumCircuit}(undef,0)
    connector_list::Vector{Connector}(undef,0)
    wire_list::Vector{Wire}(undef,0)
    MQC(crv::Vector{QuantumCircuit}) = (
        mcq = new(); for c in crv push!(mcq.circuit_list, c) end; return mcq)
    MQC(crv::Vector{QuantumCircuit}, cnv::Vector{Connector}) = (
        mcq = new(); for c in crv push!(mcq.circuit_list, c) end; 
        for n in cnv push!(mcq.connector_list, c) end; return mcq)
end

function MQCAddQC(mqc::MQC, newc::SnowFlakeQuantumCircuit)
    # check if circuit is already there
    for c in mqc.CircuitList
        if newc.id == c.id
            error("Circuit already there, can't add")
            return nothing
        end
    
    push!(mqc.CircuitList, newc)
    push!(mcq.CircuitRanking, (newc.id, 2))
    mqc.nbwire = mqc.nbwire + newc.qubit_count

    # We now create a QPlug for all the new qbits from this new circuit. They all connect to the
    # bogus starting circuit with id=0. The total number of wires is increased accordingly.
    for i in 1:newc.qubit_count
        mqc.nbwire = mqc.nbwire +1
        qp = QPlug(0,mqc.nbwire, newc.id, i)
        push!(mqc.QPortList, qp)
    end

    #sew(mqc)
end

function MQCAddQPlug(mqc::MQC, qplug::QPlug)
    # Check if qplug is acceptable.
    # Firstly, are the circuits and plugs existant.
    infound = false
    outfound = false
    for c in mqc.CircuitList
        if c.id == qplug.QCidin
            if qplug.Qwin > c.qubit_count
                error("\"in\" port of plug is out of qubit reach")
                return nothing
            end
            infound = true 
        end
        if c.id == qplug.QCidout
            if qplug.Qwout > c.qubit_count
                error("out port of wire is out of qbit reach")
                return nothing
            end
            outfound = true
        end
    end
    if infoud == false || outfound == false
        error("the circuits defined in the QPlug are not in the circuit list")
        return nothing
    end

    # Now, is there a duplicate
    for plg in mqc.QPortList
        if plg.QCidin == qplug.QCidin && plg.Qwin == qplug.Qwin
            error("There is already a QPlug with the same \"in\" connetions")
            return nothing
        end
        if plg.QCidout == qplug.QCidout && plg.Qwout == qplug.Qwout
            error("There is already a QPlug with the same \"out\" connetions")
            return nothing
        end
    end

    # All is fine, we can add this QPlug.
    # But this has consequnces. 
    #    1- A wire is potentially disapearing 
    #    2- The rank of a circuit may need to be updated.

    push!(mqc.QPortList, qplug)

    #sew(mqc)
end

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
                if cwrout.qc.id = qport.PortOut.QCid # The circuit is at the  end of at least one wire.
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