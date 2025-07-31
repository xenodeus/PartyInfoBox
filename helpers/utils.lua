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
- RGB color tables to string conversion for Windower
- Distance-based color coding for targets and party members
- Claim status color determination
- Target type color classification
]]--

local helpers_utils = {}

local degreesToDirection, getFacingDirection
do
    local dir_sets = L{'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N', 'NNE', 'NE', 'ENE', 'E'}
    helpers_utils.degreesToDirection = function(val)
        return dir_sets[((val + 8)/16):floor() + 1] or helpers_config.settings.default_values.compass
    end
    local fac_dir_sets = L{'W', 'WNW', 'NW', 'NNW', 'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W'}
    helpers_utils.getFacingDirection = function(val)
        return fac_dir_sets[math.round((val + math.pi) / math.pi * 8) + 1] or helpers_config.settings.default_values.facing
    end
end

-- Convert color table {red, green, blue} to string format "r,g,b" for Windower
function helpers_utils.color_to_string(color)
    --return tostring(color.red) .. ',' .. tostring(color.green) .. ',' .. tostring(color.blue)
    return string.format("%03d,%03d,%03d", color.red, color.green, color.blue)
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
    -- Calculate horizontal and vertical distance components
    local dx = mob1.x - mob2.x
    local dy = mob1.y - mob2.y
    -- Return Euclidean distance using Pythagorean theorem
    return math.sqrt(dx*dx + dy*dy)
end

-- Check if entity A is looking at entity B (unused but kept for future features)
function helpers_utils.looking_at(source_entity, target_entity)
    if not source_entity or not target_entity then return false end
    -- Get the facing direction of the source entity (normalized to π)
    local h = source_entity.facing % math.pi
    -- Calculate angle from source to target position (adjusted by π/2 and normalized)
    local h2 = (math.atan2(source_entity.x-target_entity.x,source_entity.y-target_entity.y) + math.pi/2) % math.pi
    -- Return true if the difference between facing and target angle is small (within 0.15 radians)
    return math.abs(h-h2) < 0.15
end

-- Determine if a mob ID represents an NPC (not player or pet)
function helpers_utils.is_npc(mob_id)
    -- Safety check - return nil if mob variable doesn't exist
    if not mob then return nil end

    -- Check if ID is in player range (less than 0x01000000)
    local is_pc = mob_id < 0x01000000    -- Player ID range
    -- Check if ID is in pet range (greater than 0x01000000 and specific bit pattern)
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700  -- Pet ID range

    -- Return false if it's a player or pet
    if is_pc or is_pet then return false end

    -- Get the actual mob object from the game
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return nil end
    -- Return true only if it's marked as NPC and not charmed
    return mob.is_npc and not mob.charmed
end
 
-- Calculate angle from player to target using vector math
function helpers_utils.get_angle(player,target)
    -- Create direction vector from player to target position
    local dir = V{target.x, target.y} - V{player.x, player.y}
    -- Create reference heading vector (pointing roughly north, 1.57075 ≈ π/2)
    local heading = V{}.from_radian(1.57075)
    -- Calculate signed angle between direction and heading vectors
    -- Uses cross product sign to determine clockwise/counterclockwise direction
    local angle = V{}.angle(dir, heading) * (dir[1]*heading[2]-dir[2]*heading[1] < 0 and -1 or 1)
    return angle
end

-- Get current camera facing angle in radians
function helpers_utils.get_camera_angle()
    -- Retrieve camera matrix from Windower
    local camera = windower.get_camera()
    local x, y
    -- Extract camera direction components based on matrix orientation
    if camera.matrix[2][3] > 0 then
        -- Forward-facing camera orientation
        x = camera.matrix[1][3] + camera.matrix[1][2]
        y = camera.matrix[3][3] + camera.matrix[3][2]
    else
        -- Backward-facing camera orientation
        x = camera.matrix[1][3] - camera.matrix[1][2]
        y = camera.matrix[3][3] - camera.matrix[3][2]
    end
    -- Convert direction components to angle using atan2 (negative x for proper orientation)
    return math.atan2(y, -x)
end

