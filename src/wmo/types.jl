@serializable struct BoundingBox
  min::NTuple{3, Float32}
  max::NTuple{3, Float32}
end

@serializable struct WMOHeader
  materials::Int64 << read(io, UInt32)
  groups::Int64 << read(io, UInt32)
  portals::Int64 << read(io, UInt32)
  lights::Int64 << read(io, UInt32)
  models::Int64 << read(io, UInt32)
  doodads::Int64 << read(io, UInt32)
  sets::Int64 << read(io, UInt32)
  ambient_color::RGBA{N0f8} << RGBA(ntuple(_ -> reinterpret(N0f8, read(io, UInt8)), 4)...)
  id::Int64 << read(io, UInt32)
  bounding_box::BoundingBox
  flags::Int64 << read(io, UInt32)
  lods::Int64 << read(io, UInt32)
end

@bitmask exported=true WMOGroupFlags::UInt32 begin
  WMO_GROUP_HAS_BSP_TREE                          = 0x01
  WMO_GROUP_HAS_LIGHT_MAP                         = 0x02
  WMO_GROUP_HAS_VERTEX_COLORS                     = 0x04
  WMO_GROUP_IS_EXTERIOR                           = 0x08
  WMO_GROUP_IS_EXTERIOR_LIT                       = 0x40
  WMO_GROUP_IS_UNREACHABLE                        = 0x80
  WMO_GROUP_SHOW_EXTERIOR_SKY_IN_INTERIOR         = 0x100
  WMO_GROUP_HAS_LIGHTS                            = 0x200
  WMO_GROUP_LOAD_FOR_LODS                         = 0x400 # used from Legion, seems to disable shadow casting when on
  WMO_GROUP_HAS_DOODADS                           = 0x800
  WMO_GROUP_HAS_WATER                             = 0x1000
  WMO_GROUP_IS_INTERIOR                           = 0x2000
  WMO_GROUP_QUERY_MOUNT_ALLOWED                   = 0x8000
  WMO_GROUP_ALWAYS_DRAW                           = 0x10000
  WMO_GROUP_SHOW_SKYBOX                           = 0x40000
  WMO_GROUP_IS_OCEAN                              = 0x80000
  WMO_GROUP_IS_MOUNT_ALLOWED                      = 0x200000
  WMO_GROUP_HAS_SECOND_SET_OF_VERTEX_COLORS       = 0x1000000
  WMO_GROUP_HAS_SECOND_SET_OF_TEXTURE_COORDINATES = 0x2000000
  WMO_GROUP_ANTI_PORTAL                           = 0x4000000
  WMO_GROUP_DISABLE_BATCH_RENDERING               = 0x8000000
  WMO_GROUP_CULL_EXTERIOR                         = 0x20000000
  WMO_GROUP_HAS_THIRD_SET_OF_TEXTURE_COORDINATES  = 0x40000000
end

@serializable struct WMOGroup
  flags::WMOGroupFlags
  bounding_box::BoundingBox
  name_offset::Optional{Int} << begin
    value = read(io, Int32)
    ifelse(value == -1, nothing, value)
  end
end

@serializable struct DoodadSet
  name::Tag{20}
  start::Int64 << read(io, UInt32)
  count::Int64 << read(io, UInt32)
  @reserved 4
end

@bitmask exported = true FogFlags::UInt32 begin
  FOG_HAS_INFINITE_RADIUS = 1
end

@serializable struct FogData
  stop::Float32
  start::Float32
  clear_value::RGBA{N0f8} << RGBA(ntuple(_ -> reinterpret(N0f8, read(io, UInt8)), 4)...)
end

@serializable struct FogInfo
  flags::FogFlags << FogFlags(read(io, UInt8))
  @reserved 3
  location::NTuple{3,Float32}
  inner_radius::Float32
  outer_radius::Float32
  normal::FogData
  underwater::FogData
end

struct NoData end

mutable struct WMOFile{IO <: Base.IO}
  io::IO
  sizes::Dictionary{Tag4,Int64}
  data::Dictionary{Tag4,Any}
end
