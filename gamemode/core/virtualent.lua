AddCSLuaFile()

virtualent = {}
virtualent.All = {}
virtualent.ByClass = {}

function virtualent.GetAll()
    return virtualent.All
end

function virtualent.FindByClass(class, noDerivatives)
    local out = {}

    if isstring(class) then
        class = Type.GetByName(class)
    end

    local t = virtualent.ByClass[class]
    if t then
        for k, v in pairs(t) do
            table.insert(out, v)
        end
    end

    if not noDerivatives then
        for k, v in pairs(class:GetDerivatives(false)) do
            table.Add(out, virtualent.FindByClass(v, true))
        end
    end

    return out
end

local VE = Type.Register("VirtualEnt", nil, { Abstract = true })
VE:CreateProperty("Index", Type.Number, { Transient = true })
VE:CreateProperty("Transmit", Type.Number, { Transient = true, Default = TRANSMIT_ALWAYS, Transmit = false })
VE:CreateProperty("Pos", Type.Vector, { Transient = true, Default = Vector(0, 0, 0) })

function VE.Prototype:Initialize()
    self:SetIndex(table.insert(virtualent.All, self))

    local t = virtualent.ByClass[self:GetType()]
    if not t then
        t = weaktable(true, true)
        virtualent.ByClass[self:GetType()] = t
    end
    t[self:GetIndex()] = self

    if SERVER then
        self.Receivers = {}
        for k, v in pairs(player.GetAll()) do
            self:TransmitTo(v)
        end
    end
end

function VE.Prototype:AddReceiver(ply)
    self.Receivers[ply] = {}
end

function VE.Prototype:RemoveReceiver(ply)
    self.Receivers[ply] = nil
end

function VE.Prototype:GetReceivers()
    local out = {}
    local idx = 1
    for k, v in pairs(self.Receivers) do
        if not IsValid(k) or not k.Initialized then
            self.Receivers[k] = nil
            continue
        end

        out[idx] = k
        idx = idx + 1
    end
    return out
end

if SERVER then
    function VE.Prototype:TransmitTo(ply)
        self:AddReceiver(ply)

        local type = self:GetType()

        rtc.Start("VirtualEnt")
            rtc.WriteInt(self:GetIndex(), 32)
            rtc.WriteInt(type:GetCode(), 32)
                
            local props = self:GetProperties()
            local propMap = type:GetPropertiesMap()

            local out = {}
            for k, v in pairs(props) do
                local pm = propMap[k]

                if pm.Type then
                    out[pm.Code] = pm.Type:Encode(v)
                else
                    out[pm.Code] = { v:GetType():GetCode(), Type.GetType(v):Encode(v) }
                end
            end

            local data = sfs.encode(out)
            rtc.WriteInt(#data, 32)
            rtc.WriteData(data, #data)
        rtc.Send(ply)
    end

    

    local function TransmitProperty(self, prop, value)
        rtc.Start("VirtualEnt.Property")
            rtc.WriteInt(self:GetIndex(), 32)
            rtc.WriteInt(prop.Code, 32)

            local encoded
            if prop.Type then
                encoded = sfs.encode(prop.Type:Encode(value))
            else
                encoded = sfs.encode({ value:GetType():GetCode(), Type.GetType(value):Encode(value) })
            end

            rtc.WriteInt(#encoded, 32)
            rtc.WriteData(encoded, #encoded)
        rtc.Send(self:GetReceivers())
    end

    function VE.Prototype:OnPropertyChanged(name, value, old)
        if old == value then
            return
        end
        
        debounce(0.1, "VirtualEnt[" .. self:GetIndex() .. "[" .. name .. "]", function ()
            local prop = self:GetType():GetProperty(name)
            TransmitProperty(self, prop, value)
        end)
    end
end

function VE.Prototype:OnDisposed()
    virtualent.All[self:GetIndex()] = nil
    virtualent.ByClass[self:GetType()][self:GetIndex()] = nil


    if SERVER then
        rtc.Start("VirtualEnt.Dispose")
            rtc.WriteInt(self:GetIndex(), 32)
        rtc.Broadcast()
    end
end

if CLIENT then
    rtc.Receive("VirtualEnt", function ()
        local id = rtc.ReadInt(32)
        local typeCode = rtc.ReadInt(32)
        local typeObj = Type.GetByCode(typeCode)
        local len = rtc.ReadInt(32)
        local data = sfs.decode(rtc.ReadData(len))

        assert(id, "Invalid VirtualEnt id received")
        assert(typeObj, "Invalid VirtualEnt type received")

        local obj = virtualent.All[id] or typeObj:New(id)
		local map = typeObj:GetPropertiesByCode()
		for k, v in pairs(data) do
			local prop = map[k]

            if prop.Type then
                obj:SetProperty(prop.Name, prop.Type:Decode(v))
			else
                obj:SetProperty(prop.Name, Type.GetType(v[1]):Decode(v[2]))
            end
		end
    end)

    rtc.Receive("VirtualEnt.Property", function ()
        local id = rtc.ReadInt(32)
        local propCode = rtc.ReadInt(32)
        local len = rtc.ReadInt(32)
        local data = sfs.decode(rtc.ReadData(len))

        local obj = virtualent.All[id]
        assert(obj, "Invalid VirtualEnt id for property update: " .. tostring(id))

        local prop = obj:GetType():GetPropertyByCode(propCode)
        assert(prop, "Invalid property code for " .. obj:GetType():GetName() .. ": " .. tostring(propCode))

        if prop.Type then
            obj:SetProperty(prop.Name, prop.Type:Decode(data))
        else
            obj:SetProperty(prop.Name, Type.GetType(data[1]):Decode(data[2]))
        end
    end)

    rtc.Receive("VirtualEnt.Dispose", function ()
        local id = rtc.ReadInt(32)
        local obj = virtualent.All[id]
        if obj then
            obj:Dispose()
        end
    end)
end

if SERVER then
    hook.Add("Symphony:InitializePlayer", "VirtualEnt", function (ply)
        for k, v in pairs(virtualent.GetAll()) do
            v:TransmitTo(ply)
        end
    end)
end