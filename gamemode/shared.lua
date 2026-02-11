AddCSLuaFile()
DeriveGamemode("sandbox")

Symphony = {}
Symphony.Version = "0.0.1"
Symphony.StartTime = SysTime()

collectgarbage("collect")
MsgC("\n\n")
file.CreateDir("symphony")

include("lib/tablex.lua")
include("lib/stringex.lua")
include("core/utils.lua")
include("lib/vguix.lua")
include("lib/materialex.lua")
include_sh("lib/cami.lua")
sfs = include_sh("lib/sfs.lua")
xml2lua = include_sh("lib/xml2lua/xml2lua.lua")

include("core/logging.lua")
Log.Write(LOG_INFO, "INFO", "Starting Symphony (" .. Symphony.Version .. ")")

include("core/types.lua")
include("core/primitives.lua")
include("core/promises.lua")
include("core/datetime.lua")
include("core/tests.lua")
include_sv("core/database.lua")
include("core/http.lua")
include("core/rpc.lua")
include("core/datatable.lua")
include("core/entdata.lua")
include("core/virtualent.lua")
include("core/proceduralmaterial.lua")
include("core/interface.lua")

include("impl/setting.lua")
include("impl/octtree.lua")
include("impl/nav.lua")
include("impl/menubar.lua")
include("impl/usergroups.lua")
include("impl/users.lua")
include("impl/commands.lua")

include("interface/helpers.lua")
include("interface/text.lua")
include("interface/overlay.lua")
include("interface/textbox.lua")



local PLY = FindMetaTable("Player")
function PLY:IsAdmin()
    return true
end

function PLY:IsSuperAdmin()
    return true
end


Xalphox = function ()
    for k, v in pairs(player.GetAll()) do
        if v:Name() == "Xalphox" then
            return v
        end
    end
end

rtc.Receive("Test", function ()
    rtc.Test = rtc.ReadObject()
    print("Received test object: " .. tostring(rtc.Test))
end)