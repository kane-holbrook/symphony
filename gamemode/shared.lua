AddCSLuaFile()
DeriveGamemode("sandbox")

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

COL_STD = Color(255, 255, 167)
COL_PRIM = Color(184, 184, 255)
COL_TYPE = Color(255, 208, 1)
PRINT_COL = Color(255, 142, 240)
PRINT_ERROR = Color(255, 100, 100)
PRINT_WARN = Color(252, 255, 68)
PRINT_DEBUG = Color(226, 226, 226)
PRINT_UI = Color(255, 173, 221)
PRINT_NET = Color(93, 244, 255)
PRINT_HTML = Color(251, 255, 0)

MsgC(PRINT_COL, "---------------------------", COL_TYPE, "-----------", PRINT_NET, "--------------------\n")
MsgC("\n")
MsgC(PRINT_COL, [[  ____                ]], COL_TYPE, [[          _]] .. "\n")
MsgC(PRINT_COL, [[ / ___| _   _ _ __ _]], COL_TYPE, [[__    _ __ | |_]], PRINT_NET, [[_   ___  _ __  _   _]] .. "\n")
MsgC(PRINT_COL, [[ \___ \| | | | '_ ]], COL_TYPE, [[` _ \  | '_ \| ]], PRINT_NET, [['_ \ / _ \| '_ \| | | |]] .. "\n")
MsgC(PRINT_COL, [[  ___) | |_| | |]], COL_TYPE, [[ | | | |_| |_) ]], PRINT_NET, [[| | | | (_) | | | | |_| |]] .. "\n")
MsgC(PRINT_COL, [[ |____/ \__, |]], COL_TYPE, [[_| |_| |_(_) ._]], PRINT_NET, [[_/|_| |_|\___/|_| |_|\__, |]] .. "\n")
MsgC(PRINT_COL, [[        |___/            |_|]], PRINT_NET, [[                      |___/]] .. "\n")
MsgC("\n")
MsgC(PRINT_COL, "-----------", COL_TYPE, "-----------", PRINT_NET, "---------------------\n")


MsgC(color_white, os.date("%X"), "|", PRINT_COL, color_white, PRINT_COL, "INFO", color_white, "|", color_white, "Framework starting\n")

sym.log("FRAMEWORK", "Framework starting.")

include("utils.lua")
sym.Include("lib/containers.lua", sym.realms.shared)
sym.Include("lib/stringex.lua", sym.realms.shared)
sym.Include("lib/mathex.lua", sym.realms.shared)
sym.Include("lib/tablex.lua", sym.realms.shared)
sym.Include("lib/filex.lua", sym.realms.shared)
sym.Include("lib/colorex.lua", sym.realms.shared)
sym.Include("lib/uuid.lua", sym.realms.shared)
sym.Include("lib/materialex.lua", sym.realms.shared)
sym.Include("lib/drawex.lua", sym.realms.shared)

Circles = sym.Include("lib/circles.lua", sym.realms.shared)

-- core/sh_database.lua
sym.Include("core/sh_types.lua", sym.realms.shared)
sym.Include("types/framework/event.lua", sym.realms.shared)
sym.Include("types/framework/proxy.lua", sym.realms.shared)
sym.Include("types/framework/primitives.lua", sym.realms.shared)
sym.Include("types/framework/promise.lua", sym.realms.shared)
sym.Include("types/framework/datetime.lua", sym.realms.shared)
sym.Include("core/sv_database.lua", sym.realms.server)
sym.Include("core/sh_tests.lua", sym.realms.shared)



-- core/sh_payloads.lua?
-- core/sh_virtual_entity.lua  --> Networking stuff
-- core/sh_permissions.lua
-- core/sh_usergroups.lua
-- core/sh_messages.lua !!
-- core/ui/* !!