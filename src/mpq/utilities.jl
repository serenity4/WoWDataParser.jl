function listfile(archive::MPQArchive)
  filename = "(listfile)"
  file = get(archive.files, filename, nothing)
  isnothing(file) && (file = find_file(archive, filename))
  isnothing(file) && return nothing
  data = read(file)
  split(replace(String(data), '\\' => '/'), in(('\r', '\n', ';')); keepempty = false)
end

Base.getindex(archive::MPQArchive, filename::AbstractString) = MPQFile(archive, filename)
Base.get(archive::MPQArchive, filename::AbstractString, default) = something(find_file(archive, filename), default)

# TODO: Preserve listfile entries for blocks we will be rewriting without modification.
function regenerate_listfile!(archive::MPQArchive)
  filename = "(listfile)"
  io = IOBuffer()
  for file in archive.files
    write(io, file.filename, '\n')
  end
  seekstart(io)
  bytes = take!(io)
  file = MPQFile(archive, filename, bytes; locale = MPQ_LOCALE_NEUTRAL)
  archive
end

canonicalize(filename) = lowercase(replace(filename, '\\' => '/'))

function regenerate_filenames!(archive::MPQArchive)
  list = listfile(archive)
  if isnothing(list)
    !archive.created && @warn "No listfile found in this archive"
    # Insert an entry here to avoid regenerating filenames again and again.
    insert!(archive.filenames, "no listfile", "NO LISTFILE")
    return
  end
  for filename in list
    insert!(archive.filenames, canonicalize(filename), filename)
  end
end
