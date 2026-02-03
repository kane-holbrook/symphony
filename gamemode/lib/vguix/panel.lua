AddCSLuaFile()

if SERVER then
    return
end

-- SizeToContent
-- Flex
-- Hover
-- Mesh

NO_OP = NO_OP or {}

function vguix.ParseExtent(value, useHeight)
    assert(value)

    local tn = tonumber(value)
    if isnumber(tn) then
        return tn
    end

    value = string.lower(value)

    if string.EndsWith(value, "px") then
        return tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "pw") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() 
            local p = self:GetParent()
            if p and p.GetPaddingLeft then
                local gap = p:GetGap()
                local gapsz = 0

                if p:GetFlow() == "X" then
                    for k, v in pairs(p:GetChildren()) do
                        if v == self then 
                            continue
                        end
                        
                        if not v:GetAbsolute() and v:GetVisible() then
                            gapsz = gapsz + gap
                        end
                    end
                end

                return math.Round(percent * (Parent.Width - p:GetPaddingLeft() - p:GetPaddingRight() - gapsz), 0)
            else
                return math.Round(percent * Parent.Width, 0) 
            end
        end)

        f.Value = percent
        f.Mode = "pw"
        return f
    elseif string.EndsWith(value, "ph") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() 
            
            local p = self:GetParent()
            if p and p.GetPaddingLeft then                
                local gap = p:GetGap()
                local gapsz = 0

                if p:GetFlow() == "Y" then
                    for k, v in pairs(p:GetChildren()) do
                        if v == self then 
                            continue
                        end
                        
                        if not v:GetAbsolute() and v:GetVisible() then
                            gapsz = gapsz + gap
                        end
                    end
                end

                return math.Round(percent * (Parent.Height - p:GetPaddingTop() - p:GetPaddingBottom()), 0)
            else
                return math.Round(percent * Parent.Height, 0) 
            end
        end)
        f.Value = percent
        f.Mode = "ph"
        return f
    elseif string.EndsWith(value, "vw") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() return math.Round(percent * ScrW(), 0) end)
        f.Value = percent
        f.Mode = "vh"
        return f
    elseif string.EndsWith(value, "vh") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() return math.Round(percent * ScrH(), 0) end)
        f.Value = percent
        f.Mode = "vh"
        return f
    elseif string.EndsWith(value, "%") then
        local percent = tonumber(string.sub(value, 1, -2)) / 100
        if useHeight then
            return vguix.ParseExtent(percent .. "ph", true)
        else
            return vguix.ParseExtent(percent .. "pw")
        end
    elseif string.EndsWith(value, "cw") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function()
            local font = self:GetSurfaceFont() -- vguix.Font(panel:GetCache("FontFamily"), panel:GetCache("FontSize"), panel:GetCache("FontWeight"), panel:GetCache("FontItalic"), panel:GetCache("FontStrikeout"))
            surface.SetFont(font)
            return surface.GetTextSize(" ") * percent
        end)

        f.Value = percent
        f.Mode = "cw"
        return f
    elseif string.EndsWith(value, "ch") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function()
            local font = self:GetSurfaceFont()
            surface.SetFont(font)
            local _, y = surface.GetTextSize(" ")
            return y * percent
        end)

        f.Value = percent
        f.Mode = "ch"
        return f
    elseif string.EndsWith(value, "ss") then
        local val = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() return ScreenScale(val) end)
        f.Value = val
        f.Mode = "ss"
        return f
    elseif string.EndsWith(value, "ssh") then
        local val = tonumber(string.sub(value, 1, -4))
        local f = wrapfunc(function() return ScreenScaleH(val) end)
        f.Value = val
        f.Mode = "ssh"
        return f
    elseif value == "auto" then
        if not useHeight then
            local f = wrapfunc(function()
                local w = self:ChildrenSizeEx()
                return w
            end)

            f.Mode = "auto"
            return f
        else
            
            local f = wrapfunc(function()
                local _, h = self:ChildrenSizeEx()
                return h
            end)

            f.Mode = "auto"
            return f
        end
            
    else
        error("Invalid extent value: " .. tostring(value))
    end
end

