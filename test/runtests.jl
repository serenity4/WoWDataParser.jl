using WoWDataParser
using WoWDataParser: RGBA, RGB16, N0f8
using LinearAlgebra: norm
using MultivariateStats: mean
using StatsBase: quantile
using BinaryParsingTools: read_binary, @tag_str, Tag
const WoW = WoWDataParser
using Test

dbc_file(name) = joinpath(DBC_DIRECTORY, "$name.dbc")
mpq_file(name) = joinpath(DATA_DIRECTORY, "$name.MPQ")
error_quantile(x, y, bound) = quantile(reshape(norm.(y - x), (prod(size(x)))), bound)

@testset "WoWDataParser.jl" begin
  @testset "Localization" begin
    @test get_locale() === :enUS
    set_locale(:enGB)
    @test get_locale() === :enGB
    set_locale(:enUS)

    @test get_default_mpq_locale() === MPQ_LOCALE_NEUTRAL
    set_default_mpq_locale(MPQ_LOCALE_ENGLISH)
    @test get_default_mpq_locale() === MPQ_LOCALE_ENGLISH
    set_default_mpq_locale(MPQ_LOCALE_NEUTRAL)

    @test get_default_dbc_locale() === DBC_LOCALE_EN_US
    set_default_dbc_locale(DBC_LOCALE_FR_FR)
    @test get_default_dbc_locale() === DBC_LOCALE_FR_FR
    set_default_dbc_locale(DBC_LOCALE_EN_US)

    set_locale(:enUS)
    lstr = l"English text"
    @test lstr[] == "English text"
    set_locale(:frFR)
    @test lstr[] == ""
    lstr = l"Texte français"
    @test lstr[] == "Texte français"
    set_locale(:enUS)
    @test lstr[] == ""
    lstr = LString((:enUS, :frFR))
    @test lstr[] == ""
    lstr = setproperties(lstr, (frFR = "Texte français", enUS = "English text"))
    @test lstr[] == "English text"
    set_locale(:frFR)
    @test lstr[] == "Texte français"
    set_locale(:enUS)

    x = l"Hello"
    y = l"Hello"
    @test x == y
    x = l"ello"
    y = l"Hello"
    @test x != y
    x = setproperties(LString(), (; enUS = "US", frFR = "FR"))
    y = l"US"
    @test x ≠ y && x[] == y[]
  end

  @testset "DBC files" begin
    @testset "Reading DBC files" begin
      dbc = DBCData(dbc_file(:TalentTab))
      @test dbc.name === :TalentTab
      @test isa(dbc, DBCData{TalentTabData})
      @test length(dbc.rows) ≥ 33

      dbc = DBCData(dbc_file(:Talent))
      @test isa(dbc, DBCData{TalentData})
      @test length(dbc.rows) ≥ 892

      dbc = DBCData(dbc_file(:Map))
      @test isa(dbc, DBCData{MapData})
      @test length(dbc.rows) == 135

      dbc = DBCData(dbc_file(:Spell))
      @test isa(dbc, DBCData{SpellData})
      @test length(dbc.rows) > 49000

      file = DBCFile(dbc_file(:Map))
      @test file.name === :Map
      @test read(file) == DBCData(dbc_file(:Map))
    end

    @testset "Writing DBC files" begin
      dbc = DBCData(dbc_file(:TalentTab))
      file = DBCFile(dbc)
      dbc2 = read(file)
      @test dbc == dbc2

      dbc = DBCData(dbc_file(:Spell))
      file = DBCFile(dbc)
      dbc2 = read(file)
      @test dbc == dbc2
    end
  end

  @testset "MPQ files" begin
    # Missing features:
    # - Sector checksum verification.
    # Missing tests:
    # - Sector-based encryption/decryption.

    @testset "Hash computations" begin
      @test WoW.SEED_BUFFER[1] === 0x55c636e2
      @test WoW.SEED_BUFFER[2] === 0x2be0170
      @test WoW.SEED_BUFFER[1140] === 0xf32f1333
      @test WoW.hash_filename("(hash table)", WoW.MPQ_HASH_FILE_KEY) === 0xc3af3770
      @test WoW.hash_filename("(block table)", WoW.MPQ_HASH_FILE_KEY) === 0xec83b3a3
    end

    @testset "Encryption" begin
      data = rand(UInt32, 1024)
      key = rand(UInt32)
      original = deepcopy(data)
      WoW.encrypt_block!(data, key)
      @test data ≠ original
      WoW.decrypt_block!(data, key)
      @test data == original
    end

    @testset "Reading MPQ files" begin
      header = open(io -> read_binary(io, MPQHeader), mpq_file("patch-3"))
      @test header.sector_size == 4096
      @test header.hash_table_length == 4096
      @test header.block_table_length == 2996
      archive = MPQArchive(mpq_file("patch-3"))
      (; hash_table, block_table) = archive
      nh = length(hash_table.entries)
      @test nh == header.hash_table_length
      @test count(==(MPQHashTableEntry()), hash_table.entries) < 0.3nh
      nb = length(block_table.entries)
      @test nb == header.block_table_length
      for block in block_table.entries
        if in(MPQ_FILE_DELETE_MARKER, block.flags)
          @test block.compressed_file_size == 0
          @test block.uncompressed_file_size == 0
        end
      end
      @test count(x -> x.compressed_file_size ≠ 0, block_table.entries) > 0.9nb
      slot = WoW.hash_table_slot(hash_table, "(listfile)")
      @test Int(slot) === 2138
      hash_entry = hash_table.entries[slot]
      @test Int(hash_entry.block_index) === 2994
      block = archive.block_table.entries[hash_entry.block_index + 1]
      @test Int(block.compressed_file_size) === 22027
      @test Int(block.uncompressed_file_size) === 166702
      @test block.flags === MPQ_FILE_COMPRESS | MPQ_FILE_SECTOR_CRC | MPQ_FILE_EXISTS
      @test block === block_table.entries[2995]
      @test_throws "No file" archive["doesnotexist"]

      file = archive["World/wmo/Northrend/Wintergrasp/WG_Tower02C.wmo"]
      @test file.filename == "World/wmo/Northrend/Wintergrasp/WG_Tower02C.wmo"
      @test file.data === archive[lowercase("World/wmo/Northrend/Wintergrasp/WG_Tower02C.wmo")].data
      @test length(archive.files) == 1

      data = read(archive["(listfile)"])
      @test length(data) === Int(block.uncompressed_file_size)
      files = listfile(archive)
      @test length(files) === 2994
      @test files[begin] == "CHARACTER/BloodElf/Female/BloodElfFemale.M2"
      @test files[end] == "WTF/DefaultBindings.wtf"

      archive = MPQArchive(mpq_file("enUS/patch-enUS"))
      talent_tabs_dbc = read(archive["DBFilesClient/TalentTab.dbc"])
      talent_tabs = DBCData(talent_tabs_dbc, :TalentTab)
      @test length(talent_tabs.rows) ≥ 33

      archive = MPQArchive(mpq_file("enUS/patch-enUS-3"))
      map_dbc = read(archive["DBFilesClient/Map.dbc"])
      map = DBCData(map_dbc, :Map)
      ref = DBCData(dbc_file(:Map))
      @test map == ref
      spell_dbc = read(archive["DBFilesClient/Spell.dbc"])
      spell = DBCData(spell_dbc, :Spell)
      @test length(spell.rows) ≥ 49839
    end

    @testset "Writing MPQ files" begin
      # Archive with no files.
      archive = MPQArchive()
      buffer = IOBuffer()
      nb = write(buffer, archive)
      @test nb > 65536
      seekstart(buffer)
      archive2 = MPQArchive(buffer)
      @test length(archive2.block_table.entries) == 1 # listfile
      seekstart(buffer)
      @test write(buffer, archive2) == nb

      # Archive with two user-created files.
      archive = MPQArchive()
      # This file will be stored as a single uncompressed sector in practice,
      # because compression will not make it smaller than its data.
      file_a = MPQFile(archive, "Test/A", UInt8[0x18, 0x9a, 0xdf, 0xe1, 0xad])
      @test_throws "already exists" MPQFile(archive, "Test/A", file_a.data)
      file_b = MPQFile(archive, "Test/B", ones(UInt8, 5000))
      buffer = IOBuffer()
      nb = write(buffer, archive)
      @test nb > 65536 + 44

      seekstart(buffer)
      archive2 = MPQArchive(buffer)
      @test length(archive2.block_table.entries) == 3
      file_a_2 = archive2["Test/A"]
      file_b_2 = archive2["Test/B"]
      @test file_a_2.block[].uncompressed_file_size == 5
      @test file_b_2.block[].uncompressed_file_size == 5000
      @test file_a_2.filename == "Test/A"
      @test read(file_a_2) == read(file_a)
      @test read(file_b_2) == read(file_b)
      @test write(IOBuffer(), archive2) == nb

      # Same, but with one file uncompressed.
      archive = MPQArchive()
      file_a = MPQFile(archive, "Test/A", ones(UInt8, 256); compression = nothing)
      @test_throws "already exists" MPQFile(archive, "Test/A", rand(UInt8, 256))
      file_b = MPQFile(archive, "Test/B", ones(UInt8, 5000))
      buffer = IOBuffer()
      nb = write(buffer, archive)
      @test nb > 65536 + 44

      seekstart(buffer)
      archive2 = MPQArchive(buffer)
      @test length(archive2.block_table.entries) == 3
      file_a_2 = archive2["Test/A"]
      file_b_2 = archive2["Test/B"]
      @test file_a_2.block[].uncompressed_file_size == 256
      @test file_a_2.block[].compressed_file_size == 256
      @test file_b_2.block[].uncompressed_file_size == 5000
      @test read(file_a_2) == read(file_a)
      @test read(file_b_2) == read(file_b)

      archive = MPQArchive(mpq_file("enUS/patch-enUS"))
      data = read(archive["DBFilesClient/TalentTab.dbc"])
      part = MPQArchive()
      file = MPQFile(part, "DBFilesClient/TalentTab.dbc", data)
      buffer = IOBuffer()
      write(buffer, part)
      seekstart(buffer)
      archive2 = MPQArchive(buffer)
      data2 = read(archive2["DBFilesClient/TalentTab.dbc"])
      @test data2 == data
    end

    @testset "MPQ collections" begin
      collection = MPQCollection([mpq_file("enUS/patch-enUS-3"), mpq_file("enUS/locale-enUS")])
      file = collection["dbfilesclient/achievement.dbc"]
      filenames = listfile(collection)
      @test file.filename == "DBFilesClient/Achievement.dbc"
      @test in(file.filename, filenames)
      @test file === collection.archives[1][file.filename]
      @test file.data === collection[lowercase("DBFilesClient/Achievement.dbc")].data
      file = collection["Fonts/FRIENDS.TTF"]
      @test in(file.filename, filenames)
      @test file === collection.archives[1][file.filename]
      file = collection["Fonts/MORPHEUS.TTF"]
      @test in(file.filename, filenames)
      @test file === collection.archives[2][file.filename]

      mpq_files = WoW.ClientMPQFiles(DATA_DIRECTORY)
      sorted = WoW.files_sorted_by_priority(mpq_files)
      priority(file) = length(sorted) - findfirst(==(file), sorted)
      @test priority("enUS/patch-enUS-3.MPQ") > priority("enUS/patch-enUS-2.MPQ")
      @test priority("enUS/patch-enUS-3.MPQ") > priority("patch-3.MPQ")
      @test priority("patch-3.MPQ") > priority("patch-2.MPQ")
      @test priority("patch-2.MPQ") > priority("patch.MPQ")
      @test priority("lichking.MPQ") > priority("expansion.MPQ")
      @test priority("common-2.MPQ") > priority("common.MPQ")
      collection = MPQCollection(DATA_DIRECTORY; filter = !endswith("patch-enUS-E.MPQ"))
      @test length(collection.archives) > 10
      @test length(collection.file_sources) > 200000
    end
  end

  @testset "BLP files" begin
    # The following example files were identified on https://wowwiki-archive.fandom.com/wiki/BLP_file
    # for their specific features suitable for testing.

    collection = MPQCollection([mpq_file("enUS/locale-enUS"), mpq_file("common"), mpq_file("lichking")])

    @testset "Reading BLP files" begin

      @testset "BLP compression" begin
        # No alpha.
        icon = collection["Interface/GLUES/LoadingBar/Loading-BarGlow.blp"]
        file = BLPFile(read(icon))
        nx, ny = size(file.image)
        @test nx == 512 && ny == 128
        @test length(file.mipmaps) == log2(ny)
        @test size(file.mipmaps[end]) == (4, 1)
        @test file.image[400, 64] === RGBA{N0f8}(0.0, 0.102, 0.275, 0.518)

        # 1-bit alpha.
        icon = collection["Interface/CURSOR/Attack.blp"]
        file = BLPFile(read(icon))
        nx, ny = size(file.image)
        @test nx == 32 && ny == 32
        @test length(file.mipmaps) == log2(nx)
        @test size(file.mipmaps[end]) == (1, 1)
        @test file.image[14, 16] === RGBA{N0f8}(0.0, 0.565, 0.725, 0.776)

        # 4-bit alpha.
        icon = collection["Character/Tauren/Female/TAURENFEMALESKIN00_01_EXTRA.BLP"]
        file = BLPFile(read(icon))
        @test file.image[14, 16] === RGBA{N0f8}(0.0, 0.141, 0.125, 0.988)

        # 8-bit alpha.
        icon = collection["Interface/CURSOR/Buy.blp"]
        file = BLPFile(read(icon))
        @test file.image[14, 16] === RGBA{N0f8}(0.0, 0.482, 0.369, 0.973)
      end

      @testset "DTX1 compression" begin
        @testset "RGB16" begin
          rgb = RGB16(N0f8(0.5), N0f8(0.2), N0f8(0.3))
          @test rgb.r === N0f8(0.502)
          @test rgb.g === N0f8(0.188)
          @test rgb.b === N0f8(0.282)
        end

        # No alpha.
        icon = collection["Interface/Icons/Trade_Alchemy.blp"]
        file = BLPFile(read(icon))
        @test file.image[3912] === RGBA{N0f8}(0.188, 0.204, 0.2, 1.0)
        @test file.image[89] === RGBA{N0f8}(0.753, 0.753, 0.753, 1.0)
        @test file.image[465] === RGBA{N0f8}(0.608, 0.545, 0.314, 1.0)

        # 1-bit alpha.
        icon = collection["Interface/AUCTIONFRAME/BuyoutIcon.blp"]
        file = BLPFile(read(icon))
        @test file.image[2] === RGBA{N0f8}(0.847, 0.706, 0.0, 1.0)

        # Has a with of 768 pixels.
        icon = collection["TILESET/Terrain Cube Maps/TCB_CrystalSong_A.blp"]
        file = BLPFile(read(icon))
        @test file.image[20, 76] === RGBA{N0f8}(0.302, 0.278, 0.376, 1.0)
      end

      @testset "DTX3 compression" begin
        # 4-bit alpha.
        icon = collection["Interface/Icons/INV_Fishingpole_02.blp"]
        file = BLPFile(read(icon))
        @test file.image[15, 20] === RGBA{N0f8}(0.357, 0.263, 0.188, 1.0)
      end

      @testset "DTX5 compression" begin
        # No alpha.
        icon = collection["Environments/Stars/HellFireSkyNebula03.blp"]
        file = BLPFile(read(icon))
        @test file.image[250, 100] === RGBA{N0f8}(0.2, 0.216, 0.094, 1.0)

        # 8-bit alpha.
        icon = collection["Interface/Icons/Ability_Rogue_Shadowstep.blp"]
        file = BLPFile(read(icon))
        @test file.image[42, 18] === RGBA{N0f8}(0.427, 0.161, 0.847, 1.0)

        image = collection["Interface/AchievementFrame/UI-Achievement-MetalBorder-Left.blp"]
        file = BLPFile(read(image))
        @test length(file.mipmaps) == 4
        @test file.image[4, 24] === RGBA{N0f8}(0.753, 0.753, 0.69, 1.0)
      end

      @testset "No compression" begin
        # TODO (requires data from Cataclysm or later)
      end
    end

    @testset "Writing BLP files" begin
      icon = collection["Environments/Stars/HellFireSkyNebula03.blp"]
      file = BLPFile(read(icon))
      data = BLPData(file.image)
      io = IOBuffer()
      write(io, data)
      serialized = take!(seekstart(io))
      file2 = BLPFile(serialized)
      @test error_quantile(file.image, file2.image, 0.77) == 0.0

      icon = collection["Interface/Icons/Ability_Rogue_Shadowstep.blp"]
      file = BLPFile(read(icon))
      data = BLPData(file.image)
      io = IOBuffer()
      write(io, data)
      serialized = take!(seekstart(io))
      file2 = BLPFile(serialized)
      @test error_quantile(file.image, file2.image, 0.96) == 0.0
    end
  end

  @testset "WMO files" begin
    collection = MPQCollection([mpq_file("enUS/locale-enUS"), mpq_file("common"), mpq_file("lichking")])

    @testset "Reading WMO files" begin
      root = read(collection["World/wmo/Azeroth/Buildings/Westfall_Stable/Westfall_StableC.wmo"])
      wmo = WMOFile(root)
      mohd = read(wmo, tag"MOHD")
      @test mohd.materials === 8
      @test mohd.groups === 1
      @test mohd.portals === 0
      @test mohd.ambient_color === RGBA{N0f8}(0.043, 0.043, 0.043, 1.0)
      @test mohd.bounding_box === WoWDataParser.BoundingBox((-12.8009205f0, -10.880446f0, -1.0901798f0), (3.8274624f0, 10.880448f0, 10.920715f0))
      motx = read(wmo, tag"MOTX")
      @test length(motx) === mohd.materials === 8
      texture = WoWDataParser.read_texture(wmo, 0)
      @test texture == motx[1]
      texture = WoWDataParser.read_texture(wmo, 106)
      @test texture == motx[3]
      mogi = read(wmo, tag"MOGI")
      @test length(mogi) === 1
      group = mogi[1]
      @test group.bounding_box === mohd.bounding_box
      mogn = read(wmo, tag"MOGN")
      @test mogn == ["stable01"]
      mosb = read(wmo, tag"MOSB")
      @test mosb === nothing
      mods = read(wmo, tag"MODS")
      @test length(mods) == 1
      doodad_set = mods[1]
      @test doodad_set.name === Tag{20}("Set_\$DefaultGlobal")
      @test doodad_set.start === 0
      @test doodad_set.count === 0
      mfog = read(wmo, tag"MFOG")
      @test length(mfog) == 1
      fog = mfog[1]
      @test fog.location === (0f0, 0f0, 0f0)
      @test fog.normal.clear_value === RGBA{N0f8}(1.0, 1.0, 1.0, 1.0)
      @test fog.underwater.clear_value === RGBA{N0f8}(1.0, 0.0, 0.0, 1.0)

      group = collection["World/wmo/Azeroth/Buildings/Westfall_Stable/Westfall_StableC_000.wmo"]
    end
  end
end;
