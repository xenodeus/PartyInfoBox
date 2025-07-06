--[[
Party Data Management Helper

PURPOSE:
Handles all party member data collection, caching, and state tracking for the PartyInfoBox addon.
Manages real-time party information and provides utilities for party member analysis.

RESPONSIBILITIES:
- Cache party member information from game data
- Track party member movement and position changes
- Determine character states (idle, moving, engaged, etc.)
- Manage party composition changes
- Provide utilities for party member lookups
- Handle movement detection and state analysis

PARTY TRACKING:
- Tracks main party (P1) and alliance parties (A1, A2)
- Monitors character positions for movement detection
- Caches party member data for quick access
- Provides state information for display formatting

STATE DETECTION:
- Analyzes character status codes to determine current state
- Tracks movement patterns to detect idle vs moving states
- Handles special states like engaged, dead, resting, etc.
- Provides color-coded state information for display

MOVEMENT TRACKING:
- Compares current position with last known position
- Detects when characters are moving vs stationary
- Maintains position history for accurate movement detection
- Cleans up tracking data when party members leave
]]--

local helpers_party = {}

-- Party-specific variables (moved from main file)
local party_member_cache = {}             -- Cache of party member data
local party_cache_update_pending = false  -- Prevents duplicate party cache updates
local movement_tracker = {}               -- Tracking positions for movement detection

-- Update the cache of party members and their data
function helpers_party.cache_party_members()
    -- Clear existing data
    helpers_display.tracked_party_members = {}
    party_member_cache = {}
    
    -- Track current party member IDs to clean up position data
    local current_party_ids = {}
    
    local party = windower.ffxi.get_party()
    if not party then return end
    
    -- Process each enabled party type
    if helpers_config.settings.parties.party then
        for i=0, (party.party1_count or 0) - 1 do
            helpers_party.store_party_member_data(party['p'..i], 1, 'P1-'..(i+1))
            if party['p'..i] and party['p'..i].mob then
                current_party_ids[party['p'..i].mob.id] = true
            end
        end
    end
    
    if helpers_config.settings.parties.alliance1 then
        for i=0, (party.party2_count or 0) - 1 do
            helpers_party.store_party_member_data(party['a1'..i], 2, 'A1-'..(i+1))
            if party['a1'..i] and party['a1'..i].mob then
                current_party_ids[party['a1'..i].mob.id] = true
            end
        end
    end
    
    if helpers_config.settings.parties.alliance2 then
        for i=0, (party.party3_count or 0) - 1 do
            helpers_party.store_party_member_data(party['a2'..i], 3, 'A2-'..(i+1))
            if party['a2'..i] and party['a2'..i].mob then
                current_party_ids[party['a2'..i].mob.id] = true
            end
        end
    end
    
    -- Remove position tracking for members no longer in party
    for mob_id, _ in pairs(movement_tracker) do
        if not current_party_ids[mob_id] then
            movement_tracker[mob_id] = nil
        end
    end
    
    -- Update display after caching
    helpers_display.update_display()
end

-- Cache data for a single party member
function helpers_party.store_party_member_data(party_member, party_number, party_position)
    if party_member and party_member.mob then
        -- Store party member info
        party_member_cache[party_member.mob.id] = {is_pc = true, party = party_number}
        table.insert(helpers_display.tracked_party_members, {
            player_position = party_position,
            player_id = party_member.mob.id,
            player_name = party_member.mob.name or ''
        })
        
        -- Also track their pet if they have one
        if party_member.mob.pet_index then
            local pet = windower.ffxi.get_mob_by_index(party_member.mob.pet_index)
            if pet then
                party_member_cache[pet.id] = {is_pet = true, owner = party_member.id, party = party_number}
            end
        end
    end
end

