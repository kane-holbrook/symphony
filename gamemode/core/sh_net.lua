AddCSLuaFile()

RPC = {}
RPC.Receivers = {}
RPC.Promises = {}

function RPC.Register(name, func)
    RPC.Receivers[name] = func
end

if CLIENT then
    function RPC.Call(name, ...)
        local p = Promise.Create()

        rtc.Start("RPC:Call")
            rtc.WriteString(p:GetId())
            rtc.WriteString(name)
            rtc.WriteObject({...})
        rtc.SendToServer()
        RPC.Promises[p:GetId()] = p
        return p
    end
else
    local ply = FindMetaTable("Player")
    function ply:RPC(name, ...)
        local p = Promise.Create()
        p.Player = self

        rtc.Start("RPC:Call")
            rtc.WriteString(p:GetId())
            rtc.WriteString(name)
            rtc.WriteObject({...})
        rtc.Send(self)
        RPC.Promises[p:GetId()] = p
        return p
    end
end

rtc.Receive("RPC:Call", function (len, ply)
    local id = rtc.ReadString()
    local name = rtc.ReadString()
    local args = rtc.ReadObject()
    
    local func = RPC.Receivers[name]
    assert(func, "No RPC function registered with name '" .. name .. "' (" .. tostring(ply) .. ")")
    if func then
        Promise.Run(function ()
            local results = { func(ply, unpack(args)) }      
            rtc.Start("RPC:Return")
                rtc.WriteString(id)
                rtc.WriteObject(results)

            if SERVER then
                rtc.Send(ply)
            else
                rtc.SendToServer()
            end
        end)
    end
end)

rtc.Receive("RPC:Return", function (len, ply)
    local id = rtc.ReadString()
    local results = rtc.ReadObject()

    local p = RPC.Promises[id]
    assert(p, "No RPC promise with ID '" .. id .. "' (" .. tostring(ply) .. ")")
    if p then
        if SERVER then 
            assert(p.Player == ply, "RPC promise player mismatch (" .. tostring(ply) .. ")")
        end

        RPC.Promises[id] = nil
        p:Complete(unpack(results))
    end
end)

RPC.Register("Ping", function (ply)
    return "Pong", 32
end)