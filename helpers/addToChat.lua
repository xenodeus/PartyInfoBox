--[[
Chat Message Helper

PURPOSE:
Provides standardized chat output functions for the PartyInfoBox addon.
Handles different message types with appropriate colors and formatting.

RESPONSIBILITIES:
- Display informational messages to chat
- Show warning messages in appropriate colors
- Display error messages with red coloring
- Show success messages with green coloring
- Format messages with consistent addon name prefixes
- Allow hiding addon name when needed for cleaner output

MESSAGE TYPES:
- Info messages: Standard informational text (color 8)
- Warning messages: Orange colored warnings (color 208)
- Error messages: Red colored errors (color 123)
- Success messages: Green colored success text (color 158)

FORMATTING:
- Addon name prefix: [PartyInfoBox] in yellow (color 220)
- Optional hiding of addon name for cleaner multi-line output
- Consistent color coding across all message types
]]--

local helpers_chat = {}

-- Display normal informational messages
function helpers_chat.add_info_to_chat(message, hide_addon_name)
    local formatted_message = message
    if not hide_addon_name then
        formatted_message = ('['.._addon.name..']'):color(220)..' ' .. message
    end
    windower.add_to_chat(8, formatted_message)
end

-- Display warning messages in orange
function helpers_chat.add_warning_to_chat(message, hide_addon_name)
    local formatted_message = message
    if not hide_addon_name then
        formatted_message = ('['.._addon.name..']'):color(220)..' ' .. message
    end
    windower.add_to_chat(208, formatted_message)  -- Orange color
end

-- Display error messages in red
function helpers_chat.add_error_to_chat(message, hide_addon_name)
    local formatted_message = message
    if not hide_addon_name then
        formatted_message = ('['.._addon.name..']'):color(220)..' ' .. message
    end
    windower.add_to_chat(123, formatted_message)  -- Red color
end

-- Display success messages in green
function helpers_chat.add_success_to_chat(message, hide_addon_name)
    local formatted_message = message
    if not hide_addon_name then
        formatted_message = ('['.._addon.name..']'):color(220)..' ' .. message
    end
    windower.add_to_chat(158, formatted_message)  -- Green color
end

return helpers_chat