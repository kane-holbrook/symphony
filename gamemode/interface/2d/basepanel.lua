AddCSLuaFile()
if SERVER then
    return
end 

local BasePanel = FindMetaTable("Panel")

function BasePanel:LoadXML()
    assert(self.Xml, "There is no XML associated with this panel.")

    local t = self.Xml
    for k, v in pairs(t.Attributes) do
        local sa = Interface.SpecialAttributes[k] 
        if sa then
            sa(el, parent, node)
        else
            self:SetProperty(k, v)
        end
    end

    self.IsRoot = true
    self:SetProperty("Root", self)

    for k, v in pairs(t.Children) do
        Interface.CreateFromNode(self, v, { Root = self })
    end
end
Interface.LoadXML = BasePanel.LoadXML

-- Properties
do
    function BasePanel:GetFuncEnv()
        local FuncEnv = self.FuncEnv
        if not FuncEnv then
            FuncEnv = {
                __index = self
            }
            FuncEnv.self = self
            self.FuncEnv = FuncEnv
        end
        return FuncEnv
    end
    Interface.GetFuncEnv = BasePanel.GetFuncEnv

    function BasePanel:SetProperty(name, value)
        assert(name, "Must provide a property name")
        
        self.Properties = self.Properties or {} 

        local p = self.Properties[name]
        if not p then
            p = {}
            p.Options = {}
            
            local f = self["Set" .. name] or self[name]
            if isfunction(f) then
                p.Setter = f
            end
        end

        local old = p.Value
        if isfunction(value) then
            p.Func = value
        else
            p.Value = value

            local FuncEnv = self:GetFuncEnv()
            FuncEnv[name] = value

            if value ~= old then
                self:OnPropertyChanged(name, value, old)
            end
        end

        self.Properties[name] = p
    end
    Interface.SetProperty = BasePanel.SetProperty

    function BasePanel:SetPropertyOption(name, key, value)
        assert(name, "Must provide a property name")
        
        self.Properties = self.Properties or {} 

        local p = self.Properties[name]
        if not p then
            p = {}
            p.Options = {}
            
            local f = self["Set" .. name] or self[name]
            if isfunction(f) then
                p.Setter = f
            end
        end

        p.Options[key] = value

        self.Properties[name] = p
    end
    Interface.SetPropertyOption = BasePanel.SetPropertyOption
    
    function BasePanel:GetPropertyOption(name, key)
        assert(name, "Must provide a property name")
        
        self.Properties = self.Properties or {} 

        local p = self.Properties[name]
        if not p then
            return nil
        else
            return p.Options[key]
        end
    end
    Interface.GetPropertyOption = BasePanel.GetPropertyOption

    function BasePanel:GetProperty(name, noRecurse, ...)
        if self.Properties then
            local p = self.Properties[name]
            if p then
                return p.Value
            end
        end
        
        if not noRecurse then
            local parent = self:GetParent()
            if parent then
                return parent:GetProperty(name, false, ...)
            end
        end

        return nil
    end
    Interface.GetProperty = BasePanel.GetProperty

    function BasePanel:GetProperties()
        return self.Properties
    end
    Interface.GetProperties = BasePanel.GetProperties

    function BasePanel:OnPropertyChanged(name, value, old)
        if name == "Ref" then
            assert(not old, "You can't change the Ref property more than once.")

            local tgt
            local p = self:GetParent()
            while p do
                tgt = p
                if tgt:GetProperty("Ref", true) or tgt.IsRoot then
                    break
                end
                p = p:GetParent()
            end

            local tgt_val = tgt[value]
            tgt[value] = self

            local FQR = { value }
            local tgt2 = tgt
            while tgt2 do 
                local ref = tgt2:GetProperty("Ref")
                local refIdx = tgt2:GetProperty("RefIndex")

                if refIdx then
                    table.insert(FQR, ref .. "[" .. refIdx .. "]")
                else
                    table.insert(FQR, ref)
                end

                tgt2 = tgt2:GetProperty("RefParent")
            end
            FQR = table.Reverse(FQR)

            self:SetProperty("FullyQualifiedRef", table.concat(FQR, "."))
            self:SetProperty("RefParent", tgt)
            return true
        end
    end
    Interface.OnPropertyChanged = BasePanel.OnPropertyChanged

    local function GetPropertyResult(...)
        return select("#", ...), {...}
    end

    function BasePanel:CalculateProperties(ctx)
        -- Create the FuncEnv if it doesn't exist already. The FuncEnv
        -- is passed into all properties.
        local FuncEnv = self.FuncEnv
        if not FuncEnv then
            FuncEnv = {
                __index = self
            }
            FuncEnv.self = self
            self.FuncEnv = FuncEnv
        end

        local parent = self:GetParent()

        if parent then
            setmetatable(FuncEnv, { __index = parent.FuncEnv })
            FuncEnv.PW = parent:GetWide()
            FuncEnv.PH = parent:GetTall()
            FuncEnv.Parent = parent
        end
        
        if not parent:GetProperty("Display") then
            return
        end

        -- Calculate the property values
        if self.Properties then
            local FuncEnv = self.FuncEnv
            
            for k, p in pairs(self.Properties) do                    
                local old = p.Last
                local packed = false

                if p.Func then
                    setfenv(p.Func, FuncEnv)
                    local num, values = GetPropertyResult(p.Func(self)) 

                    packed = num > 1
                    p.Value = packed and values or values[1]
                end

                -- Only trigger sets if the value has changed to avoid infinite layouts.
                if p.Value ~= old then
                    self:OnPropertyChanged(k, p.Value, old)

                    if p.Setter then
                        if packed then
                            p.Setter(self, unpack(p.Value))
                        else
                            p.Setter(self, p.Value)
                        end
                    end

                    p.Last = p.Value
                end 
                
                self.FuncEnv[k] = p.Value
            end

            local ref = self:GetProperty("Ref")
            if ref then
                self.FuncEnv[ref] = self
            end
        end
        
        if not self:GetProperty("Display") then
            if not self.Hidden then
                self.Hidden = true
                self:Dock(NODOCK)
                self:SetSize(0, 0)
            end
            return 0, 0
        elseif self.Hidden then
            local dock = self:GetProperty("Dock")
            if dock then
                self:Dock(dock)
            end

            self:SetSize(self:GetProperty("Width") or 1, self:GetProperty("Height") or 1)
            self.Hidden = false
        end
    end
    Interface.CalculateProperties = BasePanel.CalculateProperties
