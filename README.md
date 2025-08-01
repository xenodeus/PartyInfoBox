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
- **Compass and Direction**: Shows directional indicators and facing direction for party members
- **Customizable Display**: Enable/disable specific columns and parties with custom ordering

### Display Options
- **Configurable Columns**: Position, Party Distance, Character Name, State, Target, Target Distance, Compass Direction, Facing Direction
- **Column Order Management**: Reorder, move, and swap columns with custom arrangements
- **Visual Customization**: Toggle headers, separators, and column dividers
- **Compass Indicators**: Customizable directional icons for all 16 directions (N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW)
- **Data Source Options**: Choose between character or camera positioning for calculations
- **Timestamp Display**: Show cache and display update timestamps
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
- `//pib reload [all]` - Reload the addon (all: reload for all characters)
- `//pib refresh [all] [silent]` - Refresh party data (real mode only)

### Demo Mode
- `//pib demo` - Toggle demo mode
- `//pib demo on` - Enable demo mode
- `//pib demo off` - Disable demo mode
- `//pib demo refresh` - Refresh demo data

### Party Control
- `//pib parties` - Show party status
- `//pib party <name> [on/off/toggle]` - Control parties
  - Party names: `p1`/`party`/`main` (main), `a1`/`alliance1`/`ally1` (alliance1), `a2`/`alliance2`/`ally2` (alliance2)

### Column Control
- `//pib columns` - Show column status
- `//pib column <name> [on/off/toggle]` - Control columns
  - Column names: `pos`/`position`, `pdist`/`partydist`/`party_distance`, `char`/`character`/`name`, `state`/`status`, `target`, `tdist`/`targetdist`/`target_distance`, `compass`, `facing`

### Column Order Management
- `//pib order` - Show current column order
- `//pib order move <column> <position>` - Move column to specific position
- `//pib order swap <column1> <column2>` - Swap two columns
- `//pib order reset` - Reset to default column order

### Compass and Direction Settings
- `//pib compass` - Show compass settings
- `//pib compass icons` - Show current compass icons for all directions
- `//pib compass icon <direction> <icon>` - Set compass icon for direction (N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW)
- `//pib data_source` - Show data source settings
- `//pib data_source compass <character/camera>` - Set compass calculation source
- `//pib data_source target <member/player>` - Set target calculation method

### Display Settings
- `//pib display` - Show current display settings
- `//pib header [on/off/toggle]` - Control addon header
- `//pib separators [on/off/toggle]` - Control separator lines
- `//pib dividers [on/off/toggle]` - Control column dividers
- `//pib cache_timestamp [on/off/toggle]` - Control cache timestamp display
- `//pib display_timestamp [on/off/toggle]` - Control display timestamp display

### Focus Settings
- `//pib focus` - Show focus settings
- `//pib focus update [on/off/toggle]` - Require focus for update
- `//pib focus hide [on/off/toggle]` - Hide when not focused

### Color Customization
- `//pib colors` - Show all color settings
- Color commands (use format: `//pib <color_name> <r> <g> <b>`):
  - `header_color` - Header text color
  - `timestamp_color` - Timestamp text color
  - `npc_color` - NPC target color
  - `unclaimed_color` - Unclaimed mob color
  - `claimed_color` - Other player claimed color
  - `distance_close_color` - Close target distance color
  - `distance_medium_color` - Medium target distance color
  - `distance_far_color` - Far target distance color
  - `distance_very_far_color` - Very far target distance color
  - `member_close_color` - Close party member distance color
  - `member_medium_color` - Medium party member distance color
  - `member_far_color` - Far party member distance color
  - `member_very_far_color` - Very far party member distance color
  - `state_idle_color` - Idle state color
  - `state_moving_color` - Moving state color
  - `state_engaged_color` - Engaged state color
  - `state_dead_color` - Dead state color
  - `state_other_color` - Other states color

### Debug Commands
- `//pib debug party [member]` - Debug party data
- `//pib debug tracked [index]` - Debug tracked party members

## Column Descriptions

| Column | Name | Description |
|--------|------|-------------|
| **pos** | Position | Party position (P1-1, A1-2, etc.) |
| **pdist** | Party Distance | Distance from player to party member |
| **char** | Character | Party member's character name |
| **state** | State | Current activity (idle, moving, engaged, etc.) |
| **target** | Target | What the party member is targeting |
| **tdist** | Target Distance | Distance from party member to their target |
| **compass** | Compass Direction | Directional indicator showing where party member is relative to player |
| **facing** | Facing Direction | Direction the party member is currently facing |

## Configuration

Settings are automatically saved to `PartyInfoBox_settings.xml` in your character's data folder.

### Key Settings
- **Parties**: Enable/disable P1, A1, A2 tracking
- **Columns**: Control which information columns to display and their order
- **Compass**: Customize directional icons and calculation methods
- **Data Sources**: Configure compass and target calculation sources
- **Display**: Header, separators, dividers, timestamps, position, colors
- **Focus**: Window focus behavior
- **Timing**: Update frequencies and delays
- **Colors**: Comprehensive color customization for all elements

