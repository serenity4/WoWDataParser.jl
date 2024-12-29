# This file was automatically generated with `generator/generate_schemas.jl`.

abstract type DBCDataType end

struct AchievementData <: DBCDataType
    id::UInt32
    required_faction::Int32
    map_id::Int32
    parent_achievement::UInt32
    name::LString
    description::LString
    category_id::UInt32
    points::UInt32
    order_in_category::UInt32
    flags::UInt32
    icon::UInt32
    title_reward::LString
    count::UInt32
    ref_achievement::UInt32
end

struct AchievementCategoryData <: DBCDataType
    id::UInt32
    parent_category::Int32
    name::LString
    sort_order::UInt32
end

struct AchievementCriteriaData <: DBCDataType
    id::UInt32
    referred_achievement::UInt32
    required_type::UInt32
    asset_type::UInt32
    asset_count::UInt32
    start_event::UInt32
    start_asset::UInt32
    fail_event::UInt32
    fail_asset::UInt32
    name::LString
    flags::UInt32
    timed_type::UInt32
    timer_start_event::UInt32
    time_limit::UInt32
    show_order::UInt32
end

struct AnimationDataData <: DBCDataType
    id::UInt32
    name::String
    weapon_flags::UInt32
    body_flags::UInt32
    flags::UInt32
    fallback_animation_id::UInt32
    behaviour_id::UInt32
    behaviour_tier::UInt32
end

struct AreaGroupData <: DBCDataType
    id::UInt32
    area_id_1::UInt32
    area_id_2::UInt32
    area_id_3::UInt32
    area_id_4::UInt32
    area_id_5::UInt32
    area_id_6::UInt32
    next_group::UInt32
end

struct AreaTableData <: DBCDataType
    id::UInt32
    map::UInt32
    zone::UInt32
    explore_flag::UInt32
    flags::UInt32
    sound_preferences::UInt32
    sound_preferences_underwater::UInt32
    sound_ambience::UInt32
    zone_music::UInt32
    zone_intro_music::UInt32
    arealevel::UInt32
    name::LString
    faction_group::UInt32
    liquid_type_1::UInt32
    liquid_type_2::UInt32
    liquid_type_3::UInt32
    liquid_type_4::UInt32
    min_elevation::Float32
    ambient_multiplier::Float32
    light::UInt32
end

struct AreaTriggerData <: DBCDataType
    id::UInt32
    continent_id::UInt32
    x::Float32
    y::Float32
    z::Float32
    radius::Float32
    box_length::Float32
    box_width::Float32
    box_height::Float32
    box_yaw::Float32
end

struct CharStartOutfitData <: DBCDataType
    id::UInt32
    race::UInt8
    class::UInt8
    gender::UInt8
    outfit_id::UInt8
    item_id_1::Int32
    item_id_2::Int32
    item_id_3::Int32
    item_id_4::Int32
    item_id_5::Int32
    item_id_6::Int32
    item_id_7::Int32
    item_id_8::Int32
    item_id_9::Int32
    item_id_10::Int32
    item_id_11::Int32
    item_id_12::Int32
    item_id_13::Int32
    item_id_14::Int32
    item_id_15::Int32
    item_id_16::Int32
    item_id_17::Int32
    item_id_18::Int32
    item_id_19::Int32
    item_id_20::Int32
    item_id_21::Int32
    item_id_22::Int32
    item_id_23::Int32
    item_id_24::Int32
    display_info_1::Int32
    display_info_2::Int32
    display_info_3::Int32
    display_info_4::Int32
    display_info_5::Int32
    display_info_6::Int32
    display_info_7::Int32
    display_info_8::Int32
    display_info_9::Int32
    display_info_10::Int32
    display_info_11::Int32
    display_info_12::Int32
    display_info_13::Int32
    display_info_14::Int32
    display_info_15::Int32
    display_info_16::Int32
    display_info_17::Int32
    display_info_18::Int32
    display_info_19::Int32
    display_info_20::Int32
    display_info_21::Int32
    display_info_22::Int32
    display_info_23::Int32
    display_info_24::Int32
    inventory_type_1::Int32
    inventory_type_2::Int32
    inventory_type_3::Int32
    inventory_type_4::Int32
    inventory_type_5::Int32
    inventory_type_6::Int32
    inventory_type_7::Int32
    inventory_type_8::Int32
    inventory_type_9::Int32
    inventory_type_10::Int32
    inventory_type_11::Int32
    inventory_type_12::Int32
    inventory_type_13::Int32
    inventory_type_14::Int32
    inventory_type_15::Int32
    inventory_type_16::Int32
    inventory_type_17::Int32
    inventory_type_18::Int32
    inventory_type_19::Int32
    inventory_type_20::Int32
    inventory_type_21::Int32
    inventory_type_22::Int32
    inventory_type_23::Int32
    inventory_type_24::Int32
end

struct CharTitlesData <: DBCDataType
    id::UInt32
    unk_1::Int32
    male_title::LString
    female_title::LString
    title_mask_id::Int32
end

struct ChatChannelsData <: DBCDataType
    id::UInt32
    flags::UInt32
    faction_group::UInt32
    name::LString
    short_name::LString
end

struct ChrClassesData <: DBCDataType
    id::UInt32
    field_01::UInt32
    display_power::UInt32
    pet_name_token::UInt32
    name::LString
    name_female::LString
    name_male::LString
    file_name::String
    spell_class_set::UInt32
    flags::UInt32
    cinematic_sequence_id::UInt32
    required_expansion::UInt32
end

struct ChrRacesData <: DBCDataType
    id::UInt32
    flags::UInt32
    faction_id::UInt32
    exploreation_sound_id::UInt32
    male_display_id::UInt32
    female_display_id::UInt32
    client_prefix::String
    base_language::UInt32
    creature_type::UInt32
    res_sickness_spell_id::UInt32
    spalsh_sound_id::UInt32
    client_file_string::String
    cinematic_sequence_id::UInt32
    alliance::UInt32
    name::LString
    name_female::LString
    name_male::LString
    facial_hair_custom_1::String
    facial_hair_custom_2::String
    hair_customisation::String
    required_expansion::UInt32
end

struct CinematicCameraData <: DBCDataType
    id::UInt32
    file_path::String
    voiceover::UInt32
    x::Float32
    y::Float32
    z::Float32
    o::Float32
