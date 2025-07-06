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

-- Handle all addon commands
function helpers_commands.handle_command(commands)
    commands[1] = commands[1] and commands[1]:lower() or ''
    
    -- Basic addon commands
    if commands[1] == 'reload' then
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
        if demo_mode then
            helpers_chat.add_error_to_chat('Use "pib demo refresh" to refresh demo data.')
        else
            helpers_party.cache_party_members()
            helpers_chat.add_info_to_chat('Party data refreshed')
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
    elseif commands[1] == 'header' then
        helpers_commands.handle_display_command(commands, 'header')
    
    elseif commands[1] == 'separators' then
        helpers_commands.handle_display_command(commands, 'separators')
    
    elseif commands[1] == 'dividers' then
        helpers_commands.handle_display_command(commands, 'dividers')
    
    elseif commands[1] == 'display' then
        helpers_chat.add_info_to_chat('display settings:')
        helpers_chat.add_info_to_chat('  Addon header: ' .. (helpers_config.settings.display.show_addon_header and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Separator lines: ' .. (helpers_config.settings.display.show_separator_lines and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Column dividers: ' .. (helpers_config.settings.display.use_column_dividers and ('enabled'):color(158) or ('disabled'):color(167)), true)

    -- Focus behavior commands
    elseif commands[1] == 'focus' and commands[2] then
        helpers_commands.handle_focus_command(commands)
    
    elseif commands[1] == 'focus' then
        helpers_chat.add_info_to_chat('focus settings:')
        helpers_chat.add_info_to_chat('  Require focus for updates: ' .. (helpers_config.settings.focus.require_focus_for_updates and ('enabled'):color(158) or ('disabled'):color(167)), true)
        helpers_chat.add_info_to_chat('  Hide when not focused: ' .. (helpers_config.settings.focus.hide_when_not_focused and ('enabled'):color(158) or ('disabled'):color(167)), true)

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
    end
    
    helpers_display.update_display()
end

-- Handle focus-specific commands
function helpers_commands.handle_focus_command(commands)
    local focus_option = commands[2]:lower()
    local action = commands[3] and commands[3]:lower() or 'toggle'
    
    if focus_option == 'updates' or focus_option == 'require_updates' then
        if action == 'on' or action == 'enable' or action == 'true' then
            helpers_config.settings.focus.require_focus_for_updates = true
            helpers_chat.add_info_to_chat('Focus required for updates ' .. ('enabled'):color(158) .. '.')
        elseif action == 'off' or action == 'disable' or action == 'false' then
            helpers_config.settings.focus.require_focus_for_updates = false
            helpers_chat.add_info_to_chat('Focus required for updates ' .. ('disabled'):color(167) .. '.')
        else -- toggle
            helpers_config.settings.focus.require_focus_for_updates = not helpers_config.settings.focus.require_focus_for_updates
            helpers_chat.add_info_to_chat('Focus required for updates ' .. (helpers_config.settings.focus.require_focus_for_updates and ('enabled'):color(158) or ('disabled'):color(167)) .. '.')
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
        helpers_chat.add_error_to_chat('Unknown focus setting "' .. focus_option .. '". Available: updates, hide')
    end
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
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('display'):color(220)..' - show display settings', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('focus'):color(220)..' ['..('updates'):color(208)..'|'..('hide'):color(208)..'] ['..('on'):color(208)..'|'..('off'):color(208)..'|'..('toggle'):color(208)..'] - control focus behavior', true)
    helpers_chat.add_info_to_chat('  '..(_addon.shortname):color(220)..' '..('focus'):color(220)..' - show focus settings', true)
    helpers_chat.add_info_to_chat('  Party names: p1, a1, a2', true)
    helpers_chat.add_info_to_chat('  Column names: pos, pdist, char, state, target, tdist', true)
end

return helpers_commands