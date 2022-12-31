
using Snowflake
using UUIDs

export shQuantumCircuit
"""
	shQuantumCircuit

shQuantumCircuit is a structure holding additional descriptive information for rgw Quantum circuits such as a label for circuits and angle 
information for rotation gates R_x, R_y, R_y and the generic rotation gate.
"""
struct shQuantumCircuit
	circuitname::String
	gatelabels::Vector{String}
	shQuantumCircuit(name) = new(name, [])
end

"""
	shcircuits 

shcircuits is a global dictionary holding additional information about Snowflake circuits. Beside the UUID of the 
circuit, used as a key, the values are structures contaning the name of the circuit and a vector of Strings providing
additional information for each of the circuit's gates (if applicable).
# Example
```
julia> c = shQuantumCircuit(qubit_count = 3, bit_count = 0, "A nice circuit")
```
will create the circuit using the Snowflake constructor with the two first parameters, but additionally will
put an entry in shcircuits with the UUID of the circuit as the key and a value of a structure of type shQuantumCircuit
with "A nice circuit" as the circuitname and an empty vector of string to receive any additional description forthe gates added to the circuit via
shpush_gate!()
```
julia> shpush_gate!(c, rotation_x(pi/3), "\\pi/3")
```
The string "\\pi_3" will be added to the gatelabels of the structure corresponding to "c" (via the UUID).
"""
shcircuits = Dict{UUID, shQuantumCircuit}()

export shLaTeX
"""
	shLaTeX(pattern::String, str::String)::String

This function will substitute "pattern" inside str by "\\pattern". This is mostly used when pattern = sin, cos or sqrt. It is used in the process of formatting states and operator in string format as 
generated by [`shoperator`](@ref)

In the example below, all occurence of the string "cos" are replaced by "\\cos".
# Example
```
julia> text = "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)cos(0.69/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)sin(0.69/2)-sin(1.99/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}";
julia> shLaTeX("cos", text)
"1/sqrt{2}\\cos(1.2/2)+1/sqrt{2}-sin(1.2/2)\\cos(0.69/2)\\cos(1.99/2)+1/sqrt{2}\\cos(1.2/2)+1/sqrt{2}-sin(1.2/2)sin(0.69/2)-sin(1.99/2)\\cos(1.99/2)+1/sqrt{2}\\cos(1.2/2)+1/sqrt{2}"
```
"""
function shLaTeX(pattern::String, str::String)::String
	str2 = str
	range = findnext(pattern, str2, 1)
	done = isnothing(range)
	while (done == false)
		if range[1] == 1
			str2 = "\\" * str2
		else
			str2 = str2[1:(range[2]-2)] * "\\" * str2[(range[2]-1):end]
		end
		range = findnext(pattern, str2, range[2]+2)
		done = isnothing(range)
	end
	return(str2)
end

"""
	shLaTeX(str::String)::String

This function will substitute "cos" by "\\cos", "sin" by "\\sin" and "sqrt" by "\\sqrt" in str.
# Example
```
julia> text = "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)cos(0.69/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)sin(0.69/2)-sin(1.99/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}"
julia> shLaTeX(text)
"1/\\sqrt{2}\\cos(1.2/2)+1/\\sqrt{2}-\\sin(1.2/2)\\cos(0.69/2)\\cos(1.99/2)+1/\\sqrt{2}\\cos(1.2/2)+1/\\sqrt{2}-\\sin(1.2/2)\\sin(0.69/2)-\\sin(1.99/2)\\cos(1.99/2)+1/\\sqrt{2}\\cos(1.2/2)+1/\\sqrt{2}"
```
"""
function shLaTeX(str::String)::String
	str2 = shLaTeX("cos", str)
	str2 = shLaTeX("sin", str2)
	str2 = shLaTeX("sqrt", str2)
	return(str2)
end

