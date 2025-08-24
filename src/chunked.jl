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

function parse_chunk_sizes_with_lists(io::IO)
  sizes = Dictionary{Tag4,Union{Int64, Vector{Int64}}}()
  while !eof(io)
    chunk = Tag4(bswap(read(io, UInt32)))
    size = Int64(read(io, UInt32))
    prev = get(sizes, chunk, nothing)
    if prev === nothing
      insert!(sizes, chunk, size)
    elseif isa(prev, Int64)
      set!(sizes, chunk, Int64[prev, size])
    elseif isa(prev, Vector{Int64})
      push!(prev, size)
    end
    skip(io, size)
  end
  return sizes
end

chunk_header_size() = 4 + 4 # magic number + chunk size

function seek_chunk(io::IO, sizes::Dictionary{Tag4, Int64}, chunk::Tag4)
  offset = chunk_header_size()
  for (name, size) in pairs(sizes)
    name === chunk && break
    offset += size + chunk_header_size()
  end
  seek(io, offset)
end

function seek_chunk(io::IO, sizes::Dictionary{Tag4, Union{Int64,Vector{Int64}}}, chunk::Tag4, index::Int = 1)
  offset = chunk_header_size()
  for (name, size) in pairs(sizes)
    if name === chunk
      for (i, subsize) in enumerate(size)
        offset += subsize + chunk_header_size()
        i == index && break
      end
      break
    else
      offset += size + chunk_header_size()
    end
  end
  seek(io, offset)
end

function read_filenames_from_chunk(io::IO, chunk_size)
  filenames = String[]
  start = position(io)
  while position(io) < start + chunk_size
    while peek(io, UInt8) == 0 skip(io, 1) end
    position(io) < start + chunk_size || break
    filename = read_null_terminated_string(io)
    push!(filenames, filename)
  end
  return filenames
end
