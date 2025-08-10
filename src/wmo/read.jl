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
  sizes = Dictionary{Tag4,Int}()
  while !eof(io)
    chunk = Tag4(bswap(read(io, UInt32)))
    size = Int(read(io, UInt32))
    insert!(sizes, chunk, size)
    skip(io, size)
  end
  return sizes
end

function Base.read(wmo::WMOFile, chunk::Tag4)
  data = wmo.data[chunk]
  data !== nothing && return data
  read_chunk!(wmo, chunk)
  data = wmo.data[chunk]
  @assert data !== nothing
  return data
end

function read_chunk!(wmo::WMOFile, chunk::Tag4)
  wmo.data[chunk] = read_chunk(wmo, chunk)
end

function read_chunk(wmo::WMOFile, chunk::Tag4)
  wmo.sizes[chunk] == 0 && return missing
  seek_chunk(wmo, chunk)
  chunk === tag"MOHD" && return read(wmo.io, WMOHeader)
  chunk === tag"MOTX" && return read_textures(wmo)
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

function read_texture(wmo::WMOFile, offset::Int)
  seek_chunk(wmo, tag"MOTX")
  seek(wmo.io, position(wmo.io) + offset)
  while peek(wmo.io, UInt8) == 0 skip(wmo.io, 1) end
  return read_null_terminated_string(wmo.io)
end
