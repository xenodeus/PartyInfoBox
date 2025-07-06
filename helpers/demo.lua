--[[
Demo Mode Helper

PURPOSE:
Provides demonstration functionality for the PartyInfoBox addon.
Generates fake party data and overrides game functions for testing and configuration.

RESPONSIBILITIES:
- Generate realistic demo party data with random states
- Override Windower FFXI functions to return demo data
- Create mock party members with positions, targets, and states
- Simulate dynamic changes in party composition and status
- Provide safe testing environment without requiring actual party
]]--

local helpers_demo = {}

-- Store original functions for restoration
local original_get_mob_by_id = windower.ffxi.get_mob_by_id
local original_get_mob_by_index = windower.ffxi.get_mob_by_index
local original_get_mob_by_target = windower.ffxi.get_mob_by_target
local original_get_player = windower.ffxi.get_player
local original_get_party = windower.ffxi.get_party

-- Generate demo party data with random states and targets
-- Creates fake party members for all enabled party types
function helpers_demo.generate_demo_data()
    -- Clear existing data
    helpers_display.tracked_party_members = {}
    helpers_display.party_member_cache = {}
    helpers_display.movement_tracker = {}
    
    -- Generate main party (P1) - 6 members
    if helpers_config.settings.parties.party then
        for i = 1, 6 do
            local player_name = 'Player' .. i
            local player_id = 0x10000000 + i
            
            table.insert(helpers_display.tracked_party_members, {
                player_position = 'P1-' .. i,
                player_id = player_id,
                player_name = player_name
            })

            helpers_display.party_member_cache[player_id] = {is_pc = true, party = 1}

            -- Generate random position data for movement detection
            helpers_display.movement_tracker[player_id] = {
                x = math.random(0, 30),
                y = math.random(0, 30),
                is_moving = math.random() < 0.3  -- 30% chance of moving
            }
        end
    end
    
    -- Generate alliance party 1 (A1) - 6 members
    if helpers_config.settings.parties.alliance1 then
        for i = 1, 6 do
            local player_name = 'Ally1-' .. i
            local player_id = 0x20000000 + i
            
            table.insert(helpers_display.tracked_party_members, {
                player_position = 'A1-' .. i,
                player_id = player_id,
                player_name = player_name
            })
            
            helpers_display.party_member_cache[player_id] = {is_pc = true, party = 2}
            
            -- Generate random position data for movement detection
            helpers_display.movement_tracker[player_id] = {
                x = math.random(0, 30),
                y = math.random(0, 30),
                is_moving = math.random() < 0.3  -- 30% chance of moving
            }
        end
    end
    
    -- Generate alliance party 2 (A2) - 6 members
    if helpers_config.settings.parties.alliance2 then
        for i = 1, 6 do
            local player_name = 'Ally2-' .. i
            local player_id = 0x30000000 + i

            table.insert(helpers_display.tracked_party_members, {
                player_position = 'A2-' .. i,
                player_id = player_id,
                player_name = player_name
            })

            helpers_display.party_member_cache[player_id] = {is_pc = true, party = 3}

            -- Generate random position data for movement detection
            helpers_display.movement_tracker[player_id] = {
                x = math.random(0, 30),
                y = math.random(0, 30),
                is_moving = math.random() < 0.3  -- 30% chance of moving
            }
        end
    end
    
    -- Set demo player_id to first party member
    if #helpers_display.tracked_party_members > 0 then
        player_id = helpers_display.tracked_party_members[1].player_id
    end
end

