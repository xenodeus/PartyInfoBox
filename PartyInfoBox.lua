--[[
Copyright © 2025, Xenodeus
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PartyInfoBox nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Xenodeus BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

--[[
PartyInfoBox: A comprehensive party information display addon for FFXI

MAIN FEATURES:
- Real-time party member position tracking (P1, A1, A2)
- Distance calculations between player and party members
- Character state detection (idle, moving, engaged, resting, etc.)
- Target tracking for all party members
- Distance calculations to targets
- Customizable column display options
- Demo mode for testing and configuration
- Focus-based update control

ARCHITECTURE:
This is the main entry point that coordinates all functionality through helper modules.
The helper pattern provides clean separation of concerns:
- helpers_config: Settings and configuration management
- helpers_display: Text overlay rendering and formatting
- helpers_party: Party data collection and caching
- helpers_utils: Utility functions for calculations and checks
- helpers_events: Event handling and update logic
- helpers_commands: Chat command processing
- helpers_demo: Demo mode simulation
- helpers_chat: Chat message formatting

GLOBAL STATE:
- player_id: Current player's unique identifier
- demo_mode: Whether the addon is in demo/test mode
]]--

-- Addon metadata - Required by Windower for addon registration
_addon.name = 'PartyInfoBox'
_addon.author = 'Xenodeus'
_addon.version = '1.1.0'
_addon.commands = {'PartyInfoBox', 'pib'}  -- Chat commands that trigger this addon
_addon.shortname = 'pib'                   -- Short form for commands

-- Required Windower libraries - Core functionality provided by Windower
texts = require('texts')        -- For creating text overlay displays
strings = require('strings')    -- For string manipulation and formatting
chat = require('chat')          -- For chat commands and message handling
table = require('table')        -- For table manipulation functions
packets = require('packets')    -- For handling network packet data
res = require('resources')      -- For accessing game resource data (spells, items, etc.)

-- Required helper modules - Custom modules that handle specific functionality
helpers_config = require('helpers/config')         -- Settings management and validation
helpers_chat = require('helpers/addToChat')        -- Chat message formatting and output
helpers_commands = require('helpers/commands')     -- Command parsing and execution
helpers_events = require('helpers/events')         -- Event registration and handling
helpers_demo = require('helpers/demo')             -- Demo mode data generation
helpers_party = require('helpers/party')           -- Party data collection and caching
helpers_utils = require('helpers/utils')           -- Utility functions for calculations
helpers_display = require('helpers/display')       -- Display rendering and formatting

-- Global state variables - Accessible by all helpers
player_id = nil                 -- Current player's unique ID (set during login)
demo_mode = false               -- Whether demo mode is active (affects data source)
zoning = false                  -- Whether the player is currently zoning (affects display updates)

-- Initialize the addon
helpers_config.load_settings()  -- Load user configuration from XML file
helpers_events.register_all()   -- Register all event handlers with Windower