"""
	shLaTeX(c::QuantumCircuit, FName::String)::Bool

Will generate a file containing the LaTeX/quantikz code in the standalone documentclass.
# Arguments
- `circuit::QuantumCircuit`: a QuantumCircuit as defined by Snowflake
- `FName::String`: the name of the file to create. Warning! It will overwrite if already existing. If omitted it will print to stdout
# Example
```
julia> c = QuantumCircuit(qubit_count=3, bit_count=0);
... (a bunch of "push_gate!" goes here)
julia> shLaTeX(c);
\\begin{quantikz}
\\lstick{q[1]: } & \\gate{H} & \\gate{Ry(1.2)} & \\qw & \\ctrl{1} & \\ctrl{2} & \\ctrl{1} & \\qw & \\ctrl{1} & \\ctrl{2} & \\qw & \\qw & \\qw \\\\
\\lstick{q[2]: } & \\qw & \\qw & \\qw & \\gate{X} & \\qw & \\gate{X} & \\qw & \\gate{X} & \\qw & \\qw & \\gate{Rx(-0.29)} & \\qw \\\\
\\lstick{q[3]: } & \\qw & \\qw & \\gate{Rx(0.69)} & \\qw & \\gate{X} & \\qw & \\gate{Ry(1.99)} & \\qw & \\gate{X} & \\gate{Ry(1.99)} & \\qw & \\qw
\\end{quantikz}
```

This is an example of the output file generated by shLaTeX(). It can be copy&paste to any other Latex document.
```
\\documentclass{standalone}
\\usepackage{tikz}
\\usetikzlibrary{quantikz}
\\begin{document}

\\begin{quantikz}
\\lstick{q[1]: } & \\gate{H} & \\gate{Ry(1.2)} & \\qw & \\ctrl{1} & \\ctrl{2} & \\ctrl{1} & \\qw & \\ctrl{1} & \\ctrl{2} & \\qw & \\qw & \\qw \\\\ 
\\lstick{q[2]: } & \\qw & \\qw & \\qw & \\gate{X} & \\qw & \\gate{X} & \\qw & \\gate{X} & \\qw & \\qw & \\gate{Rx(-0.29)} & \\qw \\\\ 
\\lstick{q[3]: } & \\qw & \\qw & \\gate{Rx(0.69)} & \\qw & \\gate{X} & \\qw & \\gate{Ry(1.99)} & \\qw & \\gate{X} & \\gate{Ry(1.99)} & \\qw & \\qw
\\end{quantikz}
\\end{document}
```
"""
function shLaTeX(c::QuantumCircuit, FName = "")::Bool
    if c.qubit_count == 0 
        println("There are no qubits in the circuit")
        return false
    end

    if FName != ""
        f = open(FName, "w+")
        println(f, "\\documentclass{standalone}")
        println(f, "\\usepackage{tikz}")
        println(f, "\\usetikzlibrary{quantikz}")
        println(f, "\\begin{document}\n")
    else
        f = stdout
    end
    println(f, "\\begin{quantikz}")

    LatexCircuit = Matrix{String}(undef, c.qubit_count, length(c.pipeline)+2)
    for i in 1:c.qubit_count
        LatexCircuit[i,1] = "\\lstick{q[$i]: } & "
    end
  
    j = 2
    for Vgates in c.pipeline
        for gate in Vgates
            if length(gate.target) == 1
                qubit1 = gate.target[1]
                symbole1 = gate.display_symbol[1]
                LatexCircuit[qubit1,j] = string("\\gate{", symbole1, "} & ")
                for i in 1:c.qubit_count
                    if i != qubit1
                        LatexCircuit[i,j] = "\\qw & "
                    end
                end
            else
                qubit1 = gate.target[1]
                symbole1 = gate.display_symbol[1]
                qubit2 = gate.target[2]
                symbole2 = gate.display_symbol[2]

                if symbole1 == "*"
                    diff = qubit2 - qubit1
                    LatexCircuit[qubit1,j] = string("\\ctrl{", diff, "} & ")
                else
                    LatexCircuit[qubit1,j] = string("\\gate{", symbole1, "} & ")
                end

                if symbole2 == "*"
                    diff = qubit1 - qubit2
                    LatexCircuit[qubit2,j] = string("\\ctrl{", diff, "} & ")
                else
                    LatexCircuit[qubit2,j] = string("\\gate{", symbole2, "} & ")
                end

                for i in 1:c.qubit_count
                    if ((i != qubit1) && (i!= qubit2))
                        LatexCircuit[i,j] = "\\qw & "
                    end
                end

            end
            j = j + 1
        end
    end

    for i in 1:c.qubit_count-1
        LatexCircuit[i,j] = "\\qw \\\\ "
    end
    LatexCircuit[c.qubit_count,j] = "\\qw"

    for i in 1:c.qubit_count
        for j in 1:length(c.pipeline)+2
            print(f, LatexCircuit[i,j])
        end
        print(f, '\n')
    end

    println(f, "\\end{quantikz}")
    
    if FName != ""
        println(f, "\\end{document}\n")
    end

    if FName != ""
        close(f)
    end

    return true
end

