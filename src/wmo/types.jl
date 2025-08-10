@serializable struct WMOHeader
  materials::Int << read(io, UInt32)
  groups::Int << read(io, UInt32)
  portals::Int << read(io, UInt32)
  lights::Int << read(io, UInt32)
  models::Int << read(io, UInt32)
  doodads::Int << read(io, UInt32)
  sets::Int << read(io, UInt32)
  ambient_color::RGBA{N0f8} << RGBA(ntuple(_ -> reinterpret(N0f8, read(io, UInt8)), 4)...)
  id::Int << read(io, UInt32)
  bounding_box_corner_1::NTuple{3, Float32} << ntuple(_ -> read(io, Float32), 3)
  bounding_box_corner_2::NTuple{3, Float32} << ntuple(_ -> read(io, Float32), 3)
  flags::Int << read(io, UInt32)
  lods::Int << read(io, UInt32)
end

mutable struct WMOFile{IO <: Base.IO}
  io::IO
  sizes::Dictionary{Tag4,Int}
  data::Dictionary{Tag4,Any}
end
