--[[
Command Handler Helper

PURPOSE:
Handles all chat command processing for the PartyInfoBox addon.
Provides user interface for configuration, display control, and addon management.

RESPONSIBILITIES:
- Parse and route chat commands to appropriate handlers
- Provide help text and command documentation
- Handle configuration changes via commands
- Control demo mode activation/deactivation
- Manage display visibility and positioning
- Provide status information and debugging commands

COMMAND CATEGORIES:
- Basic commands: reload, save, show, hide, toggle
- Demo commands: demo on/off/toggle/refresh
- Party commands: party control, parties status
- Column commands: column control, columns status
- Display commands: header, separators, dividers, display
- Focus commands: focus behavior settings
- Info commands: help and status display

COMMAND STRUCTURE:
Commands follow the pattern: //partyinfobox <command> [parameters]
All commands are case-insensitive for user convenience
Parameters are validated before processing
]]--

local helpers_commands = {}

-- Color command mappings - maps command names to config color keys
local color_commands = {
    timestamp_color = 'timestamp',
    header_color = 'header',
    npc_color = 'npc',
    unclaimed_color = 'unclaimed_mob',
    claimed_color = 'other_claimed',
    distance_close_color = 'distance_close',
    distance_medium_color = 'distance_medium',
    distance_far_color = 'distance_far',
    distance_very_far_color = 'distance_very_far',
    member_close_color = 'member_distance_close',
    member_medium_color = 'member_distance_medium',
    member_far_color = 'member_distance_far',
    member_very_far_color = 'member_distance_very_far',
    state_idle_color = 'state_idle',
    state_moving_color = 'state_moving',
    state_engaged_color = 'state_engaged',
    state_dead_color = 'state_dead',
    state_other_color = 'state_other'
}

-- Display command mappings - maps command names to display types
local display_commands = {
    header = 'header',
    separators = 'separators', 
    dividers = 'dividers',
    cache_timestamp = 'cache_timestamp',
    display_timestamp = 'display_timestamp'
}

