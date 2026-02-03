AddCSLuaFile()

EntData = EntData or {}

local ENT = FindMetaTable("Entity")
function ENT:SetData(...)
    local args = {...}
    local value = table.remove(args, #args)

    local eid = self:EntIndex()
    local t = EntData[eid] 
    if not t then 
        t = {}
        EntData[eid] = t
    end

    for i=1, #args - 1 do
        local key = args[i]
        if not t[key] then
            t[key] = {}
        end
        t = t[key]
    end

    local key = args[#args]
    t[key] = value

    if SERVER then
        rtc.Start("EntData:Set")
            rtc.WriteInt(eid, 32)
            rtc.WriteInt(#args, 8)
            for i=1, #args do
                rtc.WriteType(args[i])
                print(args[i])
            end
            rtc.WriteObject(value)
        rtc.Broadcast()
    end

    hook.Run("EntDataChanged", self, key, value, eid)
end


function ENT:GetData(...)
    local ed = EntData[self:EntIndex()]
    if not ed then 
        return nil 
    end
    return Deref(ed, ...) 
end

if CLIENT then
    rtc.Receive("EntData:Set", function (len, ply)
        local eid = rtc.ReadInt(32)
        local args = {}
        for i=1, rtc.ReadInt(8) do
            table.insert(args, rtc.ReadType())
        end
        local value = rtc.ReadObject()

        local t = EntData[eid]
        if not t then
            t = {}
            EntData[eid] = t
        end

        for i=1, #args - 1 do
            local key = args[i]
            if not t[key] then
                t[key] = {}
            end
            t = t[key]
        end

        local key = args[#args]
        t[key] = value
        
        hook.Run("EntDataChanged", Entity(eid), key, value, eid)
    end)
else
    hook.Add("Symphony:InitializePlayer", function (ply)
        for k, v in pairs(EntData) do
            for key, value in pairs(v) do
                rtc.Start("EntData:Set")
                    rtc.WriteInt(k, 32)
                    rtc.WriteInt(1, 8)
                    rtc.WriteType(key)
                    rtc.WriteObject(value)
                rtc.Send(ply)
            end
        end
    end)
end
--]]

hook.Add("EntityRemoved", function (ent)
    EntData[ent] = nil
end)