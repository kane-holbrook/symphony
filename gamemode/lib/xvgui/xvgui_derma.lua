AddCSLuaFile()
if SERVER then
    return
end 

local BasePanel = FindMetaTable("Panel")

function BasePanel:LoadXML()
    assert(self.Xml, "There is no XML associated with this panel.")

    local t = self.Xml
    for k, v in pairs(t.Attributes) do
        local sa = xvgui.SpecialAttributes[k] 
        if sa then
            sa(el, parent, node)
        else
            self:SetProperty(k, v)
        end
    end

    self.IsRoot = true
    self:SetProperty("Root", self)

    for k, v in pairs(t.Children) do
        xvgui.CreateFromNode(self, v, { Root = self })
    end
end
xvgui.LoadXML = BasePanel.LoadXML

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
    xvgui.GetFuncEnv = BasePanel.GetFuncEnv

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
    xvgui.SetProperty = BasePanel.SetProperty

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
    xvgui.SetPropertyOption = BasePanel.SetPropertyOption
    
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
    xvgui.GetPropertyOption = BasePanel.GetPropertyOption

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
    xvgui.GetProperty = BasePanel.GetProperty

    function BasePanel:GetProperties()
        return self.Properties
    end
    xvgui.GetProperties = BasePanel.GetProperties

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
    xvgui.OnPropertyChanged = BasePanel.OnPropertyChanged

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
    xvgui.CalculateProperties = BasePanel.CalculateProperties
end

-- InvalidateLayout. Used for For loops
do
    BasePanel.InvalidateLayoutRaw = BasePanel.InvalidateLayoutRaw or BasePanel.InvalidateLayout
    xvgui.InvalidateLayoutRaw = BasePanel.InvalidateLayoutRaw

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
                    local el = xvgui.CreateFromNode(self, v2, { For = true })
                    for k3, v3 in pairs(v) do
                        el:SetProperty(k3, v3)
                    end
                    el.ForSource = ForFunc
                end
            end
        end
    end
    xvgui.InvalidateLayout = BasePanel.InvalidateLayout
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
    xvgui.Emit = BasePanel.Emit

    local function EmitChildren(self, panel, event, ...)
        self:HandleEmit(panel, event, ...)
        for k, v in pairs(self:GetChildren()) do
            Emit(v, panel, event, ...)
        end
    end

    function BasePanel:EmitChildren(event, ...)
        self:EmitChildren(self, self, event, ...)
    end
    xvgui.EmitChildren = BasePanel.EmitChildren

    function BasePanel:HandleEmit(panel, event, ...)
        hndl = self:GetProperty("On:" .. event)
        if hndl then
            hndl(panel, ...)
        end 
    end
    xvgui.HandleEmit = BasePanel.HandleEmit
end

function BasePanel:XMLHandleText(text, node, ctx)    
    local el = vgui.Create("XLabel", self)
    if not xvgui.IsXVGUI(el:GetParent()) then
        el:Dock(LEFT)
    end
    el:SetText(text)
    return el
end

local wp = vgui.GetWorldPanel()
wp.FuncEnv = setmetatable({
    SS = ScreenScale,
    SSH = ScreenScaleH
}, { __index = _G })
wp:SetProperty("Display", true)


XVGUI_PERFORM_LAYOUT = function (self, w, h)
    local LastW, LastH = self:GetSize()

    w, h = self:CalculateProperties()
    local fqr = self:GetProperty("FullyQualifiedRef")
    if fqr then
        hook.Run("PerformLayout:" .. fqr, self)
    end
    
    return w, h
end
xvgui.PerformLayout = XVGUI_PERFORM_LAYOUT