AddCSLuaFile()

Settings = {}
Settings.Registry = {}
Settings.KeyValues = {}

function Settings.GetAll()
    return Settings.KeyValues
end

function Settings.Register(key, type, value)
    local sd = Type.New(Type.SettingDefinition)
    sd:SetKey(key)
    sd:SetSettingType(type)
    sd:SetDefaultValue(value)
    Settings.Registry[key] = sd
    return sd
end

function Settings.GetDefinition(key)
    return Settings.Registry[key]
end

function Settings.Set(key, value, transient)
    local setting = Settings.KeyValues[key]
    if not setting then
        setting = Type.New(Type.Setting)
        setting:SetKey(key)
    end
    setting:SetValue(value)

    hook.Run("Setting.Changed", setting, key, nil)
    
    if SERVER and not transient then
        setting:Commit()
    end

    return setting
end

function Settings.Reset(key)
    return Promise.Run(function ()
        local setting = Settings.KeyValues[key]
        if not setting then
            return
        end

        local old = setting:GetValue()

        setting:Refresh():Await()

        if old ~= setting:GetValue() then
            hook.Run("Setting.Changed", setting, setting:GetValue(), old)
        end
    end)
end

function Settings.Get(key, default)
    local setting = Settings.KeyValues[key]
    if setting then
        return setting:GetValue()
    else
        return default
    end
end

function Settings.GetObject(key)
    return Settings.KeyValues[key]
end

local Setting = Type.Register("Setting", Type.VirtualEnt, { Table = "Settings", Key = "Key" })
Setting:CreateProperty("Key", Type.String, { DatabaseType = "VARCHAR(128)" })
Setting:CreateProperty("Value")

function Setting.Prototype:OnPropertyChanged(field, new, old)
    if field == "Key" then
        hook.Run("Setting.Changed", self, new, old)

        if old then
            Settings.KeyValues[old] = nil
        end

        if new then
            Settings.KeyValues[new] = self
        end
    end

    return base(self, "OnPropertyChanged", field, new, old)
end

hook.Add("DatabaseConnected", function ()
    Setting:Select():Await()
     -- VirtualEnts, so they'll automatically transmit anyway.
end)


local SettingDefinition = Type.Register("SettingDefinition")
SettingDefinition:CreateProperty("Key", Type.String, { DatabaseType = "VARCHAR(255)" })
SettingDefinition:CreateProperty("SettingType", Type.Type)
SettingDefinition:CreateProperty("DefaultValue")

function SettingDefinition.Prototype:GetValue()
    return Settings.Get(self:GetKey())
end