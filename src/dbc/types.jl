schema_type(name) = getproperty(@__MODULE__, Symbol(string(name), :Data))
dbc_filename(path::AbstractString) = Symbol(first(splitext(basename(path))))

@struct_hash_equal struct DBCData{T<:DBCDataType}
  name::Symbol
  rows::Vector{T}
end

DBCData(name, rows::AbstractVector{T}) where {T<:DBCDataType} = DBCData{T}(name, rows)

DBCData(io::IO, name::Symbol) = DBCData{schema_type(name)}(io, name)
DBCData(path::AbstractString) = DBCData{schema_type(dbc_filename(path))}(path)
DBCData(data::AbstractVector{UInt8}, name::Symbol) = DBCData(IOBuffer(data), name)
DBCData(data::AbstractVector{UInt8}, path::String) = DBCData(IOBuffer(data), dbc_filename(path))
DBCData{T}(io::IO, path::AbstractString) where {T<:DBCDataType} = DBCData{T}(io, dbc_filename(path))
DBCData{T}(io::IO, name::Symbol) where {T<:DBCDataType} = read_binary(io, DBCData{T}; name)
DBCData{T}(path::AbstractString) where {T<:DBCDataType} = open(io -> DBCData{T}(io, path), path, "r")
DBCData{T}(file::MPQFile) where {T} = read(DBCFile(file), DBCData{T})
DBCData(file::MPQFile) = read(DBCFile(file))

Base.write(io::IO, data::DBCData) = write_dbc(io, data.rows)

struct DBCFile
  name::Symbol
  data::Vector{UInt8}
end

DBCFile(path::AbstractString) = DBCFile(dbc_filename(path), read(path))
DBCFile(file::MPQFile) = DBCFile(dbc_filename(file.filename), read(file))

Base.read(file::DBCFile) = DBCData(IOBuffer(file.data), file.name)
Base.read(file::DBCFile, ::Type{DBCData{T}}) where {T<:DBCDataType} = DBCData{T}(IOBuffer(file.data), file.name)
Base.write(io::IO, file::DBCFile) = write(io, file.data)

function DBCFile(data::DBCData)
  io = IOBuffer()
  write(io, data)
  seekstart(io)
  DBCFile(data.name, read(io))
end
