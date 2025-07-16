--[[
Configuration Management Helper

PURPOSE:
Handles all settings, defaults, validation, and persistence for the PartyInfoBox addon.
Provides centralized access to user preferences and system configuration.

RESPONSIBILITIES:
- Define default configuration values
- Load settings from XML file on startup
- Save settings to XML file when changed
- Validate configuration options
- Provide helper functions for common config checks
- Manage color schemes and display formatting options

CONFIGURATION STRUCTURE:
- display: Visual appearance settings (fonts, colors, positioning)
- parties: Which party types to track (main, alliance1, alliance2)
- columns: Which data columns to show in the display
- focus: Window focus behavior settings
- colors: Color schemes for different UI elements
- distance_thresholds: Distance ranges for color coding
- timing: Update frequencies and delays
]]--

local config = require('config')

local helpers_config = {}

-- Configuration defaults - these are the fallback values if no config file exists
helpers_config.defaults = {
    -- Display appearance settings
    display = {
        pos = {x = 100, y = 100},           -- Default position on screen
        font = 'Consolas',                  -- Monospace font for alignment
        size = 10,                          -- Font size
        padding = 8,                        -- Padding around text
        bg_alpha = 150,                     -- Background transparency (0-255)
        stroke_width = 2,                   -- Text outline width
        stroke_alpha = 255,                 -- Text outline opacity
        text_color = {red = 150, green = 150, blue = 150}, -- Default text color (RGB)
        flags = {draggable = true, bold = true}, -- Display properties
        show_separator_lines = true,        -- Enable/disable horizontal separator lines
        use_column_dividers = true,         -- Use ' | ' between columns, or just ' ' if false
        show_addon_header = true,           -- Show/hide the addon name header
        show_cache_timestamp = false,       -- Show cache update timestamp
        show_display_timestamp = false      -- Show display update timestamp
    },
    
    -- Update and formatting settings
    update_frequency = 1,                   -- How often to update display (seconds)
    distance_format = '%.2f',               -- Format for target distances
    member_distance_format = '%.2f',        -- Format for party member distances
    
    -- Distance thresholds for target color coding
    distance_thresholds = {
        close = 5,      -- Green: very close targets
        medium = 15,    -- Yellow: medium distance targets
        far = 20        -- Orange: far targets (red for very far)
    },
    
    -- Distance thresholds for party member color coding
    member_distance_thresholds = {
        close = 10,     -- Green: close party members
        medium = 25,    -- Yellow: medium distance party members
        far = 45        -- Orange: far party members (red for very far)
    },
    
    -- Which parties to display
    parties = {
        party = true,           -- Main party (P1)
        alliance1 = true,       -- Alliance party 1 (A1)
        alliance2 = true        -- Alliance party 2 (A2)
    },
    
    -- Which columns to show in the display
    columns = {
        position = true,                -- Show position column [P1-1], [A1-2], etc.
        party_member_distance = true,   -- Show distance to party members
        character_name = true,          -- Show character names
        state = true,                   -- Show character states (idle, engaged, etc.)
        target_name = true,             -- Show target names
        target_distance = true          -- Show distance to targets
    },
    
    -- Window focus behavior settings
    focus = {
        require_focus_for_update = true,   -- Only update when FFXI window is focused
        hide_when_not_focused = true        -- Hide display when FFXI window loses focus
    },
    
    -- Color scheme for different elements
    colors = {
        -- Header and UI colors
        header = {red = 100, green = 150, blue = 255},      -- Header text color (light blue)
        default_grey = {red = 128, green = 128, blue = 128}, -- Default/unknown items (medium gray)
        timestamp = {red = 128, green = 128, blue = 128},  -- Default gray for timestamps
        
        -- Target claim status colors
        dead_target = {red = 155, green = 155, blue = 155},         -- Dead targets (light gray)
        player_claimed = {red = 255, green = 130, blue = 130},      -- Player or party claimed (light red/pink)
        alliance_claimed = {red = 255, green = 142, blue = 205},    -- Alliance claimed (light pink/magenta)
        party_member = {red = 102, green = 255, blue = 255},        -- Party member targets (cyan)
        player = {red = 255, green = 255, blue = 255},              -- Other players (white)
        npc = {red = 150, green = 225, blue = 150},                 -- Friendly NPCs (light green)
        unclaimed_mob = {red = 230, green = 230, blue = 138},       -- Unclaimed monsters (light yellow)
        other_claimed = {red = 153, green = 102, blue = 255},       -- Other player claimed (light purple)
        
        -- Target distance colors (how far targets are from party members)
        distance_close = {red = 0, green = 255, blue = 0},          -- Very close targets (bright green)
        distance_medium = {red = 255, green = 255, blue = 0},       -- Medium distance targets (yellow)
        distance_far = {red = 255, green = 128, blue = 0},          -- Far targets (orange)
        distance_very_far = {red = 255, green = 0, blue = 0},       -- Very far targets (red)
        
        -- Party member distance colors (how far party members are from party members)
        member_distance_close = {red = 50, green = 255, blue = 50},       -- Close party members (bright green)
        member_distance_medium = {red = 255, green = 255, blue = 50},     -- Medium distance party members (bright yellow)
        member_distance_far = {red = 255, green = 150, blue = 50},        -- Far party members (orange-yellow)
        member_distance_very_far = {red = 255, green = 50, blue = 50},    -- Very far party members (bright red)
        
        -- Character state colors
        state_idle = {red = 128, green = 128, blue = 128},          -- Standing idle (medium gray)
        state_moving = {red = 100, green = 200, blue = 100},        -- Moving/walking (green)
        state_engaged = {red = 255, green = 100, blue = 100},       -- In combat (red)
        state_dead = {red = 64, green = 64, blue = 64},             -- Dead/unconscious (dark gray)
        state_mount = {red = 255, green = 255, blue = 100},         -- On mount (stationary) (bright yellow)
        state_riding = {red = 200, green = 255, blue = 100},        -- Riding/moving on mount (yellow-green)
        state_resting = {red = 100, green = 150, blue = 255},       -- Resting for MP/HP (light blue)
        state_sitting = {red = 150, green = 150, blue = 200},       -- Sitting (light blue-gray)
        state_kneeling = {red = 150, green = 150, blue = 200},      -- Kneeling (light blue-gray)
        state_crafting = {red = 200, green = 150, blue = 100},      -- Crafting (tan/brown)
        state_fishing = {red = 100, green = 200, blue = 255},       -- Fishing (light cyan)
        state_event = {red = 255, green = 200, blue = 100},         -- In cutscene/event (light orange)
        state_other = {red = 200, green = 100, blue = 200}          -- Other/unknown states (light purple)
    },
    
    -- Timing settings for various operations
    timing = {
        party_update_delay = 1,     -- Delay before updating party cache (seconds)
        login_delay = 5             -- Delay before initializing after login (seconds)
    },
    
    -- Default display values when data is unavailable
    default_values = {
        target_name = '--',                 -- Show when no target
        distance = '--',                    -- Show when distance unavailable
        member_distance = '--'              -- Show when party member distance unavailable
    }
}

