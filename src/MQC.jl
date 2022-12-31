export Plug
"""
    Plug(c::QuantumCircuit, qb::Int)

# Members
- `circuit::QuantumCircuit`
- `qubit::Int` a valid qubit number within the above circuit (1 ≤ qubit ≤ circuit.qubit_count)

Plug is a structure containing the UUID of a Snowflake quantum circuit and a qubit number. It is the building block of a Connector.
The only validation done is that the qubit number of the circuit is valid (>0 and <=qubit_count).

The comparison operator "==" is defined for plugs and returns true with both plugs connect the same qubits of the same circuits.

# Example
```
julia> plg = Plug(c, 1)
Circuit id: f5335690-885a-11ed-3814-393fb2ae6861   qubit: 1

julia> plg2 = Plug(c,2)
Circuit id: f5335690-885a-11ed-3814-393fb2ae6861   qubit: 2

julia> plg == plg2
false
```
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
    Connector(plg1::Plug, plg2::Plug)
    Connector(c1::QuantumCircuit, qb1::Int, c2::QuantumCircuit, qb2::Int)

Connector is a structure containing two plugs: 1) the input plug which is when the qubit/circuit is coming from and 2) the output plug indicating
to which qubit/circuit it is going to.
Users can either create plugs and then a connector from them or directly create a connector by providing the circuit and the qubit.

The comparison operator "==" is defined for connectors and returns true if they have the same plugs from the same circuits IN THE SAME ORDER. If the two connectors have the same plugs but in REVERSE order, then 
function [`isinverse`](@ref) should be used to check.

The two other members are used to order them within a [`shMQC`](@ref) and need not be documented at initialization time.

# Members
- `plugin::Plug` the begining of the connector (circuit & qubit).
- `plugout::Plug`  the end of the connector (circuit & qubit).
- `stage::Int` not needed at construction time.
- `wire::Int` not needed at construction time.

# Example
In the example above, the connector is crated directly without the use of plugs. However, these will be created in the connector. Members "stage" and "wire" are used only within the shMQC at the final
construction phase [`shsew`](@ref)
```
julia> c1 = QuantumCircuit(qubit_count=4, bit_count=0);

julia> c2 = QuantumCircuit(qubit_count=4, bit_count=0);

julia> con1_1 = Connector(c1, 2, c2, 1)
Plugin  = Circuit id: 84fbcf80-8880-11ed-354f-3dafa0e9bdc6   qubit: 2
Plugout = Circuit id: 89614c80-8880-11ed-160b-75d0fd206f1d   qubit: 1
```
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
"connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout" and false otherwise.

# Example
As can be seen in the example above, the second connector is define as the inverse of the first. Since a [`shMQC`](@ref) cannot contain contradictory path, this function is used to exclude this type of situation.
```
julia> con1_1 = Connector(c1, 2, c2, 1)
Plugin  = Circuit id: 84fbcf80-8880-11ed-354f-3dafa0e9bdc6   qubit: 2
Plugout = Circuit id: 89614c80-8880-11ed-160b-75d0fd206f1d   qubit: 1

julia> con1_2 = Connector(c2, 1, c1, 2)
Plugin  = Circuit id: 89614c80-8880-11ed-160b-75d0fd206f1d   qubit: 1
Plugout = Circuit id: 84fbcf80-8880-11ed-354f-3dafa0e9bdc6   qubit: 2

julia> isinverse(con1_1, con1_2)
true
```
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

A function to checks if the output plug of connec1 is the same as the input plug of connec2. If true, it means that connec1 is just before connec2 and they are connected together in the same wire.

# Example
Three circuits are created and connector con1_1 goes from c1 to c2 while con1_2 goes from c2 to c3. Additionally, the starting qubit of con1_2 is the same as the ending qubit of con1_1. Therefore
cont1_1 is before con1_2.
```
julia> c1 = QuantumCircuit(qubit_count=4, bit_count=0);

julia> c2 = QuantumCircuit(qubit_count=4, bit_count=0);

julia> c3 = QuantumCircuit(qubit_count=4, bit_count=0);

julia> con1_1 = Connector(c1, 2, c2, 1)
Plugin  = Circuit id: 71b5cfa0-8882-11ed-0999-6ff9e4725693   qubit: 2
Plugout = Circuit id: 76869190-8882-11ed-12cd-8935492334e6   qubit: 1

julia> con1_2 = Connector(c2, 1, c3, 1)
Plugin  = Circuit id: 76869190-8882-11ed-12cd-8935492334e6   qubit: 1
Plugout = Circuit id: 802c0d10-8882-11ed-1449-7b4ca7f5e3a1   qubit: 1

julia> isbefore(con1_1, con1_2)
true
```
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
    Wire
    
The structure Wire is used to position [`Connector`](@ref)s into a [`shMQC`](@ref). It is created while sewing the circuits together using [`shsew`](@ref) and not normally used by end users.
Connectors belonging to the same wire are all connected to each other in a sequential order ( [`isbefore`])(@ref) is therefore true for two subsequent connectors in the connector_list. 

# Members
- `order::Int` in the shMQC the wires are ordered from top (=1) to buttom.
- `connector_list::Vector{Connector}` is a list of [`Connector`](@ref)s composing the Wire.
"""
mutable struct Wire
    order::Int
    connector_list::Vector{Connector}
    Wire() = new(0, Vector{Connector}())
    Wire(i::Int) = new(i, Vector{Connector}())
