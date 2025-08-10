Base.show(io::IO, lstr::LString) = print(io, 'l', sprint(show, lstr[]))

function Base.show(io::IO, data::DBCData)
  n = length(data.rows)
  print(io, typeof(data), " (")
  print(io, "name: ", data.name)
  print(io, ") with $n rows")
end

function Base.show(io::IO, collection::MPQCollection)
  print(io, MPQCollection, " (")
  print(io, length(collection.archives), " archives opened")
  print(io, ", ", length(collection.file_sources), " files in total")
  print(io, ')')
end

function Base.show(io::IO, mime::MIME"text/plain", collection::MPQCollection)
  isempty(collection.archives) && return print(io, MPQCollection, " (empty)")
  print(io, MPQCollection, " with ", length(collection.file_sources), " files across ", length(collection.archives), " archives:")
  for archive in collection.archives
    print(io, "\n⚫ ")
    show(io, mime, archive)
  end
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

function Base.show(io::IO, file::MPQFile)
  print(io, MPQFile, " (filename: $(repr(file.filename))")
  !isempty(file.data) && print(io, ", ", Base.format_bytes(length(file.data)), " of data")
  print(io, ", archive: $(file.archive)")
  print(io, ')')
end