local PANEL = FindMetaTable("Panel")
do
    function PANEL:Invoke(func, ...)
        local p = self
        while p do
            local f = p[func]
            
            if iscallable(f) then
                if f(p, self, ...) then
                    return true
                end
            end

            p = p:GetParent()
        end 
        return false
    end

    function PANEL:InvokeParent(func, ...)
        local p = self:GetParent()
        while p do
            local f = p[func]
            
            if iscallable(f) then
                if f(p, self, ...) then
                    return true
                end
            end

            p = p:GetParent()
        end 
        return false
    end

    function PANEL:InvokeChildren(func, ...)
        local function invokeChildren(p, ...)

            local f = p[func]
            if isfunction(f) then
                f(p, ...) 
            end

            for k, v in pairs(p:GetChildren()) do
                invokeChildren(v)
            end
        end

        for k, v in pairs(self:GetChildren()) do
            invokeChildren(v, ...)
        end
    end
end

function PANEL:ChildrenSizeEx()
    local w, h = 0, 0

    for k, v in pairs(self:GetChildren()) do
        if not v:GetVisible() or v.NoLayout then
            continue
        end

        local x, y, cw, ch = v:GetBounds()

        w = math.max(w, x + cw)
        h = math.max(h, y + ch)
    end

    return w, h
end

