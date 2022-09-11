"A package of different utilities to be used with the Snowflake package from Anyon Systems"
module Shovel

using Revise
using Snowflake
using Distributions
using Match

include(Stop.jl)
include(ToLaTeX.jl)
include(MQC.jl)

greet() = print("Hello World!")

end # module Shovel
