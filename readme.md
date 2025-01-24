# What is Symphony?
Symphony is a Garry's Mod framework for creating (primarily serious text-based roleplay) gamemodes. It has been built primarily with flexibility in mind, with the ultimate goal that the look and feel of the gamemode should be fully customizable by non-developer power users...

## Goals
Build a framework that
- Performs at scale
- Allows non-developer power users to customize the look and feel to fit their server's theme.
- Simplifies via abstraction and/or solves common GMod limitations for developers.
- Provides new functionality and utilities to developers to enable them to build richer content.

## Questions
- Blueprints?
- Should I make worlds intrinsic to Symphony? Yes.
- XServer OOTB?

- World
  - Map
    - sym_infmap: Defines the volume of the infmap playerspace.
    - sym_infmap_chunk: Defines a space accessible from within the infmap.
      - Chunk X
      - Chunk Y
      - Chunk W
      - Chunk H
    - Entity:Fire("SetChunkX", x)
    - Entity:Fire("SetChunkY", y)
  - Objects
    - Entities
    - Virtuals
      - Materials
      - Chunks
      - Sounds
      - Skybox
      - Triggers

## Structure
- gamemodes/symphony: Core functionality
- gamemodes/sstrp: Specific schema.

## Phase 1: Framework
- Types
  - OOP ✓
  - Networking
    - By PVS
    - HTTP Payloading?
  - Databasing
  - Parenting
  - Common
    - Promises
    - Events
    - Proxies
    - Primitives
    - Settings
- RPC
- UI
  - XML ✓
  - SymPanel ✓ 
  - Common 
    - Label ✓
    - Image
    - Header
    - Button
      - HeaderButton
      - GlassButton
    - Textbox
    - Textarea
    - Select
    - Select-Single
      - Radio
    - Select-Multiple
      - Checkbox
    - Toggle
    - ColorPicker
    - Slider
    - Typeahead
    - Popover
      - ContextMenu
      - Tooltip
- Debug tools
  - Console: Quickly find the debug information I'm looking for.
  - Performance monitor: See the bottlenecks.
    - FPS
    - Hooks
    - Entities/objects
    - Tick/framerate
    - Memory
    - Net
    - Edicts
    - As a budget!
  - Exception handling: Quickly identify problems and why they are happening.
  - Unit testing: Have confidence my code is still working.
  - Object explorer: See a list of objects, their data, and who they are networked to.
  - Debug helpers:
    - Lines: See links
    - Boxes: See volumes
    - Spheres: See radiuses
    - Heat map
    - 3D Text
    - Pinnable 2D Text

## Phase 2: Roleplay
- Sessions
- Permissions
- Accounts
  - Groups
    - Roles
  - Characters
    - Attributes
    - Appearance
      - Clothes
      - Texture editor
    - Inventory
    - Factions (Type of group)
      - Roles
- Items
- Chat
- Commands
- HUD

## Phase 3: World
- Terrain
  - Heightmap
  - BSP
  - Procedural
  - Cave
  - FGD
- Cosmos
  - Map
  - Bodies
    - Stars
    - Planets
    - Moons
  - Locations on bodies
  - Ships
  - Hypergates
- World creating
  - Soundscapes
  - 3D sounds
  - Scenes
  - World material modification
  - Post processing
  - Skybox
  - NPCs
    - Pathfinding
    - Humanoid
      - Go To
      - Play Animation
      - Attack
      - Breach
      - Find Cover
      - Repeat chain
    - Arachnid
      - Go To
      - Attack
  - Workshop
  - Triggers
  - Mission files

## Phase 4: Artificial Intelligence
- Interacting (chatting) with NPCs
  - Storing memories of previous interactions
  - Triggering actions as above based on interaction(s).
- Game mastering
  - Narrate and provide responses to player actions (injuries, mechanic work, etc)
  - Where apppropriate trigger world events in response to player actions (spawning items, triggering NPCs)
- Tactical AI
  - Command complex tactics and strategies for NPCs (i.e. arachnids) either in response to player actions, or for the purposes of storytelling.
- Storytelling
  - Generate narratively rich and entertaining multi-chapter missions based on an overarching storyline.
  - Amend the storyline to reflect player actions. 

## Design decisions
- There are no plugins.