-- Create a demo party member mob with random status
-- Returns a mock mob object with realistic properties for testing
function helpers_demo.create_demo_mob(tracked_member)
    local demo_states = {0, 1, 2, 33, 44, 47, 50}  -- Various status IDs for testing
    
    local mob = {
        id = tracked_member.player_id,
        name = tracked_member.player_name,
        x = math.random(0, 30),  -- Small coordinate range for realistic distances
        y = math.random(0, 30),
        status = demo_states[math.random(#demo_states)],
        hpp = math.random(0, 100),
        claim_id = math.random() < 0.7 and 0 or tracked_member.player_id,  -- 70% unclaimed
        is_npc = false,
        spawn_type = 1,
        target_index = math.random() < 0.6 and math.random(1, 2048) or nil  -- 60% chance of having target
    }
    
    return mob
end

-- Create a demo target mob with random properties
-- Returns a mock target object with various monster types and states
function helpers_demo.create_demo_target()
    local demo_targets = {'Goblin', 'Orc', 'Bee', 'Rabbit', 'Lizard', 'Crab', 'Worm', 'Skeleton', 'Bat', 'Spider'}
    
    local target = {
        id = math.random(0x40000000, 0x4FFFFFFF),  -- Target ID range
        name = demo_targets[math.random(#demo_targets)],
        x = math.random(0, 30),  -- Small coordinate range for realistic distances
        y = math.random(0, 30),
        hpp = math.random(0, 100),
        claim_id = math.random() < 0.5 and 0 or math.random(0x10000000, 0x3FFFFFFF),
        is_npc = true,
        spawn_type = math.random() < 0.8 and 16 or 2  -- Mostly hostile mobs
    }
    
    return target
end

-- Function to enable demo mode overrides
-- Replaces Windower functions with demo versions that return fake data
function helpers_demo.enable_demo_mode()
    -- Override get_mob_by_id to return demo data
    windower.ffxi.get_mob_by_id = function(mob_id)
        if demo_mode then
            -- Look for party member with this ID
            for _, tracked_member in ipairs(helpers_display.tracked_party_members) do
                if tracked_member.player_id == mob_id then
                    return helpers_demo.create_demo_mob(tracked_member)
                end
            end
            -- If not found, might be a target mob
            if mob_id >= 0x40000000 then
                return helpers_demo.create_demo_target()
            end
            return nil
        else
            return original_get_mob_by_id(mob_id)
        end
    end

    -- Override get_mob_by_index to return demo targets
    windower.ffxi.get_mob_by_index = function(index)
        if demo_mode then
            -- 70% chance of having a target
            if math.random() < 0.7 then
                return helpers_demo.create_demo_target()
            end
            return nil
        else
            return original_get_mob_by_index(index)
        end
    end

    -- Override get_mob_by_target to return demo targets
    windower.ffxi.get_mob_by_target = function(target_type)
        if demo_mode then
            if target_type == 't' and math.random() < 0.8 then  -- 80% chance of having a target
                return helpers_demo.create_demo_target()
            end
            return nil
        else
            return original_get_mob_by_target(target_type)
        end
    end

    -- Override get_player to return demo player data
    windower.ffxi.get_player = function()
        if demo_mode then
            return {
                id = player_id or 0x10000001,
                name = 'DemoPlayer',
                x = 50,
                y = 50
            }
        else
            return original_get_player()
        end
    end

    -- Override get_party to return demo party data
    windower.ffxi.get_party = function()
        if demo_mode then
            return {
                party1_count = helpers_config.settings.parties.party and 6 or 0,
                party2_count = helpers_config.settings.parties.alliance1 and 6 or 0,
                party3_count = helpers_config.settings.parties.alliance2 and 6 or 0
            }
        else
            return original_get_party()
        end
    end
end

-- Function to disable demo mode overrides
-- Restores original Windower functions when demo mode is turned off
function helpers_demo.disable_demo_mode()
    -- Restore original functions
    windower.ffxi.get_mob_by_id = original_get_mob_by_id
    windower.ffxi.get_mob_by_index = original_get_mob_by_index
    windower.ffxi.get_mob_by_target = original_get_mob_by_target
    windower.ffxi.get_player = original_get_player
    windower.ffxi.get_party = original_get_party

    -- Reset player_id to real player ID
    local real_player = windower.ffxi.get_player()
    if real_player then
        player_id = real_player.id
    end
end

return helpers_demo