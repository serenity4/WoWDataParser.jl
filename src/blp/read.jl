function BinaryParsingTools.swap_endianness(io::IO, ::Type{BLPFile})
  peek(io, Tag4) == reverse(BLP_MAGIC_NUMBER)
end

BLPFile(path::AbstractString) = open(io -> read_binary(io, BLPFile), path, "r")
BLPFile(bytes::AbstractVector) = read_binary(IOBuffer(bytes), BLPFile)

function Base.read(io::BinaryIO, ::Type{BLPFile})
  magic = read(io, Tag4)
  magic === BLP_MAGIC_NUMBER || error("Magic number does not match that of a BLP file: got '$magic' instead of '$BLP_MAGIC_NUMBER'")
  type = read(io, UInt32)
  type == 1 || error("BLP file type expected to be 1, but is $type")
  compression = read(io, BLPCompression)
  alpha_depth = read(io, UInt8)
  any(==(alpha_depth), (0, 1, 4, 8)) || error("Unsupported alpha depth value: $alpha_depth")
  pixel_format = read(io, BLPPixelFormat)
  mip_flags = read(io, UInt8)
  has_mips = Bool(mip_flags & 0x01)
  width = read(io, UInt32)
  height = read(io, UInt32)
  mipmap_offsets = [read(io, UInt32) for _ in 1:16]
  mipmap_lengths = [read(io, UInt32) for _ in 1:16]
  if compression === BLP_COMPRESSION_BLP
    palette = [reinterpret(ABGR{N0f8}, read(io, UInt32)) for _ in 1:256]
  else
    palette = nothing
    skip(io, 1024)
  end
  images = read_blp_images(io, width, height, compression, alpha_depth, pixel_format, has_mips, mipmap_offsets, mipmap_lengths, palette)
  BLPFile(popfirst!(images), images)
end

