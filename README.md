# PartyInfoBox

A comprehensive party information display addon for Final Fantasy XI (FFXI) using Windower.

## Overview

PartyInfoBox provides real-time tracking and display of party member information including positions, distances, states, and targets. It's designed to help players coordinate better with their party members during gameplay.

## Features

### Core Functionality
- **Real-time Party Tracking**: Monitors main party (P1) and alliance parties (A1, A2)
- **Distance Calculations**: Shows distances between player and party members
- **Character State Detection**: Displays member states (idle, moving, engaged, resting, etc.)
- **Target Tracking**: Shows what each party member is targeting
- **Target Distance**: Calculates distances to party member targets
- **Customizable Display**: Enable/disable specific columns and parties

### Display Options
- **Configurable Columns**: Position, Party Distance, Character Name, State, Target, Target Distance
- **Visual Customization**: Toggle headers, separators, and column dividers
- **Color Coding**: Distance-based coloring and state-specific colors
- **Focus Control**: Hide/show based on game window focus

### Demo Mode
- **Testing Environment**: Generate fake party data for configuration
- **Safe Configuration**: Test display settings without requiring actual party
- **Realistic Simulation**: Random states, targets, and movement patterns

## Installation

1. Download the PartyInfoBox addon
2. Extract to your Windower addons directory:
   ```
   Windower/addons/PartyInfoBox/
   ```
3. Load the addon in-game:
   ```
   //lua load PartyInfoBox
   ```

## Commands

All commands use the format: `//partyinfobox <command>` or `//pib <command>`

### Basic Commands
- `//pib show` - Show the display
- `//pib hide` - Hide the display
- `//pib toggle` - Toggle display visibility
- `//pib save` - Save current settings
- `//pib reload` - Reload the addon

### Demo Mode
- `//pib demo` - Toggle demo mode
- `//pib demo on` - Enable demo mode
- `//pib demo off` - Disable demo mode
- `//pib demo refresh` - Refresh demo data

### Party Control
- `//pib parties` - Show party status
- `//pib party <name> [on/off/toggle]` - Control parties
  - Party names: `p1` (main), `a1` (alliance1), `a2` (alliance2)

### Column Control
- `//pib columns` - Show column status
- `//pib column <name> [on/off/toggle]` - Control columns
  - Column names: `pos`, `pdist`, `char`, `state`, `target`, `tdist`

### Display Settings
- `//pib header [on/off/toggle]` - Control addon header
- `//pib separators [on/off/toggle]` - Control separator lines
- `//pib dividers [on/off/toggle]` - Control column dividers
- `//pib display` - Show current display settings

### Focus Settings
- `//pib focus` - Show focus settings
- `//pib focus updates [on/off/toggle]` - Require focus for updates
- `//pib focus hide [on/off/toggle]` - Hide when not focused

## Column Descriptions

| Column | Name | Description |
|--------|------|-------------|
| **pos** | Position | Party position (P1-1, A1-2, etc.) |
| **pdist** | Party Distance | Distance from player to party member |
| **char** | Character | Party member's character name |
| **state** | State | Current activity (idle, moving, engaged, etc.) |
| **target** | Target | What the party member is targeting |
| **tdist** | Target Distance | Distance from player to the target |

## Configuration

Settings are automatically saved to `PartyInfoBox_settings.xml` in your character's data folder.

### Key Settings
- **Parties**: Enable/disable P1, A1, A2 tracking
- **Columns**: Control which information columns to display
- **Display**: Header, separators, dividers, position, colors
- **Focus**: Window focus behavior
- **Timing**: Update frequencies and delays

## Color Coding

### Character States
- **Idle**: Default color for standing characters
- **Moving**: Characters currently in motion
- **Engaged**: Characters in combat
- **Dead**: Knocked out characters
- **Resting**: Characters sitting/resting
- **Other States**: Fishing, crafting, events, etc.