-- Internal settings storage - holds the current configuration
helpers_config.settings = nil

-- Load settings from file - reads user configuration from XML
function helpers_config.load_settings()
    helpers_config.settings = config.load(helpers_config.defaults)
    return helpers_config.settings
end

-- Save settings to file - writes current configuration to XML
function helpers_config.save_settings(display)
    -- Save current display position if provided
    if display then
        helpers_config.settings.display.pos.x, helpers_config.settings.display.pos.y = display:pos()
    end
    config.save(helpers_config.settings)
end

-- Reload settings from file - re-reads configuration from XML
function helpers_config.reload_settings()
    helpers_config.settings = config.load(helpers_config.defaults)
    return helpers_config.settings
end

-- Get settings reference (for read-only access) - returns current config
function helpers_config.get_settings()
    return helpers_config.settings
end

-- Update specific setting - changes a config value by path
function helpers_config.update_setting(path, value)
    local current = helpers_config.settings
    local keys = {}
    
    -- Parse the path (e.g., "display.show_addon_header" -> {"display", "show_addon_header"})
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end
    
    -- Navigate to the parent table
    for i = 1, #keys - 1 do
        if current[keys[i]] then
            current = current[keys[i]]
        else
            return false -- Invalid path
        end
    end
    
    -- Set the value
    current[keys[#keys]] = value
    return true
end

-- Get specific setting value - retrieves a config value by path
function helpers_config.get_setting(path)
    local current = helpers_config.settings
    
    -- Parse the path
    for key in string.gmatch(path, "[^%.]+") do
        if current[key] then
            current = current[key]
        else
            return nil -- Invalid path
        end
    end
    
    return current
end

-- Check if any columns are enabled for display - determines if display should show
function helpers_config.any_columns_enabled()
    for _, enabled in pairs(helpers_config.settings.columns) do
        if enabled then
            return true
        end
    end
    return false
end

-- Count how many columns are enabled (for layout calculations) - used for display width
function helpers_config.count_enabled_columns()
    local count = 0
    for _, enabled in pairs(helpers_config.settings.columns) do
        if enabled then
            count = count + 1
        end
    end
    return count
end

-- Check if any parties are enabled for display - determines if tracking should occur
function helpers_config.any_parties_enabled()
    for _, enabled in pairs(helpers_config.settings.parties) do
        if enabled then
            return true
        end
    end
    return false
end

-- Count how many parties are enabled - used for party processing
function helpers_config.count_enabled_parties()
    local count = 0
    for _, enabled in pairs(helpers_config.settings.parties) do
        if enabled then
            count = count + 1
        end
    end
    return count
end

return helpers_config