-- Properties
do
    PANEL._InvalidateLayout = PANEL._InvalidateLayout or PANEL.InvalidateLayout
    function PANEL:InvalidateLayout(force)

        LayoutMutex = LayoutMutex or {}

        hook.Run("Panel.InvalidateLayout", self, force)
        self._LayoutInvalidated = true

        if self.BeforeInvalidateLayout then
            self:BeforeInvalidateLayout(force)
        end
        
        local r = self:_InvalidateLayout(force)
        LayoutMutex = nil

        if self.AfterInvalidateLayout then
            self:AfterInvalidateLayout(force)
        end
        
        return r
    end

    local DockEnum = {
        ["FILL"] = FILL,
        ["LEFT"] = LEFT,
        ["RIGHT"] = RIGHT,
        ["TOP"] = TOP,
        ["BOTTOM"] = BOTTOM,
        ["NODOCK"] = NODOCK
    }

    PANEL._Dock = PANEL._Dock or PANEL.Dock
    function PANEL:Dock(value)
        if isstring(value) then
            value = DockEnum[string.upper(value)]
            assert(value, "Invalid dock value")
        end

        return self:_Dock(value)
    end
    
    PANEL._SetName = PANEL._SetName or PANEL.SetName
    function PANEL:SetName(name)
        self:GetFuncEnv()[name] = self
        
        if name ~= "Component" then
            self:InvokeParent("ChildSetName", name)
        end
        return self:_SetName(name)
    end

    function PANEL:ChildSetName(src, value)
        if self:GetName() ~= self.ClassName then
            self[value] = src
            return true
        end
    end

    PANEL._SetVisible = PANEL._SetVisible or PANEL.SetVisible
    function PANEL:SetVisible(value)
        self.NotVisible = not value
        return self:_SetVisible(value)
    end

    function PANEL:GetVisible(value)
        return self.NotVisible ~= true
    end

    function PANEL:GetFuncEnv(key)
        if not self.FuncEnv then
            self.FuncEnv = setmetatable({ self = self, Width = 0, Height = 0, X = 0, Y = 0 }, {
                __index = function (t, k)
                    local parent = self:GetParent()
                    if parent then
                        parent = parent:GetFuncEnv()
                    end

                    if k == "Parent" then
                        return parent
                    end

                    return rawget(t, k) or (parent and parent[k]) or _G[k]
                end
            })
        end

        if key then
            return self.FuncEnv[key]
        end

        return self.FuncEnv
    end

    function PANEL:SetFuncEnv(key, value)
        assert(isstring(key), "SetFuncEnv key must be a string")

        local fe = self:GetFuncEnv()
        fe[key] = value
    end

    function PANEL:SetEval(bool)
        self.Eval = bool
        self.LastEval = engine.TickCount()
        self:SetFuncEnv("Eval", bool)
    end

    function PANEL:GetEval(bool)
        return self:GetFuncEnv("Eval")
    end

    function PANEL:ShouldEval()
        if self:GetParent() and not self:GetParent():ShouldEval() then
            self:SetFuncEnv("Eval", r)
            return false
        end

        if self.LastEval == engine.TickCount() then
            return self:GetFuncEnv("Eval")
        end

        local f = self:GetComputed("Eval")
        if f then
            local r = f.Func(self, w, h)
            self:SetFuncEnv("Eval", r)
            self.Eval = r
    
            if not r then
                return false
            end
        end
        
        self.LastEval = engine.TickCount()

    end

    function PANEL:InvalidateChildrenEx(recursive, immediate, topDown)
        if topDown then
            self:InvalidateLayout(immediate)
        end
        
        for k, v in pairs(self:GetChildren()) do
            if recursive then
                v:InvalidateChildrenEx(recursive, immediate, topDown)
            else
                v:InvalidateLayout(immediate)
            end
        end

        if not topDown then
            self:InvalidateLayout(immediate)
        end
    end

    PANEL._SetWide = PANEL._SetWide or PANEL.SetWide
    function PANEL:SetWide(value)
        if isstring(value) then
            value = vguix.ParseExtent(value)

            if iscallable(value) then
                self:SetComputed("Wide", value)
                self:InvalidateLayout()
                return
            end
        end

        local fe = self:GetFuncEnv()

        if self.Debug and self.Debug["Wide"] then
            print(self, "SetWide", value, debug.getinfo(2).currentline, debug.getinfo(2).short_src)
        end

        fe.Width = value
        return self:_SetWide(value)
    end
    PANEL.SetWidth = PANEL.SetWide
    PANEL.GetWidth = PANEL.GetWide

    PANEL._SetTall = PANEL._SetTall or PANEL.SetTall
    function PANEL:SetTall(value)        
        if isstring(value) then
            value = vguix.ParseExtent(value, true)

            if iscallable(value) then
                self:SetComputed("Tall", value)
                self:InvalidateLayout()
                return
            end
        end

        if self.Debug and self.Debug["Tall"] then
            print(self, "SetTall", value)
        end

        self:GetFuncEnv().Height = value
        return self:_SetTall(value)
    end
    PANEL.SetHeight = PANEL.SetTall
    PANEL.GetHeight = PANEL.GetTall

    PANEL._SetSize = PANEL._SetSize or PANEL.SetSize
    function PANEL:SetSize(w, h)
        
        if isstring(w) then
            self:SetWide(w)
            w = nil
        end
        
        if isstring(h) then
            self:SetTall(h)
            h = nil
        end

        if w and h then
            local fe = self:GetFuncEnv()
            fe.Width = w
            fe.Height = h
                
            if self.Debug and (self.Debug["Width"] or self.Debug["Tall"]) then
                print(self, "SetSize", w, h, debug.getinfo(2).short_src, debug.getinfo(2).currentline)
            end

            self:_SetSize(w, h)
        elseif w then
            self:SetWide(w)
        elseif h then
            self:SetTall(h)
        end
    end

    function PANEL:IsWidthAuto()
        local widthFunction = self:GetComputed("Wide")
        if widthFunction and istable(widthFunction.Func) then
            return widthFunction.Func.Mode == "auto"
        end
        return false
    end

    function PANEL:IsHeightAuto()
        local heightFunction = self:GetComputed("Tall")
        if heightFunction and istable(heightFunction.Func) then
            return heightFunction.Func.Mode == "auto"
        end
        return false
    end

    PANEL._SetPos = PANEL._SetPos or PANEL.SetPos
    function PANEL:SetPos(x, y)
        local fe = self:GetFuncEnv()
        fe.X = x
        fe.Y = y
        return self:_SetPos(x, y)
    end

    PANEL._SetX = PANEL._SetX or PANEL.SetX
    function PANEL:SetX(x)
        
        if isstring(x) then
            x = vguix.ParseExtent(x)

            if iscallable(x) then
                self:SetComputed("X", x)
                self:InvalidateLayout()
                return
            end
        end

        self:GetFuncEnv().X = x
        return self:_SetX(x)
    end

    PANEL._SetY = PANEL._SetY or PANEL.SetY
    function PANEL:SetY(y)
        
        if isstring(y) then
            y = vguix.ParseExtent(y, true)

            if iscallable(y) then
                self:SetComputed("Y", y)
                self:InvalidateLayout()
                return
            end
        end

        self:GetFuncEnv().Y = y
        return self:_SetY(y)
    end

    function PANEL:GetSurfaceFont()
        local fe = self:GetFuncEnv()
        return vguix.Font(
            fe.FontName, 
            fe.FontSize, 
            fe.FontWeight, 
            fe.FontBlurSize, 
            fe.FontScanLines, 
            fe.FontAntiAlias, 
            fe.FontUnderline, 
            fe.FontItalic, 
            fe.FontStrikeOut, 
            fe.FontSymbol, 
            fe.FontRotary, 
            fe.FontShadow, 
            fe.FontAdditive, 
            fe.FontOutline, 
            fe.FontExtended
        )
    end

    function PANEL:Global(name)
        _G[name] = self
    end

    PANEL._DockPadding = PANEL._DockPadding or PANEL.DockPadding
    function PANEL:DockPadding(left, top, right, bottom)
        assert(left, "DockPadding requires at least a left value")

        if isstring(left) and not top then
            left, top, right, bottom = unpack(string.Split(left, ","))
        end

        top = top or left
        right = right or left
        bottom = bottom or top

        left = vguix.ParseExtent(left)
        top = vguix.ParseExtent(top, true)
        right = vguix.ParseExtent(right)
        bottom = vguix.ParseExtent(bottom, true)

        if iscallable(left) or iscallable(top) or iscallable(right) or iscallable(bottom) then
            self:SetComputed("DockPadding", function ()
                return iscallable(left) and left() or left, 
                    iscallable(top) and top() or top, 
                    iscallable(right) and right() or right, 
                    iscallable(bottom) and bottom() or bottom
            end)
            self:InvalidateLayout()
            return
        end
        
        return self:_DockPadding(left, top, right, bottom)
    end

    PANEL._DockMargin = PANEL._DockMargin or PANEL.DockMargin
    function PANEL:DockMargin(left, top, right, bottom)
        assert(left, "DockMargin requires at least a left value")

        if isstring(left) and not top then
            left, top, right, bottom = unpack(string.Split(left, ","))
        end

        top = top or left
        right = right or left
        bottom = bottom or top

        left = vguix.ParseExtent(left)
        top = vguix.ParseExtent(top, true)
        right = vguix.ParseExtent(right)
        bottom = vguix.ParseExtent(bottom, true)

        if iscallable(left) or iscallable(top) or iscallable(right) or iscallable(bottom) then
            self:SetComputed("DockMargin", function ()
                return iscallable(left) and left() or left, 
                    iscallable(top) and top() or top, 
                    iscallable(right) and right() or right, 
                    iscallable(bottom) and bottom() or bottom
            end)
            self:InvalidateLayout()
            return
        end
        
        return self:_DockMargin(left, top, right, bottom)
    end

    PANEL._SetCursor = PANEL._SetCursor or PANEL.SetCursor
    function PANEL:SetCursor(cursor, noPropagate)
        if not noPropagate then
            self:GetFuncEnv().Cursor = cursor
        end

        if cursor and cursor ~= "" then
            return self:_SetCursor(cursor)
        end
    end

    vguix.AccessorFunc(PANEL, "Hover", "Hover", "Boolean")
    vguix.AccessorFunc(PANEL, "HoverNoLayout", "HoverNoLayout", "Boolean")

    function PANEL:SetHover(value)
        
        if value then
            self:SetFuncEnv("IsHovered", false)
        else
            self:SetFuncEnv("IsHovered", nil)
        end
        
        self.Hover = value
    end

    vguix.AccessorFunc(PANEL, "Absolute", "Absolute", "Boolean")
    vguix.AccessorFunc(PANEL, "Grow", "Grow", "Boolean")

    AccessorFunc(PANEL, "Row", "Row", FORCE_NUMBER)
    AccessorFunc(PANEL, "Column", "Column", FORCE_NUMBER)
    AccessorFunc(PANEL, "RowSpan", "RowSpan", FORCE_NUMBER)
    AccessorFunc(PANEL, "ColSpan", "ColSpan", FORCE_NUMBER)

    vguix.AccessorFunc(PANEL, "MarginLeft", "MarginLeft", "X")
    vguix.AccessorFunc(PANEL, "MarginTop", "MarginTop", "Y")
    vguix.AccessorFunc(PANEL, "MarginRight", "MarginRight", "X")
    vguix.AccessorFunc(PANEL, "MarginBottom", "MarginBottom", "Y")

    function PANEL:SetMargin(left, top, right, bottom)
        assert(left, "Margin requires at least a left value")

        if isstring(left) and not top then
            left, top, right, bottom = unpack(string.Split(left, ","))
        end

        top = top or left
        right = right or left
        bottom = bottom or top

        self:SetMarginLeft(left)
        self:SetMarginTop(top)
        self:SetMarginRight(right)
        self:SetMarginBottom(bottom)
    end

    function PANEL:GetMargin()
        return self:GetMarginLeft(), self:GetMarginTop(), self:GetMarginRight(), self:GetMarginBottom()
    end

    function PANEL:SetComputed(property, func, order, options)
        assert(isstring(property), "Computed property name must be a string")
        assert(not func or iscallable(func), "Computed property " .. property .. ": function must be a function")
        assert(not order or isnumber(order), "Computed property order must be a number or nil")

        if property == "Width" then
            property = "Wide"
        end

        if property == "Height" then
            property = "Tall"
        end

        options = options or {}

        if not func then
            self.Computed[property] = nil
            return
        end
        
        if istable(func) then
            setfenv(getmetatable(func).__call, self:GetFuncEnv())
        else
            setfenv(func, self:GetFuncEnv())
        end

        local existing = self.Computed[property]
        if existing then

            if order and existing.Order ~= order then
                setmetatable(self.Computed, nil) -- Invalidate the cache
            end

            t = existing
            t.Name = property
            t.Func = func
            t.Order = order or t.Order

            table.Merge(t.Options, options)
        else
            local t = {
                Name = property,
                Func = func,
                Order = order or 1,
                Options = options
            }
            setmetatable(self.Computed, nil) -- Invalidate the cache
            self.Computed[property] = t
        end
    end

    function PANEL:GetComputed(property)
        if not self.Computed then
            return nil
        end

        if not property then
            local mt = getmetatable(self.Computed)
            if not mt then
                mt = table.ClearKeys(self.Computed)
                table.sort(mt, function (a, b)
                    return a.Order < b.Order
                end)

                setmetatable(self.Computed, mt)
            end
            return mt
        end

        return self.Computed[property]
    end