end

export ismember
"""
    ismember(connec::Connector, wire::Wire)::Bool
    ismember(plg::Plug, wire::Wire)::Bool

Checks if a given [`Connector`](@ref) or [`Plug`](@ref) is already in a [`Wire`](@ref). Another internal function checking if a connector is part of a given wire in a [`shMQC`](@ref).
This is an iternal fuction not needed by end users.
"""
function ismember(connec::Connector, wire::Wire)::Bool
    for con in wire.connector_list
        if connec == con return true end
    end
    return false
end

"""
Does not seem to be used anymore. Deprecated?
"""
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

export CircuitPosition
"""
    CircuitPosition

# Members
- circuit::QuantumCircuit
- stage::Int

Structure used to document the position of circuits in an [`shMQC`](@ref). This is for internal use.
"""
mutable struct CircuitPosition
    circuit::QuantumCircuit
    stage::Int
    CircuitPosition(circuit::QuantumCircuit) = new(circuit, 1)
end

export shMQC
"""
The structure shMQC is the main element of the Meta Quantum Circuit utility.
After adding Snowflake QuantumCircuits and [`Connector`](@ref)s to it, a quantikz/LaTeX file can be produced and, most importantly, a new circuit can be generated from the shMQC.

The main use of shMQC is to build larger circuits using alreday available circuits by plugin them together.

# Members
- `circuit_list::Vector{QuantumCircuit}`
- `connector_list::Vector{Connector}`
- `wire_list::Vector{Wire}`

The circuit_list and connector_list are self-explanatory. The wire_list is build by the [`shsew`](@ref) function to align all elements together.
"""
struct shMQC
    circuit_list::Vector{QuantumCircuit}
    connector_list::Vector{Connector}
    wire_list::Vector{Wire}
    shMQC() = new(Vector{QuantumCircuit}(), Vector{Connector}(), Vector{Wire}())
end

export shprintlightQC
"""
    shprintlightQC(io::IO, circuit::QuantumCircuit)

A quick display of basic info on a QuantumCircuit. Sometime there is too much information when displaying QuantumCircuit information.

# Example
```
julia> c1
Quantum Circuit Object:
   id: 71b5cfa0-8882-11ed-0999-6ff9e4725693
   qubit_count: 4
   bit_count: 0
q[1]:──H────*────X────*───────────────────*────Z──
            |         |                   |    |
q[2]:───────X─────────Z──────────────*────|────|──
                                     |    |    |
q[3]:──────────────────────H─────────|────Z────|──
                                     |         |
q[4]:───────────────────────────H────Z─────────*──

julia> shprintlightQC(stdout, c1)
circuit id: 71b5cfa0-8882-11ed-0999-6ff9e4725693  qubit_count = 4  pipeline size = 9
```
"""
function shprintlightQC(io::IO, circuit::QuantumCircuit)
    println(io, "circuit id: ", circuit.id, "  qubit_count = ", circuit.qubit_count, "  pipeline size = ", length(circuit.pipeline))