end

struct CinematicSequencesData <: DBCDataType
    id::UInt32
    sound_id::UInt32
    camera_1::UInt32
    camera_2::UInt32
    camera_3::UInt32
    camera_4::UInt32
    camera_5::UInt32
    camera_6::UInt32
    camera_7::UInt32
    camera_8::UInt32
end

struct CreatureDisplayInfoData <: DBCDataType
    id::UInt32
    model_id::UInt32
    sound_id::UInt32
    extended_display_info_id::UInt32
    creature_model_scale::Float32
    creature_model_alpha::UInt32
    texture_variation_1::String
    texture_variation_2::String
    texture_variation_3::String
    portrait_texture_name::String
    blood_level::Int32
    blood_id::UInt32
    npc_sound_id::UInt32
    particle_color_id::UInt32
    creature_geoset_data::UInt32
    object_effect_package_id::UInt32
end

struct CreatureDisplayInfoExtraData <: DBCDataType
    id::UInt32
    display_race_id::UInt32
    display_sex_id::UInt32
    skin_id::UInt32
    face_id::UInt32
    hair_style_id::UInt32
    hair_color_id::UInt32
    facial_hair_id::UInt32
    head_display_id::UInt32
    shoulders_display_id::UInt32
    shirt_display_id::UInt32
    chest_display_id::UInt32
    belt_display_id::UInt32
    legs_display_id::UInt32
    boots_display_id::UInt32
    bracers_display_id::UInt32
    gloves_display_id::UInt32
    tabard_display_id::UInt32
    cape_display_id::UInt32
    flags::UInt32
    baked_texture_i_dblp::String
end

struct CreatureModelDataData <: DBCDataType
    id::UInt32
    flags::UInt32
    model_path::String
    size_class::UInt32
    model_scale::Float32
    blood_id::UInt32
    footprint_texture_id::UInt32
    footprint_texture_length::Float32
    footprint_texture_width::Float32
    footprint_particle_scale::Float32
    foley_material_id::UInt32
    footstep_shake_size::UInt32
    death_thud_shake_size::UInt32
    sound_data::UInt32
    collision_width::Float32
    collision_height::Float32
    mount_height::Float32
    geo_box_min_x::Float32
    geo_box_min_y::Float32
    geo_box_min_z::Float32
    geo_box_max_x::Float32
    geo_box_max_y::Float32
    geo_box_max_z::Float32
    world_effect_scale::Float32
    attached_effect_scale::Float32
    missile_collision_radius::Float32
    missile_collision_push::Float32
    missile_collision_raise::Float32
end

struct CreatureSoundDataData <: DBCDataType
    id::UInt32
    sound_exertion_id::UInt32
    sound_exertion_critical_id::UInt32
    sound_injury_id::UInt32
    sound_injury_critical_id::UInt32
    sound_injury_crushing_blow_id::UInt32
    sound_death_id::UInt32
    sound_stun_id::UInt32
    sound_stand_id::UInt32
    sound_footstep_id::UInt32
    sound_aggro_id::UInt32
    sound_wing_flap_id::UInt32
    sound_wing_glide_id::UInt32
    sound_alert_id::UInt32
    sound_fidget_1::UInt32
    sound_fidget_2::UInt32
    sound_fidget_3::UInt32
    sound_fidget_4::UInt32
    sound_fidget_5::UInt32
    custom_attack_1::UInt32
    custom_attack_2::UInt32
    custom_attack_3::UInt32
    custom_attack_4::UInt32
    npc_sound_id::UInt32
    loop_sound_id::UInt32
    creature_impact_type::UInt32
    sound_jump_start_id::UInt32
    sound_jump_end_id::UInt32
    sound_pet_attack_id::UInt32
    sound_pet_order_id::UInt32
    sound_pet_dismiss_id::UInt32
    fidget_delay_seconds_min::UInt32
    fidget_delay_seconds_max::UInt32
    birth_sound_id::UInt32
    spell_cast_directed_sound_id::UInt32
    submerge_sound_id::UInt32
    submerged_sound_id::UInt32
    creature_sound_data_id_pet::UInt32
end

struct CurrencyCategoryData <: DBCDataType
    id::UInt32
    flags::UInt32
    name::LString
end

struct CurrencyTypesData <: DBCDataType
    id::UInt32
    item::UInt32
    category::UInt32
    bit_index::UInt32
end

struct DungeonEncounterData <: DBCDataType
    id::UInt32
    map_id::UInt32
    difficulty::UInt32
    order_index::Int32
    bit::UInt32
    name::LString
    icon_id::UInt32
end

struct FactionData <: DBCDataType
    id::UInt32
    reputation_index::Int32
    reputation_race_mask_1::Int32
    reputation_race_mask_2::Int32
    reputation_race_mask_3::Int32
    reputation_race_mask_4::Int32
    reputation_class_mask_1::Int32
    reputation_class_mask_2::Int32
    reputation_class_mask_3::Int32
    reputation_class_mask_4::Int32
    reputation_base_1::Int32
    reputation_base_2::Int32
    reputation_base_3::Int32
    reputation_base_4::Int32
    reputation_flags_1::Int32
    reputation_flags_2::Int32
    reputation_flags_3::Int32
    reputation_flags_4::Int32
    parent_faction_id::UInt32
    parent_faction_mod_1::Float32
    parent_faction_mod_2::Float32
    parent_faction_cap_1::Int32
    parent_faction_cap_2::Int32
    name::LString
    description::LString
end

struct FactionGroupData <: DBCDataType
    id::UInt32
    mask_id::Int32
    internal_name::String
    name::LString
end

struct FactionTemplateData <: DBCDataType
    id::UInt32
    faction::Int32
    flags::Int32
    faction_group::Int32
    friend_group::Int32
    enemy_group::Int32
    enemies_1::Int32
    enemies_2::Int32
    enemies_3::Int32
    enemies_4::Int32
    friends_1::Int32
    friends_2::Int32
    friends_3::Int32
    friends_4::Int32
end

struct FileDataData <: DBCDataType
    id::UInt32
    file_name::String
    file_path::String
end

