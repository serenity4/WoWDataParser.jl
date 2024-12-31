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

ht_size(ht::MPQHashTable) = ht_size(length(ht.entries))
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

MPQBlockTable() = MPQBlockTable(MPQBlock[])

struct MPQFile{A}
  archive::A
  filename::String
  locale::Optional{MPQLocale}
  flags::MPQFileFlags
  compression::Optional{MPQCompressionFlags}
  block::Base.RefValue{MPQBlock}
  data::Vector{UInt8}
  created::Bool
end

hasblock(file::MPQFile) = file.block[].uncompressed_file_size !== 0xffffffff
function getblock(file::MPQFile)
  hasblock(file) || error("The provided file does not have an associated block")
  file.block[]
end
shouldencrypt(file::MPQFile) = in(MPQ_FILE_ENCRYPTED, file.flags)
shouldcompress(file::MPQFile) = in(MPQ_FILE_COMPRESS, file.flags)
iscompressed(block::MPQBlock) = block.compressed_file_size !== block.uncompressed_file_size
iscompressed(file::MPQFile) = iscompressed(getblock(file))
isimploded(block::MPQBlock) = in(MPQ_FILE_IMPLODE, block.flags)
isimploded(file::MPQFile) = isimploded(getblock(file))
isencrypted(block::MPQBlock) = in(MPQ_FILE_ENCRYPTED, block.flags)
isencrypted(file::MPQFile) = isencrypted(getblock(file))

mutable struct MPQArchive{IO<:Base.IO}
  io::IO
  const hash_table::MPQHashTable
  const block_table::MPQBlockTable
  const sector_size::Int
  const files::Dictionary{String, MPQFile{MPQArchive{IO}}}
  const filenames::Dictionary{String, String}
  const created::Bool
end

function MPQArchive(; max_files = 4096, sector_size = 4096)
  ispow2(sector_size) || error("Sector size must be a power of two.")
  MPQArchive(IOBuffer(), MPQHashTable(max_files), MPQBlockTable(), sector_size, true)
end

MPQArchive(io, ht, bt, sector_size, created = false) = MPQArchive(io, ht, bt, sector_size, Dictionary{String, MPQFile{MPQArchive{typeof(io)}}}(), Dictionary{String,String}(), created)

function Base.show(io::IO, archive::MPQArchive)
  print(io, MPQArchive, " (")
  ne = count(file -> !file.created, archive.files)
  nc = count(file -> file.created, archive.files)
  n = length(archive.block_table.entries) + nc
  print(io, n, " files in archive")
  ne ≠ 0 && print(io, ", ", ne, " files extracted")
  nc ≠ 0 && print(io, ", ", nc, " files created")
  print(io, ", sector size: ", Base.format_bytes(archive.sector_size))
  print(io, ", limit: ", length(archive.hash_table.entries), " files")
  print(io, ')')
end

function MPQFile(archive::MPQArchive, filename::AbstractString, hash_entry::MPQHashTableEntry, block::MPQBlock)
  MPQFile(archive, convert(String, filename), hash_entry.locale, block.flags, nothing, Ref(block), UInt8[], false)
end

function MPQFile(archive::MPQArchive, filename::AbstractString, data::AbstractVector{UInt8}; locale::Optional{MPQLocale} = nothing, flags::MPQFileFlags = MPQFileFlags(), compression::Optional{MPQCompressionFlags} = DEFAULT_COMPRESSION_METHOD, encrypt::Bool = false, force::Bool = false)
  lfilename = canonicalize(filename)
  haskey(archive.files, lfilename) && !force && error("The file $(repr(filename)) already exists")
  flags |= MPQ_FILE_EXISTS
  !isnothing(compression) && (flags |= MPQ_FILE_COMPRESS)
  encrypt && (flags |= MPQ_FILE_ENCRYPTED)
  placeholder = MPQBlock(0xffffffff, 0xffffffff, 0xffffffff, typemax(MPQFileFlags))
  isempty(archive.filenames) && filename ≠ "(listfile)" && regenerate_filenames!(archive)
  afilename = get(archive.filenames, lfilename, filename)
  file = MPQFile(archive, afilename, locale, flags, compression, Ref(placeholder), data, true)
  force ? set!(archive.files, lfilename, file) : insert!(archive.files, lfilename, file)
  file
end

function Base.show(io::IO, file::MPQFile)
  print(io, MPQFile, " (filename: $(repr(file.filename))")
  !isempty(file.data) && print(io, ", ", Base.format_bytes(length(file.data)), " of data")
  print(io, ", archive: $(file.archive)")
  print(io, ')')
end
