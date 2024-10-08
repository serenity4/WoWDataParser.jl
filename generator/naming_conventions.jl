abstract type NamingConvention end

abstract type CamelCase <: NamingConvention end
abstract type SnakeCase <: NamingConvention end

struct SnakeCaseLower <: SnakeCase
    value::Any
    SnakeCaseLower(value) =
        is_snake_case(value) && lowercase(value) == value ? new(value) : error("Invalid string format $value")
end

struct SnakeCaseUpper <: SnakeCase
    value::Any
    SnakeCaseUpper(value) =
        is_snake_case(value) && uppercase(value) == value ? new(value) : error("Invalid string format $value")
end

struct CamelCaseLower <: CamelCase
    value::Any
    CamelCaseLower(value) =
        is_camel_case(value) && uppercase(value[1]) != value[1] ? new(value) : error("Invalid string format $value")
end

struct CamelCaseUpper <: CamelCase
    value::Any
    CamelCaseUpper(value) =
        is_camel_case(value) && uppercase(value[1]) == value[1] ? new(value) : error("Invalid string format $value")
end

Base.split(str::SnakeCase) = split(str.value, "_")

function Base.split(str::CamelCase)
    strval = str.value
    if all(!isdigit, strval)
        lowercase(strval) == strval && return [strval]
        length(strval) > 1 && lowercase(strval[2:end]) == strval[2:end] && return [strval]
    end
    reg_upper = r"(([A-Z]+|\d+)(?=(([A-Z]+|\d+)|$))|([A-Z]{1})[a-z]*?(?=($|([A-Z]|\d))))"
    if uppercase(strval[1]) == strval[1] # CamelCaseUpper
        matches = getproperty.(collect(eachmatch(reg_upper, strval)), :match)
    else
        first = match(r"[a-z]+(?=([A-Z]|\d))", strval).match
        matches = [first, getproperty.(collect(eachmatch(reg_upper, strval)), :match)...]
    end
    matches
end

SnakeCaseLower(parts::AbstractArray) = SnakeCaseLower(lowercase(snake_case(parts)))
SnakeCaseUpper(parts::AbstractArray) = SnakeCaseUpper(uppercase(snake_case(parts)))

CamelCaseLower(parts::AbstractArray) = CamelCaseLower(camel_case(lowercase.(parts)))
CamelCaseUpper(parts::AbstractArray) = CamelCaseUpper(uppercasefirst(camel_case(lowercase.(parts))))

snake_case(parts::AbstractArray) = join(parts, "_")
camel_case(parts::AbstractArray) = length(parts) == 1 ? parts[1] : join([parts[1], uppercasefirst.(parts[2:end])...])

Base.convert(T::Type{SnakeCaseLower}, str::SnakeCaseUpper) = T(lowercase(str.value))
Base.convert(T::Type{SnakeCaseUpper}, str::SnakeCaseLower) = T(uppercase(str.value))
Base.convert(T::Type{CamelCaseLower}, str::CamelCaseUpper) = T(lowercase(str.value[1]) * str.value[2:end])
Base.convert(T::Type{CamelCaseUpper}, str::CamelCaseLower) = T(uppercasefirst(str.value))
Base.convert(T::Type{<:CamelCase}, str::SnakeCase) = T(split(str))
Base.convert(T::Type{<:SnakeCase}, str::CamelCase) = T(split(str))
nc_convert(T::Type{<:NamingConvention}, str::AbstractString) =
    Base.convert(T, (detect_convention(str, instance = true))).value
nc_convert(T::Type{<:NamingConvention}, sym::Symbol) = Symbol(nc_convert(T, string(sym)))

is_camel_case(str) = !occursin("_", str)
is_snake_case(str) = lowercase(str) == str || uppercase(str) == str

is_camel_case(str::NamingConvention) = is_camel_case(str.value)
is_snake_case(str::NamingConvention) = is_snake_case(str.value)

function detect_convention(str; instance = false)
    instanced(T, x) = instance ? T(x) : T
    is_camel_case(str) && lowercase(str)[1] == str[1] && return instanced(CamelCaseLower, str)
    is_camel_case(str) && uppercase(str)[1] == str[1] && return instanced(CamelCaseUpper, str)
    is_snake_case(str) && lowercase(str) == str && return instanced(SnakeCaseLower, str)
    is_snake_case(str) && uppercase(str) == str && return instanced(SnakeCaseUpper, str)
    error("No convention detected for string $str")
end