"""
	shLaTeX(mat::Matrix{String})

Will convert to LaTeX the operator matrix generated by [`shoperator`](@ref)  A garder???
In the example above a Kroneker product of a CNOT circuit by an Hadamard circuit (both in "string" version) is generated.
The function shLaTeX is then used to produce the LaTeX version of it.
```
julia> mat2 = shcnot(1,2,2);
julia> mat3 = shhadamard();
julia> mat4 = shkron(mat3,mat2)
8×8 Matrix{String}:
 "1/sqrt{2}"  "0"          "0"          "0"          "1/sqrt{2}"   "0"           "0"           "0"
 "0"          "1/sqrt{2}"  "0"          "0"          "0"           "1/sqrt{2}"   "0"           "0"
 "0"          "0"          "0"          "1/sqrt{2}"  "0"           "0"           "0"           "1/sqrt{2}"
 "0"          "0"          "1/sqrt{2}"  "0"          "0"           "0"           "1/sqrt{2}"   "0"
 "1/sqrt{2}"  "0"          "0"          "0"          "-1/sqrt{2}"  "0"           "0"           "0"
 "0"          "1/sqrt{2}"  "0"          "0"          "0"           "-1/sqrt{2}"  "0"           "0"
 "0"          "0"          "0"          "1/sqrt{2}"  "0"           "0"           "0"           "-1/sqrt{2}"
 "0"          "0"          "1/sqrt{2}"  "0"          "0"           "0"           "-1/sqrt{2}"  "0"
 julia> shLaTeX(mat4)
 \\begin{bmatrix}
 1/\\sqrt{2} &0 &0 &0 &1/\\sqrt{2} &0 &0 &0 \\\\
 0 &1/\\sqrt{2} &0 &0 &0 &1/\\sqrt{2} &0 &0 \\\\
 0 &0 &0 &1/\\sqrt{2} &0 &0 &0 &1/\\sqrt{2} \\\\
 0 &0 &1/\\sqrt{2} &0 &0 &0 &1/\\sqrt{2} &0 \\\\
 1/\\sqrt{2} &0 &0 &0 &-1/\\sqrt{2} &0 &0 &0 \\\\
 0 &1/\\sqrt{2} &0 &0 &0 &-1/\\sqrt{2} &0 &0 \\\\
 0 &0 &0 &1/\\sqrt{2} &0 &0 &0 &-1/\\sqrt{2} \\\\
 0 &0 &1/\\sqrt{2} &0 &0 &0 &-1/\\sqrt{2} &0 \\\\
 \\end{bmatrix}
```
"""
function shLaTeX(mat::Matrix{String})
	sz = size(mat)
	println("\\begin{bmatrix}")
	for i in 1:sz[1]
		for j in 1:(sz[2] - 1)
			str = shLaTeX(mat[i,j])
			print(str, " &")
		end
		str = shLaTeX(mat[i,sz[2]])
		println(str, " \\\\")
	end
	println("\\end{bmatrix}")
end

"""
    shLaTeX(mqc::shMQC, FName = "")::Bool

# Arguments
- `mqc::shMQC`: a Meta Quantum Circuit as defined by Shovel
- `FName::String`: the name of the file to create. Warning! It will overwrite if already existing. If omitted it will print to stdout

A [`shMQC`](@ref) is usually large and only used as an intermediate step before being transformed into a Snowflake QuantumCircuit. It is nevertheless possible to produce
a meaningful LaTeX output that can be analysed for troubleshooting.
# Example
```
julia> shLaTeX(mqc, "Foo.bar")
```
"""
function shLaTeX(mqc::shMQC, FName = "")::Bool
    position!(mqc)

    if lastindex(mqc.circuit_list) == 0 
        println("There are no circuits in the Meta circuit")
        return false
    end

    if FName != ""
        f = open(FName, "w+")
        println(f, "\\documentclass{standalone}")
        println(f, "\\usepackage{tikz}")
        println(f, "\\usetikzlibrary{quantikz}")
        println(f, "\\begin{document}\n")
    else
        f = stdout
    end
    
    println(f, "\\begin{quantikz}[transparent, column sep=1cm, row sep={1cm,between origins}]")
    for i in 1:length(mqc.circuit_list) print(f, "& ") end
    print(f, "& & \\\\ \n")

    go_up = (length(mqc.wire_list)+2) / 2
    print(f, "& & ")
    for i in 1:length(mqc.circuit_list) 
        print(f, "\\gate[wires=", length(mqc.wire_list)+2, ", label style={yshift=", go_up, "cm}]{\\mbox{Circuit ", i,
        "}} & ")
    end
    print(f, "& \\\\ \n")

    for wire in mqc.wire_list
        if wire.order == 1
            print(f, "\\lstick[wires=", length(mqc.wire_list), "]{\\ket{\\Phi}} \n")
        end
        print(f, "& \\lstick{ wire ", wire.order, "} & ")

        i = Int(0)
        for circuit in mqc.circuit_list
            i = i + 1
            over = true
            qb = 0
            for connec in wire.connector_list
                if connec.plugin.circuit.id == circuit.id
                    over = false
                    qb = connec.plugin.qubit
                end
            end
            if over == false
                print(f, "\\gateinput{qb=", qb, "} & ")
            else
                print(f, "\\linethrough & ")
            end
        end
        if wire.order == 1
            print(f, "\\qw \\rstick[wires=", length(mqc.wire_list), "]{\\ket{\\Psi}} \\\\ \n")
        else
            print(f, "\\qw \\\\ \n")
        end
    end

    for i in 1:length(mqc.circuit_list) print(f, "& ") end
    print(f, "& & \n")

    println(f, "\\end{quantikz}")
    
    if FName != ""
        println(f, "\\end{document}\n")
    end

    if FName != ""
        close(f)
    end

    return true
end

