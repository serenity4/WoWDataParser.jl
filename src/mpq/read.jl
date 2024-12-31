const MPQ_MAGIC_NUMBER = Tag4(('M', 'P', 'Q', '\x1A'))

function BinaryParsingTools.swap_endianness(io::IO, ::Type{MPQArchive})
  peek(io, Tag4) == reverse(MPQ_MAGIC_NUMBER)
end

MPQArchive(path::AbstractString) = finalizer(x -> close(x.io), MPQArchive(open(path, "r")))
MPQArchive(io::IO) = read_binary(io, MPQArchive)

function Base.read(io::BinaryIO, ::Type{MPQArchive})
  header = read(io, MPQHeader)
  ht = read(io, MPQHashTable, header)
  bt = read(io, MPQBlockTable, header)
  MPQArchive(io, ht, bt, header.sector_size)
end

function extended_offset(hi, offset)
  hi == 0 && return UInt64(offset)
  (UInt64(hi) << 32) | UInt64(offset)
end

function decompose_offset(offset)
  offset = convert(UInt64, offset)
  offset & 0xffffffff00000000 == 0 && return (UInt16(0), UInt32(offset))
  hi = UInt16(offset >> 32)
  low = UInt32(offset & 0x00000000ffffffff)
  (hi, low)
end

function Base.read(io::IO, ::Type{MPQHeader})
  magic_number = read(io, Tag4)
  magic_number === MPQ_MAGIC_NUMBER || error("The file's magic number does not correspond to a MPQ format.")
  header_size = read(io, UInt32)
  header_size == 44 || error("Expected a header size of 44 bytes (read a size of $header_size).")
  archive_size = read(io, UInt32)
  format = read(io, UInt16)
  format == 1 || error("Only WOTLK-compatible MPQ files are supported; format must therefore be 1, but is $format")
  block_size_exponent = read(io, UInt16)
  block_size = 2^block_size_exponent
  sector_size = 512block_size

  hash_table_offset = read(io, UInt32)
  block_table_offset = read(io, UInt32)
  hash_table_length = read(io, UInt32)
  block_table_length = read(io, UInt32)

  hi_block_table_offset_64 = read(io, UInt64)
  hi_hash_table_offset = read(io, UInt16)
  hi_block_table_offset = read(io, UInt16)

  hash_table_offset = extended_offset(hi_hash_table_offset, hash_table_offset)
  block_table_offset = extended_offset(hi_block_table_offset, block_table_offset)

  if hi_block_table_offset_64 ≠ 0
    error("Expected value of `hi_block_table_offset_64` to be zero; got $hi_block_table_offset_64 instead")
  end

  MPQHeader(sector_size, hash_table_length, block_table_length, hash_table_offset, block_table_offset)
end

function Base.read(io::IO, ::Type{MPQHashTable}, header::MPQHeader)
  compressed = ht_size_compressed(header) < ht_size(header)
  !compressed || error("Compressed hash tables are not supported")

  seek(io, header.hash_table_offset)
  data = [read(io, UInt32) for _ in 1:(ht_size_compressed(header) ÷ 4)]
  decrypt_block!(data, MPQ_KEY_HASH_TABLE)
  # Decompression step would go there.
  entries = reinterpret(MPQHashTableEntry, data)
  MPQHashTable(entries)
end

function Base.read(io::IO, ::Type{MPQBlockTable}, header::MPQHeader)
  seek(io, header.block_table_offset)
  nb = sizeof(MPQBlock) * header.block_table_length
  data = [read(io, UInt32) for _ in 1:(nb ÷ sizeof(UInt32))]
  decrypt_block!(data, MPQ_KEY_BLOCK_TABLE)
  entries = reinterpret(MPQBlock, data)
  MPQBlockTable(entries)
end

function find_file(archive::MPQArchive, filename::AbstractString)
  hash_entry = find_hash_entry(archive, filename)
  isnothing(hash_entry) && return nothing
  block = archive.block_table.entries[hash_entry.block_index + 1]
  MPQFile(archive, filename, hash_entry, block)
