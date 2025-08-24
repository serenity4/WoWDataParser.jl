# Data is always in little-endian format.
BinaryParsingTools.swap_endianness(io::IO, ::Type{ADTFile}) = ENDIAN_BOM ≠ 0x04030201

ADTFile(bytes::AbstractVector) = ADTFile(IOBuffer(bytes))
ADTFile(path::AbstractString) = finalizer(x -> close(x.io), ADTFile(open(path, "r")))
ADTFile(io::IO) = read_binary(io, ADTFile)

Base.getindex(adt::ADTFile, name::Tag4) = read(adt, name)

function Base.read(io::BinaryIO, ::Type{ADTFile})
  sizes = parse_chunk_sizes_with_lists(io)
  data = Dictionary{Tag4,Any}()
  for chunk in keys(sizes)
    insert!(data, chunk, NoData())
  end
  ADTFile(io, sizes, data)
end

function Base.read(adt::ADTFile, chunk::Tag4)
  data = adt.data[chunk]
  data !== NoData() && return data
  read_chunk!(adt, chunk)
  data = adt.data[chunk]
  @assert data !== NoData()
  return data
end

function read_chunk!(adt::ADTFile, chunk::Tag4)
  adt.data[chunk] = read_chunk(adt, chunk)
end

function read_chunk(adt::ADTFile, chunk::Tag4, index::Int = 1)
  adt.sizes[chunk] == 0 && return missing
  seek_chunk(adt.io, adt.sizes, chunk, index)
  chunk === tag"MCIN" && return read_chunk_infos(adt)::Matrix{ADTChunkInfo}
  chunk === tag"MTEX" && return read_textures(adt)::Vector{String}
  @warn "Parsing not implemented for chunk $chunk"
  return missing
end

function read_chunk_infos(adt::ADTFile)
  infos = Matrix{ADTChunkInfo}(undef, 16, 16)
  for i in 1:16
    for j in 1:16
      infos[i] = read(adt.io, ADTChunkInfo)
      skip(adt.io, 4)
    end
  end
  return infos
end

read_textures(adt::ADTFile) = read_filenames_from_chunk(adt.io, adt.sizes[tag"MTEX"])