export shpush_gate!
"""
    shpush_gate!(c::QuantumCircuit, gate::Gate, label::String)

# Arguments
- `c::QuantumCircuit`: a Snowflake QuantumCircuit.
- `gate::Gate`: a Snowflake Gate.
- `label::String`: a nice lable to supplement the standard Snowflake display_symbom in the QuantumCircuit pipeline
    
This allows to insert better labelling such as LaTeX code for improved clarity
# Example
```julia-repl
julia> shpush_gate!(c, rotation_z(1, sqrt(2.0*pi)), "R_z(\\sqrt{2\\pi})")
Quantum Circuit Object:
    id: 0197d410-788e-11ed-290c-adec58eae39f
    qubit_count: 1
    bit_count: 0
q[1]:--R_z(\\sqrt{2\\pi})--
    
julia> shLaTeX(c)
\\begin{quantikz}
\\lstick{q[1]: } & \\gate{R_z(\\sqrt{2\\pi}} & \\qw
\\end{quantikz}
true
```
The Quantikz/LaTeX file will display ``R_z(\\sqrt{2\\pi})`` instead of "Rz(2.5066282746310002)".
"""
function shpush_gate!(c::QuantumCircuit, gate::Gate, label::String)
    Snowflake.push_gate!(c, gate)
    last = length(c.pipeline)
    c.pipeline[last][1].display_symbol[1] = label
    return c
end

export shQuantumCircuit
function shQuantumCircuit(q::Int, b::Int, label::String)::QuantumCircuit
	c = QuantumCircuit(qubit_count=q, bit_count=b)
	shc = shQuantumCircuit(label)
	shcircuits
	push!(shcircuits, c.id=>shc)
	println(shcircuits)
	return c
end

export shstrmult
"""
	shstrmult(s1::String, s2::String)::String will lexicographically multiply (concatenate) two strings.

The concatenation will follow the following rules:
shstrmult("0", "a string") => "0"
shstrmult("1", "a string") => "a string"
shstrmult("a string", "0") => "0"
shstrmult("a string", "1") => "a string"
Otherwise
shstrmult("a string", "-a second string") => "a string-a second string"

The arithmetic defined by shstrmult is at the base of the arithmetic of matric multiplication [`shmult`](@ref) and Kroneker product [`shkron`](@ref) of string matrix for operators.
```
julia> a = "0" ; b= "a string";

julia> shstrmult(a,b)
"0"

julia> c = "1";

julia> shstrmult(c,b)
"a string"

julia> shstrmult(c,a)
"0"
```
"""
function shstrmult(s1::String, s2::String)::String
    if ((s1 == "") || (s2 == "")) return("") end
	if (s1 == "1") return(s2) end
	if (s1 == "0") return(s1) end
	if (s2 == "1") return(s1) end
	if (s2 == "0") return(s2) end
	return(s1*s2)
end

export shmult
"""
	shmult(mat1::Matrix{String}, mat2::Matrix{String})::Matrix{String} will perform the lexicographic multiplication of two string matrices. It is based on the rules for function shstrmult()

This will perform the matrix multiplication mat1 × mat2 using String matrices using the same rules as shstrmult.
# Parameters
- mat1 and mat2 have to satisfy size(mat1)[2] == size(mat2)[1]

The return matrix will have size (size(mat1)[1], size(mat2)[2])

# Example 1
```
julia> A = [ "a" "b" ; "c" "d" ];

julia> B = [ "e" "f" ; "g" "h" ; "i" "j" ];

julia> C = shmult(B, A)
3×2 Matrix{String}:
 "ea+fc"  "eb+fd"
 "ga+hc"  "gb+hd"
 "ia+jc"  "ib+jd"
```

# Example 2
```
julia> A = [ "1" "b" ; "c" "0" ];

julia> B = [ "e" "f" ; "g" "h" ; "i" "j" ];

julia> C = shmult(B, A)
3×2 Matrix{String}:
 "e+fc"  "eb"
 "g+hc"  "gb"
 "i+jc"  "ib"
```
As can be seen in the second example, the fact that A[1,1] = "1" makes it irrelevant and it is simply remove ( "1" * "any_string" = "any_string"). 
Hereas, A[2,2] = "0" which implies that and multiplycation results into "0" and will be removed unless it is alone ("0" + "any_string" = "any_string", but "0" + nothing = "0")
"""
function shmult(mat1::Matrix{String}, mat2::Matrix{String})::Matrix{String}
	sz1 = size(mat1)
	sz2 = size(mat2)
	if sz1[2] != sz2[1] 
		error("Matrix sizes don't match")
	end
	mat3 = Matrix{String}(undef, sz1[1], sz2[2])
	if (sz1[2] != sz2[1])
		return(mat3)
	end

	mat3 .= "0"
	for i in 1:sz1[1]
		for j in 1:sz2[2]
			str = shstrmult(mat1[i,1], mat2[1,j])
			if (str != "0")
				mat3[i,j] = str
			end
			for k in 2:sz1[2]
				str = shstrmult(mat1[i,k], mat2[k,j])
				if (str != "0")
					if (mat3[i,j] == "0")
						mat3[i,j] = str
					else
						if (str[1] == "-")
							mat3[i,j] = mat3[i,j] * str
						else
							mat3[i,j] = mat3[i,j] * "+" * str
						end
					end
				end
			end
		end
	end
	return(mat3)
end

