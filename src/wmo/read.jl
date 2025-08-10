# Data is always in little-endian format.
BinaryParsingTools.swap_endianness(io::IO, ::Type{WMOFile}) = ENDIAN_BOM ≠ 0x04030201

WMOFile(bytes::AbstractVector) = WMOFile(IOBuffer(bytes))
WMOFile(path::AbstractString) = finalizer(x -> close(x.io), WMOFile(open(path, "r")))
WMOFile(io::IO) = read_binary(io, WMOFile)

function Base.read(io::BinaryIO, ::Type{WMOFile})
  sizes = parse_chunk_sizes(io)
  data = Dictionary{Tag4,Any}()
  for chunk in keys(sizes)
    insert!(data, chunk, nothing)
  end
  WMOFile(io, sizes, data)
end

function parse_chunk_sizes(io::IO)
  sizes = Dictionary{Tag4,Int64}()
  while !eof(io)
    chunk = Tag4(bswap(read(io, UInt32)))
    size = Int64(read(io, UInt32))
    insert!(sizes, chunk, size)
    skip(io, size)
  end
  return sizes
end

function Base.read(wmo::WMOFile, chunk::Tag4)
  data = wmo.data[chunk]
  data !== NoData() && return data
  read_chunk!(wmo, chunk)
  data = wmo.data[chunk]
  @assert data !== NoData()
  return data
end

function read_chunk!(wmo::WMOFile, chunk::Tag4)
  wmo.data[chunk] = read_chunk(wmo, chunk)
end

function read_chunk(wmo::WMOFile, chunk::Tag4)
  wmo.sizes[chunk] == 0 && return missing
  seek_chunk(wmo, chunk)
  chunk === tag"MOHD" && return read(wmo.io, WMOHeader)
  chunk === tag"MOTX" && return read_textures(wmo)::Vector{String}
  chunk === tag"MOGI" && return read_groups(wmo)::Vector{WMOGroup}
  chunk === tag"MOGN" && return read_group_names(wmo)::Vector{String}
  chunk === tag"MOSB" && return read_skybox(wmo)::Optional{String}
  chunk === tag"MODS" && return read_doodad_sets(wmo)::Vector{DoodadSet}
  chunk === tag"MFOG" && return read_fog_infos(wmo)::Vector{FogInfo}
  @warn "Parsing not implemented for chunk $chunk"
  return missing
end

function seek_chunk(wmo::WMOFile, chunk::Tag4)
  offset = 8 # magic number + size
  for (name, size) in pairs(wmo.sizes)
    name === chunk && break
    offset += size + 8
  end
  seek(wmo.io, offset)
end

function read_textures(wmo::WMOFile)
  filenames = String[]
  start = position(wmo.io)
  size = wmo.sizes[tag"MOTX"]
  while position(wmo.io) < start + size
    while peek(wmo.io, UInt8) == 0 skip(wmo.io, 1) end
    position(wmo.io) < start + size || break
    filename = read_null_terminated_string(wmo.io)
    push!(filenames, filename)
  end
  return filenames
end

function read_texture(wmo::WMOFile, offset::Int64)
  seek_chunk(wmo, tag"MOTX")
  skip(wmo.io, offset)
  while peek(wmo.io, UInt8) == 0 skip(wmo.io, 1) end
  return read_null_terminated_string(wmo.io)
end

function read_group_name(wmo::WMOFile, offset::Int64)
  seek_chunk(wmo, tag"MOGN")
  skip(wmo.io, offset)
  while peek(wmo.io, UInt8) == 0 skip(wmo.io, 1) end
  return read_null_terminated_string(wmo.io)
end

function read_group_names(wmo::WMOFile)
  names = String[]
  start = position(wmo.io)
  size = wmo.sizes[tag"MOGN"]
  while position(wmo.io) < start + size
    while peek(wmo.io, UInt8) == 0 skip(wmo.io, 1) end
    position(wmo.io) < start + size || break
    name = read_null_terminated_string(wmo.io)
    push!(names, name)
  end
  return names
end

function read_groups(wmo::WMOFile)
  seek_chunk(wmo, tag"MOGI")
  n = fld(wmo.sizes[tag"MOGI"], 32)
  return [read(wmo.io, WMOGroup) for _ in 1:n]
end

function read_skybox(wmo::WMOFile)
  seek_chunk(wmo, tag"MOSB")
  peek(wmo.io, UInt8) == 0 && return nothing
  return read_null_terminated_string(wmo.io)
end

function read_doodad_sets(wmo::WMOFile)
  seek_chunk(wmo, tag"MODS")
  n = fld(wmo.sizes[tag"MODS"], 32)
  return [read(wmo.io, DoodadSet) for _ in 1:n]
end

function read_fog_infos(wmo::WMOFile)
  seek_chunk(wmo, tag"MFOG")
  n = fld(wmo.sizes[tag"MFOG"], 48)
  return [read(wmo.io, FogInfo) for _ in 1:n]
end
