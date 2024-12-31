struct MPQCollection{IO<:Base.IO}
  archives::Vector{MPQArchive{IO}}
  file_sources::Dictionary{String, MPQArchive{IO}}
end

struct ClientMPQFiles
  data_directory::String
  files::Vector{String}
  locale_files::Vector{String}
  locale_folder::Optional{String}
end

is_mpq(file) = endswith(file, ".MPQ") || endswith(file, ".mpq")

function ClientMPQFiles(data_directory::AbstractString)
  files = String[]
  locale_files = String[]
  locale_folder = nothing
  files = readdir(data_directory)
  i = findfirst(file -> haskey(MPQ_LOCALE_LIST, Symbol(file)), files)
  locale_folder = isnothing(i) ? nothing : files[i]
  filter!(is_mpq, files)
  locale_files = isnothing(locale_folder) ? String[] : filter!(is_mpq, readdir(joinpath(data_directory, locale_folder)))
  ClientMPQFiles(data_directory, files, locale_files, locale_folder)
end

function add_locale_mpq_files!(list, prefix, locale_files, locale_folder)
  locale = basename(locale_folder)
  prefix *= "-$locale"
  append!(list, joinpath(locale_folder, file) for file in filter(startswith("$prefix-"), locale_files))
  i = findfirst(startswith("$prefix."), locale_files)
  !isnothing(i) && push!(list, joinpath(locale_folder, locale_files[i]))
  list
end

function add_mpq_files!(list, prefix, files)
  append!(list, filter(startswith("$prefix-"), files))
  i = findfirst(startswith("$prefix."), files)
  !isnothing(i) && push!(list, files[i])
  list
end

function files_sorted_by_priority((; files, locale_files, locale_folder)::ClientMPQFiles)
  list = String[]
  files = sort(files; rev = true)
  locale_files = sort(locale_files; rev = true)
  if !isnothing(locale_folder)
    add_locale_mpq_files!(list, "patch", locale_files, locale_folder)
    add_locale_mpq_files!(list, "lichking-locale", locale_files, locale_folder)
    add_locale_mpq_files!(list, "lichking-speech", locale_files, locale_folder)
    add_locale_mpq_files!(list, "expansion-locale", locale_files, locale_folder)
    add_locale_mpq_files!(list, "expansion-speech", locale_files, locale_folder)
    add_locale_mpq_files!(list, "locale", locale_files, locale_folder)
    add_locale_mpq_files!(list, "speech", locale_files, locale_folder)
    add_locale_mpq_files!(list, "base", locale_files, locale_folder)
  end
  add_mpq_files!(list, "patch", files)
  add_mpq_files!(list, "lichking", files)
  add_mpq_files!(list, "expansion", files)
  add_mpq_files!(list, "common", files)
  list
end

function MPQCollection(data_directory::AbstractString)
  files = ClientMPQFiles(data_directory)
  MPQCollection(joinpath.(data_directory, files_sorted_by_priority(files)))
end

function MPQCollection(files)
  archives = MPQArchive.(files)
  file_sources = Dictionary{String, typeof(archives[1])}()
  for archive in archives
    regenerate_filenames!(archive)
    list = listfile(archive)
    isnothing(list) && continue
    for file in list
      get!(file_sources, canonicalize(file), archive)
    end
  end
  sortkeys!(file_sources)
  MPQCollection(archives, file_sources)
end

function listfile(collection::MPQCollection)
  list = String[]
  for (lfilename, archive) in pairs(collection.file_sources)
    push!(list, archive.filenames[lfilename])
  end
  list
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

function MPQFile(collection::MPQCollection, filename::AbstractString)
  archive = get(collection.file_sources, canonicalize(filename), nothing)
  isnothing(archive) && error("No file named $(repr(filename)) exists in this collection.")
  MPQFile(archive, filename)
end

Base.getindex(collection::MPQCollection, filename::AbstractString) = MPQFile(collection, filename)