end

-- InvalidateLayout. Used for For loops
do
    BasePanel.InvalidateLayoutRaw = BasePanel.InvalidateLayoutRaw or BasePanel.InvalidateLayout
    Interface.InvalidateLayoutRaw = BasePanel.InvalidateLayoutRaw

    function BasePanel:InvalidateLayout(layoutNow)
        self:InvalidateLayoutRaw(layoutNow)

        local ForFunc = self.ForFunc
        if ForFunc then
            -- Clear out the existing children.
            for k, v in pairs(self:GetChildren()) do
                if v.ForSource == ForFunc then
                    v:Remove()
                end 
            end

            local data = ForFunc()
            self:SetProperty("ForData", data)

            for k, v in pairs(data) do
                for k2, v2 in pairs(self.ForXml) do
                    local el = Interface.CreateFromNode(self, v2, { For = true })
                    for k3, v3 in pairs(v) do
                        el:SetProperty(k3, v3)
                    end
                    el.ForSource = ForFunc
                end
            end
        end
    end
    Interface.InvalidateLayout = BasePanel.InvalidateLayout
end

-- Events/emits
do
    local function Emit(self, panel, event, ...)
        self:HandleEmit(panel, event, ...)

        local p = self:GetParent()
        if p then
            local rtn = Emit(p, panel, event, ...) 
            if rtn ~= nil then
                return rtn
            end
        end
    end

    function BasePanel:Emit(event, ...)
        return Emit(self, self, event, ...)
    end
    Interface.Emit = BasePanel.Emit

    local function EmitChildren(self, panel, event, ...)
        self:HandleEmit(panel, event, ...)
        for k, v in pairs(self:GetChildren()) do
            Emit(v, panel, event, ...)
        end
    end

    function BasePanel:EmitChildren(event, ...)
        self:EmitChildren(self, self, event, ...)
    end
    Interface.EmitChildren = BasePanel.EmitChildren

    function BasePanel:HandleEmit(panel, event, ...)
        hndl = self:GetProperty("On:" .. event)
        if hndl then
            hndl(panel, ...)
        end 
    end
    Interface.HandleEmit = BasePanel.HandleEmit
end