-- Handle all addon commands
function helpers_commands.handle_command(commands)
    commands[1] = commands[1] and commands[1]:lower() or ''
    
    -- Basic addon commands
    if commands[1] == 'reload' then
        if commands[2] and commands[2]:lower() == 'all' then
            windower.send_command('send @others lua reload ' .. _addon.name)
        end
        windower.send_command('lua reload ' .. _addon.name)
    elseif commands[1] == 'save' then
        helpers_config.save_settings(helpers_display.display)
        helpers_chat.add_info_to_chat('Settings saved.')

    elseif commands[1] == 'show' then
        helpers_display.display_visible = true
        if helpers_display.display then helpers_display.display:show() end

    elseif commands[1] == 'hide' then
        helpers_display.display_visible = false
        if helpers_display.display then helpers_display.display:hide() end

    elseif commands[1] == 'toggle' then
        helpers_display.display_visible = not helpers_display.display_visible
        if helpers_display.display then
            if helpers_display.display_visible then
                helpers_display.display:show()
            else
                helpers_display.display:hide()
            end
        end
    
    -- Demo mode commands
    elseif commands[1] == 'demo' then
        local demo_command = commands[2] and commands[2]:lower() or 'toggle'
        if demo_command == 'on' then
            demo_mode = true
            helpers_display.display_visible = true
            helpers_demo.enable_demo_mode()
            helpers_demo.generate_demo_data()
            helpers_display.update_display()
            helpers_chat.add_info_to_chat('Demo mode '..('enabled'):color(158))
        elseif demo_command == 'off' then
            demo_mode = false
            helpers_display.display_visible = true
            helpers_demo.disable_demo_mode()
            helpers_party.cache_party_members()
            helpers_chat.add_info_to_chat('Demo mode '..('disabled'):color(167))
        elseif demo_command == 'refresh' then
            if demo_mode then
                helpers_demo.generate_demo_data()
                helpers_display.update_display()
                helpers_chat.add_info_to_chat('Demo data refreshed')
            else
                helpers_chat.add_error_to_chat('Refresh only works in demo mode. Use "pib refresh" to refresh real party data.')
            end
        else -- toggle
            demo_mode = not demo_mode
            helpers_display.display_visible = true
            if demo_mode then
                helpers_demo.enable_demo_mode()
                helpers_demo.generate_demo_data()
                helpers_display.update_display()
                helpers_chat.add_info_to_chat('Demo mode '..('enabled'):color(158))
            else
                helpers_demo.disable_demo_mode()
                helpers_party.cache_party_members()
                helpers_chat.add_info_to_chat('Demo mode '..('disabled'):color(167))
            end
        end
        
    elseif commands[1] == 'refresh' then
        if commands[2] and commands[2]:lower() == 'all' then
            local silent = commands[3] and commands[3]:lower() == 'silent' and true or false
            windower.send_command('send @others ' .. _addon.name .. ' refresh silent')
        end
        if demo_mode then
            helpers_chat.add_error_to_chat('Use "pib demo refresh" to refresh demo data.')
        else
            helpers_party.cache_party_members()
            local silent = commands[2] and commands[2]:lower() == 'silent' and true or false
            if not silent then
                helpers_chat.add_info_to_chat('Party data refreshed')
            end
        end
    
    -- Party control commands
    elseif commands[1] == 'party' and commands[2] then
        helpers_commands.handle_party_command(commands)
    
    elseif commands[1] == 'parties' then
        helpers_chat.add_info_to_chat('party status:')
        helpers_chat.add_info_to_chat('  Main Party (P1): ' .. (helpers_config.settings.parties.party and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Alliance 1 (A1): ' .. (helpers_config.settings.parties.alliance1 and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Alliance 2 (A2): ' .. (helpers_config.settings.parties.alliance2 and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Demo Mode: ' .. (demo_mode and ('enabled'):color(158) or ('disabled'):color(167)), true)

    -- Column control commands
    elseif commands[1] == 'column' and commands[2] then
        helpers_commands.handle_column_command(commands)
    
    elseif commands[1] == 'columns' then
        helpers_chat.add_info_to_chat('column status:')
        helpers_chat.add_info_to_chat('  Position: ' .. (helpers_config.settings.columns.position and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Party Distance: ' .. (helpers_config.settings.columns.party_member_distance and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Character: ' .. (helpers_config.settings.columns.character_name and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  State: ' .. (helpers_config.settings.columns.state and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Target: ' .. (helpers_config.settings.columns.target_name and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Target Distance: ' .. (helpers_config.settings.columns.target_distance and ('enabled'):color(158) or ('disabled'):color(167)), true)

    -- Display control commands
    elseif commands[1] == 'display' then
        helpers_chat.add_info_to_chat('display settings:')
        helpers_chat.add_info_to_chat('  Addon header: ' .. (helpers_config.settings.display.show_addon_header and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Separator lines: ' .. (helpers_config.settings.display.show_separator_lines and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Column dividers: ' .. (helpers_config.settings.display.use_column_dividers and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Cache timestamp: ' .. (helpers_config.settings.display.show_cache_timestamp and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Display timestamp: ' .. (helpers_config.settings.display.show_display_timestamp and ('enabled'):color(158) or ('disabled'):color(167)), true)
        
    elseif display_commands[commands[1]] then
        helpers_commands.handle_display_command(commands, display_commands[commands[1]])
    
    -- Colors control commands
    elseif commands[1] == 'colors' then
        helpers_commands.show_color_status()

    elseif color_commands[commands[1]] then
        helpers_commands.handle_color_command(commands, color_commands[commands[1]])

    -- Focus behavior commands
    elseif commands[1] == 'focus' and commands[2] then
        helpers_commands.handle_focus_command(commands)
    
    elseif commands[1] == 'focus' then
        helpers_chat.add_info_to_chat('focus settings:')
        helpers_chat.add_info_to_chat('  Require focus for update: ' .. (helpers_config.settings.focus.require_focus_for_update and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Hide when not focused: ' .. (helpers_config.settings.focus.hide_when_not_focused and ('enabled'):color(158) or ('disabled'):color(167)), true)

    elseif commands[1] == 'debug' then
        if commands[2] and commands[2]:lower() == 'party' then
            if commands[3] then
                windower.add_to_chat(8, 'windower.ffxi.get_party()['..commands[3]:lower()..']:')
                table.vprint(windower.ffxi.get_party()[commands[3]:lower()])
            else
                windower.add_to_chat(8, 'windower.ffxi.get_party():')
                table.vprint(windower.ffxi.get_party())
            end
        elseif commands[2] and commands[2]:lower() == 'tracked' then
            if commands[3] then
                windower.add_to_chat(8, 'helpers_display.tracked_party_members['..commands[3]..']:')
                table.vprint(helpers_display.tracked_party_members[tonumber(commands[3])])
            else
                windower.add_to_chat(8, 'helpers_display.tracked_party_members:')
                table.vprint(helpers_display.tracked_party_members)
            end
        end

    -- Help command (default)
    else
        helpers_commands.show_help()
    end
end

-- Handle party-specific commands
function helpers_commands.handle_party_command(commands)
    local party_identifier = commands[2]:lower()
    local action = commands[3] and commands[3]:lower() or 'toggle'
    
    -- Map user-friendly names to setting keys
    local party_map = {
        p1 = 'party', party1 = 'party', party = 'party', main = 'party',
        a1 = 'alliance1', alliance1 = 'alliance1', ally1 = 'alliance1',
        a2 = 'alliance2', alliance2 = 'alliance2', ally2 = 'alliance2'
    }
    
    local setting_key = party_map[party_identifier]
    if setting_key then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.parties[setting_key] = true
            helpers_chat.add_info_to_chat('Party "' .. setting_key .. '" '..('enabled'):color(158)..'.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.parties[setting_key] = false
            helpers_chat.add_info_to_chat('Party "' .. setting_key .. '" '..('disabled'):color(167)..'.')
        else -- toggle
            helpers_config.settings.parties[setting_key] = not helpers_config.settings.parties[setting_key]
            helpers_chat.add_info_to_chat('Party "' .. setting_key .. '" ' .. (helpers_config.settings.parties[setting_key] and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
        
        -- Update display immediately after party change
        if helpers_config.any_parties_enabled() and helpers_config.any_columns_enabled() then
            if demo_mode then
                helpers_demo.generate_demo_data()
                helpers_display.update_display()
            else
                helpers_party.cache_party_members()
            end
        else
            if display then display:hide() end
            if not helpers_config.any_parties_enabled() then
                helpers_chat.add_info_to_chat('All parties disabled. Display hidden.')
            end
        end
    else
        helpers_chat.add_error_to_chat('Unknown party "' .. party_identifier .. '". Available: p1, a1, a2')
    end
end

-- Handle column-specific commands
function helpers_commands.handle_column_command(commands)
    local column_identifier = commands[2]:lower()
    local action = commands[3] and commands[3]:lower() or 'toggle'
    
    -- Map user-friendly names to setting keys
    local column_map = {
        pos = 'position', position = 'position',
        pdist = 'party_member_distance', partydist = 'party_member_distance', party_distance = 'party_member_distance',
        char = 'character_name', character = 'character_name', name = 'character_name',
        state = 'state', status = 'state',
        target = 'target_name',
        tdist = 'target_distance', targetdist = 'target_distance', target_distance = 'target_distance'
    }
    
    local setting_key = column_map[column_identifier]
    if setting_key then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.columns[setting_key] = true
            helpers_chat.add_info_to_chat('Column "' .. setting_key .. '" '..('enabled'):color(158)..'.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.columns[setting_key] = false
            helpers_chat.add_info_to_chat('Column "' .. setting_key .. '" '..('disabled'):color(167)..'.')
        else -- toggle
            helpers_config.settings.columns[setting_key] = not helpers_config.settings.columns[setting_key]
            helpers_chat.add_info_to_chat('Column "' .. setting_key .. '" ' .. (helpers_config.settings.columns[setting_key] and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
        
        -- Update display immediately after column change
        if helpers_config.any_columns_enabled() and helpers_config.any_parties_enabled() then
            helpers_display.update_display()
        else
            if display then display:hide() end
            if not helpers_config.any_columns_enabled() then
                helpers_chat.add_info_to_chat('All columns disabled. Display hidden.')
            end
        end
    else
        helpers_chat.add_error_to_chat('Unknown column "' .. column_identifier .. '". Available: pos, pdist, char, state, target, tdist')
    end
end

-- Handle display-specific commands
function helpers_commands.handle_display_command(commands, command_type)
    local action = commands[2] and commands[2]:lower() or 'toggle'
    
    if command_type == 'header' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.display.show_addon_header = true
            helpers_chat.add_info_to_chat('Addon header ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.display.show_addon_header = false
            helpers_chat.add_info_to_chat('Addon header ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.display.show_addon_header = not helpers_config.settings.display.show_addon_header
            helpers_chat.add_info_to_chat('Addon header ' .. (helpers_config.settings.display.show_addon_header and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    elseif command_type == 'separators' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.display.show_separator_lines = true
            helpers_chat.add_info_to_chat('Separator lines ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.display.show_separator_lines = false
            helpers_chat.add_info_to_chat('Separator lines ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.display.show_separator_lines = not helpers_config.settings.display.show_separator_lines
            helpers_chat.add_info_to_chat('Separator lines ' .. (helpers_config.settings.display.show_separator_lines and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    elseif command_type == 'dividers' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.display.use_column_dividers = true
            helpers_chat.add_info_to_chat('Column dividers ' .. ('enabled'):color(158) .. ' (using " | ").')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.display.use_column_dividers = false
            helpers_chat.add_info_to_chat('Column dividers ' .. ('disabled'):color(167) .. ' (using " ").')
        else -- toggle
            helpers_config.settings.display.use_column_dividers = not helpers_config.settings.display.use_column_dividers
            helpers_chat.add_info_to_chat('Column dividers ' .. (helpers_config.settings.display.use_column_dividers and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    elseif command_type == 'cache_timestamp' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.display.show_cache_timestamp = true
            helpers_chat.add_info_to_chat('Cache timestamp ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.display.show_cache_timestamp = false
            helpers_chat.add_info_to_chat('Cache timestamp ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.display.show_cache_timestamp = not helpers_config.settings.display.show_cache_timestamp
            helpers_chat.add_info_to_chat('Cache timestamp ' .. (helpers_config.settings.display.show_cache_timestamp and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    elseif command_type == 'display_timestamp' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.display.show_display_timestamp = true
            helpers_chat.add_info_to_chat('Display timestamp ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.display.show_display_timestamp = false
            helpers_chat.add_info_to_chat('Display timestamp ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.display.show_display_timestamp = not helpers_config.settings.display.show_display_timestamp
            helpers_chat.add_info_to_chat('Display timestamp ' .. (helpers_config.settings.display.show_display_timestamp and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    end
    
    helpers_display.update_display()
end

-- Handle focus-specific commands
function helpers_commands.handle_focus_command(commands)
    local focus_option = commands[2]:lower()
    local action = commands[3] and commands[3]:lower() or 'toggle'
    
    if focus_option == 'update' or focus_option == 'require_update' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.focus.require_focus_for_update = true
            helpers_chat.add_info_to_chat('Focus required for update ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.focus.require_focus_for_update = false
            helpers_chat.add_info_to_chat('Focus required for update ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.focus.require_focus_for_update = not helpers_config.settings.focus.require_focus_for_update
            helpers_chat.add_info_to_chat('Focus required for update ' .. (helpers_config.settings.focus.require_focus_for_update and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    elseif focus_option == 'hide' or focus_option == 'hide_unfocused' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.focus.hide_when_not_focused = true
            helpers_chat.add_info_to_chat('Hide when not focused ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.focus.hide_when_not_focused = false
            helpers_chat.add_info_to_chat('Hide when not focused ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.focus.hide_when_not_focused = not helpers_config.settings.focus.hide_when_not_focused
            helpers_chat.add_info_to_chat('Hide when not focused ' .. (helpers_config.settings.focus.hide_when_not_focused and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
        end
    else
        helpers_chat.add_error_to_chat('Unknown focus setting "' .. focus_option .. '". Available: update, hide')
    end
end

-- Handle generic color command
function helpers_commands.handle_color_command(commands, color_type)
    if commands[2] and commands[3] and commands[4] then
        local r, g, b = tonumber(commands[2]), tonumber(commands[3]), tonumber(commands[4])
        if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
            helpers_config.settings.colors[color_type].red = r
            helpers_config.settings.colors[color_type].green = g
            helpers_config.settings.colors[color_type].blue = b
            local friendly_name = color_type:gsub("_", " "):gsub("^%l", string.upper)
            helpers_chat.add_info_to_chat(friendly_name .. ' color set to RGB(' .. r .. ', ' .. g .. ', ' .. b .. ')')
            helpers_display.update_display()
        else
            helpers_chat.add_error_to_chat('Invalid RGB values. Must be 0-255')
        end
    else
        local color = helpers_config.settings.colors[color_type]
        local friendly_name = color_type:gsub("_", " ")
        helpers_chat.add_info_to_chat('Current ' .. friendly_name .. ' color: RGB(' .. color.red .. ', ' .. color.green .. ', ' .. color.blue .. ')')
    end
end

-- Show all color settings
function helpers_commands.show_color_status()
    helpers_chat.add_info_to_chat('color settings:')
    helpers_chat.add_info_to_chat('  Header: RGB(' .. helpers_config.settings.colors.header.red .. ', ' .. helpers_config.settings.colors.header.green .. ', ' .. helpers_config.settings.colors.header.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Timestamp: RGB(' .. helpers_config.settings.colors.timestamp.red .. ', ' .. helpers_config.settings.colors.timestamp.green .. ', ' .. helpers_config.settings.colors.timestamp.blue .. ')', true)
    helpers_chat.add_info_to_chat('  NPC: RGB(' .. helpers_config.settings.colors.npc.red .. ', ' .. helpers_config.settings.colors.npc.green .. ', ' .. helpers_config.settings.colors.npc.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Unclaimed mob: RGB(' .. helpers_config.settings.colors.unclaimed_mob.red .. ', ' .. helpers_config.settings.colors.unclaimed_mob.green .. ', ' .. helpers_config.settings.colors.unclaimed_mob.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Other claimed: RGB(' .. helpers_config.settings.colors.other_claimed.red .. ', ' .. helpers_config.settings.colors.other_claimed.green .. ', ' .. helpers_config.settings.colors.other_claimed.blue .. ')', true)
    helpers_chat.add_info_to_chat('Distance colors:', true)
    helpers_chat.add_info_to_chat('  Close: RGB(' .. helpers_config.settings.colors.distance_close.red .. ', ' .. helpers_config.settings.colors.distance_close.green .. ', ' .. helpers_config.settings.colors.distance_close.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Medium: RGB(' .. helpers_config.settings.colors.distance_medium.red .. ', ' .. helpers_config.settings.colors.distance_medium.green .. ', ' .. helpers_config.settings.colors.distance_medium.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Far: RGB(' .. helpers_config.settings.colors.distance_far.red .. ', ' .. helpers_config.settings.colors.distance_far.green .. ', ' .. helpers_config.settings.colors.distance_far.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Very far: RGB(' .. helpers_config.settings.colors.distance_very_far.red .. ', ' .. helpers_config.settings.colors.distance_very_far.green .. ', ' .. helpers_config.settings.colors.distance_very_far.blue .. ')', true)
    helpers_chat.add_info_to_chat('Member distance colors:', true)
    helpers_chat.add_info_to_chat('  Close: RGB(' .. helpers_config.settings.colors.member_distance_close.red .. ', ' .. helpers_config.settings.colors.member_distance_close.green .. ', ' .. helpers_config.settings.colors.member_distance_close.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Medium: RGB(' .. helpers_config.settings.colors.member_distance_medium.red .. ', ' .. helpers_config.settings.colors.member_distance_medium.green .. ', ' .. helpers_config.settings.colors.member_distance_medium.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Far: RGB(' .. helpers_config.settings.colors.member_distance_far.red .. ', ' .. helpers_config.settings.colors.member_distance_far.green .. ', ' .. helpers_config.settings.colors.member_distance_far.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Very far: RGB(' .. helpers_config.settings.colors.member_distance_very_far.red .. ', ' .. helpers_config.settings.colors.member_distance_very_far.green .. ', ' .. helpers_config.settings.colors.member_distance_very_far.blue .. ')', true)
    helpers_chat.add_info_to_chat('State colors:', true)
    helpers_chat.add_info_to_chat('  Idle: RGB(' .. helpers_config.settings.colors.state_idle.red .. ', ' .. helpers_config.settings.colors.state_idle.green .. ', ' .. helpers_config.settings.colors.state_idle.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Moving: RGB(' .. helpers_config.settings.colors.state_moving.red .. ', ' .. helpers_config.settings.colors.state_moving.green .. ', ' .. helpers_config.settings.colors.state_moving.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Engaged: RGB(' .. helpers_config.settings.colors.state_engaged.red .. ', ' .. helpers_config.settings.colors.state_engaged.green .. ', ' .. helpers_config.settings.colors.state_engaged.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Dead: RGB(' .. helpers_config.settings.colors.state_dead.red .. ', ' .. helpers_config.settings.colors.state_dead.green .. ', ' .. helpers_config.settings.colors.state_dead.blue .. ')', true)
    helpers_chat.add_info_to_chat('  Other: RGB(' .. helpers_config.settings.colors.state_other.red .. ', ' .. helpers_config.settings.colors.state_other.green .. ', ' .. helpers_config.settings.colors.state_other.blue .. ')', true)
end

-- Show help information
function helpers_commands.show_help()
    helpers_chat.add_info_to_chat('commands:')
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('reload'):color(220)..', '..('save'):color(220)..', '..('show'):color(220)..', '..('hide'):color(220)..', '..('toggle'):color(220), true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('demo'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'|'..('refresh'):color(208)..'] - control demo mode', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('refresh'):color(220)..' - refresh party data (real mode only)', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('parties'):color(220)..' - show party status', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('party'):color(220)..' '..('<name>'):color(167)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control parties', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('columns'):color(220)..' - show column status', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('column'):color(220)..' '..('<name>'):color(167)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control columns', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('header'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control addon header', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('separators'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control separator lines', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('dividers'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control column dividers', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('cache_timestamp'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control cache timestamp display', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('display_timestamp'):color(220)..' ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control display timestamp display', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('colors'):color(220)..' - show all color settings', true)
    helpers_chat.add_info_to_chat('Color commands (set with '..('<r> <g> <b>'):color(167)..'):', true)
    helpers_chat.add_info_to_chat('  '..('header_color'):color(220)..', '..('timestamp_color'):color(220)..', '..('npc_color'):color(220)..', '..('unclaimed_color'):color(220)..', '..('claimed_color'):color(220), true)
    helpers_chat.add_info_to_chat('  '..('distance_close_color'):color(220)..', '..('distance_medium_color'):color(220)..', '..('distance_far_color'):color(220)..', '..('distance_very_far_color'):color(220), true)
    helpers_chat.add_info_to_chat('  '..('member_close_color'):color(220)..', '..('member_medium_color'):color(220)..', '..('member_far_color'):color(220)..', '..('member_very_far_color'):color(220), true)
    helpers_chat.add_info_to_chat('  '..('state_idle_color'):color(220)..', '..('state_moving_color'):color(220)..', '..('state_engaged_color'):color(220)..', '..('state_dead_color'):color(220)..', '..('state_other_color'):color(220), true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('display'):color(220)..' - show display settings', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('focus'):color(220)..' ['..('update'):color(208)..'|'..('hide'):color(208)..'] ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control focus behavior', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('focus'):color(220)..' - show focus settings', true)
    helpers_chat.add_info_to_chat('  Party names: p1, a1, a2', true)
    helpers_chat.add_info_to_chat('  Column names: pos, pdist, char, state, target, tdist', true)
    helpers_chat.add_info_to_chat('  Focus options: update, hide', true)
    helpers_chat.add_info_to_chat('  Commands using ['..('all'):color(208)..'] as parameter: reload, refresh', true)
end

return helpers_commands