export shkron
"""
	shkron(mat1::Matrix{String}, mat2::Matrix{String})::Matrix{String} will perform the lexicographic Kroneker product of two matrices.

Kroneker product of two string matrices. Here again, the logic of shstrmult is used to remove unneeded "0" and "1"

# Example 1
```
julia> A = [ "a" "b" ; "c" "d" ];

julia> B = [ "e" "f" ; "g" "h" ; "i" "j" ];

julia> C = shkron(B, A)
6×4 Matrix{String}:
 "ea"  "eb"  "fa"  "fb"
 "ec"  "ed"  "fc"  "fd"
 "ga"  "gb"  "ha"  "hb"
 "gc"  "gd"  "hc"  "hd"
 "ia"  "ib"  "ja"  "jb"
 "ic"  "id"  "jc"  "jd"
```

# Example 2
In this second example a value of B is equal to "0" and another is equal to "1".
```
julia> A = [ "a" "b" ; "c" "d" ];

julia> B = [ "e" "0" ; "1" "h" ; "i" "j" ];

julia> C = shkron(B, A)
6×4 Matrix{String}:
 "ea"  "eb"  "0"   "0"
 "ec"  "ed"  "0"   "0"
 "a"   "b"   "ha"  "hb"
 "c"   "d"   "hc"  "hd"
 "ia"  "ib"  "ja"  "jb"
 "ic"  "id"  "jc"  "jd"
```
"""
function shkron(mat1::Matrix{String}, mat2::Matrix{String})::Matrix{String}
	mat3 = kron(mat1, mat2)
	sz = size(mat3)
	for i in 1:sz[1]
		for j in 1:sz[2]
			if ((mat3[i,j][begin] == '1') && (mat3[i,j][begin+1] != '/')) 
				mat3[i,j] = SubString(mat3[i,j], 2, lastindex(mat3[i,j])) 
			end
			if (mat3[i,j][begin] == '0') mat3[i,j] = "0" end
			
			if (lastindex(mat3[i,j]) > 1)
				if (mat3[i,j][lastindex(mat3[i,j])] == '1') mat3[i,j] = SubString(mat3[i,j], 1, lastindex(mat3[i,j])-1) end
				if (mat3[i,j][lastindex(mat3[i,j])] == '0') mat3[i,j] = "0" end
			end
		end
	end
	return(mat3)
end

export shrx
"""
	shrx(gate::Gate)::Matrix{String}

Returns the string expression of the operator of gate doing a rotation around the X axis using the information provided in a Gate (gate.parameters[1]).

# Example
```
julia> gate = rotation_x(2, 0.20)
Gate Object:
instruction symbol: rx
parameters: [0.2]
targets: [2]
operator:
(2, 2)-element Snowflake.Operator:
Underlying data Matrix{Complex}:
0.9950041652780258 + 0.0im    0.0 - 0.09983341664682815im
0.0 - 0.09983341664682815im    0.9950041652780258 + 0.0im

julia> shrx(gate)
2×2 Matrix{String}:
 "cos(0.2/2)"   "sin(0.2/2)"
 "sin(0.2/2)i"  "cos(0.2/2)"
```
"""
function shrx(gate::Gate)::Matrix{String}
	mat = Matrix{String}(undef, 2,2)
	if (gate.instruction_symbol != "rx") return(mat) end
	mat[1,1] = "cos(" * string(gate.parameters[1]) * "/2)"
	mat[1,2] = "sin(" * string(gate.parameters[1]) * "/2)"
	mat[2,1] = "sin(" * string(gate.parameters[1]) * "/2)i"
	mat[2,2] = "cos(" * string(gate.parameters[1]) * "/2)"
	return(mat)
end

export shry
"""
	shry(gate::Gate)::Matrix{String}

Returns the Latex expression of the operator of gate doing a rotation around the Y axis using the information provided in a Gate (gate.parameters[1]).

# Example
```
julia> gate = rotation_y(1, 1.3)
Gate Object:
instruction symbol: ry
parameters: [1.3]
targets: [1]
operator:
(2, 2)-element Snowflake.Operator:
Underlying data Matrix{Complex}:
0.7960837985490558 + 0.0im    -0.6051864057360395 - 3.705697973360661e-17im
0.6051864057360395 - 3.705697973360661e-17im    0.7960837985490558 + 0.0im


julia> shry(gate)
2×2 Matrix{String}:
 "cos(1.3/2)"   "sin(1.3/2)"
 "-sin(1.3/2)"  "cos(1.3/2)"
```
"""
function shry(gate::Gate)::Matrix{String}
	mat = Matrix{String}(undef, 2,2)
	if (gate.instruction_symbol != "ry") return(mat) end
	mat[1,1] = "cos(" * string(gate.parameters[1]) * "/2)"
	mat[1,2] = "sin(" * string(gate.parameters[1]) * "/2)"
	mat[2,1] = "-sin(" * string(gate.parameters[1]) * "/2)"
	mat[2,2] = "cos(" * string(gate.parameters[1]) * "/2)"
	return(mat)
end

