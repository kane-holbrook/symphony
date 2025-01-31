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
IncludeEx("lib/containers.lua", Realm.Shared)
IncludeEx("lib/stringex.lua", Realm.Shared)
IncludeEx("lib/mathex.lua", Realm.Shared)
IncludeEx("lib/tablex.lua", Realm.Shared)
IncludeEx("lib/filex.lua", Realm.Shared)
IncludeEx("lib/colorex.lua", Realm.Shared)
IncludeEx("lib/uuid.lua", Realm.Shared)
IncludeEx("lib/materialex.lua", Realm.Shared)
IncludeEx("lib/drawex.lua", Realm.Shared)

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
IncludeEx("core/sh_tests.lua", Realm.Shared)



-- core/sh_payloads.lua?
-- core/sh_virtual_entity.lua  --> Networking stuff
-- core/sh_permissions.lua
-- core/sh_usergroups.lua
-- core/sh_messages.lua !!
-- core/ui/* !!

--[[
if IsValid(ws) then
    ws:Remove()
end

ws = vgui.Create("DHTML")
ws:SetPaintedManually(true)
print("boop")
ws:SetHTML([[
    <html>
    <head>
        <script>
            function startStreaming() {
                fetch("http://sstrp.net:3000/stream")
                    .then(response => {
                        const reader = response.body.getReader();

                        function readChunk() {
                            reader.read().then(({ done, value }) => {
                                if (done) {
                                    console.log("Stream ended.");
                                    return;
                                }

                                console.log("Received chunk:" + value); // Print raw binary chunk

                                readChunk(); // Keep reading until done
                            });
                        }

                        console.log("stream")

                        readChunk();
                    })
                    .catch(error => console.error("Fetch error:", error));
            }

            window.onload = startStreaming;
        </script>
    </head>
    <body>
        <h2>Streaming Binary Data...</h2>
    </body>
    </html>

--]]--)
--[[
-- Function to send messages via WebSocket
function SendWebSocketMessage(msg)
    if IsValid(ws) then ws:RunJavascript("sendMessage(" .. util.TableToJSON(msg) .. ");") end
end

-- Hook for receiving messages from WebSocket
ws:AddFunction("gmod", "receive", function(event, data)
    if event == "ws_ready" then
        print("[WebSocket] Connected and ready!")
    elseif event == "ws_message" then
        print("[WebSocket] Received:", data)
    elseif event == "ws_closed" then
        print("[WebSocket] Disconnected.")
    elseif event == "ws_error" then
        print("[WebSocket] Error:", data)
    end
end)--]]