struct GameObjectDisplayInfoData <: DBCDataType
    id::UInt32
    model_name::String
    sound_1::UInt32
    sound_2::UInt32
    sound_3::UInt32
    sound_4::UInt32
    sound_5::UInt32
    sound_6::UInt32
    sound_7::UInt32
    sound_8::UInt32
    sound_9::UInt32
    sound_10::UInt32
    geo_box_min_x::Float32
    geo_box_min_y::Float32
    geo_box_min_z::Float32
    geo_box_max_x::Float32
    geo_box_max_y::Float32
    geo_box_max_z::Float32
    object_effect_package_id::UInt32
end

struct GameTipsData <: DBCDataType
    id::UInt32
    name::LString
end

struct GemPropertiesData <: DBCDataType
    id::UInt32
    spell_item_enchantment_ref::UInt32
    max_countinv::UInt32
    max_countitem::UInt32
    gem_type::UInt32
end

struct HolidayDescriptionsData <: DBCDataType
    id::UInt32
    description::LString
end

struct HolidayNamesData <: DBCDataType
    id::UInt32
    name::LString
end

struct HolidaysData <: DBCDataType
    id::UInt32
    duration_1::Int32
    duration_2::Int32
    duration_3::Int32
    duration_4::Int32
    duration_5::Int32
    duration_6::Int32
    duration_7::Int32
    duration_8::Int32
    duration_9::Int32
    duration_10::Int32
    event_date_1::Int32
    event_date_2::Int32
    event_date_3::Int32
    event_date_4::Int32
    event_date_5::Int32
    event_date_6::Int32
    event_date_7::Int32
    event_date_8::Int32
    event_date_9::Int32
    event_date_10::Int32
    event_date_11::Int32
    event_date_12::Int32
    event_date_13::Int32
    event_date_14::Int32
    event_date_15::Int32
    event_date_16::Int32
    event_date_17::Int32
    event_date_18::Int32
    event_date_19::Int32
    event_date_20::Int32
    event_date_21::Int32
    event_date_22::Int32
    event_date_23::Int32
    event_date_24::Int32
    event_date_25::Int32
    event_date_26::Int32
    region::Int32
    looping::Int32
    calendar_flags_1::Int32
    calendar_flags_2::Int32
    calendar_flags_3::Int32
    calendar_flags_4::Int32
    calendar_flags_5::Int32
    calendar_flags_6::Int32
    calendar_flags_7::Int32
    calendar_flags_8::Int32
    calendar_flags_9::Int32
    calendar_flags_10::Int32
    event_calendar_name::UInt32
    event_calendar_description::UInt32
    event_calendar_overlay::String
    priority::Int32
    event_scheduler_type::Int32
    event_flags::Int32
end

struct ItemData <: DBCDataType
    item_id::UInt32
    item_class::UInt32
    item_sub_class::UInt32
    soundoverridesubclassid::Int32
    material_id::Int32
    item_display_info::UInt32
    inventory_slot_id::UInt32
    sheath_id::UInt32
end

struct ItemClassData <: DBCDataType
    id::UInt32
    secondary_id::UInt32
    is_weapon::UInt32
    name::LString
end

struct ItemDisplayInfoData <: DBCDataType
    id::UInt32
    left_model::String
    right_model::String
    left_model_texture::String
    right_model_texture::String
    inventory_icon_1::String
    inventory_icon_2::String
    geoset_group_1::UInt32
    geoset_group_2::UInt32
    geoset_group_3::UInt32
    flags::UInt32
    spell_visual_id::UInt32
    group_sound_index::UInt32
    helmet_geoset_visual_1::UInt32
    helmet_geoset_visual_2::UInt32
    upper_arm_texture::String
    lower_arm_texture::String
    hands_texture::String
    upper_torso_texture::String
    lower_torso_texture::String
    upper_leg_texture::String
    lower_leg_texture::String
    foot_texture::String
    item_visual::UInt32
    particle_color_id::UInt32
end

struct ItemExtendedCostData <: DBCDataType
    id::UInt32
    cost_honour::UInt32
    cost_arena::UInt32
    unknown_1::UInt32
    required_item_1::UInt32
    required_item_2::UInt32
    required_item_3::UInt32
    required_item_4::UInt32
    required_item_5::UInt32
    required_item_count_1::UInt32
    required_item_count_2::UInt32
    required_item_count_3::UInt32
    required_item_count_4::UInt32
    required_item_count_5::UInt32
    personal_rating::UInt32
    purchase_group::UInt32
end

struct ItemRandomPropertiesData <: DBCDataType
    id::Int32
    name::String
    enchantment_1::Int32
    enchantment_2::Int32
    enchantment_3::Int32
    enchantment_4::Int32
    enchantment_5::Int32
    localized_name::LString
end

struct ItemRandomSuffixData <: DBCDataType
    id::Int32
    name::LString
    internal_name::String
    enchantment_1::Int32
    enchantment_2::Int32
    enchantment_3::Int32
    enchantment_4::Int32
    enchantment_5::Int32
    allocation_pct_1::Int32
    allocation_pct_2::Int32
    allocation_pct_3::Int32
    allocation_pct_4::Int32
    allocation_pct_5::Int32
end

struct ItemSetData <: DBCDataType
    id::UInt32
    name::LString
    item_id_1::UInt32
    item_id_2::UInt32
    item_id_3::UInt32
    item_id_4::UInt32
    item_id_5::UInt32
    item_id_6::UInt32
    item_id_7::UInt32
    item_id_8::UInt32
    item_id_9::UInt32
    item_id_10::UInt32
    item_id_11::UInt32
    item_id_12::UInt32
    item_id_13::UInt32
    item_id_14::UInt32
    item_id_15::UInt32
    item_id_16::UInt32
    item_id_17::UInt32
    set_bonus_1::UInt32
    set_bonus_2::UInt32
    set_bonus_3::UInt32
    set_bonus_4::UInt32
    set_bonus_5::UInt32
    set_bonus_6::UInt32
    set_bonus_7::UInt32
    set_bonus_8::UInt32
    set_bonus_threshold_1::UInt32
    set_bonus_threshold_2::UInt32
    set_bonus_threshold_3::UInt32
    set_bonus_threshold_4::UInt32
    set_bonus_threshold_5::UInt32
    set_bonus_threshold_6::UInt32
    set_bonus_threshold_7::UInt32
    set_bonus_threshold_8::UInt32
    required_skill::UInt32
    required_skill_rank::UInt32
end

