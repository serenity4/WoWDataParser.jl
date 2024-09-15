module WoWDBCReader

using Accessors
using BinaryParsingTools
using BitMasks
using CodecBzip2: Bzip2Compressor, Bzip2Decompressor
using CodecZlib: ZlibCompressor, ZlibDecompressor
using Dictionaries
using StructEquality
using TranscodingStreams: TranscodingStreams

const Optional{T} = Union{T, Nothing}

const LOCALE = Ref(:enUS)
set_locale(new::Symbol) = LOCALE[] = new
get_locale() = LOCALE[]

include("dbc/localization.jl")
include("dbc/schemas.jl")
include("dbc/types.jl")
include("dbc/read.jl")
include("dbc/write.jl")

include("mpq/locale.jl")
include("mpq/compression.jl")
include("mpq/types.jl")
include("mpq/collection.jl")
include("mpq/utilities.jl")
include("mpq/hash.jl")
include("mpq/cryptography.jl")
include("mpq/read.jl")
include("mpq/write.jl")

export LString,
       setproperties,
       DBCLocale, DBC_LOCALE_EN_US, DBC_LOCALE_KO_KR, DBC_LOCALE_FR_FR, DBC_LOCALE_DE_DE, DBC_LOCALE_EN_CN, DBC_LOCALE_EN_TW, DBC_LOCALE_ES_ES, DBC_LOCALE_ES_MX, DBC_LOCALE_RU_RU, DBC_LOCALE_PT_PT, DBC_LOCALE_IT_IT, DBC_LOCALE_UNKNOWN, DBC_LOCALE_EN_GB, DBC_LOCALE_ZH_CN, DBC_LOCALE_ZH_TW, DBC_LOCALE_PT_BR,
       MPQLocale, MPQ_LOCALE_NEUTRAL, MPQ_LOCALE_CHINESE, MPQ_LOCALE_CZECH, MPQ_LOCALE_GERMAN, MPQ_LOCALE_ENGLISH, MPQ_LOCALE_SPANISH, MPQ_LOCALE_FRENCH, MPQ_LOCALE_ITALIAN, MPQ_LOCALE_JAPANESE, MPQ_LOCALE_KOREAN, MPQ_LOCALE_DUTCH, MPQ_LOCALE_POLISH, MPQ_LOCALE_PORTUGUESE, MPQ_LOCALE_RUSSSIAN, MPQ_LOCALE_ENGLISH_UK, MPQ_LOCALE_UNDEFINED,
       @l_str,
       get_locale,
       set_locale,
       get_default_dbc_locale,
       set_default_dbc_locale,
       get_default_mpq_locale,
       set_default_mpq_locale,
       DBCData,
       DBCFile,
       MPQHeader,
       MPQHashTableEntry, MPQHashTable,
       MPQFile,
       MPQArchive,
       MPQCollection,
       find_file,
       listfile

end
