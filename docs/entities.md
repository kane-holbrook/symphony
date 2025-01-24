# Setting
Every type can have settings attributed. These are arbitrary keyvalue pairs.

* Key: The name of the setting
* Scope: global|server|user|character|faction|entity
* Type
* Value
* Default
* Permission: The permission needed to change/view it.


# Location
* ID
* Title
* Parent
* Map
* Entities<*>
  * Chunk
    * Type: Physical, Infmap, Procedural, Map
  * Skybox
  * Ent
  * SymObject
  * NPC
  * Sound
  * Rematerial
  * Trigger
    * Event
    * Sound
    * PostProcessing
    * Scene

# Scene
* Timeline<time, *>
    * Lua
    * EntFire
    * 2D
      * Animation
    * Camera
    * NPC
    * Physics
    * Scene<self>
    * Sound

# Character
An individual character.

* ID: UUID
* Name: Their name
* Faction: What faction they belong to.


# Usergroup
* ID: UUID
* Parent: UUID
* Name
* Type: Faction, Usergroup, CharacterGroup
* Permissions[]
* Roles[]
  * Name
  * Permissions[]
* GetMembers()

    # Faction
    * Image
    * Owner
    * Settings?
    * Models[]
    * Roles
    * Icon
    * Models[]


# Appearance
* Model
* Items[]
    * Materials