struct ItemSubClassData <: DBCDataType
    class::UInt32
    sub_class::UInt32
    prerequisite_proficiency::UInt32
    postrequisite_proficiency::UInt32
    flags::UInt32
    display_flags::UInt32
    weapon_parry_seq::UInt32
    weapon_ready_seq::UInt32
    weapon_attack_seq::UInt32
    weapon_swing_size::UInt32
    display_name::LString
    verbose_name::LString
end

struct LFGDungeonGroupData <: DBCDataType
    id::UInt32
    name::LString
    order::UInt32
    parent::UInt32
    type::UInt32
end

struct LFGDungeonsData <: DBCDataType
    id::UInt32
    name::LString
    min_level::UInt32
    max_level::UInt32
    target_level::UInt32
    target_level_min::UInt32
    target_level_max::UInt32
    map_id::UInt32
    difficulty::UInt32
    flags::UInt32
    type_id::UInt32
    faction::Int32
    texture::String
    expansion::UInt32
    order_id::UInt32
    group_id::UInt32
    tooltip::LString
end

struct LightData <: DBCDataType
    id::UInt32
    map_id::Int32
    pos_x::Float32
    pos_y::Float32
    pos_z::Float32
    falloff_start::Float32
    falloff_end::Float32
    params_clear::Int32
    params_clear_underwater::Int32
    params_storm::Int32
    params_storm_underwater::Int32
    params_death::Int32
    params_unk_1::Int32
    params_unk_2::Int32
    params_unk_3::Int32
end

struct LightFloatBandData <: DBCDataType
    id::UInt32
    num_entries::Int32
    time_value_1::UInt32
    time_value_2::UInt32
    time_value_3::UInt32
    time_value_4::UInt32
    time_value_5::UInt32
    time_value_6::UInt32
    time_value_7::UInt32
    time_value_8::UInt32
    time_value_9::UInt32
    time_value_10::UInt32
    time_value_11::UInt32
    time_value_12::UInt32
    time_value_13::UInt32
    time_value_14::UInt32
    time_value_15::UInt32
    time_value_16::UInt32
    float_value_1::Float32
    float_value_2::Float32
    float_value_3::Float32
    float_value_4::Float32
    float_value_5::Float32
    float_value_6::Float32
    float_value_7::Float32
    float_value_8::Float32
    float_value_9::Float32
    float_value_10::Float32
    float_value_11::Float32
    float_value_12::Float32
    float_value_13::Float32
    float_value_14::Float32
    float_value_15::Float32
    float_value_16::Float32
end

struct LightIntBandData <: DBCDataType
    id::UInt32
    num_entries::Int32
    time_value_1::UInt32
    time_value_2::UInt32
    time_value_3::UInt32
    time_value_4::UInt32
    time_value_5::UInt32
    time_value_6::UInt32
    time_value_7::UInt32
    time_value_8::UInt32
    time_value_9::UInt32
    time_value_10::UInt32
    time_value_11::UInt32
    time_value_12::UInt32
    time_value_13::UInt32
    time_value_14::UInt32
    time_value_15::UInt32
    time_value_16::UInt32
    colour_value_1::UInt32
    colour_value_2::UInt32
    colour_value_3::UInt32
    colour_value_4::UInt32
    colour_value_5::UInt32
    colour_value_6::UInt32
    colour_value_7::UInt32
    colour_value_8::UInt32
    colour_value_9::UInt32
    colour_value_10::UInt32
    colour_value_11::UInt32
    colour_value_12::UInt32
    colour_value_13::UInt32
    colour_value_14::UInt32
    colour_value_15::UInt32
    colour_value_16::UInt32
end

struct LightParamsData <: DBCDataType
    id::UInt32
    higlight_sky::UInt32
    skybox_id::UInt32
    cloud_type::Int32
    glow::Float32
    water_shallow_alpha::Float32
    water_deep_alpha::Float32
    ocean_shallow_alpha::Float32
    ocean_deep_alpha::Float32
end

struct LightSkyboxData <: DBCDataType
    id::UInt32
    name::String
    flags::UInt32
end

struct LoadingScreensData <: DBCDataType
    id::UInt32
    name::String
    file_name::String
    has_wide_screen::UInt32
end

struct LockData <: DBCDataType
    id::UInt32
    type_1::UInt32
    type_2::UInt32
    type_3::UInt32
    type_4::UInt32
    type_5::UInt32
    type_6::UInt32
    type_7::UInt32
    type_8::UInt32
    index_1::UInt32
    index_2::UInt32
    index_3::UInt32
    index_4::UInt32
    index_5::UInt32
    index_6::UInt32
    index_7::UInt32
    index_8::UInt32
    skill_1::UInt32
    skill_2::UInt32
    skill_3::UInt32
    skill_4::UInt32
    skill_5::UInt32
    skill_6::UInt32
    skill_7::UInt32
    skill_8::UInt32
    action_1::UInt32
    action_2::UInt32
    action_3::UInt32
    action_4::UInt32
    action_5::UInt32
    action_6::UInt32
    action_7::UInt32
    action_8::UInt32
end

struct LockTypeData <: DBCDataType
    id::UInt32
    name::LString
    resource_name::LString
    verb::LString
    cursor_name::String
end

struct MapData <: DBCDataType
    id::UInt32
    directory_name::String
    instance_type::UInt32
    flags::UInt32
    pvp::UInt32
    map_name_lang::LString
    area_table_id::UInt32
    map_description_0_lang::LString
    map_description_1_lang::LString
    loading_screen_id::UInt32
    minimap_icon_scale::Float32
    corpse_map_id::Int32
    corpse_x::Float32
    corpse_y::Float32
    time_of_day_override::Int32
    expansion_id::UInt32
    raid_offset::UInt32
    max_players::UInt32
end

struct MapDifficultyData <: DBCDataType
    id::UInt32
    map::UInt32
    difficulty::Int32
    message::LString
    raid_duration_seconds::UInt32
    max_players::UInt32
    difficulty_string::String
end

struct MovieData <: DBCDataType
    id::UInt32
    movie_path::String
    volume::Int32
end

struct MovieFileDataData <: DBCDataType
    id::UInt32
    resolution::UInt32
end

struct MovieVariationData <: DBCDataType
    id::UInt32
    movie_id::UInt32
    file_data_id::UInt32
end

