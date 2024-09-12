struct MPQHeader
  sector_size::Int64
  # Number of entries in the hash table. Must be a power of two, and must be less than 2^16 for
  # the original MoPaQ format, or less than 2^20 for the Burning Crusade format.
  hash_table_length::Int64
  # Number of entries in the block table.
  block_table_length::Int64
  # Offset to the beginning of the hash table, relative to the beginning of the archive.
  hash_table_offset::Int64
  # Offset to the beginning of the block table, relative to the beginning of the archive.
  block_table_offset::Int64
end

function MPQHeader(sector_size, hash_table_length, block_table_length; hash_table_offset = 44, block_table_offset = hash_table_offset + hash_table_length * sizeof(MPQHashTable))
  MPQHeader(sector_size, hash_table_length, block_table_length, hash_table_offset, block_table_offset)
end

ht_size_compressed(header::MPQHeader) = Int(header.block_table_offset - header.hash_table_offset)
ht_size(header::MPQHeader) = ht_size(header.hash_table_length)

@enum MPQLocale::UInt16 begin
  MPQ_LOCALE_NEUTRAL      = 0x0000
  MPQ_LOCALE_CHINESE      = 0x0404
  MPQ_LOCALE_CZECH        = 0x0405
  MPQ_LOCALE_GERMAN       = 0x0407
  MPQ_LOCALE_ENGLISH      = 0x0409
  MPQ_LOCALE_SPANISH      = 0x040a
  MPQ_LOCALE_FRENCH       = 0x040c
  MPQ_LOCALE_ITALIAN      = 0x0410
  MPQ_LOCALE_JAPANESE     = 0x0411
  MPQ_LOCALE_KOREAN       = 0x0412
  MPQ_LOCALE_DUTCH        = 0x0413
  MPQ_LOCALE_POLISH       = 0x0415
  MPQ_LOCALE_PORTUGUESE   = 0x0416
  MPQ_LOCALE_RUSSSIAN     = 0x0419
  MPQ_LOCALE_ENGLISH_UK   = 0x0809
  MPQ_LOCALE_UNDEFINED    = 0xffff
end

struct MPQHashTableEntry
  ha::UInt32
  hb::UInt32
  locale::MPQLocale
  platform::UInt8
  reserved::UInt8
  block_index::UInt32
end

MPQHashTableEntry() = MPQHashTableEntry(0xffffffff, 0xffffffff, MPQ_LOCALE_UNDEFINED, 0xff, 0xff, 0xffffffff)

struct MPQHashTable
  entries::Vector{MPQHashTableEntry}
end

MPQHashTable(n::Integer = 4096) = MPQHashTable(fill(MPQHashTableEntry(), n))

ht_size(ht::MPQHashTable) = ht_size(length(ht))
ht_size(n::Integer) = 16n

@bitmask exported = true MPQFileFlags::UInt32 begin
  "Implode method (By PKWARE Data Compression Library)."
  MPQ_FILE_IMPLODE = 0x00000100
  "Compress methods (By multiple methods)."
  MPQ_FILE_COMPRESS = 0x00000200
  "Indicates an encrypted file."
  MPQ_FILE_ENCRYPTED = 0x00010000
  "Indicates an encrypted file with key v2."
  MPQ_FILE_KEY_V2 = 0x00020000
  "The file is a patch file. Raw file data begin with MPQPatchInfo structure."
  MPQ_FILE_PATCH_FILE = 0x00100000
  "File is stored as a single unit, rather than split into sectors (Thx, Quantam)."
  MPQ_FILE_SINGLE_UNIT = 0x01000000
  "File is a deletion marker. Used in MPQ patches, indicating that the file no longer exists."
  MPQ_FILE_DELETE_MARKER = 0x02000000
  "File has checksums for each sector."
  MPQ_FILE_SECTOR_CRC = 0x04000000

  # Ignored if file is not compressed or imploded.
  "Set if file exists, reset when the file was deleted."
  MPQ_FILE_EXISTS = 0x80000000
  "Replace when the file exists (SFileAddFile)."
  MPQ_FILE_REPLACEEXISTING = 0x80000000
  "Mask for a file being compressed."
  MPQ_FILE_COMPRESS_MASK = 0x0000FF00

  "Use default flags for internal files."
  MPQ_FILE_DEFAULT_INTERNAL = 0xFFFFFFFF
end

struct MPQBlock
  # Offset of the beginning of the file, relative to the beginning of the archive.
  file_offset::UInt32
  compressed_file_size::UInt32
  # Should be 0 if the block is not a file.
  uncompressed_file_size::UInt32
  # Flags for the file. See MPQ_FILE_XXXX constants
  flags::MPQFileFlags
end

function Base.show(io::IO, block::MPQBlock)
  print(io, MPQBlock, '(')
  print(io, "offset: ", block.file_offset)
  print(io, ", compressed size: ", Base.format_bytes(Int(block.compressed_file_size)))
  if !iszero(block.uncompressed_file_size)
    print(io, ", uncompressed size: ", Base.format_bytes(Int(block.uncompressed_file_size)))
  end
  print(io, ", flags: ", block.flags)
  print(io, ')')
end

struct MPQBlockTable
  entries::Vector{MPQBlock}
end

struct MPQFile end

mutable struct MPQArchive{IO<:Base.IO}
  io::IO
  hash_table::MPQHashTable
  block_table::MPQBlockTable
  sector_size::Int
  function MPQArchive(io::IO, hash_table, block_table, sector_size)
    archive = new{typeof(io)}(io, hash_table, block_table, sector_size)
    finalizer(x -> close(x.io), archive)
  end
end
