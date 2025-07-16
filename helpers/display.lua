--[[
Display Management Helper

PURPOSE:
Handles all text overlay rendering and formatting for the PartyInfoBox addon.
Manages the visual presentation of party data in a structured table format.

RESPONSIBILITIES:
- Initialize and manage the text display object
- Format party member data into aligned columns
- Apply color coding based on distance, state, and target information
- Handle display visibility and positioning
- Calculate column widths for proper alignment
- Generate formatted output with headers and separators

DISPLAY STRUCTURE:
- Header: Addon name (optional)
- Column headers: Position, Distance, Character, State, Target, etc.
- Data rows: One row per party member with formatted columns
- Separators: Horizontal lines between sections (optional)
- Color coding: Distance-based and state-based coloring

FORMATTING FEATURES:
- Monospace font alignment for clean columns
- Dynamic column width calculation
- Configurable column dividers (' | ' or spaces)
- Color-coded text for different data types
- Responsive layout based on enabled columns
]]--

local helpers_display = {}

-- Display-specific variables (direct access like helpers_config.settings)
helpers_display.tracked_party_members = {}    -- List of party members to display
helpers_display.last_update = 0               -- Timestamp of last display update
helpers_display.display_visible = true        -- Whether GUI should be shown
helpers_display.display = nil                 -- Text display object

local last_display_update = nil

-- Initialize the text display object with current settings
-- Creates a new text overlay with user-configured appearance settings
function helpers_display.initialize_display()
    -- Clean up existing display if it exists
    if helpers_display.display then
        helpers_display.display:destroy()
        helpers_display.display = nil
    end
    
    -- Create new text display object with current settings
    helpers_display.display = texts.new({
        pos = {x = helpers_config.settings.display.pos.x, y = helpers_config.settings.display.pos.y},
        text = {
            font = helpers_config.settings.display.font,
            size = helpers_config.settings.display.size,
            color = {
                helpers_config.settings.display.text_color.red,
                helpers_config.settings.display.text_color.green,
                helpers_config.settings.display.text_color.blue
            },
        },
        flags = helpers_config.settings.display.flags,
        bg = {alpha = helpers_config.settings.display.bg_alpha},
        stroke = {width = helpers_config.settings.display.stroke_width, alpha = helpers_config.settings.display.stroke_alpha},
        padding = helpers_config.settings.display.padding
    })
    helpers_display.display:hide()  -- Start hidden, will be shown when data is available
end

-- Add this helper function for right-aligned text:
local function format_timestamp_line(label, timestamp, max_length)
    local line = label .. timestamp
    local padding_needed = max_length - string.len(line)
    
    if padding_needed > 0 then
        -- Add spaces to right-align the timestamp
        return label .. string.rep(" ", padding_needed) .. timestamp
    else
        -- If line is too long, just return as-is
        return line
    end
end