struct OverrideSpellDataData <: DBCDataType
    id::UInt32
    spellid_1::UInt32
    spellid_2::UInt32
    spellid_3::UInt32
    spellid_4::UInt32
    spellid_5::UInt32
    spellid_6::UInt32
    spellid_7::UInt32
    spellid_8::UInt32
    spellid_9::UInt32
    spellid_10::UInt32
    flags::UInt32
end

struct QuestSortData <: DBCDataType
    id::UInt32
    name::LString
end

struct QuestXPData <: DBCDataType
    id::Int32
    difficulty_1::Int32
    difficulty_2::Int32
    difficulty_3::Int32
    difficulty_4::Int32
    difficulty_5::Int32
    difficulty_6::Int32
    difficulty_7::Int32
    difficulty_8::Int32
    difficulty_9::Int32
    difficulty_10::Int32
end

struct ScreenEffectData <: DBCDataType
    id::UInt32
    name::String
    type::UInt32
    colour::UInt32
    screen_edge_size::UInt32
    black_white_value::UInt32
    unknown::UInt32
    light_id::Int32
    sound_ambience_id::UInt32
    sound_music_id::UInt32
end

struct SkillLineData <: DBCDataType
    id::UInt32
    category::UInt32
    cost_id::UInt32
    name::LString
    description::LString
    spell_icon::UInt32
    tooltip::LString
    can_link::UInt32
end

struct SkillLineAbilityData <: DBCDataType
    id::UInt32
    skill_id::UInt32
    spell_id::UInt32
    chr_races::UInt32
    chr_classes::UInt32
    unk_1::UInt32
    unk_2::UInt32
    required_skill_value::UInt32
    spell_id_parent::UInt32
    acquire_method::UInt32
    skill_grey_level::UInt32
    skill_green_level::UInt32
    character_points_1::UInt32
    character_points_2::UInt32
end

struct SkillRaceClassInfoData <: DBCDataType
    id::UInt32
    skill_line_dbc_record::UInt32
    race_mask::UInt32
    class_mask::UInt32
    flags::UInt32
    min_level::UInt32
    skill_tier_id::UInt32
    skill_cost_index::UInt32
end

struct SoundEntriesData <: DBCDataType
    id::UInt32
    sound_type::UInt32
    sound_name::String
    name_1::String
    name_2::String
    name_3::String
    name_4::String
    name_5::String
    name_6::String
    name_7::String
    name_8::String
    name_9::String
    name_10::String
    freq_1::UInt32
    freq_2::UInt32
    freq_3::UInt32
    freq_4::UInt32
    freq_5::UInt32
    freq_6::UInt32
    freq_7::UInt32
    freq_8::UInt32
    freq_9::UInt32
    freq_10::UInt32
    file_path::String
    volume::Float32
    flags::UInt32
    min_distance::Float32
    max_distance::Float32
    eax_def::UInt32
    sound_entries_advanced_id::UInt32
end

struct SpellData <: DBCDataType
    id::UInt32
    category::UInt32
    dispel::UInt32
    mechanic::UInt32
    attributes::UInt32
    attributes_ex::UInt32
    attributes_ex_2::UInt32
    attributes_ex_3::UInt32
    attributes_ex_4::UInt32
    attributes_ex_5::UInt32
    attributes_ex_6::UInt32
    attributes_ex_7::UInt32
    stances::UInt32
    unknown_1::UInt32
    stances_not::UInt32
    unknown_2::UInt32
    targets::UInt32
    target_creature_type::UInt32
    requires_spell_focus::UInt32
    facing_caster_flags::UInt32
    caster_aura_state::UInt32
    target_aura_state::UInt32
    caster_aura_state_not::UInt32
    target_aura_state_not::UInt32
    caster_aura_spell::UInt32
    target_aura_spell::UInt32
    exclude_caster_aura_spell::UInt32
    exclude_target_aura_spell::UInt32
    casting_time_index::UInt32
    recovery_time::UInt32
    category_recovery_time::UInt32
    interrupt_flags::UInt32
    aura_interrupt_flags::UInt32
    channel_interrupt_flags::UInt32
    proc_flags::UInt32
    proc_chance::UInt32
    proc_charges::UInt32
    maximum_level::UInt32
    base_level::UInt32
    level::UInt32
    duration_index::UInt32
    power_type::UInt32
    mana_cost::UInt32
    mana_cost_per_level::UInt32
    mana_per_second::UInt32
    mana_per_second_per_level::UInt32
    range_index::UInt32
    speed::Float32
    modal_next_spell::UInt32
    stack_amount::UInt32
    totem_1::UInt32
    totem_2::UInt32
    reagent_1::Int32
    reagent_2::Int32
    reagent_3::Int32
    reagent_4::Int32
    reagent_5::Int32
    reagent_6::Int32
    reagent_7::Int32
    reagent_8::Int32
    reagent_count_1::UInt32
    reagent_count_2::UInt32
    reagent_count_3::UInt32
    reagent_count_4::UInt32
    reagent_count_5::UInt32
    reagent_count_6::UInt32
    reagent_count_7::UInt32
    reagent_count_8::UInt32
    equipped_item_class::Int32
    equipped_item_sub_class_mask::Int32
    equipped_item_inventory_type_mask::Int32
    effect_1::UInt32
    effect_2::UInt32
    effect_3::UInt32
    effect_die_sides_1::Int32
    effect_die_sides_2::Int32
    effect_die_sides_3::Int32
    effect_real_points_per_level_1::Float32
    effect_real_points_per_level_2::Float32
    effect_real_points_per_level_3::Float32
    effect_base_points_1::Int32
    effect_base_points_2::Int32
    effect_base_points_3::Int32
    effect_mechanic_1::UInt32
    effect_mechanic_2::UInt32
    effect_mechanic_3::UInt32
    effect_implicit_target_a_1::UInt32
    effect_implicit_target_a_2::UInt32
    effect_implicit_target_a_3::UInt32
    effect_implicit_target_b_1::UInt32
    effect_implicit_target_b_2::UInt32
    effect_implicit_target_b_3::UInt32
    effect_radius_index_1::UInt32
    effect_radius_index_2::UInt32
    effect_radius_index_3::UInt32
    effect_apply_aura_name_1::UInt32
    effect_apply_aura_name_2::UInt32
    effect_apply_aura_name_3::UInt32
    effect_amplitude_1::UInt32
    effect_amplitude_2::UInt32
    effect_amplitude_3::UInt32
    effect_multiple_value_1::Float32
    effect_multiple_value_2::Float32
    effect_multiple_value_3::Float32
    effect_chain_target_1::UInt32
    effect_chain_target_2::UInt32
    effect_chain_target_3::UInt32
    effect_item_type_1::UInt32
    effect_item_type_2::UInt32
    effect_item_type_3::UInt32
    effect_misc_value_1::Int32
    effect_misc_value_2::Int32
    effect_misc_value_3::Int32
    effect_misc_value_b_1::Int32
    effect_misc_value_b_2::Int32
    effect_misc_value_b_3::Int32
    effect_trigger_spell_1::UInt32
    effect_trigger_spell_2::UInt32
    effect_trigger_spell_3::UInt32
    effect_points_per_combo_point_1::Float32
    effect_points_per_combo_point_2::Float32
    effect_points_per_combo_point_3::Float32
    effect_class_mask_a_1::UInt32
    effect_class_mask_a_2::UInt32
    effect_class_mask_a_3::UInt32
    effect_class_mask_b_1::UInt32
    effect_class_mask_b_2::UInt32
    effect_class_mask_b_3::UInt32
    effect_class_mask_c_1::UInt32
    effect_class_mask_c_2::UInt32
    effect_class_mask_c_3::UInt32
    visual_1::UInt32
    visual_2::UInt32
    icon_id::UInt32
    active_icon_id::UInt32
    priority::UInt32
    name::LString
    rank::LString
    description::LString
    tool_tip::LString
    mana_cost_percentage::UInt32
    start_recovery_category::UInt32
    start_recovery_time::UInt32
    maximum_target_level::UInt32
    class::Class
    class_flags::UInt32
    class_flags_1::UInt32
    class_flags_2::UInt32
    maximum_affected_targets::UInt32
    damage_class::UInt32
    prevention_type::UInt32
    stance_bar_order::UInt32
    effect_damage_multiplier_1::Float32
    effect_damage_multiplier_2::Float32
    effect_damage_multiplier_3::Float32
    minimum_faction_id::UInt32
    minimum_reputation::UInt32
    required_aura_vision::UInt32
    totem_category_1::UInt32
    totem_category_2::UInt32
    area_group_id::UInt32
    school::MagicSchool
    rune_cost_id::UInt32
    missile_id::UInt32
    power_display_id::UInt32
    effect_bonus_multiplier_1::Float32
    effect_bonus_multiplier_2::Float32
    effect_bonus_multiplier_3::Float32
    description_variable_id::UInt32
    difficulty_id::UInt32