### Compass and Direction Settings
- **Compass Icons**: Customize icons for each of the 8 cardinal and intercardinal directions
- **Data Source - Compass**: Choose between character position or camera position for directional calculations
- **Data Source - Target**: Choose between member-based or player-based target distance calculations
- **Column Order**: Fully customizable column arrangement with move, swap, and reset options

## Color Coding

### Character States
- **Idle**: Default color for standing characters
- **Moving**: Characters currently in motion
- **Engaged**: Characters in combat
- **Dead**: Knocked out characters
- **Resting**: Characters sitting/resting
- **Mount/Riding**: Characters on mounts (stationary/moving)
- **Crafting**: Characters crafting items
- **Fishing**: Characters fishing
- **Event**: Characters in cutscenes/events
- **Other States**: Kneeling, sitting, etc.

### Target Colors
- **Unclaimed**: Available monsters
- **Player Claimed**: Claimed by you
- **Party Claimed**: Claimed by party member
- **Alliance Claimed**: Claimed by alliance member
- **Other Claimed**: Claimed by other players
- **Dead Target**: Dead monsters
- **Party Member**: Other party members as targets
- **Player**: Other players as targets
- **NPC**: Friendly NPCs as targets

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

- **Efficient Update**: Only update when data changes
- **Focus Optimization**: Optional focus-based updating
- **Cached Data**: Prevents redundant game data queries
- **Configurable Frequency**: Adjustable update intervals
- **Smart Party Detection**: Automatic updates when party composition changes

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

## Known Issues

### Party Data After Zoning
Sometimes after zoning into certain areas, party data may appear incomplete or missing. This can occur due to packet loss or data conflicts during the zone transition.

**Note:** Improvements in v1.1.1 should reduce this issue, but due to its random nature, it may still occasionally occur.

**Symptoms:**
- Missing party members in display
- Incorrect or outdated party information
- Empty party data despite being in a party

**Solutions:**
- `//pib refresh` - Refresh party data (quickest fix)
- `//pib reload` - Reload the entire addon (more thorough)

This issue is typically temporary and resolves itself with the above commands.

## Changelog

### v1.2.0
- **NEW**: Advanced column system with customizable order and display control
- **NEW**: Compass and directional indicators for party members and targets
- **NEW**: Facing direction tracking for party members
- **NEW**: Data source configuration system for compass and target calculations
- **NEW**: Customizable compass icons for all 8 directions (N, NE, E, SE, S, SW, W, NW)
- **NEW**: Column order management with move, swap, and reset commands
- **NEW**: Extensive command aliases and shortcuts for easier usage
- **NEW**: Migration system for upgrading settings from older versions
- **NEW**: Enhanced data source options (character vs camera positioning)
- **NEW**: Target calculation methods (member-based vs player-based)
- **ENHANCED**: Massive command system expansion with 390+ lines of new functionality
- **ENHANCED**: Complete display engine overhaul with 450+ lines of rendering improvements
- **ENHANCED**: Configuration system with 270+ lines of new settings management
- **ENHANCED**: Utility functions with 195+ lines of additional calculations
- **ENHANCED**: Column management with enabled/disabled states and custom headers
- **ENHANCED**: Help system with comprehensive command documentation
- **ENHANCED**: Debug commands for party data and tracked member inspection
- **ENHANCED**: Data source controls for compass and distance calculations
- **IMPROVED**: Command parsing with extensive alias support
- **IMPROVED**: Settings validation and migration handling
- **IMPROVED**: Display formatting with compass and directional data
- **IMPROVED**: Color system integration with new column types
- **IMPROVED**: Configuration persistence and backward compatibility

### v1.1.1
- **FIXED**: Improved party data handling after zoning to reduce incomplete data issues
- **ENHANCED**: Better packet loss recovery mechanisms during zone transitions
- **IMPROVED**: More robust party data refresh logic to handle data conflicts

### v1.1.0
- **NEW**: Comprehensive color customization system with RGB controls
- **NEW**: Timestamp display options (cache and display update times)
- **NEW**: Enhanced command system with multi-party reload/refresh (`all` parameter)
- **NEW**: Silent refresh option for batch operations
- **NEW**: Debug commands for troubleshooting party data
- **NEW**: Expanded party name aliases (main, ally1, ally2, etc.)
- **NEW**: Expanded column name aliases for easier command usage
- **ENHANCED**: Movement detection system with position tracking
- **ENHANCED**: State detection for mounts, crafting, fishing, events
- **ENHANCED**: Target type detection and color coding
- **ENHANCED**: Distance threshold customization for both targets and party members
- **ENHANCED**: Display formatting with improved alignment and color support
- **ENHANCED**: Demo mode with more realistic data simulation
- **ENHANCED**: Error handling and user feedback messages
- **IMPROVED**: Performance optimizations for party data caching
- **IMPROVED**: Focus behavior controls for better window management
- **IMPROVED**: Command validation and error messages

### v1.0.0
- Initial release
- Core party tracking functionality
- Demo mode implementation
- Basic command system
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

Customizing example to achieve such view:
- `//pib header off`
- `//pib separators off`
- `//pib dividers off`
- `//pib save`
