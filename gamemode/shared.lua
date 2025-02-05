AddCSLuaFile()
DeriveGamemode("sandbox")

SYMPHONY = true

-- Type
-- Database
-- Network
  -- Start
  -- Send
-- Interface
  -- Create
  -- Register
  -- CreateFromXML
  -- RegisterFromXML
  -- CreateTheme
-- Fonts
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

function Benchmark(f)
    local s = SysTime()
    f()
    return SysTime() - s
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
xml2lua = IncludeEx("lib/xml2lua/xml2lua.lua", Realm.Shared)

Circles = IncludeEx("lib/circles.lua", Realm.Shared)

-- core/sh_database.lua
IncludeEx("core/sh_types.lua", Realm.Shared)
IncludeEx("types/framework/event.lua", Realm.Shared)
IncludeEx("types/framework/proxy.lua", Realm.Shared)
IncludeEx("types/framework/primitives.lua", Realm.Shared)
IncludeEx("types/framework/promise.lua", Realm.Shared)
IncludeEx("types/framework/rpc.lua", Realm.Shared)
IncludeEx("types/framework/datetime.lua", Realm.Shared)
IncludeEx("core/sv_database.lua", Realm.Server)
IncludeEx("interface/interface.lua", Realm.Shared)
IncludeEx("core/sh_tests.lua", Realm.Shared)

IncludeEx("views/setup/shared.lua", Realm.Shared)

print("___LOAD____")