export shrz
"""
	shrz(gate::Gate)::Matrix{String}

Returns the Latex expression of the operator of gate doing a rotation around the Z axis using the information provided in a Gate (gate.parameters[1]).

# Example
```
julia> gate = rotation_z(1, 1.9)
Gate Object:
instruction symbol: rz
parameters: [1.9]
targets: [1]
operator:
(2, 2)-element Snowflake.Operator:
Underlying data Matrix{Complex}:
0.5816830894638835 - 0.8134155047893737im    0.0 + 0.0im
0.0 + 0.0im    0.5816830894638835 + 0.8134155047893737im


julia> shrz(gate)
2×2 Matrix{String}:
 "e^(-i1.9/2)"  "0"
 "0"            "e^(i1.9/2)"
```
"""
function shrz(gate::Gate)::Matrix{String}
	mat = Matrix{String}(undef, 2,2)
	if (gate.instruction_symbol != "rz") return(mat) end
	mat[1,1] = "e^(-i" * string(gate.parameters[1]) * "/2)"
	mat[1,2] = "0"
	mat[2,1] = "0"
	mat[2,2] = "e^(i" * string(gate.parameters[1]) * "/2)"
	return(mat)
end

export shr
"""
	shr(gate::Gate)::Matrix{String}

Returns the Latex expression of the operator of gate doing a rotation with θ and ϕ axis using the information provided in shcircuits.

# Example
```
julia> gate = rotation(1, 1.9, 2.1)
Gate Object:
instruction symbol: r
parameters: [1.9, 2.1]
targets: [1]
operator:
(2, 2)-element Snowflake.Operator:
Underlying data Matrix{Complex}:
0.5816830894638835 + 0.0im    -0.7021478827116092 + 0.4106496490140421im
0.7021478827116092 + 0.4106496490140421im    0.5816830894638835 + 0.0im


julia> shr(gate)
2×2 Matrix{String}:
 "cos(1.9/2}"            "-ie^{-i2.1}sin(1.9/2)"
 "-ie^{i2.1}sin(1.9/2)"  "cos(1.9/2}"
```
"""
function shr(gate::Gate)::Matrix{String}
	mat = Matrix{String}(undef, 2,2)
	if (gate.instruction_symbol != "r") return(mat) end
	mat[1,1] = "cos(" * string(gate.parameters[1]) * "/2}"
	mat[1,2] = "-ie^{-i" * string(gate.parameters[2]) * "}sin(" * string(gate.parameters[1]) * "/2)"
	mat[2,1] = "-ie^{i" * string(gate.parameters[2]) * "}sin(" * string(gate.parameters[1]) * "/2)"
	mat[2,2] = "cos(" * string(gate.parameters[1]) * "/2}"
	return(mat)
end

export shhadamard
"""
	shry(gate::Gate)::Matrix{String}

Returns the Latex expression of the operator of a Hadamard gate no information needs to be provided in shcircuits for that type of circuit.

# Example
```
julia> shhadamard()
2×2 Matrix{String}:
 "1/sqrt{2}"  "1/sqrt{2}"
 "1/sqrt{2}"  "-1/sqrt{2}"
```
"""
function shhadamard()::Matrix{String}
	return( [ "1/sqrt{2}" "1/sqrt{2}" ; "1/sqrt{2}" "-1/sqrt{2}" ] )
end

export shid
"""
	shid()()::Matrix{String}

Returns a simple identity matrix in string format.

# Example
```
julia> shid()
2×2 Matrix{String}:
 "1"  "0"
 "0"  "1"
```
"""
function shid()::Matrix{String}
	return([ "1" "0" ; "0" "1"])
end

"""
	shid(N::Int)::Matrix{String}

Returns the 2^N X 2^N identity matrix in string format.

# Example
```
julia> shid(3)
8×8 Matrix{String}:
 "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"
```
"""
function shid(N::Int)::Matrix{String}
	mat = Matrix{String}(undef, 2^N, 2^N)
	mat .= "0"
	for i in 1:(2^N)
		mat[i,i] = "1"
	end
	return(mat)
end

export shcnot
"""
	shcnot()::Matrix{String}

Returns the 4x4 CNOT matrix in string format.

# Example
```
julia> shcnot()
4×4 Matrix{String}:
 "1"  "0"  "0"  "0"
 "0"  "1"  "0"  "0"
 "0"  "0"  "0"  "1"
 "0"  "0"  "1"  "0"
```
"""
function shcnot()::Matrix{String}
	return( [ "1" "0" "0" "0" ; "0" "1" "0" "0" ; "0" "0" "0" "1" ; "0" "0" "1" "0" ])
end

export shcnot1
"""
	shcnot1(crtl::Int, N::Int)::Matrix{String}

This function returns, in string format, the CNOT matrix for a set of N qubits when the control qubit is at position ctrl (ctrl < (N-1)) and
the target qubit is right under it (crtl+1). BEWARE! It is assumed here that the control qubit is over the target.

# Example
```
julia> shcnot1(2, 3)
8×8 Matrix{String}:
 "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"
 "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"
 "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"
```
"""
function shcnot1(crtl::Int, N::Int)::Matrix{String}
	if ((crtl < 1) || (crtl >= N))
		return nothing
	end
	id = shid()
	cnot = shcnot()
	
	if (crtl == 1)
		mat = cnot
		for i in 3:N
			mat = shkron(mat, id)
		end
	else
		mat1 = shid(crtl-1)
		mat = shkron(mat1, cnot)
		if ((N-(crtl+1)) > 0)
			mat1 = shid(N-(crtl+1))
			mat = shkron(mat, mat1)
		end
	end
	return(mat)