### Target Colors
- **Unclaimed**: Available monsters
- **Player Claimed**: Claimed by you
- **Party Claimed**: Claimed by party member
- **Alliance Claimed**: Claimed by alliance member
- **Other Claimed**: Claimed by other players

### Distance Colors
- **Close**: Very near (green)
- **Medium**: Moderate distance (yellow)
- **Far**: Distant (orange)
- **Very Far**: Very distant (red)

## Architecture

The addon uses a modular helper system:

- **helpers/config.lua**: Settings and configuration management
- **helpers/display.lua**: Text overlay rendering and formatting
- **helpers/party.lua**: Party data collection and caching
- **helpers/utils.lua**: Utility functions for calculations
- **helpers/events.lua**: Event handling and update logic
- **helpers/commands.lua**: Chat command processing
- **helpers/demo.lua**: Demo mode simulation
- **helpers/addToChat.lua**: Chat message formatting

## Performance

- **Efficient Updates**: Only updates when data changes
- **Focus Optimization**: Optional focus-based updating
- **Cached Data**: Prevents redundant game data queries
- **Configurable Frequency**: Adjustable update intervals

## Troubleshooting

### Display Not Showing
1. Check if any parties are enabled: `//pib parties`
2. Check if any columns are enabled: `//pib columns`
3. Try toggling display: `//pib toggle`
4. Enable demo mode for testing: `//pib demo on`

### No Party Data
1. Ensure you're in a party
2. Try refreshing: `//pib refresh`
3. Check enabled parties: `//pib parties`
4. Reload addon: `//pib reload`

### Settings Not Saving
1. Manually save: `//pib save`
2. Check file permissions in Windower data folder
3. Reload addon: `//pib reload`

## Version History

### v1.0.0
- Initial release
- Core party tracking functionality
- Demo mode implementation
- Comprehensive command system
- Configurable display options

## License

Copyright © 2025, Xenodeus. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of PartyInfoBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL XENODEUS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Screenshots

### Main Display
# PartyInfoBox

A comprehensive party information display addon for Final Fantasy XI (FFXI) using Windower.

## Overview

PartyInfoBox provides real-time tracking and display of party member information including positions, distances, states, and targets. It's designed to help players coordinate better with their party members during gameplay.

## Features

### Core Functionality
- **Real-time Party Tracking**: Monitors main party (P1) and alliance parties (A1, A2)
- **Distance Calculations**: Shows distances between player and party members
- **Character State Detection**: Displays member states (idle, moving, engaged, resting, etc.)
- **Target Tracking**: Shows what each party member is targeting
- **Target Distance**: Calculates distances to party member targets
- **Customizable Display**: Enable/disable specific columns and parties

### Display Options
- **Configurable Columns**: Position, Party Distance, Character Name, State, Target, Target Distance
- **Visual Customization**: Toggle headers, separators, and column dividers
- **Color Coding**: Distance-based coloring and state-specific colors
- **Focus Control**: Hide/show based on game window focus

### Demo Mode
- **Testing Environment**: Generate fake party data for configuration
- **Safe Configuration**: Test display settings without requiring actual party
- **Realistic Simulation**: Random states, targets, and movement patterns

## Installation

1. Download the PartyInfoBox addon
2. Extract to your Windower addons directory:
   ```
   Windower/addons/PartyInfoBox/
   ```
3. Load the addon in-game:
   ```
   //lua load PartyInfoBox
   ```

## Commands

All commands use the format: `//partyinfobox <command>` or `//pib <command>`

### Basic Commands
- `//pib show` - Show the display
- `//pib hide` - Hide the display
- `//pib toggle` - Toggle display visibility
- `//pib save` - Save current settings
- `//pib reload` - Reload the addon

### Demo Mode
- `//pib demo` - Toggle demo mode
- `//pib demo on` - Enable demo mode
- `//pib demo off` - Disable demo mode
- `//pib demo refresh` - Refresh demo data

### Party Control
- `//pib parties` - Show party status
- `//pib party <name> [on/off/toggle]` - Control parties
  - Party names: `p1` (main), `a1` (alliance1), `a2` (alliance2)

