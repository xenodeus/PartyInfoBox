--[[
Event Handler Helper

PURPOSE:
Manages all Windower event registrations and handlers for the PartyInfoBox addon.
Coordinates game state changes with display updates and party data management.

RESPONSIBILITIES:
- Register event handlers with Windower
- Handle game state changes (login, logout, zone changes)
- Manage display update timing and frequency
- Control focus-based behavior
- Coordinate between demo mode and live mode
- Handle party composition changes through network packets

EVENT TYPES HANDLED:
- incoming chunk: Network packets for party updates
- prerender: Main update loop, called every frame
- zone change: Player changes zones
- login: Player logs into the game
- load: Addon is loaded/reloaded
- addon command: Chat commands directed to this addon
- unload: Addon is being unloaded

UPDATE LOGIC:
- Checks if updates should occur based on focus settings
- Manages update frequency to avoid excessive processing
- Handles both demo mode and live mode updates
- Coordinates party data caching and display updates
]]--

local helpers_events = {}

-- Handle incoming network packets to detect party changes
-- Monitors specific packet types that indicate party composition has changed
function helpers_events.handle_party_packets(id, data)
    if id == 0x0DD then  -- Party update packet
        -- Schedule party cache update to avoid spam during rapid changes
        if not helpers_party.is_cache_update_pending() then
            helpers_party.set_cache_update_pending(true)
            coroutine.schedule(function()
                if not demo_mode then
                    helpers_party.cache_party_members()
                end
                helpers_party.set_cache_update_pending(false)
            end, helpers_config.settings.timing.party_update_delay)
        end
    end
end

-- Main update loop - runs every frame
-- This is the core update function that drives all display updates
function helpers_events.prerender()
    -- Safety checks - don't display if nothing is enabled
    if not helpers_config.any_columns_enabled() then
        if helpers_display.display then helpers_display.display:hide() end
        return
    end
    
    if not helpers_config.any_parties_enabled() then
        if helpers_display.display then helpers_display.display:hide() end
        return
    end
    
    -- Demo mode has different update logic
    if demo_mode then
        local now = os.time()
        -- Update demo data every 10 seconds instead of every second
        if now - helpers_display.last_update >= 10 then
            helpers_display.last_update = now
            helpers_demo.generate_demo_data()
            helpers_display.update_display()
        end
        return
    end
    
    -- Normal mode update logic
    local now = os.time()
    if now - helpers_display.last_update >= helpers_config.settings.update_frequency then
        helpers_display.last_update = now
        
        -- Only update if logged into the game
        if windower.ffxi.get_info().logged_in then
            -- Check if window focus is required for updates
            local has_focus = windower.has_focus()
            local should_update = not helpers_config.settings.focus.require_focus_for_updates or has_focus
            
            if should_update then
                -- Count party members from enabled parties only
                local party_count = 0
                if windower.ffxi.get_party() then
                    if helpers_config.settings.parties.party then
                        party_count = party_count + (windower.ffxi.get_party().party1_count or 0)
                    end
                    if helpers_config.settings.parties.alliance1 then
                        party_count = party_count + (windower.ffxi.get_party().party2_count or 0)
                    end
                    if helpers_config.settings.parties.alliance2 then
                        party_count = party_count + (windower.ffxi.get_party().party3_count or 0)
                    end
                end
                
                -- Update cache if party size changed, otherwise just update display
                if party_count > 1 and #helpers_display.tracked_party_members ~= party_count then
                    helpers_party.cache_party_members()
                else
                    helpers_display.update_display()
                end
            end
            
            -- Hide display if focus is lost and hiding is enabled
            if helpers_config.settings.focus.hide_when_not_focused and not has_focus then
                if helpers_display.display then helpers_display.display:hide() end
            end
        else
            -- Not logged in, hide display
            if helpers_display.display then helpers_display.display:hide() end
        end
    end
end

-- Handle zone changes - clear position data and refresh party
-- Called when player moves between zones/areas
function helpers_events.zone_change()
    helpers_party.clear_movement_tracker()  -- Movement tracking becomes invalid after zone change
    if not helpers_party.is_cache_update_pending() then
        helpers_party.set_cache_update_pending(true)
        coroutine.schedule(function()
            -- Double-check demo mode hasn't been enabled during the delay
            if not demo_mode then
                helpers_party.cache_party_members()
            end
            helpers_party.set_cache_update_pending(false)
        end, 7)  -- Wait 7 seconds for zone to stabilize
    end
end

-- Handle login events
-- Called when player successfully logs into the game
function helpers_events.login()
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
        
        -- Initialize display if not already done
        if not helpers_display.display then
            helpers_display.initialize_display()
        end
        
        -- Schedule party cache update after login delay
        if not helpers_party.is_cache_update_pending() then
            helpers_party.set_cache_update_pending(true)
            coroutine.schedule(function()
                if not demo_mode then
                    helpers_party.cache_party_members()
                end
                helpers_party.set_cache_update_pending(false)
            end, helpers_config.settings.timing.login_delay)
        end
    end
end

-- Handle addon load events
-- Called when addon is first loaded or reloaded
function helpers_events.load()
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
        
        -- Initialize display if not already done
        if not helpers_display.display then
            helpers_display.initialize_display()
        end
        
        -- Schedule party cache update after load delay
        if not helpers_party.is_cache_update_pending() then
            helpers_party.set_cache_update_pending(true)
            coroutine.schedule(function()
                if not demo_mode then
                    helpers_party.cache_party_members()
                end
                helpers_party.set_cache_update_pending(false)
            end, helpers_config.settings.timing.login_delay)
        end
    end
end

-- Handle addon commands
-- Routes chat commands to the command handler
function helpers_events.addon_command(...)
    local commands = {...}
    helpers_commands.handle_command(commands)
end

-- Cleanup when addon is unloaded
-- Ensures proper cleanup of resources when addon shuts down
function helpers_events.unload()
    if helpers_display.display then
        helpers_display.display:destroy()
        helpers_display.display = nil
    end
    helpers_party.clear_movement_tracker()
end

-- Register all event handlers
-- Sets up all the event listeners with Windower
function helpers_events.register_all()
    -- Register event handlers
    windower.register_event('incoming chunk', helpers_events.handle_party_packets)
    windower.register_event('prerender', helpers_events.prerender)
    windower.register_event('zone change', helpers_events.zone_change)
    windower.register_event('login', helpers_events.login)
    windower.register_event('load', helpers_events.load)
    windower.register_event('addon command', helpers_events.addon_command)
    windower.register_event('unload', helpers_events.unload)
end

return helpers_events