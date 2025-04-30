const DBC_MAGIC_NUMBER = tag4"CBDW"

BinaryParsingTools.cache_stream_in_ram(io::IO, ::Type{DBCData}) = true
BinaryParsingTools.swap_endianness(io::IO, ::Type{DBCData}) = peek(io, Tag4) == reverse(DBC_MAGIC_NUMBER)

function read_strings(io::IO, string_block_size::UInt32)
  # Strings are all the way to the end of the file.
  seekend(io)
  p = position(io)
  seek(io, p - string_block_size)
  (io, -Int64(string_block_size))
  strings = String[]
  indices = Dict{Int64,Int64}()
  i = 1
  while !eof(io)
    string = read_null_terminated_string(io)
    n = length(string) + 1 # add one for the null byte character that we don't keep
    push!(strings, string)
    indices[i] = lastindex(strings)
    i += n
  end
  strings, indices
end

function find_string(strings, indices, char_index)
  i = get(indices, char_index, nothing)
  if isnothing(i)
    # Perhaps the index is stored, and not an offset?
    i = get(indices, char_index - 1, nothing)
    isnothing(i) && error("Could not find string at index $char_index")
  end
  strings[i]
end

@generated function read_dbc_row(io::IO, strings, indices, ::Type{T}) where {T<:DBCDataType}
  ex = Expr(:call, T)
  for i in 1:fieldcount(T)
    subT = fieldtype(T, i)
    if subT === String
      push!(ex.args, :(find_string(strings, indices, 1 + read(io, Int32))))
    elseif subT === LString
      args = Expr[]
      for name in fieldnames(subT)[1:(end - 1)]
        push!(args, :(find_string(strings, indices, 1 + read(io, Int32))))
      end
      push!(args, :(read(io, UInt32)))
      push!(ex.args, :(LString($(args...))))
    else
      push!(ex.args, :(read(io, $subT)))
    end
  end
  ex
end

# `fieldcount` but recursing into `LString`s.
@generated function _fieldcount(::Type{T}) where {T}
  sum(x -> ifelse(x === LString, 17, 1), fieldtypes(T); init = 0)
end

function Base.read(io::IO, ::Type{DBCData{T}}; name::Symbol) where {T<:DBCDataType}
  magic = read(io, Tag4)
  magic === tag4"WDBC" || error("The provided file has an invalid signature: $magic")
  record_count = read(io, UInt32)
  field_count = read(io, UInt32)
  _fieldcount(T) == field_count || error("Inconsistent field counts between DBC and its schema: $(_fieldcount(T)) ≠ $field_count")
  record_size = read(io, UInt32)
  string_block_size = read(io, UInt32)
  p = position(io)
  strings, indices = read_strings(io, string_block_size)
  seek(io, p)
  rows = Vector{T}(undef, record_count)
  for i in 1:record_count
    seek(io, p + (i - 1)record_size)
    rows[i] = read_dbc_row(io, strings, indices, T)
  end
  DBCData(name, rows)
end
