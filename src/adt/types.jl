@serializable struct ADTChunkInfo
  offset::Int64 << read(io, UInt32)
  size::Int64 << read(io, UInt32)
  flags::Int64 << read(io, UInt32)
end

mutable struct ADTFile{IO <: Base.IO}
  io::IO
  sizes::Dictionary{Tag4,Union{Int64,Vector{Int64}}}
  data::Dictionary{Tag4,Any}
end