function BasePanel:ParseNode(parent, node, ctx)
    local el = vgui.Create(node.Tag, parent)
    local types = Interface.GetAttributes(node.Tag)

    -- Attributes
    for k, v in pairs(node.Attributes) do
        local sa = Interface.SpecialAttributes[k] 
        if sa then
            if sa(el, v, node, ctx) == true then
                continue
            end
        else
            local splitted = string.Split(k, ":")
            if #splitted > 1 then
                local sp = Interface.SpecialPrefixes[splitted[1]]
                if sp and sp(el, splitted[2], v, splitted, node, ctx) then
                    continue
                end
            end

            if not isfunction(v) then
                local at = types[k]
                if at then
                    if isfunction(at) then
                        v = at(v)
                    else
                        v = at:Parse(v)
                    end
                end
            end
            el:SetProperty(k, v)
        end
    end

    -- Children
    for k, v in pairs(node.Children) do
        Interface.CreateFromNode(el, v, ctx)
    end

    return el
end

function BasePanel:ParseContent(text, node, ctx)
    local el = vgui.Create("Text", self)
    if not Interface.IsPanelInitialized(el:GetParent()) then
        el:Dock(LEFT)
    end
    el:SetProperty("Content", text)
end

local wp = vgui.GetWorldPanel()
wp.FuncEnv = setmetatable({
    SS = ScreenScale,
    SSH = ScreenScaleH
}, { __index = _G })
wp:SetProperty("Display", true)


INTERFACE_PERFORM_LAYOUT = function (self, w, h)
    local LastW, LastH = self:GetSize()

    w, h = self:CalculateProperties()
    local fqr = self:GetProperty("FullyQualifiedRef")
    if fqr then
        hook.Run("PerformLayout:" .. fqr, self)
    end
    
    return w, h
end
Interface.PerformLayout = INTERFACE_PERFORM_LAYOUT

local function DefaultExtent(value)
    if string.EndsWith(value, "px") then
        return tonumber(string.sub(value, 1, -3))
    end

    if string.EndsWith(value, "ss") then
        return function ()
            return ScreenScale(tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "ssh") then
        return function ()
            return ScreenScaleH(tonumber(string.sub(value, 1, -4)))
        end
    end

    if string.EndsWith(value, "vw") then
        return function ()
            return ScrW() * (tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "vh") then
        return function ()
            return ScrH() * (tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "pw") then
        return function ()
            return PW * (tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "ph") then
        return function ()
            return PH * (tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "cw") then
        return function ()
            local font = self:CalculateFont()
            surface.SetFont(font)
            local x2, y2 = surface.GetTextSize(" ")
            return x2 * tonumber(string.sub(value, 1, -3))
        end
    end

    if string.EndsWith(value, "ch") then
        return function ()
            local font = self:CalculateFont()
            surface.SetFont(font)
            local x2, y2 = surface.GetTextSize(" ")
            return y2 * tonumber(string.sub(value, 1, -3))
        end
    end

    error("Invalid extent: " .. value)
end

function Interface.ExtentW(value)
    local tn = tonumber(value)
    if tn then
        return function ()
            return ScreenScale(value)
        end
    end
    
    if string.EndsWith(value, "%") then
        return function ()
            return PW * (tonumber(string.sub(value, 1, -2)) / 100)
        end
    end

    return DefaultExtent(value)
end

function Interface.ExtentH(value)
    local tn = tonumber(value)
    if tn then
        return function ()
            return ScreenScaleH(value)
        end
    end

    if string.EndsWith(value, "%") then
        return function ()
            return PH * (tonumber(string.sub(value, 1, -2)) / 100)
        end
    end

    return DefaultExtent(value)
end

function Interface.Extent4(value)
    value = string.Replace(value, ",", " ")
    value = string.Replace(value, "  ", " ")
    local s = string.Split(value, " ")

    local l, t, r, b = s[1], s[2], s[3], s[4]
    if not r then
        r = l
    end

    if not b then
        b = t
    end

    if not t then
        t = l
        b = l
        r = l
    end

    print(Interface.ExtentW(l), Interface.ExtentH(t), Interface.ExtentW(r), Interface.ExtentH(b))
    return Interface.ExtentW(l), Interface.ExtentH(t), Interface.ExtentW(r), Interface.ExtentH(b)    
end

Interface.RegisterAttribute("Panel", "X", Interface.ExtentW)
Interface.RegisterAttribute("Panel", "Y", Interface.ExtentH)
Interface.RegisterAttribute("Panel", "Width", Interface.ExtentW)
Interface.RegisterAttribute("Panel", "Height", Interface.ExtentH)
Interface.RegisterAttribute("Panel", "Wide", Interface.ExtentW)
Interface.RegisterAttribute("Panel", "Tall", Interface.ExtentH)
Interface.RegisterAttribute("Panel", "DockPadding", Interface.Extent4)
Interface.RegisterAttribute("Panel", "DockMargin", Interface.Extent4)