-- Calculate the relative angle needed to turn camera toward target
function helpers_utils.get_camera_turn_direction(target_degrees, camera_angle)
    if target_degrees == nil or camera_angle == nil then
        return nil
    end
    
    -- Convert target degrees to radians for comparison with camera angle
    local target_radians = math.rad(target_degrees)
    
    -- Calculate the difference between target direction and camera facing
    local angle_diff = target_radians - camera_angle
    
    -- Subtract 90-degree correction (π/2 radians) to account for coordinate system difference
    angle_diff = angle_diff - math.pi/2
    
    -- Normalize the angle to [-π, π] range to get shortest rotation direction
    while angle_diff > math.pi do
        angle_diff = angle_diff - 2 * math.pi
    end
    while angle_diff < -math.pi do
        angle_diff = angle_diff + 2 * math.pi
    end
    
    -- Convert back to degrees for compass direction
    local relative_degrees = math.deg(angle_diff)
    
    return relative_degrees
end

function helpers_utils.degrees_to_compass(degrees)
    local direction = helpers_config.settings.default_values.compass
    if degrees == nil then
        return direction
    end
    if degrees > -22.5 and degrees <= 22.5 then
        direction = 'S'
    elseif degrees > 22.5 and degrees <= 67.5 then
        direction = 'SW'
    elseif degrees > 67.5 and degrees <= 112.5 then
        direction = 'W'
    elseif degrees > 112.5 and degrees <= 157.5 then
        direction = 'NW'
    elseif (degrees > 157.5 and degrees <= 180) or (degrees < -157.5 and degrees > -180) then
        direction = 'N'
    elseif degrees >= -157.5 and degrees < -112.5 then
        direction = 'NE'
    elseif degrees >= -112.5 and degrees < -67.5 then
        direction = 'E'
    elseif degrees >= -67.5 and degrees <= -22.5 then
        direction = 'SE'
    end
    return direction
end

function helpers_utils.get_compass_direction(player_mob, target_mob)
    if target_mob == nil then 
        return helpers_config.settings.default_values.compass
    end
    local degrees = math.deg(helpers_utils.get_angle(player_mob, target_mob))
    local compass = helpers_utils.degreesToDirection(degrees)
    return compass
end

function helpers_utils.get_compass_icon(player_mob, target_mob)
    return helpers_utils.compass_to_icon(helpers_utils.get_compass_direction(player_mob, target_mob))
end

function helpers_utils.compass_to_icon(compass)
    if compass == nil or compass == '' or compass == helpers_config.settings.default_values.compass then
        return helpers_config.settings.compass_icons.invalid or helpers_config.settings.default_values.compass_icon
    end
    
    return helpers_config.settings.compass_icons[compass] or helpers_config.settings.compass_icons.invalid
end

-- Get compass direction to turn camera toward target
function helpers_utils.get_camera_compass_direction(player_mob, target_mob)
    if not player_mob or not target_mob then
        return helpers_config.settings.default_values.compass
    end
    
    -- Get target direction in degrees
    local target_degrees = math.deg(helpers_utils.get_angle(player_mob, target_mob))
    
    -- Get current camera angle
    local camera_angle = helpers_utils.get_camera_angle() -- This returns angle in radians
    
    -- Calculate relative turn direction
    local turn_degrees = helpers_utils.get_camera_turn_direction(target_degrees, camera_angle)
    
    if turn_degrees == nil then
        return helpers_config.settings.default_values.compass
    end
    
    -- Convert to compass direction
    return helpers_utils.degreesToDirection(turn_degrees)
end

function helpers_utils.get_camera_compass_icon(player_mob, target_mob)
    local compass_direction = helpers_utils.get_camera_compass_direction(player_mob, target_mob)
    return helpers_utils.compass_to_icon(compass_direction)
end

-- Get visual character count (handles Unicode properly)
function helpers_utils.visual_length(str)
    if not str then return 0 end
    
    -- For simple ASCII characters, use regular length
    if str:match("^[%w%s%p]*$") then
        return string.len(str)
    end
    
    -- For Unicode characters, count visual characters
    local count = 0
    for char in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        count = count + 1
    end
    return count
end

-- Format string with proper visual padding
function helpers_utils.visual_format(str, width, align)
    local visual_len = helpers_utils.visual_length(str)
    local padding = width - visual_len
    
    if padding <= 0 then
        return str
    end
    
    if align == 'right' then
        return string.rep(' ', padding) .. str
    else -- left align (default)
        return str .. string.rep(' ', padding)
    end
end

return helpers_utils