end

"""
	shcnot(crtl::Int, trgt::Int, N::Int)::Matrix{String}

Returns, in string format, the CNOT matrix for a set of N qubits where the control qubit is at position crtl and the target is at position trgt wit (trgt>crtl).

# Example
```
julia> shcnot(2,4,4)
16×16 Matrix{String}:
 "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"  "0"  "0"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"
 "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "0"  "1"  "0"
```
"""
function shcnot(crtl::Int, trgt::Int, N::Int)::Matrix{String}
	if ((crtl < 1) || trgt < 1) || (crtl > N) || (trgt > N)
		return
	end
	if (trgt == crtl + 1)
		return(shcnot1(crtl, N))
	end
	
	mat = shid(N)
	if (crtl == 1)
		for i in 1:(trgt-1)
			mat1 = shcnot1(i, N)
			mat = shmult(mat, mat1)
		end
		
		for i in (trgt-2):-1:2
			mat1 = shcnot1(i, N)
			mat = shmult(mat, mat1)
		end
		
		for i in 1:(trgt-1)
			mat1 = shcnot1(i, N)
			mat = shmult(mat, mat1)
		end
		
		for i in (trgt-2):-1:2
			mat1 = shcnot1(i, N)
			mat = shmult(mat, mat1)
		end
		return(mat)
	else
		mat2 = shid(crtl-1)
		mat1 = shcnot(1, trgt-crtl+1, N-crtl+1)
		mat = shkron(mat2, mat1)
		return(mat)
	end
end

export shoperator
"""
	shoperator(c::QuantumCircuit)::Matrix{String}

Returns, in string format, the resulting operator of a quantum circuit.

This can give a fairly large matrix difficult to read. However each individual element of it can be displayed, as in the example above to see what is happeneing in the operator.

# Example
```
julia> c = QuantumCircuit(qubit_count=3, bit_count=0);
julia> push_gate!(c, hadamard(1));
julia> push_gate!(c, rotation_y(1, 1.2));
julia> push_gate!(c, rotation_x(3, 0.69));
julia> push_gate!(c, control_x(1,2));
julia> push_gate!(c, control_x(1,3));
julia> push_gate!(c, control_x(1,2));
julia> push_gate!(c, rotation_y(3, 1.99));
julia> push_gate!(c, control_x(1,2));
julia> push_gate!(c, control_x(1,3));
julia> push_gate!(c, rotation_y(3, 1.99));
julia> push_gate!(c, rotation_x(2, -0.29));

julia> mat = shoperator(c)
8×8 Matrix{String}:
 "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-s" ⋯ 226 bytes ⋯ ".99/2)-sin(1.99/2)cos(-0.29/2)"         …  "1/sqrt{2}sin(1.2/2)+1/sqrt{2}co" ⋯ 221 bytes ⋯ "1.99/2)cos(1.99/2)cos(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-s" ⋯ 228 bytes ⋯ ".99/2)-sin(1.99/2)cos(-0.29/2)"          "1/sqrt{2}sin(1.2/2)+1/sqrt{2}co" ⋯ 223 bytes ⋯ "1.99/2)cos(1.99/2)cos(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-s" ⋯ 227 bytes ⋯ "99/2)-sin(1.99/2)sin(-0.29/2)i"           "1/sqrt{2}sin(1.2/2)+1/sqrt{2}co" ⋯ 221 bytes ⋯ "1.99/2)cos(1.99/2)sin(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+1/sqrt{2}-s" ⋯ 229 bytes ⋯ "99/2)-sin(1.99/2)sin(-0.29/2)i"         "1/sqrt{2}sin(1.2/2)+1/sqrt{2}co" ⋯ 223 bytes ⋯ "1.99/2)cos(1.99/2)sin(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+-1/sqrt{2}-" ⋯ 230 bytes ⋯ ".99/2)-sin(1.99/2)cos(-0.29/2)"        "1/sqrt{2}sin(1.2/2)+-1/sqrt{2}c" ⋯ 225 bytes ⋯ "1.99/2)cos(1.99/2)cos(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+-1/sqrt{2}-" ⋯ 232 bytes ⋯ ".99/2)-sin(1.99/2)cos(-0.29/2)"   …  "1/sqrt{2}sin(1.2/2)+-1/sqrt{2}c" ⋯ 227 bytes ⋯ "1.99/2)cos(1.99/2)cos(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+-1/sqrt{2}-" ⋯ 231 bytes ⋯ "99/2)-sin(1.99/2)sin(-0.29/2)i"       "1/sqrt{2}sin(1.2/2)+-1/sqrt{2}c" ⋯ 225 bytes ⋯ "1.99/2)cos(1.99/2)sin(-0.29/2)"
 "1/sqrt{2}cos(1.2/2)+-1/sqrt{2}-" ⋯ 233 bytes ⋯ "99/2)-sin(1.99/2)sin(-0.29/2)i"     "1/sqrt{2}sin(1.2/2)+-1/sqrt{2}c" ⋯ 227 bytes ⋯ "1.99/2)cos(1.99/2)sin(-0.29/2)"

julia> mat[1,1]
"1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)cos(0.69/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)sin(0.69/2)-sin(1.99/2)cos(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)cos(0.69/2)sin(1.99/2)+1/sqrt{2}cos(1.2/2)+1/sqrt{2}-sin(1.2/2)sin(0.69/2)cos(1.99/2)-sin(1.99/2)cos(-0.29/2)"
```
"""
function shoperator(c::QuantumCircuit)::Matrix{String}
	finalmat = shid(c.qubit_count)#Matrix{String}(undef, 2^c.qubit_count, 2^c.qubit_count)
	mat = shid()
	id = shid()
	for i in 1:length(c.pipeline)
		gate = c.pipeline[i][1]
		if (gate.instruction_symbol == "rx") # rotation_x
			if (gate.target[1] == 1)
				mat = shrx(gate)
				for g in 2:c.qubit_count
					mat = shkron(mat, id)
				end
			else
				for i in 1:gate.target[1]-1
					if (i == 1) 
						mat = id
					else
						mat = shkron(mat, id)
					end
				end
				r = shrx(gate)
				mat = shkron(mat, r)
				for i in (gate.target[1]+1:c.qubit_count)
					mat = shkron(mat, id)
				end
			end
		end
		if (gate.instruction_symbol == "ry") # rotation_y
			if (gate.target[1] == 1)
				mat = shry(gate)
				for g in 2:c.qubit_count
					mat = shkron(mat, id)
				end
			else
				for i in 1:gate.target[1]-1
					if (i == 1) 
						mat = id
					else
						mat = shkron(mat, id)
					end
				end
				r = shry(gate)
				mat = shkron(mat, r)
				for i in gate.target[1]+1:c.qubit_count
					mat = shkron(mat, id)
				end
			end
		end
		if (gate.instruction_symbol == "rz") # rotation_z
			if (gate.target[1] == 1)
				mat = shrz(gate)
				for g in 2:c.qubit_count
					mat = shkron(mat, id)
				end
			else
				for i in 1:gate.target[1]-1
					if (i == 1) 
						mat = id
					else
						mat = shkron(mat, id)
					end
				end
				r = shrz(gate)
				mat = shkron(mat, r)
				for i in gate.target[1]+1:c.qubit_count
					mat = shkron(mat, id)
				end
			end
		end