end

struct SpellCastTimesData <: DBCDataType
    id::UInt32
    casting_time::Int32
    casting_time_per_level::Int32
    minimum_casting_time::Int32
end

struct SpellCategoryData <: DBCDataType
    id::UInt32
    flags::UInt32
end

struct SpellDescriptionVariablesData <: DBCDataType
    id::UInt32
    formula::String
end

struct SpellDifficultyData <: DBCDataType
    id::UInt32
    difficulties_1::UInt32
    difficulties_2::UInt32
    difficulties_3::UInt32
    difficulties_4::UInt32
end

struct SpellDispelTypeData <: DBCDataType
    id::UInt32
    name::LString
    combinations::UInt32
    immunity_possible::UInt32
    internal_name::UInt32
end

struct SpellDurationData <: DBCDataType
    id::UInt32
    base_duration::UInt32
    per_level::Int32
    maximum_duration::Int32
end

struct SpellFocusObjectData <: DBCDataType
    id::UInt32
    name::LString
end

struct SpellIconData <: DBCDataType
    id::UInt32
    name::String
end

struct SpellItemEnchantmentData <: DBCDataType
    id::UInt32
    charges::UInt32
    spell_dispel_type_1::UInt32
    spell_dispel_type_2::UInt32
    spell_dispel_type_3::UInt32
    min_amount_1::UInt32
    min_amount_2::UInt32
    min_amount_3::UInt32
    max_amount_1::UInt32
    max_amount_2::UInt32
    max_amount_3::UInt32
    object_id_1::UInt32
    object_id_2::UInt32
    object_id_3::UInt32
    s_ref_name::LString
    item_visuals::UInt32
    flags::UInt32
    item_cache::UInt32
    spell_item_enchantment_condition::UInt32
    skill_line::UInt32
    skill_level::UInt32
    required_level::UInt32
end

struct SpellMechanicData <: DBCDataType
    id::UInt32
    name::LString
end

struct SpellMissileData <: DBCDataType
    id::UInt32
    flags::UInt32
    default_pitch_min::Float32
    default_pitch_max::Float32
    default_speed_min::Float32
    default_speed_max::Float32
    randomize_facing_min::Float32
    randomize_facing_max::Float32
    randomize_pitch_min::Float32
    randomize_pitch_max::Float32
    randomize_speed_min::Float32
    randomize_speed_max::Float32
    gravity::Float32
    max_duration::Float32
    collision_radius::Float32
end

struct SpellMissileMotionData <: DBCDataType
    id::UInt32
    name::String
    script::String
    flags::Int32
    missile_count::Int32
end

struct SpellRadiusData <: DBCDataType
    id::UInt32
    radius::Float32
    radius_per_level::Float32
    maximum_radius::Float32
end

struct SpellRangeData <: DBCDataType
    id::UInt32
    minimum_range_hostile::Float32
    minimum_range_friend::Float32
    maximum_range_hostile::Float32
    maximum_range_friend::Float32
    type::Int32
    name::LString
    short_name::LString
end

struct SpellRuneCostData <: DBCDataType
    id::UInt32
    rune_cost_1::UInt32
    rune_cost_2::UInt32
    rune_cost_3::UInt32
    rune_power_gain::UInt32
end

struct SpellShapeshiftFormData <: DBCDataType
    id::UInt32
    action_bar::UInt32
    name::LString
    creature_type_1::Int32
    creature_type_2::Int32
    spell_icon::Int32
    combat_round_time::Int32
    display_1::UInt32
    display_2::UInt32
    display_3::UInt32
    display_4::UInt32
    preset_spell_id_1::UInt32
    preset_spell_id_2::UInt32
    preset_spell_id_3::UInt32
    preset_spell_id_4::UInt32
    preset_spell_id_5::UInt32
    preset_spell_id_6::UInt32
    preset_spell_id_7::UInt32
    preset_spell_id_8::UInt32