end

export printshMQC
"""
    printshMQC(io::IO, mqc::shMQC)

Summary print of what's inside a [`shMQC`](@ref).

# Example
In the example abva, 5 circuits are added into a [`shMQC`](@ref), using [`shMQCAddCircuit`](@ref), and several connectors, using [`shMQCAddConnector`]@(ref)  defining the piping of the [`shMQC`](@ref).
```
julia> mqc = shMQC();
julia> shMQCAddCircuit(mqc, c1);
julia> shMQCAddCircuit(mqc, c2);
julia> shMQCAddCircuit(mqc, c3);
julia> shMQCAddCircuit(mqc, c4);
julia> shMQCAddCircuit(mqc, c5);
julia> shMQCAddConnector(mqc, con1_1);
julia> shMQCAddConnector(mqc, con1_2);
julia> shMQCAddConnector(mqc, con1_3);
julia> shMQCAddConnector(mqc, con2_1);
julia> shMQCAddConnector(mqc, con2_2);
julia> shMQCAddConnector(mqc, con2_3);
julia> shMQCAddConnector(mqc, con3_1);
julia> shMQCAddConnector(mqc, con3_2);
julia> shMQCAddConnector(mqc, con3_3);
julia> shMQCAddConnector(mqc, con4_1);
julia> shMQCAddConnector(mqc, con4_2);
julia> shMQCAddConnector(mqc, con4_3);

julia> mqc
The shMQC is made of these circuits:
circuit id: 24a8c970-8886-11ed-3438-9f8d7f11f419  qubit_count = 4  pipeline size = 9
circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6  qubit_count = 4  pipeline size = 9
circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905  qubit_count = 4  pipeline size = 9
circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8  qubit_count = 4  pipeline size = 9
circuit id: 24def4a0-8886-11ed-15e9-d90899ad2133  qubit_count = 6  pipeline size = 14

And these connector
Connector 1
Plugin  = Circuit id: 24a8c970-8886-11ed-3438-9f8d7f11f419   qubit: 2
Plugout = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 1
Connector 2
Plugin  = Circuit id: 24a8c970-8886-11ed-3438-9f8d7f11f419   qubit: 3
Plugout = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 2
Connector 3
Plugin  = Circuit id: 24a8c970-8886-11ed-3438-9f8d7f11f419   qubit: 4
Plugout = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 3
Connector 4
Plugin  = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 2
Plugout = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 1
Connector 5
Plugin  = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 3
Plugout = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 2
Connector 6
Plugin  = Circuit id: 24b68510-8886-11ed-211f-c9940c38b4a6   qubit: 4
Plugout = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 3
Connector 7
Plugin  = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 2
Plugout = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 1
Connector 8
Plugin  = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 3
Plugout = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 2
Connector 9
Plugin  = Circuit id: 24c48ed0-8886-11ed-3ef0-994877b2a905   qubit: 4
Plugout = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 3
Connector 10
Plugin  = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 1
Plugout = Circuit id: 24def4a0-8886-11ed-15e9-d90899ad2133   qubit: 3
Connector 11
Plugin  = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 3
Plugout = Circuit id: 24def4a0-8886-11ed-15e9-d90899ad2133   qubit: 2
Connector 12
Plugin  = Circuit id: 24d61b00-8886-11ed-1cc7-173c101871b8   qubit: 4
Plugout = Circuit id: 24def4a0-8886-11ed-15e9-d90899ad2133   qubit: 5
```
"""
function printshMQC(io::IO, mqc::shMQC)
    println(io, "\nThe shMQC is made of these circuits:")
    for circuit in mqc.circuit_list
        shprintlightQC(io, circuit)
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


Base.show(io::IO, mqc::shMQC) = printshMQC(io, mqc)