### Column Control
- `//pib columns` - Show column status
- `//pib column <name> [on/off/toggle]` - Control columns
  - Column names: `pos`, `pdist`, `char`, `state`, `target`, `tdist`

### Display Settings
- `//pib header [on/off/toggle]` - Control addon header
- `//pib separators [on/off/toggle]` - Control separator lines
- `//pib dividers [on/off/toggle]` - Control column dividers
- `//pib display` - Show current display settings

### Focus Settings
- `//pib focus` - Show focus settings
- `//pib focus updates [on/off/toggle]` - Require focus for updates
- `//pib focus hide [on/off/toggle]` - Hide when not focused

## Column Descriptions

| Column | Name | Description |
|--------|------|-------------|
| **pos** | Position | Party position (P1-1, A1-2, etc.) |
| **pdist** | Party Distance | Distance from player to party member |
| **char** | Character | Party member's character name |
| **state** | State | Current activity (idle, moving, engaged, etc.) |
| **target** | Target | What the party member is targeting |
| **tdist** | Target Distance | Distance from player to the target |

## Configuration

Settings are automatically saved to `PartyInfoBox_settings.xml` in your character's data folder.

### Key Settings
- **Parties**: Enable/disable P1, A1, A2 tracking
- **Columns**: Control which information columns to display
- **Display**: Header, separators, dividers, position, colors
- **Focus**: Window focus behavior
- **Timing**: Update frequencies and delays

## Color Coding

### Character States
- **Idle**: Default color for standing characters
- **Moving**: Characters currently in motion
- **Engaged**: Characters in combat
- **Dead**: Knocked out characters
- **Resting**: Characters sitting/resting
- **Other States**: Fishing, crafting, events, etc.

### Target Colors
- **Unclaimed**: Available monsters
- **Player Claimed**: Claimed by you
- **Party Claimed**: Claimed by party member
- **Alliance Claimed**: Claimed by alliance member
- **Other Claimed**: Claimed by other players

### Distance Colors
- **Close**: Very near (green)
- **Medium**: Moderate distance (yellow)
- **Far**: Distant (orange)
- **Very Far**: Very distant (red)

## Architecture

The addon uses a modular helper system:

- **helpers/config.lua**: Settings and configuration management
- **helpers/display.lua**: Text overlay rendering and formatting
- **helpers/party.lua**: Party data collection and caching
- **helpers/utils.lua**: Utility functions for calculations
- **helpers/events.lua**: Event handling and update logic
- **helpers/commands.lua**: Chat command processing
- **helpers/demo.lua**: Demo mode simulation
- **helpers/addToChat.lua**: Chat message formatting

## Performance

- **Efficient Updates**: Only updates when data changes
- **Focus Optimization**: Optional focus-based updating
- **Cached Data**: Prevents redundant game data queries
- **Configurable Frequency**: Adjustable update intervals

## Troubleshooting

### Display Not Showing
1. Check if any parties are enabled: `//pib parties`
2. Check if any columns are enabled: `//pib columns`
3. Try toggling display: `//pib toggle`
4. Enable demo mode for testing: `//pib demo on`

### No Party Data
1. Ensure you're in a party
2. Try refreshing: `//pib refresh`
3. Check enabled parties: `//pib parties`
4. Reload addon: `//pib reload`

### Settings Not Saving
1. Manually save: `//pib save`
2. Check file permissions in Windower data folder
3. Reload addon: `//pib reload`

## Version History

### v1.0.0
- Initial release
- Core party tracking functionality
- Demo mode implementation
- Comprehensive command system
- Configurable display options

## License

Copyright © 2025, Xenodeus. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of PartyInfoBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL XENODEUS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Screenshots

### Main Display
![Main Display](https://xenodeus.github.io/images/PartyInfoBox_example_01.png)
![Main Display 2](https://xenodeus.github.io/images/PartyInfoBox_example_02.png)