function read_blp_images(io, width, height, compression, alpha_depth, pixel_format, has_mips::Bool, mipmap_offsets, mipmap_lengths, palette)
  mip_range = 0:(has_mips ? minimum(Int ∘ ceil ∘ log2, (width, height)) : 0)
  images = Matrix{RGBA{N0f8}}[]
  for (level, offset, size) in zip(mip_range, mipmap_offsets, mipmap_lengths)
    nx, ny = width >> level, height >> level
    n = nx * ny
    !iszero(offset) && seek(io, offset)
    if compression === BLP_COMPRESSION_BLP
      image = zeros(RGBA{N0f8}, nx, ny)
      palette::Vector{ABGR{N0f8}}
      for i in 1:n
        index = read(io, UInt8)
        pixel = palette[index + 1]
        image[i] = RGBA(pixel.r, pixel.g, pixel.b, pixel.alpha)
      end
      if alpha_depth > 0
        n_per_alpha = 8 ÷ alpha_depth
        na = nx * ny >> (n_per_alpha - 1)
        for i in 1:na
          alpha = read(io, UInt8)
          for k in 1:n_per_alpha
            pixel = image[i]
            image[i] = @set pixel.alpha = reinterpret(N0f8, (alpha << (8 - k * alpha_depth)) >> 8 - alpha_depth)
          end
        end
      end
      push!(images, image)
    elseif compression === BLP_COMPRESSION_DXTC && pixel_format === BLP_PIXEL_FORMAT_DXT1
      image = zeros(RGBA{N0f8}, nx, ny)
      push!(images, image)
      sx, sy = cld(nx, 4), cld(ny, 4)
      for y in 1:sy
        offset_y = 4(y - 1)
        for x in 1:sx
          offset_x = 4(x - 1)
          a = read(io, RGB16)
          b = read(io, RGB16)
          bits = read(io, UInt32)
          reserved = a.data > b.data ? nothing : RGBA{N0f8}(0, 0, 0, ifelse(alpha_depth == 0, 1, 0))
          for bx in 1:4
            i = bx + offset_x
            i > nx && break
            for by in 1:4
              j = by + offset_y
              j > ny && break
              bit_offset = 2 * (bx + 4(by - 1) - 1)
              bit = ((bits << (30 - bit_offset)) >> 30) % UInt8
              if isnothing(reserved)
                pixel = bit == 0x00 ? RGB{Float64}(a) : bit == 0x01 ? RGB{Float64}(b) : mix(a, b, (bit - 1)/3)
                image[i, j] = RGBA{N0f8}(pixel.r, pixel.g, pixel.b, 1)
              elseif bit == 0x03
                image[i, j] = reserved
              else
                pixel = bit == 0x00 ? RGB{Float64}(a) : bit == 0x01 ? RGB{Float64}(b) : mix(a, b, 0.5)
                image[i, j] = RGBA{N0f8}(pixel.r, pixel.g, pixel.b, 1)
              end
            end
          end
        end
      end
    elseif compression === BLP_COMPRESSION_DXTC && pixel_format === BLP_PIXEL_FORMAT_DXT3
      image = zeros(RGBA{N0f8}, nx, ny)
      push!(images, image)
      sx, sy = cld(nx, 4), cld(ny, 4)
      for y in 1:sy
        offset_y = 4(y - 1)
        for x in 1:sx
          offset_x = 4(x - 1)
          alphas = read(io, UInt64)
          a = read(io, RGB16)
          b = read(io, RGB16)
          bits = read(io, UInt32)
          for bx in 1:4
            i = bx + offset_x
            i > nx && break
            for by in 1:4
              j = by + offset_y
              j > ny && break
              bit_offset = 2 * (bx + 4(by - 1) - 1)
              alpha_offset = 4 * (bx + 4(by - 1) - 1)
              bit = ((bits << (30 - bit_offset)) >> 30) % UInt8
              pixel = bit == 0x00 ? RGB{Float64}(a) : bit == 0x01 ? RGB{Float64}(b) : mix(a, b, (bit - 1)/3)
              alpha = (((alphas << (60 - alpha_offset)) >> 60) % UInt16) / 15
              image[i, j] = RGBA{N0f8}(pixel.r, pixel.g, pixel.b, alpha)
            end
          end
        end
      end
    elseif compression === BLP_COMPRESSION_DXTC && pixel_format === BLP_PIXEL_FORMAT_DXT5
      image = zeros(RGBA{N0f8}, nx, ny)
      push!(images, image)
      sx, sy = cld(nx, 4), cld(ny, 4)
      for y in 1:sy
        offset_y = 4(y - 1)
        for x in 1:sx
          offset_x = 4(x - 1)
          p = position(io)
          alpha_block = try
            read(io, UInt64)
          catch EOFError
            @goto next # assume the rest is zero
          end
          alpha_a = (alpha_block & 0xff) / 255
          alpha_b = ((alpha_block & 0xff00) >> 8) / 255
          alpha_bits = alpha_block >> 16
          a = read(io, RGB16)
          b = read(io, RGB16)
          bits = read(io, UInt32)
          for bx in 1:4
            i = bx + offset_x
            i > nx && break
            for by in 1:4
              j = by + offset_y
              j > ny && break
              bit_offset = 2 * (bx + 4(by - 1) - 1)
              alpha_offset = 3 * (bx + 3(by - 1) - 1)
              bit = ((bits << (30 - bit_offset)) >> 30) % UInt8
              pixel = bit == 0x00 ? RGB{Float64}(a) : bit == 0x01 ? RGB{Float64}(b) : mix(a, b, (bit - 1)/3)
              alpha_code = (alpha_bits >> alpha_offset) & 0x07
              alpha = alpha_code == 0x00 ? alpha_a : alpha_code == 0x01 ? alpha_b : if alpha_a > alpha_b
                mix(alpha_a, alpha_b, (alpha_code - 1) / 7)
              else
                alpha_code == 0x06 ? 0.0 : alpha_code == 0x07 ? 1.0 : mix(alpha_a, alpha_b, (alpha_code - 1) / 5)
              end
              image[i, j] = RGBA{N0f8}(pixel.r, pixel.g, pixel.b, alpha)
            end
          end
        end
      end
    else
      error("Unsupported compression format $compression with pixel format $pixel_format")
    end
    @label next
  end
  images
end

mix(a::RGB16, b::RGB16, weight) = RGB(((1 - weight) .* (a.r, a.g, a.b) .+ weight .* (b.r, b.g, b.b))...)
mix(a, b, weight) = (1 .- weight) .* a .+ weight .* b
