--[[
Utility Functions Helper

PURPOSE:
Provides common utility functions used throughout the PartyInfoBox addon.
Contains helper functions for calculations, color management, and data processing.

RESPONSIBILITIES:
- Distance calculations between entities
- Color conversion and formatting utilities
- Target type detection and classification
- Color coding based on distance thresholds
- Claim status determination and color assignment
- NPC detection and mob type classification

UTILITY CATEGORIES:
- Color utilities: Convert colors, apply distance-based coloring
- Target utilities: Determine target types, claim status, etc.
- Distance utilities: Calculate distances between mobs/players
- Entity utilities: Check mob types, facing direction, etc.

COLOR SYSTEM:
- RGB color tables to string conversion for Windower display
- Distance-based color coding for targets and party members
- Claim status color determination
- Target type color classification
]]--

local helpers_utils = {}

-- Convert color table {red, green, blue} to string format "r,g,b" for Windower
function helpers_utils.color_to_string(color)
    return tostring(color.red) .. ',' .. tostring(color.green) .. ',' .. tostring(color.blue)
end

-- Determine who has claimed a target (0=unclaimed, 1=player, 2=party, 3=alliance)
function helpers_utils.check_claim(claim_id)
    if claim_id == nil then
        return 0  -- Unclaimed
    end
    if player_id == claim_id then
        return 1  -- Player claimed
    else
        local is_member, party_num = helpers_party.is_party_member_or_pet(claim_id)
        if is_member and party_num == 1 then
            return 2  -- Party member claimed
        elseif is_member and party_num > 1 then
            return 3  -- Alliance member claimed
        end
    end
    return 0  -- Unclaimed
end

-- Get appropriate color for a target based on its status and claim
function helpers_utils.get_tint_by_target(target)
    -- Priority order: dead > claimed status > target type
    if target == nil then
        return helpers_config.settings.colors.default_grey
    elseif target.hpp == 0 then
        return helpers_config.settings.colors.dead_target
    elseif helpers_utils.check_claim(target.claim_id) == 1 or helpers_utils.check_claim(target.claim_id) == 2 then
        return helpers_config.settings.colors.player_claimed
    elseif helpers_utils.check_claim(target.claim_id) == 3 then
        return helpers_config.settings.colors.alliance_claimed
    elseif helpers_party.is_party_member_or_pet(target.id) and target.id ~= player_id then
        return helpers_config.settings.colors.party_member
    elseif not target.is_npc then
        return helpers_config.settings.colors.player
    elseif target.spawn_type == 2 or target.spawn_type == 34 then
        return helpers_config.settings.colors.npc
    elseif target.claim_id == 0 then
        return helpers_config.settings.colors.unclaimed_mob
    elseif target.claim_id ~= 0 then
        return helpers_config.settings.colors.other_claimed
    end
    return helpers_config.settings.colors.default_grey
end

-- Get color for target distance based on distance thresholds
function helpers_utils.get_tint_by_target_distance(target_distance)
    if target_distance == nil then
        return helpers_config.settings.colors.default_grey
    elseif target_distance <= helpers_config.settings.distance_thresholds.close then
        return helpers_config.settings.colors.distance_close
    elseif target_distance <= helpers_config.settings.distance_thresholds.medium then
        return helpers_config.settings.colors.distance_medium
    elseif target_distance <= helpers_config.settings.distance_thresholds.far then
        return helpers_config.settings.colors.distance_far
    else
        return helpers_config.settings.colors.distance_very_far
    end
end

-- Get color for party member distance based on distance thresholds
function helpers_utils.get_member_distance_color(distance)
    if distance == nil then
        return helpers_config.settings.colors.default_grey
    elseif distance <= helpers_config.settings.member_distance_thresholds.close then
        return helpers_config.settings.colors.member_distance_close
    elseif distance <= helpers_config.settings.member_distance_thresholds.medium then
        return helpers_config.settings.colors.member_distance_medium
    elseif distance <= helpers_config.settings.member_distance_thresholds.far then
        return helpers_config.settings.colors.member_distance_far
    else
        return helpers_config.settings.colors.member_distance_very_far
    end
end

-- Calculate 2D distance between two entities using Pythagorean theorem
function helpers_utils.get_distance(mob1, mob2)
    if not mob1 or not mob2 then return 0 end
    local dx = mob1.x - mob2.x
    local dy = mob1.y - mob2.y
    return math.sqrt(dx*dx + dy*dy)
end

-- Check if entity A is looking at entity B (unused but kept for future features)
function helpers_utils.looking_at(source_entity, target_entity)
    if not source_entity or not target_entity then return false end
    local h = source_entity.facing % math.pi
    local h2 = (math.atan2(source_entity.x-target_entity.x,source_entity.y-target_entity.y) + math.pi/2) % math.pi
    return math.abs(h-h2) < 0.15
end

-- Determine if a mob ID represents an NPC (not player or pet)
function helpers_utils.is_npc(mob_id)
    if not mob then return nil end

    local is_pc = mob_id < 0x01000000    -- Player ID range
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700  -- Pet ID range

    if is_pc or is_pet then return false end

    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return nil end
    return mob.is_npc and not mob.charmed
end

return helpers_utils