end

function MPQFile(archive::MPQArchive, filename::AbstractString)
  lfilename = canonicalize(filename)
  isempty(archive.filenames) && regenerate_filenames!(archive)
  afilename = get(archive.filenames, lfilename, filename)
  file = get(archive.files, afilename, nothing)
  !isnothing(file) && return file
  file = find_file(archive, afilename)
  isnothing(file) && error("No file named '$filename' exists in this archive")
  insert!(archive.files, afilename, file)
  file
end

function Base.read(file::MPQFile)
  file.created && return file.data
  !isempty(file.data) && return file.data
  (; archive, filename) = file
  isdefined(file.block, 1) || error("The file must be associated with a block for data to be read")
  block = getblock(file)
  seek(archive.io, block.file_offset)
  n = cld(Int64(block.uncompressed_file_size), archive.sector_size)
  key = isencrypted(file) ? file_decryption_key(filename, block) : nothing
  isimploded(file) && error("Imploded data is not supported at the moment.")
  if iscompressed(file)
    read_compressed_block_data!(file.data, archive.io, block, n, archive.sector_size, key)
  else
    read_uncompressed_block_data!(file.data, archive.io, block, n, archive.sector_size, key)
  end
  file.data
end

function find_hash_entry(archive::MPQArchive, filename::AbstractString)
  slot = hash_table_slot(archive.hash_table, filename)
  slot == 0xffffffff && return nothing
  archive.hash_table.entries[slot]
end

function read_compressed_block_data!(data::Vector{UInt8}, io::IO, block::MPQBlock, ns, sector_size, key::Optional{UInt32})
  p = position(io)
  sector_offsets = Int64[read(io, Int32) for _ in 1:(ns + 1)]
  final_size = Int64(block.uncompressed_file_size) % sector_size
  sector_buffer = zeros(UInt8, sector_size)
  decompression_buffer = zeros(UInt8, sector_size)
  sizehint!(data, block.uncompressed_file_size)
  for i in 1:ns
    i == ns && (decompression_buffer = zeros(UInt8, final_size))
    offset, next_offset = sector_offsets[i], sector_offsets[i + 1]
    seek(io, p + offset)
    compressed_sector_size = next_offset - offset
    uncompressed_sector_size = ifelse(i == ns, final_size, sector_size)
    # The sector is compressed only if its size is strictly lesser than its uncompressed size.
    if uncompressed_sector_size == compressed_sector_size
      # The sector is stored uncompressed.
      for j in 1:uncompressed_sector_size sector_buffer[j] = read(io, UInt8) end
      sector = @view sector_buffer[1:uncompressed_sector_size]
      !isnothing(key) && decrypt_block!(reinterpret(UInt32, sector), key + UInt32(i - 1))
      append!(data, sector)
    else
      # The sector is stored in a compressed form.
      method = read(io, MPQCompressionFlags)
      datasize = compressed_sector_size - one(compressed_sector_size)
      for j in 1:datasize sector_buffer[j] = read(io, UInt8) end
      sector = @view sector_buffer[1:datasize]
      sector = decompress!(decompression_buffer, IOBuffer(sector), method)
      !isnothing(key) && decrypt_block!(reinterpret(UInt32, sector), key + UInt32(i - 1))
      append!(data, sector)
    end
  end
  data
end

function read_uncompressed_block_data!(data::Vector{UInt8}, io::IO, block::MPQBlock, ns, sector_size, key::Optional{UInt32})
  final_size = Int64(block.uncompressed_file_size) % sector_size
  sector_buffer = zeros(UInt8, sector_size)
  for i in 1:ns
    size = i == ns ? final_size : sector_size
    for j in 1:size
      sector_buffer[j] = read(io, UInt8)
    end
    sector = @view sector_buffer[1:size]
    if !isnothing(key)
      sector = reinterpret(UInt32, sector)
      decrypt_block!(sector, key + UInt32(i - 1))
      sector = reinterpret(UInt8, sector)
    end
    append!(data, sector)
  end
  data
end
