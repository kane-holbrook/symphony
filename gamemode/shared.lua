AddCSLuaFile()
DeriveGamemode("sandbox")

SYMPHONY = true

-- Network
  -- Start
  -- Send
-- Interface
  -- Create
  -- Register
  -- CreateFromXML
  -- RegisterFromXML
  -- CreateTheme
-- Materials
-- Blueprint
  -- Register
  -- Unregister
  -- GetAll
-- Event
-- Debug
  -- Exceptions
  -- Annotate(ent, key, data). If data is a function, run every tick.
-- Permission
  -- Register
-- Usergroup
  -- Register
-- Feature
  -- Register
  -- GetAll
-- Setting
--  Register
--  Unregister
--  Get
--  Set
-- Console
  -- Write

sym = sym or {}

function Benchmark(f, n)
    local s = SysTime()
    n = n or 1
    for i=1, n do
      f()
    end
    print(SysTime() - s)
end

local Logged = {}
function sym.log(type, content, data, time, realm)
    table.insert(Logged, { 
        timestamp = os.date("%Y-%m-%dT%H:%M:%SZ", os.time(os.date("!*t"))),
        realm = realm or "CLIENT",
        type = type,
        content = content,
        data = data
    })
end

function PrintAndReturn(...)
    print("P&R", ...)
    return ...
end


-- Networking

SYM_START_TIME = SysTime()

include("utils.lua")
IncludeEx("lib/containers.lua", Realm.Shared)
IncludeEx("lib/stringex.lua", Realm.Shared)
IncludeEx("lib/mathex.lua", Realm.Shared)
IncludeEx("lib/tablex.lua", Realm.Shared)
IncludeEx("lib/filex.lua", Realm.Shared)
IncludeEx("lib/colorex.lua", Realm.Shared)
IncludeEx("lib/uuid.lua", Realm.Shared)
IncludeEx("lib/materialex.lua", Realm.Shared)
IncludeEx("lib/drawex.lua", Realm.Shared)
IncludeEx("lib/xvgui/xvgui.lua", Realm.Shared)
xml2lua = IncludeEx("lib/xml2lua/xml2lua.lua", Realm.Shared)
neonate = IncludeEx("lib/neonate.lua", Realm.Shared)
Circles = IncludeEx("lib/circles.lua", Realm.Shared)
RNDX = IncludeEx("lib/rndx.lua", Realm.Shared)

-- core/sh_database.lua
IncludeEx("core/sh_net.lua", Realm.Shared)
IncludeEx("core/sh_types.lua", Realm.Shared)
IncludeEx("types/framework/event.lua", Realm.Shared)
IncludeEx("types/framework/proxy.lua", Realm.Shared)
IncludeEx("types/framework/primitives.lua", Realm.Shared)
IncludeEx("types/framework/promise.lua", Realm.Shared)
IncludeEx("types/framework/rpc.lua", Realm.Shared)
IncludeEx("types/framework/collections.lua", Realm.Shared)
IncludeEx("types/framework/datetime.lua", Realm.Shared)
IncludeEx("core/sv_database.lua", Realm.Server)
IncludeEx("core/sh_tests.lua", Realm.Shared)

IncludeEx("interface/interface_v3.lua", Realm.Shared)

--IncludeEx("views/setup/shared.lua", Realm.Shared)
--IncludeEx("interface/interface_v2.lua", Realm.Shared)
--[[IncludeEx("derma/window.lua", Realm.Shared)
IncludeEx("derma/scroll.lua", Realm.Shared)
IncludeEx("derma/button.lua", Realm.Shared)
IncludeEx("derma/textbox.lua", Realm.Shared)
IncludeEx("derma/checkbox.lua", Realm.Shared)
IncludeEx("derma/radio.lua", Realm.Shared)
IncludeEx("derma/popover.lua", Realm.Shared)
IncludeEx("derma/tooltip.lua", Realm.Shared)
IncludeEx("derma/picklist.lua", Realm.Shared)
IncludeEx("derma/slider.lua", Realm.Shared)
IncludeEx("derma/colorpicker.lua", Realm.Shared)--]]

--IncludeEx("views/intro/intro.lua", Realm.Shared) --]]
--IncludeEx("views/settings/settings.lua", Realm.Shared)




-- gma.lua
gma = {}

local function writeCString(f, s)
    f:Write(s)
    f:Write("\0")
end

--- Writes a GMA archive to disk
-- @param name string
-- @param description string
-- @param author string
-- @param version integer
-- @param files table: { {filename=string, size=int, data=string}, ... }
-- @param out_path string
function gma.create(name, description, author, version, type, tags, files, out_path)
    assert(name and description and author and version and files and type and tags and out_path, "Missing parameters")

    local f = file.Open(out_path, "wb", "DATA")

    -- From https://erysdren.me/docs/gma/
    
    f:Write("GMAD") -- Magic - 0x00
    f:WriteByte(3) -- Version - 0x04
    f:WriteUInt64(0) -- Steam ID - 0x05
    f:WriteUInt64(os.time()) -- Addon creation timestamp - 0x0D
    f:WriteByte(0) -- Padding

    writeCString(f, name)
    writeCString(f, util.TableToJSON( { description = description, type = type, tags = tags }, true  ))
    writeCString(f, author)
    f:WriteLong(version)

    local idx = 1
    for k, v in pairs(files) do
      f:WriteLong(idx)
      writeCString(f, k)
      f:WriteUInt64(#v)
      f:WriteLong(util.CRC(v))
      idx = idx + 1
    end

    f:WriteByte(0)

    for k, v in pairs(files) do
        f:Write(v)
    end
    f:Flush()

    local crc = util.CRC(file.Read(out_path, "DATA"))
    f:WriteLong(crc) -- CRC32 of the file data
    f:Close()
    return true
end


-- You must pre-load all file data manually
local files = {
  ["lua/test.lua"] = "Hello world!"
}

gma.create(
    "Starship Troopers RP | sstrp.net",
    "Description",
    "Author Name",
    1,
    "servercontent",
    {"roleplay"},
    files,
    "my_cool_addon.gma"
)




print("___LOAD____")