#		if gate.instruction_symbol == "r" # rotation (theta and phi)
#			...
#		end
		if (gate.instruction_symbol == "h") # hadamard
			if (gate.target[1] == 1)
				mat = shhadamard()
				for g in 2:c.qubit_count
					mat = shkron(mat, id)
				end
			else
				for i in 1:gate.target[1]-1
					if (i == 1) 
						mat = id
					else
						mat = shkron(mat, id)
					end
				end
				r = shhadamard()
				mat = shkron(mat, r)
				for i in gate.target[1]+1:c.qubit_count
					mat = shkron(mat, id)
				end
			end
		end
		if (gate.instruction_symbol == "cx") # control_x
			if (gate.target[1] == 1)
				mat = shcnot(gate.target[1], gate.target[2], (gate.target[2] - gate.target[1]) + 1)
				for i in (gate.target[2]+1):c.qubit_count
					mat = shkron(mat, id)
				end
			else
				for i in 1:gate.target[1]-1
					mat = shkron(mat, id)
				end
				mat1 = shcnot(gate.target[1], gate.target[2], (gate.target[2] - gate.target[1]) + 1)
				mat = shkron(mat, mat1)
				for i in gate.target[2]+1:c.qubit_count
					mat = shkron(mat, id)
				end
			end
		end
#=
		if gate.instruction_symbol == "cz" control_z
			...
		end
		if gate.instruction_symbol == "iswap" # iswap
			...
		end
		if gate.instruction_symbol == "x" # sigma_x
			...
		end
		if gate.instruction_symbol == "y" # sigma_y
			...
		end
		if gate.instruction_symbol == "z" # sigma_z
			...
		end
		if gate.instruction_symbol == "s" # phase
			...
		end
		if gate.instruction_symbol == "t" # pi_8
			...
		end
		if gate.instruction_symbol == "i" # eye
			...
		end
=#

		println("Step ", i, " in the pipeline. The operator for this step is:")
		display(mat)
		finalmat = shmult(finalmat, mat)
		display(finalmat)
		readline()

	end
	return(finalmat)
end

export shblock
"""
	shblock(mat::Matrix{String}, bstart::Int, bsize::Int)::Matrix{String}

will return the submatrix of a square matrix starting at position "bstart, bstart" and of size bsize x bsize
Is it needed?????
"""
function shblock(mat::Matrix{String}, bstart::Int, bsize::Int)::Matrix{String}
	sz = size(mat)
	if (sz[1] != sz[2]) # not a square matrix
		error("Not a square matrix")
	end
	if (bstart < 0) || (bstart > sz[1]) || ((bstart+bsize) > sz[1])
		error("Block is not inside matrix")
	end
	mat2 = mat[bstart:(bstart+bsize), bstart:(bstart+bsize)]
	return(mat2)
end