-- Main function to update the display with current party data
-- This is the core function that processes all party member data and renders the display
function helpers_display.update_display()
    -- Early exit if display should be hidden
    if not helpers_display.display_visible then
        if helpers_display.display then helpers_display.display:hide() end
        return
    end

    -- Early exit if no columns are enabled
    if not helpers_config.any_columns_enabled() then
        if helpers_display.display then helpers_display.display:hide() end
        return
    end
    
    -- Early exit if no parties are enabled
    if not helpers_config.any_parties_enabled() then
        if helpers_display.display then helpers_display.display:hide() end
        return
    end

    if helpers_party.dummy_members_need_update() then
        --helpers_chat.add_error_to_chat('Dummy members need update, refreshing display...')
        coroutine.schedule(function()
            -- Force a party update to refresh dummy members
            windower.send_command(_addon.shortname .. ' refresh silent')
        end, 1)
        return
    end

    local formatted_member_data = {}  -- Processed data for each party member
    local party_member_found = false  -- Track if any valid party members exist
    
    -- Initialize column width tracking variables
    -- These track the maximum width needed for each column to ensure proper alignment
    local position_column_width = helpers_config.settings.columns.position and #('Pos.') or 0
    local member_distance_column_width = helpers_config.settings.columns.party_member_distance and #('Dist.') or 0
    local character_name_column_width = helpers_config.settings.columns.character_name and #('Character') or 0
    local state_column_width = helpers_config.settings.columns.state and #('State') or 0
    local target_name_column_width = helpers_config.settings.columns.target_name and #('Target') or 0
    local target_distance_column_width = helpers_config.settings.columns.target_distance and #('Dist.') or 0
    
    -- Get current player information for distance calculations
    local player = windower.ffxi.get_player()
    local player_mob = player and player.id and windower.ffxi.get_mob_by_id(player.id) or nil
    
    -- Process each tracked party member
    for _, tracked_member in ipairs(helpers_display.tracked_party_members) do
        -- Get the mob entity for this party member
        local member_entity = tracked_member.player_id and not tracked_member.dummy and windower.ffxi.get_mob_by_id(tracked_member.player_id) or nil
        if member_entity ~= nil or tracked_member.dummy then
            party_member_found = true

            -- Get basic member information
            local position_display_text = tracked_member.player_position  -- P1-1, A1-2, etc.
            local member_name_color = helpers_utils.get_tint_by_target(member_entity)
            local character_name = tracked_member.player_name
            
            -- Calculate party member distance from current player
            local member_distance_color = helpers_config.settings.colors.default_grey
            local member_distance_text = helpers_config.settings.default_values.member_distance
            
            if not tracked_member.dummy then
                -- Distance calculation logic
                if player_mob and member_entity.id and member_entity.id ~= player_id then
                    -- Calculate distance to other party members
                    local distance = helpers_utils.get_distance(player_mob, member_entity)
                    member_distance_color = helpers_utils.get_member_distance_color(distance)
                    member_distance_text = string.format(helpers_config.settings.member_distance_format, distance)
                elseif member_entity.id == player_id then
                    -- Distance to self is always 0
                    member_distance_text = string.format(helpers_config.settings.member_distance_format, 0.00)
                    member_distance_color = helpers_config.settings.colors.member_distance_close
                end
            end
            
            -- Get party member state (idle, engaged, moving, etc.)
            local member_state_text, member_state_color = helpers_party.get_member_state_info(member_entity)
            
            -- Initialize target data with default values
            local target_name_color = helpers_config.settings.colors.default_grey
            local target_name_text = helpers_config.settings.default_values.target_name
            local target_distance_color = helpers_config.settings.colors.default_grey
            local target_distance_text = helpers_config.settings.default_values.distance
            
            -- Get target information for this party member
            local member_target_mob = nil
            if not tracked_member.dummy and member_entity.id == player_id then
                -- For the current player, get their current target
                member_target_mob = windower.ffxi.get_mob_by_target('t')
            else
                -- For other party members, get their target if available
                if not tracked_member.dummy and member_entity.target_index then
                    member_target_mob = windower.ffxi.get_mob_by_index(member_entity.target_index)
                end
            end
            
            -- Process target information if a target exists
            if member_target_mob ~= nil then
                target_name_text = member_target_mob.name or ''
                target_name_color = helpers_utils.get_tint_by_target(member_target_mob)
                local distance = helpers_utils.get_distance(member_entity, member_target_mob)
                target_distance_color = helpers_utils.get_tint_by_target_distance(distance)
                target_distance_text = string.format(helpers_config.settings.distance_format, distance)
            end

            -- Update column width tracking for proper alignment
            if helpers_config.settings.columns.position then
                position_column_width = math.max(position_column_width, #position_display_text)
            end
            if helpers_config.settings.columns.party_member_distance then
                member_distance_column_width = math.max(member_distance_column_width, #member_distance_text)
            end
            if helpers_config.settings.columns.character_name then
                character_name_column_width = math.max(character_name_column_width, #character_name)
            end
            if helpers_config.settings.columns.state then
                state_column_width = math.max(state_column_width, #member_state_text)
            end
            if helpers_config.settings.columns.target_name then
                target_name_column_width = math.max(target_name_column_width, #target_name_text)
            end
            if helpers_config.settings.columns.target_distance then
                target_distance_column_width = math.max(target_distance_column_width, #target_distance_text)
            end

            -- Store processed data for this party member
            table.insert(formatted_member_data, {
                member_position = position_display_text,
                member_distance = member_distance_text,
                member_distance_color = helpers_utils.color_to_string(member_distance_color),
                member_name = character_name,
                member_name_color = helpers_utils.color_to_string(member_name_color),
                member_state = member_state_text,
                member_state_color = helpers_utils.color_to_string(member_state_color),
                target_name = target_name_text,
                target_name_color = helpers_utils.color_to_string(target_name_color),
                target_distance = target_distance_text,
                target_distance_color = helpers_utils.color_to_string(target_distance_color)
            })
        end
    end

    -- Hide display if no valid party members found
    if not party_member_found then
        helpers_display.display:hide()
        return
    end

    -- Build the formatted display output
    local lines = {}  -- Array to hold each line of the display
    local max_line_length = 0  -- Track maximum line length for consistent width

    -- Add addon header if enabled
    if helpers_config.settings.display.show_addon_header then
        local header_line = '['..string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%s\\cr', _addon.name).."]"
        table.insert(lines, header_line)
        max_line_length = #('['.._addon.name.."]")  -- Calculate header length without color codes
    end

    -- Calculate total line width for separator lines
    local separator_count = helpers_config.count_enabled_columns() - 1
    local divider_width = helpers_config.settings.display.use_column_dividers and 3 or 1  -- ' | ' vs ' '
    local column_widths = 0
    
    -- Sum up all column widths
    if helpers_config.settings.columns.position then column_widths = column_widths + position_column_width end
    if helpers_config.settings.columns.party_member_distance then column_widths = column_widths + member_distance_column_width end
    if helpers_config.settings.columns.character_name then column_widths = column_widths + character_name_column_width end
    if helpers_config.settings.columns.state then column_widths = column_widths + state_column_width end
    if helpers_config.settings.columns.target_name then column_widths = column_widths + target_name_column_width end
    if helpers_config.settings.columns.target_distance then column_widths = column_widths + target_distance_column_width end

    max_line_length = math.max(max_line_length, column_widths + (separator_count * divider_width))

    -- Add separator line after header if enabled
    if helpers_config.settings.display.show_separator_lines then
        table.insert(lines, string.rep('-', max_line_length))
    end

    -- Update the display timestamp
    last_display_update = os.date("%H:%M:%S")
    
    -- Get cache timestamp from party helper
    local cache_time = helpers_party.get_last_cache_update()
    
    -- Add the two new timestamp lines with right-alignment using existing max_line_length
    if helpers_config.settings.display.show_cache_timestamp then
        local cache_line = format_timestamp_line("Cache Updated: ", cache_time, max_line_length)
        table.insert(lines, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.timestamp)..')%s\\cr', cache_line))
    end
    
    if helpers_config.settings.display.show_display_timestamp then
        local display_line = format_timestamp_line("Display Updated: ", last_display_update, max_line_length)
        table.insert(lines, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.timestamp)..')%s\\cr', display_line))
    end

    -- Add separator line after timestamps if enabled and timestamps were shown
    if helpers_config.settings.display.show_separator_lines and 
       (helpers_config.settings.display.show_cache_timestamp or helpers_config.settings.display.show_display_timestamp) then
        table.insert(lines, string.rep('-', max_line_length))
    end
    
    -- Build column headers
    local header_parts = {}
    if helpers_config.settings.columns.position then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..position_column_width..'s\\cr', 'Pos.'))
    end
    if helpers_config.settings.columns.party_member_distance then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..member_distance_column_width..'s\\cr', 'Dist.'))
    end
    if helpers_config.settings.columns.character_name then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..character_name_column_width..'s\\cr', 'Character'))
    end
    if helpers_config.settings.columns.state then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..state_column_width..'s\\cr', 'State'))
    end
    if helpers_config.settings.columns.target_name then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..target_name_column_width..'s\\cr', 'Target'))
    end
    if helpers_config.settings.columns.target_distance then
        table.insert(header_parts, string.format('\\cs('..helpers_utils.color_to_string(helpers_config.settings.colors.header)..')%-'..target_distance_column_width..'s\\cr', 'Dist.'))
    end
    
    -- Join headers with appropriate dividers
    local column_divider = helpers_config.settings.display.use_column_dividers and ' | ' or ' '
    local header = table.concat(header_parts, column_divider)
    table.insert(lines, header)

    -- Build data rows for each party member
    for _, formatted_row_data in ipairs(formatted_member_data) do
        local line_parts = {}
        
        -- Add each enabled column with proper formatting and coloring
        if helpers_config.settings.columns.position then
            table.insert(line_parts, string.format('%-'..position_column_width..'s', formatted_row_data.member_position))
        end
        if helpers_config.settings.columns.party_member_distance then
            local raw_distance = formatted_row_data.member_distance
            local formatted_distance = string.format('%'..member_distance_column_width..'s', raw_distance)
            table.insert(line_parts, string.format('\\cs('..formatted_row_data.member_distance_color..')%s\\cr', formatted_distance))
        end
        if helpers_config.settings.columns.character_name then
            local raw_name = formatted_row_data.member_name
            local formatted_name = string.format('%-'..character_name_column_width..'s', raw_name)
            table.insert(line_parts, string.format('\\cs('..formatted_row_data.member_name_color..')%s\\cr', formatted_name))
        end
        if helpers_config.settings.columns.state then
            local raw_state = formatted_row_data.member_state
            local formatted_state = string.format('%-'..state_column_width..'s', raw_state)
            table.insert(line_parts, string.format('\\cs('..formatted_row_data.member_state_color..')%s\\cr', formatted_state))
        end
        if helpers_config.settings.columns.target_name then
            local raw_target = formatted_row_data.target_name
            local formatted_target = string.format('%-'..target_name_column_width..'s', raw_target)
            table.insert(line_parts, string.format('\\cs('..formatted_row_data.target_name_color..')%s\\cr', formatted_target))
        end
        if helpers_config.settings.columns.target_distance then
            local raw_target_distance = formatted_row_data.target_distance
            local formatted_target_distance = string.format('%'..target_distance_column_width..'s', raw_target_distance)
            table.insert(line_parts, string.format('\\cs('..formatted_row_data.target_distance_color..')%s\\cr', formatted_target_distance))
        end
        
        -- Join row data with appropriate dividers
        local line = table.concat(line_parts, column_divider)
        table.insert(lines, line)
    end

    -- Add bottom separator line if enabled
    if helpers_config.settings.display.show_separator_lines then
        table.insert(lines, string.rep('-', max_line_length))
    end
    
    -- Update display with formatted text and show it
    helpers_display.display:text(table.concat(lines, '\n'))
    --helpers_display.display:text(table.concat(lines, '\n'):gsub(" ", ".")) -- Replace spaces with dots for alignment check
    helpers_display.display:show()
end

-- Add getter function for display timestamp
function helpers_display.get_last_display_update()
    return last_display_update or "Never"
end

return helpers_display