-- Check if a party member has moved since last update (for movement detection)
function helpers_party.detect_member_movement(mob)
    if not mob or not mob.id then return false end
    
    local mob_id = mob.id
    local current_x = mob.x
    local current_y = mob.y
    
    -- Initialize position tracking for new party members
    if not movement_tracker[mob_id] then
        movement_tracker[mob_id] = {
            x = current_x,
            y = current_y,
            is_moving = false
        }
        return false
    end
    
    -- Compare with last known position
    local last_pos = movement_tracker[mob_id]
    local is_moving = (last_pos.x ~= current_x or last_pos.y ~= current_y)
    
    -- Update stored position with current data
    movement_tracker[mob_id] = {
        x = current_x,
        y = current_y,
        is_moving = is_moving
    }
    
    return is_moving
end

-- Determine party member state based on status ID and movement
-- Returns: state_name (string), state_color (color table)
function helpers_party.get_member_state_info(mob)
    if not mob then return 'Unknown', helpers_config.settings.colors.state_other end
    
    local status_id = mob.status
    
    -- Check status IDs against known values and add movement detection
    if status_id == 0 then -- Idle status
        if helpers_party.detect_member_movement(mob) then
            return 'Moving', helpers_config.settings.colors.state_moving
        else
            return 'Idle', helpers_config.settings.colors.state_idle
        end
    elseif status_id == 1 then -- Engaged in combat
        return 'Engaged', helpers_config.settings.colors.state_engaged
    elseif status_id == 2 then -- Dead
        return 'Dead', helpers_config.settings.colors.state_dead
    elseif status_id == 3 then -- Engaged dead (rare)
        return 'Dead', helpers_config.settings.colors.state_dead
    elseif status_id == 4 then -- In event/cutscene
        return 'Event', helpers_config.settings.colors.state_event
    elseif status_id == 5 or status_id == 85 then -- On Mount
        -- For mount statuses with movement detection
        if helpers_party.detect_member_movement(mob) then
            return 'Riding', helpers_config.settings.colors.state_riding
        else
            return 'Mount', helpers_config.settings.colors.state_mount
        end
    elseif status_id == 33 then -- Resting
        return 'Resting', helpers_config.settings.colors.state_resting
    elseif status_id == 44 then -- Crafting
        return 'Crafting', helpers_config.settings.colors.state_crafting
    elseif status_id == 47 then -- Sitting
        return 'Sitting', helpers_config.settings.colors.state_sitting
    elseif status_id == 48 then -- Kneeling
        return 'Kneeling', helpers_config.settings.colors.state_kneeling
    elseif (status_id >= 38 and status_id <= 43) or (status_id >= 50 and status_id <= 62) then -- Fishing
        return 'Fishing', helpers_config.settings.colors.state_fishing
    elseif status_id >= 63 and status_id <= 75 then -- Chair sitting
        return 'Sitting', helpers_config.settings.colors.state_sitting
    else
        -- Unknown status - still check for movement and try to get name from resources
        if helpers_party.detect_member_movement(mob) then
            return 'Moving', helpers_config.settings.colors.state_moving
        else
            -- Try to get status name from game resources, fallback to 'Other'
            local status_info = res.statuses[status_id]
            local status_name = status_info and status_info.en or 'Other'
            return status_name, helpers_config.settings.colors.state_other
        end
    end
end

-- Check if a mob ID belongs to a party member or their pet
-- Returns: is_member (boolean), party_number (1=main, 2=alliance1, 3=alliance2)
function helpers_party.is_party_member_or_pet(mob_id)
    if mob_id == player_id then return true, 1 end -- Current player is always party member
    if helpers_utils.is_npc(mob_id) then return false end -- NPCs are not party members
    if party_member_cache[mob_id] == nil then return false end -- Not in party cache
    return party_member_cache[mob_id], party_member_cache[mob_id].party
end

-- Get party cache update pending status
function helpers_party.is_cache_update_pending()
    return party_cache_update_pending
end

-- Set party cache update pending status
function helpers_party.set_cache_update_pending(status)
    party_cache_update_pending = status
end

-- Clear movement tracker (for zone changes)
function helpers_party.clear_movement_tracker()
    movement_tracker = {}
end

return helpers_party