export shMQCAddCircuit
"""
    shMQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Bool 

This function is used to add a Snowflake QuantumCircuit to a [`shMQC`](@ref).
A given circuit cannot be add twice ot the [`shMQC`](@ref). However, two distinct circuits with identical circuitry can as long as their id is different.
The function will retrun true if the addition was successful. The addition is successful is it retrurs true. Otherwise, the circuit is probably already in the [`shMQC`](@ref).

# Example
```
julia> mqc = shMQC();
julia> shMQCAddCircuit(mqc, c1)
true
```
"""
function shMQCAddCircuit(mqc::shMQC, newc::QuantumCircuit)::Bool
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

export shMQCAddConnector
"""
    shMQCAddConnector(mqc::shMQC, connec::Connector)::Bool 

This function is used to add a connector to an MQC. It has several consistancy checks and will return false if the proposed connector creates inconsistencies such as circular circuitry (a list of connector looping back to the initial circuit) or duplicate [`Connector`](@ref)s.

# Example 1
In this example a connector is to be added but the end part of the connector was not added to the [`shMQC`](@ref). Hece it will fail for not finding it.
```
julia> mqc = shMQC();
julia> shMQCAddCircuit(mqc, c1);
julia> shMQCAddConnector(mqc, con1_1)
At least one circuits defined in the plugs of the connector are not in the circuit list of the shMQC. Noting to connect to
```

# Example 2
Now the two end are in the shMQC
```
julia> mqc = shMQC();

julia> shMQCAddCircuit(mqc, c1);

julia> shMQCAddCircuit(mqc, c2);

julia> shMQCAddConnector(mqc, con1_1)
true
```
"""
function shMQCAddConnector(mqc::shMQC, connec::Connector)::Bool
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
        println(stderr, "At least one circuits defined in the plugs of the connector are not in the circuit list of the [`shMQC`](@ref). Noting to connect to")
        return false
    end

    # Now, is there a duplicate
    for connec2 in mqc.connector_list
        if connec.plugin == connec2.plugin
            println(stderr, "There is already a connector with the same plugin in the shMQC")
            return false
        end
        if connec.plugout == connec2.plugout
            println(stderr, "There is already a connector with the same plugout in the shMQC")
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
    # Are we sure? if the loop does not get back to the exact same qubit, this is still an incoherent circuit.
    push!(mqc.connector_list, connec)

    return true

end

"""
    buildwire!(mqc::shMQC)

Builds the wires of the [`shMQC`](@ref). Provided for sake of completeness. Users should not need it in normal circumstances DO NOT export. Returns nothing
The "shsew" function uses it.
"""
function buildwire!(mqc::shMQC)
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

    # We now create the temporary phi circuit as an origin of the shMQC
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

    # We now create the temporary psi circuit as exit circuit of the shMQC
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

"""
    position!(mqc::shMQC)::Vector{CircuitPosition}

Builds the "position" information of the circuits within the [`shMQC`](@ref). internal use, DO NOT export.
"""
function position!(mqc::shMQC)::Vector{CircuitPosition}
    
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

"""
    safecopy(oldpipe)::Vector{Gate}

Will take the pipeline inside a QuantumCircuit and return a copy of it. This is a "true" copy occupying a new memory chunck. Internal use, DO NOT export.
"""
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