end

struct SpellVisualData <: DBCDataType
    id::UInt32
    precast_kit::UInt32
    cast_kit::UInt32
    impact_kit::UInt32
    state_kit::UInt32
    state_done_kit::UInt32
    channel_kit::UInt32
    has_missile::Int32
    missile_model::UInt32
    missile_path_type::UInt32
    missile_destination_attachment::UInt32
    missile_sound::UInt32
    anim_event_sound_id::UInt32
    flags::UInt32
    caster_impact_kit::UInt32
    target_impact_kit::UInt32
    missile_attachment::UInt32
    missile_follow_ground_height::UInt32
    missile_follow_drop_speed::UInt32
    missile_follow_approach::UInt32
    missile_follow_ground_flags::UInt32
    missile_motion::UInt32
    missile_targeting_kit::UInt32
    instant_area_kit::UInt32
    impact_area_kit::UInt32
    persistent_area_kit::UInt32
    missile_cast_offset_x::Float32
    missile_cast_offset_y::Float32
    missile_cast_offset_z::Float32
    missile_impact_offset_x::Float32
    missile_impact_offset_y::Float32
    missile_impact_offset_z::Float32
end

struct SpellVisualEffectNameData <: DBCDataType
    id::UInt32
    name::String
    file_path::String
    area_effect_size::Float32
    scale::Float32
    min_allowed_scale::Float32
    max_allowed_scale::Float32
end

struct SpellVisualKitData <: DBCDataType
    id::UInt32
    start_anim_id::UInt32
    animation_id::UInt32
    head_effect::UInt32
    chest_effect::UInt32
    base_effect::UInt32
    left_hand_effect::UInt32
    right_hand_effect::UInt32
    breath_effect::UInt32
    left_weapon_effect::UInt32
    right_weapon_effect::UInt32
    special_effect_1::UInt32
    special_effect_2::UInt32
    special_effect_3::UInt32
    world_effect::UInt32
    sound_id::UInt32
    shake_id::UInt32
    char_proc_1::UInt32
    char_proc_2::UInt32
    char_proc_3::UInt32
    char_proc_4::UInt32
    char_param_zero_1::Float32
    char_param_zero_2::Float32
    char_param_zero_3::Float32
    char_param_zero_4::Float32
    char_param_one_1::Float32
    char_param_one_2::Float32
    char_param_one_3::Float32
    char_param_one_4::Float32
    char_param_two_1::Float32
    char_param_two_2::Float32
    char_param_two_3::Float32
    char_param_two_4::Float32
    char_param_three_1::Float32
    char_param_three_2::Float32
    char_param_three_3::Float32
    char_param_three_4::Float32
    flags::UInt32
end

struct SpellVisualKitAreaModelData <: DBCDataType
    id::UInt32
    name::String
    enum_id::UInt32
end

struct SpellVisualKitModelAttachData <: DBCDataType
    id::UInt32
    parent_spell_visual_kit_id::UInt32
    spell_visual_effect_name_id::UInt32
    attachment_id::UInt32
    offset_x::Float32
    offset_y::Float32
    offset_z::Float32
    yaw::Float32
    pitch::Float32
    roll::Float32
end

struct SpellVisualPrecastTransitionsData <: DBCDataType
    id::UInt32
    precast_load_anim_name::String
    precast_hold_anim_name::String
end

struct StationeryData <: DBCDataType
    id::UInt32
    item_id::UInt32
    texture::String
    flags::UInt32
end

struct TalentData <: DBCDataType
    id::UInt32
    talent_tab_id::UInt32
    tier_id::UInt32
    column_index::UInt32
    spell_rank_1::UInt32
    spell_rank_2::UInt32
    spell_rank_3::UInt32
    spell_rank_4::UInt32
    spell_rank_5::UInt32
    spell_rank_6::UInt32
    spell_rank_7::UInt32
    spell_rank_8::UInt32
    spell_rank_9::UInt32
    prereq_talent_1::UInt32
    prereq_talent_2::UInt32
    prereq_talent_3::UInt32
    prereq_rank_1::UInt32
    prereq_rank_2::UInt32
    prereq_rank_3::UInt32
    flags::UInt32
    required_spell_id::UInt32
    allow_for_pet_flags_1::UInt32
    allow_for_pet_flags_2::UInt32
end

struct TalentTabData <: DBCDataType
    id::UInt32
    name::LString
    icon_id::UInt32
    race_mask::UInt32
    class_mask::UInt32
    creature_family_category::UInt32
    order_index::UInt32
    background_file_name::String
end

struct TaxiNodesData <: DBCDataType
    id::UInt32
    map::Int32
    x::Float32
    y::Float32
    z::Float32
    name::LString
    mount_1::UInt32
    mount_2::UInt32
end

struct TaxiPathData <: DBCDataType
    id::UInt32
    from_taxi_node::UInt32
    to_taxi_node::UInt32
    cost::UInt32
end

struct TaxiPathNodeData <: DBCDataType
    id::UInt32
    path_id::UInt32
    node_index::UInt32
    map_id::UInt32
    x::Float32
    y::Float32
    z::Float32
    flags::UInt32
    delay::UInt32
    arrival_event_id::UInt32
    departure_event_id::UInt32
end

struct TotemCategoryData <: DBCDataType
    id::UInt32
    name::LString
    category_type::UInt32
    category_mask::UInt32
end

struct VehicleData <: DBCDataType
    id::UInt32
    flags::UInt32
    turn_speed::Float32
    pitch_speed::Float32
    pitch_min::Float32
    pitch_max::Float32
    seat_id_1::UInt32
    seat_id_2::UInt32
    seat_id_3::UInt32
    seat_id_4::UInt32
    seat_id_5::UInt32
    seat_id_6::UInt32
    seat_id_7::UInt32
    seat_id_8::UInt32
    mouse_look_offset_pitch::Float32
    camera_fade_dist_scalar_min::Float32
    camera_fade_dist_scalar_max::Float32
    camera_pitch_offset::Float32
    facing_limit_right::Float32
    facing_limit_left::Float32
    mssl_trgt_turn_lingering::Float32
    mssl_trgt_pitch_lingering::Float32
    mssl_trgt_mouse_lingering::Float32
    mssl_trgt_end_opacity::Float32
    mssl_trgt_arc_speed::Float32
    mssl_trgt_arc_repeat::Float32
    mssl_trgt_arc_width::Float32
    mssl_trgt_impact_radius_1::Float32
    mssl_trgt_impact_radius_2::Float32
    mssl_trgt_arc_texture::String
    mssl_trgt_impact_texture::String
    mssl_trgt_impact_model_1::String
    mssl_trgt_impact_model_2::String
    camera_yaw_offset::Float32
    ui_locomotion_type::UInt32
    mssl_trgt_impact_tex_radius::Float32
    ui_seat_indicator_type::UInt32
    power_display_1::Int32
    power_display_2::Int32
    power_display_3::Int32
