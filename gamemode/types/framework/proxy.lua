
local PROXY = Type.Register("Proxy")
PROXY:CreateProperty("Value")
PROXY.Prototype.Set = PROXY.Prototype.SetValue
PROXY.Prototype.Get = PROXY.Prototype.GetValue

function PROXY.Prototype:Initialize()
    self.Event = Type.New(Type.EventBus)
end

function PROXY.Prototype:Hook(...)
    return self.Event:Hook("Change", ...)
end

function PROXY.Prototype:Unhook(...)
    return self.Event:Unhook("Change", ...)
end

function PROXY.Prototype:SetValue(value)
    local old = self.Value
    self.Value = value
    return self.Event:Run("Change", value, old)
end

function PROXY.Metamethods:__tostring()
    return "Proxy[" .. stringex.ToString(self.Value) .. "]"
end

function Proxy(value)
    local p = Type.New(PROXY)
    p:SetValue(value)
    return p
end

function IsProxy(obj)
    return Type.IsDerived(obj, PROXY)
end


hook.Add("Test.Register", "Proxies", function ()
    Test.Register("Proxies", function ()
        local proxy = Proxy(32)
        local valueChanged = false
        Test.Equals(proxy:GetValue(), 32)

        local id = proxy:Hook(function(newValue, oldValue)
            Test.Equals(oldValue, 32)
            Test.Equals(newValue, 42)
            valueChanged = true
        end)

        proxy:SetValue(42)
        Test.Equals(proxy:GetValue(), 42)
        Test.Equals(valueChanged, true)
        Test.Equals(tostring(proxy), "Proxy[42]")

        proxy:Unhook(id)
        
        proxy:SetValue("Hello")
        Test.Equals(tostring(proxy), "Proxy[\"Hello\"]")

        Test.Equals(IsProxy(proxy), true)
    end)
end)