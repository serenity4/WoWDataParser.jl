@enum DBCLocale::UInt32 begin
  DBC_LOCALE_EN_US = 0
  DBC_LOCALE_KO_KR = 1
  DBC_LOCALE_FR_FR = 2
  DBC_LOCALE_DE_DE = 3
  DBC_LOCALE_EN_CN = 4
  DBC_LOCALE_EN_TW = 5
  DBC_LOCALE_ES_ES = 6
  DBC_LOCALE_ES_MX = 7
  DBC_LOCALE_RU_RU = 8
  DBC_LOCALE_PT_PT = 10
  DBC_LOCALE_IT_IT = 11
  DBC_LOCALE_UNKNOWN = 12
end

const DBC_LOCALE_EN_GB = DBC_LOCALE_EN_US
const DBC_LOCALE_ZH_CN = DBC_LOCALE_EN_CN
const DBC_LOCALE_ZH_TW = DBC_LOCALE_EN_TW
const DBC_LOCALE_PT_BR = DBC_LOCALE_PT_PT

const DBC_LOCALE_LIST = Dict{Symbol,DBCLocale}(
  :enUS => DBC_LOCALE_EN_US,
  :koKR => DBC_LOCALE_KO_KR,
  :frFR => DBC_LOCALE_FR_FR,
  :deDE => DBC_LOCALE_DE_DE,
  :enCN => DBC_LOCALE_EN_CN,
  :enTW => DBC_LOCALE_EN_TW,
  :esES => DBC_LOCALE_ES_ES,
  :esMX => DBC_LOCALE_ES_MX,
  :ruRU => DBC_LOCALE_RU_RU,
  :ptPT => DBC_LOCALE_PT_PT,
  :itIT => DBC_LOCALE_IT_IT,
)

const DEFAULT_DBC_LOCALE = Ref(DBC_LOCALE_LIST[get_locale()])

"Get the current locale."
get_default_dbc_locale() = DEFAULT_DBC_LOCALE[]

"Set the current locale with a new value, returning the one that was previously set."
function set_default_dbc_locale(new::DBCLocale)
  old = DEFAULT_DBC_LOCALE[]
  DEFAULT_DBC_LOCALE[] = new
  old
end

set_default_dbc_locale(new::Nothing) = set_default_dbc_locale(DBC_LOCALE_UNKNOWN)
set_default_dbc_locale(new::Symbol) = set_default_dbc_locale(DBC_LOCALE_LIST[new])

struct LString
  enUS::String
  enGB::String
  koKR::String
  frFR::String
  deDE::String
  enCN::String
  zhCN::String
  enTW::String
  zhTW::String
  esES::String
  esMX::String
  ruRU::String
  ptPT::String
  ptBR::String
  itIT::String
  unknown::String
  mask::UInt32
end

@generated function Base.:(==)(x::LString, y::LString)
  foldl((a, b) -> :($a && x.$b == y.$b), fieldnames(LString)[1:(end - 1)]; init = :true)
end

Base.broadcastable(lstr::LString) = Ref(lstr)

Base.getindex(lstr::LString) = getproperty(lstr, get_locale())
Base.isempty(lstr::LString) = isempty(lstr[])

LString(locale::Symbol) = LString((locale,))
function LString(locales::Union{Tuple, AbstractVector} = ())
  empty = ""
  mask = foldl((x, y) -> x | UInt32(DBC_LOCALE_LIST[y]), locales; init = UInt32(0))
  LString(ntuple(_ -> empty, 8)..., ntuple(_ -> empty, 8)..., mask)
end

function LString(str::T, locale::Symbol = get_locale()) where {T<:AbstractString}
  setproperties(LString(locale), NamedTuple{(locale,), Tuple{T}}((str,)))::LString
end

Base.show(io::IO, lstr::LString) = print(io, 'l', sprint(show, lstr[]))

macro l_str(ex) :(LString($(esc(ex)))) end

WoWBase.query_parameter(x::LString) = x[]

Base.convert(::Type{String}, lstr::LString) = lstr[]
Base.convert(::Type{LString}, str::AbstractString) = LString(str)