end

struct VehicleSeatData <: DBCDataType
    id::UInt32
    flags::Int32
    attachment_id::Int32
    attachment_offset_x::Float32
    attachment_offset_y::Float32
    attachment_offset_z::Float32
    enter_pre_delay::Float32
    enter_speed::Float32
    enter_gravity::Float32
    enter_min_duration::Float32
    enter_max_duration::Float32
    enter_min_arc_height::Float32
    enter_max_arc_height::Float32
    enter_anim_start::Int32
    enter_anim_loop::Int32
    ride_anim_start::Int32
    ride_anim_loop::Int32
    ride_upper_anim_start::Int32
    ride_upper_anim_loop::Int32
    exit_pre_delay::Float32
    exit_speed::Float32
    exit_gravity::Float32
    exit_min_duration::Float32
    exit_max_duration::Float32
    exit_min_arc_height::Float32
    exit_max_arc_height::Float32
    exit_anim_start::Int32
    exit_anim_loop::Int32
    exit_anim_end::Int32
    passenger_yaw::Float32
    passenger_pitch::Float32
    passenger_roll::Float32
    passenger_attachment_id::Int32
    vehicle_enter_anim::Int32
    vehicle_exit_anim::Int32
    vehicle_ride_anim_loop::Int32
    vehicle_enter_anim_bone::Int32
    vehicle_exit_anim_bone::Int32
    vehicle_ride_anim_loop_bone::Int32
    vehicle_enter_anim_delay::Float32
    vehicle_exit_anim_delay::Float32
    vehicle_ability_display::UInt32
    enter_ui_sound_id::UInt32
    exit_ui_sound_id::UInt32
    ui_skin::UInt32
    flags_b::Int32
    camera_entering_delay::Float32
    camera_entering_duration::Float32
    camera_exiting_delay::Float32
    camera_exiting_duration::Float32
    camera_offset_x::Float32
    camera_offset_y::Float32
    camera_offset_z::Float32
    camera_pos_chase_rate::Float32
    camera_facing_chase_rate::Float32
    camera_entering_zoom::Float32
    camera_seat_zoom_min::Float32
    camera_seat_zoom_max::Float32
end

struct WMOAreaTableData <: DBCDataType
    id::Int32
    wmo_id::Int32
    name_set_id::Int32
    wmo_group_id::Int32
    sound_provider_pref::UInt32
    sound_provider_pref_underwater::UInt32
    ambience_id::UInt32
    zone_music::UInt32
    intro_sound::UInt32
    flags::UInt32
    area_table_id::UInt32
    name::LString
end

struct WorldStateUIData <: DBCDataType
    id::UInt32
    map_id::UInt32
    area_id::UInt32
    phase_shift::UInt32
    icon::String
    text::LString
    tooltip::LString
    world_state::Int32
    type::Int32
    dynamic_icon::String
    dynamic_tooltip::LString
    extended_ui_state_var::UInt32
    extended_ui_state_var_neutral::UInt32
    extended_ui_state_var_unk_1::UInt32
    extended_ui_state_var_unk_2::UInt32
end

struct ZoneMusicData <: DBCDataType
    id::UInt32
    name::String
    silence_min_day::UInt32
    silence_min_night::UInt32
    silence_max_day::UInt32
    silence_max_night::UInt32
    day_music::UInt32
    night_music::UInt32
end


export AchievementData, AchievementCategoryData, AchievementCriteriaData, AnimationDataData, AreaGroupData, AreaTableData, AreaTriggerData, CharStartOutfitData, CharTitlesData, ChatChannelsData, ChrClassesData, ChrRacesData, CinematicCameraData, CinematicSequencesData, CreatureDisplayInfoData, CreatureDisplayInfoExtraData, CreatureModelDataData, CreatureSoundDataData, CurrencyCategoryData, CurrencyTypesData, DungeonEncounterData, FactionData, FactionGroupData, FactionTemplateData, FileDataData, GameObjectDisplayInfoData, GameTipsData, GemPropertiesData, HolidayDescriptionsData, HolidayNamesData, HolidaysData, ItemData, ItemClassData, ItemDisplayInfoData, ItemExtendedCostData, ItemRandomPropertiesData, ItemRandomSuffixData, ItemSetData, ItemSubClassData, LFGDungeonGroupData, LFGDungeonsData, LightData, LightFloatBandData, LightIntBandData, LightParamsData, LightSkyboxData, LoadingScreensData, LockData, LockTypeData, MapData, MapDifficultyData, MovieData, MovieFileDataData, MovieVariationData, OverrideSpellDataData, QuestSortData, QuestXPData, ScreenEffectData, SkillLineData, SkillLineAbilityData, SkillRaceClassInfoData, SoundEntriesData, SpellData, SpellCastTimesData, SpellCategoryData, SpellDescriptionVariablesData, SpellDifficultyData, SpellDispelTypeData, SpellDurationData, SpellFocusObjectData, SpellIconData, SpellItemEnchantmentData, SpellMechanicData, SpellMissileData, SpellMissileMotionData, SpellRadiusData, SpellRangeData, SpellRuneCostData, SpellShapeshiftFormData, SpellVisualData, SpellVisualEffectNameData, SpellVisualKitData, SpellVisualKitAreaModelData, SpellVisualKitModelAttachData, SpellVisualPrecastTransitionsData, StationeryData, TalentData, TalentTabData, TaxiNodesData, TaxiPathData, TaxiPathNodeData, TotemCategoryData, VehicleData, VehicleSeatData, WMOAreaTableData, WorldStateUIData, ZoneMusicData
