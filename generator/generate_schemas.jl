using JSON3

include("naming_conventions.jl")

schema_directory(model = "wotlk") = joinpath(@__DIR__, "schemas", model)

schema_type(schema) = Symbol(replace(string(schema), '_' => ""), :Data)

function datatype(type::AbstractString)
  type == "uint8" && return :UInt8
  type == "uint" && return :UInt32
  type == "int" && return :Int32
  type == "string" && return :String
  type == "float" && return :Float32
  type == "null" && return :Missing
  # Assume it's an existing (manually-input) Julia type.
  isuppercase(type[1]) && return Symbol(type)
  error("Unknown type '$type'")
end

function generate_schema_types()
  dest = joinpath(dirname(@__DIR__), "src", "dbc", "schemas.jl")
  open(dest, "w+") do io
    types = Symbol[]
    println(io, "# This file was automatically generated with `generator/generate_schemas.jl`.\n")
    println(io, "abstract type DBCDataType end\n")
    println(io, "Base.broadcastable(x::DBCDataType) = Ref(x)\n")
    for file in readdir(schema_directory(); join = true)
      schema_name = first(splitext(basename(file)))
      sname = schema_type(schema_name)
      fields = Expr(:block)
      lines = collect(eachline(file))
      filter!(lines) do line
        line = strip(line)
        startswith(line, "IGNORE_ORDER") && return false
        startswith(line, '#') && return false
        isempty(line) && return false
        true
      end
      i = 1
      n = length(lines)
      fields = Expr(:block)
      while i ≤ n
        line = strip(strip(lines[i]), '\t')
        items = split(line, ' ')
        type, name = items
        name = replace(name, '_' => "")
        if length(items) == 3
          @assert type == "uint" && items[end] == "string"
          type = "string"
        end
        loc_part = match(r"(.*)(enUS|en_US|1|0)$", items[2])
        if i + 16 ≤ n && !isnothing(loc_part) && (type == "string" || type == "uint") && all(@view lines[(i + 1):(i + 15)]) do next
            next = strip(strip(next), '\t')
            endswith(next, type) || startswith(next, type)
          end && begin
            next = strip(strip(lines[i + 16]), '\t')
            _type, _name = split(next, ' ')
            base = loc_part[1]
            _name == base * "Mask" || _name == base * "Flags" || _name == base * "Flag"
          end
          i += 17
          name = replace(name, Regex("$(loc_part[2])\$") => "")
          name = nc_convert(SnakeCaseLower, name)
          type = :LString
        else
          name = nc_convert(SnakeCaseLower, name)
          type = datatype(type)
          i += 1
        end
        push!(fields.args, :($(Symbol(name))::$type))
      end
      push!(types, sname)
      type = Expr(:struct, false, :($sname <: DBCDataType), fields)
      println(io, "@struct_hash_equal_isequal ", type)
      println(io)
    end
    println(io, '\n', "export\n       ", join(types, ",\n       "))
    @info "Schema types written to $dest"
  end
end

generate_schema_types()