end


-- DPanel
local DPanel = vgui.GetControlTable("DPanel")
DPanel._SetBackgroundColor = DPanel._SetBackgroundColor or DPanel.SetBackgroundColor
function DPanel:SetBackgroundColor(color)
    if isstring(color) then        
        local parts = string.Split(color:Replace("Color", ""):Replace("(", ""):Replace(")", ""), ",")
        color = Color(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]) or 255)
    end

    return self:_SetBackgroundColor(color)
end 

local WorldPanel = vgui.GetWorldPanel()
do
    WorldPanel.FuncEnv = {
        X = 0,
        Y = 0,
        Width = ScrW(),
        Height = ScrH(),

        FontName = system.IsOSX() and "Helvetica" or "Tahoma",
        FontSize = 5,
        FontWeight = 300,
        FontColor = color_white,
        FontItalic = false,
        FontUnderline = false,
        FontStrikeOut = false,
        FontExtended = false,
        FontBlurSize = 0,
        FontScanLines = 0,
        FontAntiAlias = true,
        FontSymbol = false,
        FontRotary = false,
        FontShadow = false,
        FontAdditive = false,
        FontOutline = false,
        Eval = true
    }    

    hook.Add("OnScreenSizeChanged", "WorldPanel.OnScreenSizeChanged", function (w, h)
        FontData = 0

        WorldPanel.FuncEnv.Width = w
        WorldPanel.FuncEnv.Height = h
        WorldPanel:InvalidateChildren(true)
    end)
    
end




local DMenu = vgui.GetControlTable("DMenu")
DMenu.NoLayout = true


--[[
    <Panel>
        <Paint>
            <Rect />
            <TexturedRect />
            <Mesh :Display></Mesh>
        </Paint>
    </Panel>
]]