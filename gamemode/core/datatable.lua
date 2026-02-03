AddCSLuaFile()

DataTables = {}

local DT = Type.Register("DataTable")
DT:CreateProperty("Id", Type.String, { Default = function () return uuid() end })

function DataTable()
    local dt = Type.New(DT)
    getmetatable(dt).Receivers = {}

    DataTables[dt:GetId()] = dt
    return dt
end

if SERVER then
    function DT.Prototype:AddReceiver(ply)
        getmetatable(self).Receivers[ply] = true
    end

    function DT.Prototype:RemoveReceiver(ply)
        getmetatable(self).Receivers[ply] = nil
    end

    function DT.Prototype:GetReceivers()
        return getmetatable(self).Receivers
    end

    function DT.Prototype:ClearReceivers()
        getmetatable(self).Receivers = {}
    end

    function DT:Encode(obj, ply)
        if ply then
            obj:AddReceiver(ply)
        end
        
		local out = {}
        table.insert(out, table.Count(self))
		for k, v in pairs(self) do
            local t = {}
            local k_type = Type.GetType(k)
            t[1] = k_type:GetCode()
            t[2] = k_type:Encode(k, ply)

            local v_type = Type.GetType(v)
            t[3] = v_type:GetCode()
            t[4] = v_type:Encode(v, ply)
		end

		return out
    end

    function DT:Decode(obj)
        local dt = DataTable()
        local count = table.remove(obj, 1)
        for i=1, count do
            local k_type = Type.GetByCode(table.remove(obj, 1))
            local k = k_type:Decode(table.remove(obj, 1))

            local v_type = Type.GetByCode(table.remove(obj, 1))
            local v = v_type:Decode(table.remove(obj, 1))

            dt[k] = v
        end

        return dt
    end
        
    function DT.Prototype:Set(...)
        local args = {...}
        local value = table.remove(args, #args)
        
        local t = self

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
            rtc.Start("DataTable:Set")
                rtc.WriteString(self:GetId())
                rtc.WriteInt(#args, 8)
                for i=1, #args do
                    rtc.WriteType(args[i])
                end
                rtc.WriteObject(value)
            rtc.Send(self:GetReceivers())
        end

        hook.Run("DataTableChanged", self, key, value, eid)
    end
end

function DT.Prototype:Get(...)
    return Deref(self, ...)
end

if CLIENT then
    rtc.Receive("DataTable:Set", function (len, ply)
        local id = rtc.ReadString()
        
        local args = {}
        for i=1, rtc.ReadInt(8) do
            table.insert(args, rtc.ReadType())
        end
        local value = rtc.ReadObject()

        local t = DataTables[id]
        if not t then
            return
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
        
        hook.Run("DataTableChanged", t, key, value)
    end)
end

function DT.Prototype:OnDisposed()
    base(self, "OnDisposed")
    DataTables[self:GetId()] = nil
end