export shsew
"""
    shsew(mqc::shMQC)::QuantumCircuit

This function takes an [`shMQC`](@ref) and returns a standard Snowflake QuantumCircuit equivalent. This is the main goal of the [`shMQC`](@ref) concept.

# Example
A [`shMQC`](@ref) is created with 5 circuits and 12 connectors. The resulting quantum circuit is then created by sewing all pieces together.
```
julia> mqc

The shMQC is made of these circuits:
circuit id: 9c9b32e0-8888-11ed-0a20-f12af1106257  qubit_count = 4  pipeline size = 9
circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8  qubit_count = 4  pipeline size = 9
circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874  qubit_count = 4  pipeline size = 9
circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58  qubit_count = 4  pipeline size = 9
circuit id: 9ccb6aa0-8888-11ed-02ee-d37c6c44d379  qubit_count = 6  pipeline size = 14

And these connector
Connector 1
Plugin  = Circuit id: 9c9b32e0-8888-11ed-0a20-f12af1106257   qubit: 2
Plugout = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 1
Connector 2
Plugin  = Circuit id: 9c9b32e0-8888-11ed-0a20-f12af1106257   qubit: 3
Plugout = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 2
Connector 3
Plugin  = Circuit id: 9c9b32e0-8888-11ed-0a20-f12af1106257   qubit: 4
Plugout = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 3
Connector 4
Plugin  = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 2
Plugout = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 1
Connector 5
Plugin  = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 3
Plugout = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 2
Connector 6
Plugin  = Circuit id: 9ca6cba0-8888-11ed-375f-ef0c51f31fc8   qubit: 4
Plugout = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 3
Connector 7
Plugin  = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 2
Plugout = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 1
Connector 8
Plugin  = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 3
Plugout = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 2
Connector 9
Plugin  = Circuit id: 9cb39ce0-8888-11ed-05d5-bff313ab1874   qubit: 4
Plugout = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 3
Connector 10
Plugin  = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 1
Plugout = Circuit id: 9ccb6aa0-8888-11ed-02ee-d37c6c44d379   qubit: 3
Connector 11
Plugin  = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 3
Plugout = Circuit id: 9ccb6aa0-8888-11ed-02ee-d37c6c44d379   qubit: 2
Connector 12
Plugin  = Circuit id: 9cc3062e-8888-11ed-2d41-45f511d1ab58   qubit: 4
Plugout = Circuit id: 9ccb6aa0-8888-11ed-02ee-d37c6c44d379   qubit: 5

julia> newcq = shsew(mqc)
Quantum Circuit Object:
   id: ac5ded7e-8888-11ed-3316-75f366b5ec40
   qubit_count: 10
   bit_count: 0
Part 1 of 2
q[1]: ──H────*────X────*───────────────────*────Z─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
             |         |                   |    |
q[2]: ───────X─────────Z──────────────*────|────|────H────*────X────*───────────────────*────Z────────────────────────────────────────────────────────────────────────────────────────────────────────────────
                                      |    |    |         |         |                   |    |
q[3]: ──────────────────────H─────────|────Z────|─────────X─────────Z──────────────*────|────|────H────*────X────*───────────────────*────Z───────────────────────────────────────────────────────────────────
                                      |         |                                  |    |    |         |         |                   |    |
q[4]: ───────────────────────────H────Z─────────*────────────────────────H─────────|────Z────|─────────X─────────Z──────────────*────|────|────H────*────X────*───────────────────*────Z──────────────────────
                                                                                   |         |                                  |    |    |         |         |                   |    |
q[5]: ────────────────────────────────────────────────────────────────────────H────Z─────────*────────────────────────H─────────|────Z────|─────────X─────────Z──────────────*────|────|──────────────────────
                                                                                                                                |         |                                  |    |    |
q[6]: ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────H────Z─────────*────────────────────────H─────────|────Z────|───────────────────X──
                                                                                                                                                                             |         |                   |  
q[7]: ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────H────Z─────────*─────────H─────────|──
                                                                                                                                                                                                           |
q[8]: ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────H──────────────*──

q[9]: ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

q[10]:────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────H───────


Part 2 of 2
q[1]: ──────────────────────────────────────────────────

q[2]: ──────────────────────────────────────────────────

q[3]: ──────────────────────────────────────────────────

q[4]: ────────────H──────────────Z─────────X────────────
                                 |         |
q[5]: ───────────────────────────|─────────|────────────
                                 |         |
q[6]: ───────Z──────────────*────|─────────|─────────*──
             |              |    |         |         |
q[7]: ───────|──────────────|────|─────────*─────────|──
             |              |    |                   |
q[8]: ──X────*──────────────|────*────Z──────────────|──
                            |         |              |
q[9]: ─────────────────H────Z─────────*─────────X────|──
                                                |    |
q[10]:──────────────────────────────────────────*────X──
```
"""
function shsew(mqc::shMQC)::QuantumCircuit
    buildwire!(mqc)
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

    # All circuits in the shMQC are done and newpipeline contains all info with proper qubit numbering

    return newcircuit
end
