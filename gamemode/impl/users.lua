AddCSLuaFile()

local User = Type.Register("User", nil, { Table = "Users", Key = "SteamID" })
User:CreateProperty("SteamID", Type.String, { DatabaseType = "VARCHAR(32)" })
User:CreateProperty("Name", Type.String, { DatabaseType = "VARCHAR(128)" })
User:CreateProperty("Usergroups", Type.Table, { Default = {} })
User:CreateProperty("LastJoin", Type.DateTime)
User:CreateProperty("Created", Type.DateTime, { Default = function () return DateTime() end })
User:CreateProperty("Data", Type.Table, { Default = {} })

function User.Prototype:GetData(...)
    return Deref(self.Data, ...)
end

function User.Prototype:SetData(...)
    local args = {...}
    local value = table.remove(args, #args)

    if value == NULL then
        value = nil
    end

    local data = self:GetData()
    local t = data
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
        local ply = player.GetBySteamID64(self:GetSteamID())
        if ply then
            rtc.Start("User:SetData")
                rtc.WriteInt(#args, 8)
                for i=1, #args do
                    rtc.WriteType(args[i])
                end
                rtc.WriteObject(value)
            rtc.Send(ply)
        end
    end

    hook.Run("UserDataChanged", self, key, value)
end

if CLIENT then
    rtc.Receive("User:SetData", function (len, ply)
        local user = LocalPlayer():GetUser()
        assert(user, "Received User data for invalid player")

        local args = {}
        for i=1, rtc.ReadInt(8) do
            table.insert(args, rtc.ReadType())
        end
        local value = rtc.ReadObject()

        local data = user:GetData()
        local t = data
        for i=1, #args - 1 do
            local key = args[i]
            if not t[key] then
                t[key] = {}
            end
            t = t[key]
        end

        local key = args[#args]
        t[key] = value

        hook.Run("UserDataChanged", user, key, value)
    end)
end

local PLY = FindMetaTable("Player")
function PLY:GetUser()
    return self.User
end

function PLY:GetUserData(...)
    local user = self:GetUser()
    if not user then
        return nil
    end
    return user:GetData(...)
end

function PLY:SetUserData(...)
    local user = self:GetUser()
    if not user then
        return
    end
    return user:SetData(...)
end

function PLY:GetUsergroups()
    return Deref(self, "GetUser", "GetUsergroups")
end

function PLY:HasPermission(perm)
    for k, v in pairs(self:GetUsergroups()) do
        local ug = Usergroups.GetByName(v)
        if ug and ug:HasPermission(perm) then
            return true
        end
    end
    return false
end