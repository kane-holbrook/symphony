AddCSLuaFile()
if SERVER then
    return
end


local bp = FindMetaTable("Panel")

-- Parentage
-- Extents
-- Transitions
local WorldPanel
function Interface.GetWorldPanel()
    return WorldPanel
end

local function BaseExtent(panel, prop, value, useHeight)
    local tn = tonumber(value)
    if isnumber(tn) then
        panel:SetPropertyComputed(prop, nil)
        return tn
    else
        value = string.lower(value)
    end

    if isfunction(value) then
        panel:SetPropertyComputed(prop, value)
        return nil
    elseif string.EndsWith(value, "px") then
        panel:SetPropertyComputed(prop, nil)
        return tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "pw") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() 
            if self.DebugProperties.Bounds then
                El = self
            end
            return percent * (Parent.Width - Parent:GetPaddingLeft() - Parent:GetPaddingRight()) 
        end)
        f.Value = percent
        f.Mode = "pw"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "ph") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() return percent * (Parent.Height - Parent:GetPaddingTop() - Parent:GetPaddingBottom()) end)
        f.Value = percent
        f.Mode = "ph"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "vw") then
        local percent = tonumber(string.sub(value, 1, -3)) / 100
        local f = wrapfunc(function() return percent * ScrW() end)
        f.Value = percent
        f.Mode = "vw"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "vh") then
        local percent = tonumber(string.sub(value, 1, -3)) / 100
        local f = wrapfunc(function() return percent * ScrH() end)
        f.Value = percent
        f.Mode = "vh"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "%") then
        local percent = tonumber(string.sub(value, 1, -2)) / 100
        if useHeight then
            return BaseExtent(panel, prop, percent .. "ph")
        else
            return BaseExtent(panel, prop, percent .. "pw")
        end
        return nil
    elseif string.EndsWith(value, "cw") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function()
            local font = Interface.Font(panel:GetCache("FontFamily"), panel:GetCache("FontSize"), panel:GetCache("FontWeight"))
            surface.SetFont(font)
            return surface.GetTextSize(" ") * percent
        end)

        f.Value = percent
        f.Mode = "cw"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "ch") then
        local percent = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function()
            local font = Interface.Font(panel:GetCache("FontFamily"), panel:GetCache("FontSize"), panel:GetCache("FontWeight"))
            surface.SetFont(font)
            local _, y = surface.GetTextSize(" ")
            return y * percent
        end)

        f.Value = percent
        f.Mode = "ch"
        panel:SetPropertyComputed(prop, f)
    elseif string.EndsWith(value, "ss") then
        local val = tonumber(string.sub(value, 1, -3))
        local f = wrapfunc(function() return ScreenScale(val) end)
        f.Value = val
        f.Mode = "ss"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif string.EndsWith(value, "ssh") then
        local val = tonumber(string.sub(value, 1, -4))
        local f = wrapfunc(function() return ScreenScaleH(val) end)
        f.Value = val
        f.Mode = "ssh"
        panel:SetPropertyComputed(prop, f)
        return nil
    elseif value == "auto" then
        if useHeight then
            local f = wrapfunc(function()
                return self.Height -- Calculated in CalculateBounds
            end)

            f.Mode = "auto"
            panel:SetPropertyComputed(prop, f)
        else
            
            local f = wrapfunc(function()
                return self.Width -- Calculated in CalculateBounds
            end)

            f.Mode = "auto"
            panel:SetPropertyComputed(prop, f)
        end
        return nil
    elseif value == "fill" then
        local f = wrapfunc(function()
            return useHeight and self.Height or self.Width
        end)

        f.Mode = "fill"
        panel:SetPropertyComputed(prop, f)
        return nil
    else
        error("Invalid extent value: " .. tostring(value))
    end
end

function Interface.ExtentX(pnl, prop, value)
    return BaseExtent(pnl, prop, value)
end

function Interface.ExtentY(pnl, prop, value)
    return BaseExtent(pnl, prop, value, true)
end

Rect = Type.Register("Rect", nil, {
    VGUI = "EditablePanel"
})

Rect:CreateProperty("Panel")
Rect:CreateProperty("Debug", Type.Boolean, { Default = false })
Rect:CreateProperty("Name", Type.String, { Set = function (pnl, value)
    if value then
        pnl:SetName(value)
    else
        local c = pnl:GetController()
        pnl:SetName(c:GetType():GetName() .. "[" .. c:GetId() .. "]")
    end
end, Get = bp.GetName })
Rect:CreateProperty("Parent")
Rect:CreateProperty("FontFamily", Type.String)
Rect:CreateProperty("FontSize", Type.Number)
Rect:CreateProperty("FontWeight", Type.Number)
Rect:CreateProperty("FontColor", Type.Color)
Rect:CreateProperty("FontShadow", Type.Number)
Rect:CreateProperty("FontAdditive", Type.Boolean)

Rect:CreateProperty("PaddingLeft", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("PaddingTop", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentY
})

Rect:CreateProperty("PaddingRight", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("PaddingBottom", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentY
})

Rect:CreateProperty("Width", Type.Number, {
    Manual = true,
    Parse = Interface.ExtentX,
    Set = bp.SetWide,
    Get = bp.GetWide,
    Default = 0
})

Rect:CreateProperty("Height", Type.Number, {
    Manual = true,
    Parse = Interface.ExtentY,
    Set = bp.SetTall,
    Get = bp.GetTall,
    Default = 0
})

Rect:CreateProperty("X", Type.Number, {
    Manual = true,
    Parse = Interface.ExtentX,
    Set = bp.SetX,
    Get = bp.GetX,
    Default = 0
})

Rect:CreateProperty("Y", Type.Number, {
    Manual = true,
    Parse = function (self, name, value)
        return Interface.ExtentY(self, name, value)
    end,
    Set = bp.SetY,
    Get = bp.GetY,
    Default = 0
})
Rect:CreateProperty("Hover", Type.Boolean, { Default = false })
Rect:CreateProperty("IsHovered", Type.Boolean)

Rect:CreateProperty("Display", Type.Boolean, {
    Default = true,
    Manual = true
})

Rect:CreateProperty("SuppressLayout", Type.Boolean, {
    Default = false
})

Rect:CreateProperty("Align", Type.Number, { Manual = true, Default = 7, Parse = function (pnl, prop, value)
    if isstring(value) and value == "false" then
        return nil
    else
        return tonumber(value)
    end
end })
Rect:CreateProperty("Flow", Type.String, {
    Default = "X"
})

Rect:CreateProperty("Grow", Type.Boolean, {
    Default = false
})

Rect:CreateProperty("Gap", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("MarginLeft", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("MarginTop", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentY
})

Rect:CreateProperty("MarginRight", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("MarginBottom", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentY
})

Rect:CreateProperty("Absolute", Type.Boolean, {
    Default = false
})

Rect:CreateProperty("Fill", Type.Color)
Rect:CreateProperty("Material", Type.Any, {
    Parse = function(self, name, value)
        if isstring(value) then
            return Material(value)
        else
            return value
        end
    end,
})
Rect:CreateProperty("Repeat", Type.Boolean, {
    Default = false
})

Rect:CreateProperty("U", Type.Number, {
    Default = 0
})

Rect:CreateProperty("V", Type.Number, {
    Default = 0
})

Rect:CreateProperty("FillScale", Type.Number, {
    Default = 1
})

Rect:CreateProperty("Stroke", Type.Color, { Default = color_white })
Rect:CreateProperty("StrokeWidth", Type.Number, {
    Default = 0,
    Parse = Interface.ExtentX
})

Rect:CreateProperty("Static", Type.Boolean, {
    Default = false
})

Rect:CreateProperty("Shape", Type.Table, { Manual = true })

Rect:CreateProperty("Cursor", Type.String, { 
    Set = function (pan, name, value)
        value = value or pan:GetController().Cache.Cursor or ""
        pan:SetCursor(value)        
    end
})
Rect:CreateProperty("Popup", Type.Boolean, { Manual = true })


function Rect.Prototype:GetPadding()
    return self:GetPaddingLeft(), self:GetPaddingTop(), self:GetPaddingRight(), self:GetPaddingBottom()
end

function Rect.Prototype:GetMargin()
    return self:GetMarginLeft(), self:GetMarginTop(), self:GetMarginRight(), self:GetMarginBottom()
end

function Rect.Metamethods:__tostring()
    return self:GetType():GetName() .. "[" .. (self:GetName() or self:GetId()) .. "]"
end

function Rect.Prototype:Initialize(id)
    self.DebugProperties = {}
    self.Cache = setmetatable({
        self = self
    }, {
        __index = function(t, k)

            local p = self:GetParent()
            if k == "Parent" then
                return p and p.Cache 
            end
            return rawget(t, k) or self[k] or (p and p.Cache[k]) or _G[k]
        end
    })

    self.Children = {}
    self.Computed = {}
    self.Transitions = {}
    self.Events = {}
    self.Hooked = {}

    self:SetSize("auto", "auto")

    self:LoadFromXML()

    self.Initialized = true
end

function Rect.Prototype:LoadFromXML()
    local typ = self:GetType()
    if not typ.Xml then
        return
    end

    typ:CreateFromNode(nil, typ.Xml, self)
end

function Rect.Prototype:SetPadding(l, t, r, b)
    if isstring(l) and string.find(l, ",") then
        l, t, r, b = unpack(string.Split(l, ","))
    end

    self:SetPaddingLeft(l)
    self:SetPaddingTop(t or l)
    self:SetPaddingRight(r or l)
    self:SetPaddingBottom(b or t or l)
end

function Rect.Prototype:SetMargin(l, t, r, b)
    if isstring(l) and string.find(l, ",") then
        l, t, r, b = unpack(string.Split(l, ","))
    end

    self:SetMarginLeft(l)
    self:SetMarginTop(t or l)
    self:SetMarginRight(r or l)
    self:SetMarginBottom(b or t or l)
end

function Rect.Prototype:GetFont()
    return Interface.Font(self.Cache.FontFamily, self.Cache.FontSize, self.Cache.FontWeight)
end

local notex = Material("vgui/white")
function Rect.Prototype:Paint(w, h)
    local fcol = self:GetFill()
    local poly = self:GetShape() and self.Poly
    if fcol then
        local mat = self:GetMaterial() or notex
        if isfunction(mat) then
            mat = mat(self, w, h)
        end

        surface.SetMaterial(mat)
        surface.SetDrawColor(fcol)

        if poly then
            surface.DrawPoly(poly)
        else
            if self:GetRepeat() then
                local scale = self:GetFillScale()
                local u, v = self:GetU(), self:GetV()
                local texW, texH = mat:Width(), mat:Height()
                local uSpan = w / (texW / scale)
                local vSpan = h / (texH / scale)
                surface.DrawTexturedRectUV(0, 0, w, h, u, v, u + uSpan, v + vSpan)
            else
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end
    end

    local strokeW = self:GetStrokeWidth()
    if strokeW > 0 then

        surface.SetDrawColor(self:GetStroke())
        if poly then
            local s = self:GetShape()
            local cx, cy = w/2, h/2
            local sx, sy = s[1], s[2]
            for i=1, #s, 2 do
                local x1 = s[i]
                local y1 = s[i + 1]
                local x2 = s[i + 2] or sx
                local y2 = s[i + 3] or sy

                local addX = x1 < cx and 1 or -1
                local addY = y1 < cy and 1 or -1
                local addX2 = x2 < cx and 1 or -1
                local addY2 = y2 < cy and 1 or -1

                for l=1, strokeW do
                    surface.DrawLine(x1 + (l * addX), y1 + (l * addY), x2 + (l * addX2), y2 + (l * addY2), w, y)
                end
            end
        else
            surface.DrawOutlinedRect(0, 0, w, h, strokeW)
        end
    end

    for k, v in pairs(self:GetChildren()) do
        if v:GetStatic() then
            local pos = Vector(v:GetX(), v:GetY(), 0)
            local mm = Matrix()
            mm:Translate(pos)
            cam.PushModelMatrix(mm, true)
                v:Paint(v:GetWidth(), v:GetHeight())
            cam.PopModelMatrix()

            if v:GetDebug() or v.DebugProperties.Paint then
                print(self, "Static:Paint", v:GetName(), pos.x, pos.y, v:GetWidth(), v:GetHeight())
            end
        end
    end

    self:PaintTransitions(w, h)
end

function Rect.Prototype:PaintTransitions(w, h)
    local now = CurTime()
    for key, t in pairs(self.Transitions) do
        local delta = math.min(1, (now - t.startTime) / (t.endTime - t.startTime))
        local eased = t.ease(delta)
        local value = Lerp(eased, t.from, t.to)
        t.current = value
        self:SetProperty(key, value, true)
        self:RenderProperty(key) -- force render
        if delta >= 1 then self.Transitions[key] = nil end
    end
end

function Rect.Prototype:GetChildren()
    return self.Children
end

function Rect.Prototype:OnChildAdded(child)
    if self.Initialized and IsValid(self._Default) then
        child:SetParent(self._Default)
    end
end

function Rect.Prototype:OnChildRemoved(child)
end

function Rect.Prototype:SetProperty(name, value, noParse)
    local p = Type.GetType(self):GetPropertiesMap()[name]
    local opt
    if p then
        opt = p.Options
        if opt.Parse and not noParse then
            value = opt.Parse(self, name, value)
        elseif p.Type and not p.Options.NoValidate then
            assert(value == nil or Type.Is(value, p.Type), tostring(self) .. ": Property " .. name .. " expects " .. p.Type:GetName() .. " but got " .. Type.GetType(value):GetName())
        end
    end

    local old = self[name]
    self[name] = value
    self.Cache[name] = value
    self:OnPropertyChanged(name, value, old)
end

function Rect.Prototype:SetPropertyComputed(name, func)
    if istable(func) then
        setfenv(func:GetFunction(), self.Cache)
    elseif isfunction(func) then
        setfenv(func, self.Cache)
    end

    self.Computed[name] = func
end

function Rect.Prototype:GetPropertyComputed(name)
    return self.Computed[name]
end
Rect.Prototype.GetComputedProperty = Rect.Prototype.GetPropertyComputed

function Rect.Prototype:Transition(name, to, duration, ease, relayout)
    self.Transitions = self.Transitions or {}
    local transition = self.Transitions[name] or {}
    local from = transition.current or self:GetProperty(name) -- fallback to target to avoid snap on first run
    local startTime = CurTime()
    local endTime = startTime + duration
    local easingFunc = ease or math.ease.InOutQuad -- fallback to a reasonable default
    transition.from = from
    transition.to = to
    transition.startTime = startTime
    transition.endTime = endTime
    transition.ease = easingFunc
    transition.relayout = relayout
    -- Cache the current state
    transition.current = from
    self.Transitions[name] = transition
    self:SetPropertyComputed(name, nil)
end

function Rect.Prototype:Emit(event, ...)
    if self:OnReceive(self, event, ...) then return true end
    local p = self:GetParent()
    while p do
        if p:OnReceive(self, event, ...) then 
            return true 
        end
        p = p:GetParent()
    end
    return false
end

function Rect.Prototype:OnReceive(source, event, ...)
    if event == "CursorEntered" then
        if self:OnCursorEntered(source) then
            return true
        end
    elseif event == "CursorExited" then
        if self:OnCursorExited(source) then
            return true
        end
    end

    local f = self.Events[event]
    if f then 
        return f(source, ...) 
    end
end

function Rect.Prototype:Listen(event, func)
    setfenv(func, self.Cache)
    self.Events[event] = func
end


function Rect.Prototype:RenderProperty(name, force)
    
    local opt = self:GetType():GetPropertiesMap()[name]
    assert(opt)
    
    if not force and opt.Debounce then
        debounce(self:GetId() .. ":" .. name, 0.1, function()
            self:RenderProperty(name, true)
        end)
        return
    end

    local f = self.Computed[name]
    local value
    if f then 
        local succ, v = xpcall(f, function (msg)
            ErrorNoHaltWithStack(tostring(self) .. ": Property " .. name .. " failed to render: " .. msg)
        end, self)
        
        if not succ then
            return
        end

        value = v 

        self:SetProperty(name, value, true)
    else
        value = self:GetProperty(name)
    end
    
    local panel = self:GetPanel()
    if IsValid(panel) then
        value = self:GetProperty(name)

        local setter = opt.Options.Set
        if setter then
            local getter = opt.Options.Get
            if getter then
                local current = getter(panel)
                if current == value and not force then 
                    return value
                end
            end

            setter(panel, value)
        end
    end

    return value
end

function Rect.Prototype:GetPos()
    return self:GetX(), self:GetY()
end

function Rect.Prototype:SetPos(x, y)
    self:SetX(x)
    self:SetY(y)
end

function Rect.Prototype:GetSize()
    return self:GetWidth(), self:GetHeight()
end

function Rect.Prototype:SetSize(w, h)
    self:SetWidth(w)
    self:SetHeight(h)
end

function Rect.Prototype:OnPropertyChanged(name, value, old)
    if self:GetDebug() or self.DebugProperties[name] then
        local st = debug.getinfo(3, "Sl")
        print(self, "OnPropertyChanged", name, value, old, st.short_src, st.currentline)
    end

    if name == "Name" then
        local p = self:GetParent()
        --while p and not p:GetName() do
        --    p = p:GetParent()
        --end

        if p then
            assert(not p[value] or p[value] == self, "Conflicting ref name: " .. value)
            p[value] = self
            
            if old then 
                p[old] = nil 
            end
        end
        return true
    end

    if name == "Parent" then
        local ref = self:GetName()
        if old then
            table.RemoveByValue(old.Children, self)
            if ref then 
                old[ref] = nil 
            end
            old:OnChildRemoved(self)
        end

        if value then
            table.insert(value.Children, self)
            if ref then
                assert(not value[ref] or value[ref] == self, "Duplicate name: " .. ref)
                value[ref] = self
            end
            value:OnChildAdded(self)
        end
        return true
    end
end

function Rect.Prototype:InvalidateLayout(layoutNow)
    self.LayoutScheduled = true

    if layoutNow then
        self:PerformLayout()
    else
        debounce(self:GetId(), 0, function()
            self:PerformLayout()
        end)
    end
end

function Rect.Prototype:CancelLayout()
    cancelDebounce(self:GetId())
end

function Rect.Prototype:IsVisible()
    if not self:GetDisplay() then
        return false     
    end

    local p = self:GetParent()
    if p and not p:IsVisible() then 
        return false 
    end

    return true
end

function Rect.Prototype:GetCache(key)
    if not key then return self.Cache end
    return self.Cache[key]
end

function Rect.Prototype:OnStartDisplay()
end

function Rect.Prototype:OnStopDisplay()
end

function Rect.Prototype:PerformLayout()
    if self:GetSuppressLayout() then
        return
    end

    local root = false
    if not Interface.LayoutMutex then
        Interface.LayoutMutex = {} -- Just to get a unique mutex for this layout pass
        root = true
    end

    if not self.LastLayout then
        for k, v in pairs(self.Hooked) do
            hook.Add(k, v.key, v.func)
        end
    end

    self:RenderProperty("Display")

    local TypeOptions = self:GetType():GetOptions()
    -- Handle display
    local isvisible = self:IsVisible()
    local pnl = self:GetPanel()
    local parent = self:GetParent()
    if isvisible and not pnl then
        if not self:GetStatic() and TypeOptions.VGUI then
            pnl = vgui.Create(TypeOptions.VGUI, parent:GetPanel())
            pnl.Controller = self

            self:SetPanel(pnl, parent:GetPanel())

            if self.Paint then 
                pnl.Paint = function(p, w, h) return self:Paint(w, h, p) end 
            end

            if self.TestHover then
                pnl.TestHover = function(p, x, y) return self:TestHover(x, y) end
            end

            if self.OnCursorEntered then
                pnl.OnCursorEntered = function(p) self:OnCursorEntered() end
            end

            if self.OnCursorExited then
                pnl.OnCursorExited = function(p) self:OnCursorExited() end
            end

            if self.OnMousePressed then
                pnl.OnMousePressed = function(p, m) self:OnMousePressed(m) end
            end

            if self.OnMouseReleased then
                pnl.OnMouseReleased = function(p, m) self:OnMouseReleased(m) end
            end

            if self.OnMouseWheeled then
                pnl.OnMouseWheeled = function(p, delta) self:OnMouseWheeled(delta) end
            end

            if self.OnKeyPressed then
                pnl.OnKeyPressed = function(p, key) self:OnKeyPressed(key) end
            end

            if self.OnKeyReleased then
                pnl.OnKeyReleased = function(p, key) self:OnKeyReleased(key) end
            end

            if self.OnCursorMoved then
                pnl.OnCursorMoved = function(p, x, y) self:OnCursorMoved(x, y) end
            end

            if self:GetPopup() then
                pnl:MakePopup()
            end

            self:OnStartDisplay()
        end
    elseif pnl and not isvisible then
        self:OnStopDisplay()
        pnl:Remove()
        self:SetPanel(nil)
    end

    local w, h, changed = self:CalculateBounds()

    -- Now the shape
    local shape = self:RenderProperty("Shape")
    if shape then
        local poly = {
        }
        
        local idx = 1
        for i=1, #shape, 2 do
            local x2 = shape[i]
            local y2 = shape[i + 1]

            poly[idx] = {
                x = x2,
                y = y2,
                u = x2/w,
                v = y2/h
            } 
            idx = idx + 1
        end
        self.Poly = poly
    end

    local props = self:GetType():GetProperties()
    for k, v in pairs(props) do
        if v.Options.Manual then 
            continue 
        end
        self:RenderProperty(v.Name)
    end

    for k, v in pairs(self:GetChildren()) do
        v:PerformLayout()
    end

    --self:LayoutChildren()

    if root then
        Interface.LayoutMutex = nil
    end

    self.LastLayout = engine.TickCount()
    self.LayoutScheduled = false

    return
end

function Rect.Prototype:TestHover(x, y)
    local p = self:GetPanel()
    local v = Vector(x, y)
    local abs = Vector(p:LocalToScreen(0, 0))

    return v:WithinAABox(abs, abs + Vector(self:GetWidth(), self:GetHeight()))
end

function Rect.Prototype:OnCursorEntered(src)
    
    if self:GetDebug() or self.DebugProperties[name] then
        print(self, "CursorEntered", src)
    end

    if self:GetHover() then
        self:SetIsHovered(true)
        self:InvalidateLayout(true)

        if self:GetDebug() or self.DebugProperties[name] then
            print(self, "CursorEntered", src)
        end
        return true
    end

    if not src then
        self:Emit("CursorEntered")
    end
end

function Rect.Prototype:OnCursorExited(src)
    if self:GetHover() then
        self:SetIsHovered(nil)
        if self:GetDebug() or self.DebugProperties[name] then
            print(self, "CursorExited", src)
        end
        self:InvalidateLayout(true)
        return true
    end
    
    if not src then
        self:Emit("CursorExited")
    end
end

function Rect.Prototype:OnMousePressed(m)
    self:Emit("MousePressed", m)
end

function Rect.Prototype:OnMouseReleased(m)
    self:Emit("MouseReleased", m)
end

function Rect.Prototype:OnKeyPressed(key)
    self:Emit("KeyPressed", key)
end

function Rect.Prototype:OnKeyReleased(key)
    self:Emit("KeyReleased", key)
end

function Rect.Prototype:OnMouseWheeled(delta)
    self:Emit("MouseWheeled", delta)
end

function Rect.Prototype:IsWidthAuto()
    local widthFunction = self:GetPropertyComputed("Width")
    if istable(widthFunction) then
        return widthFunction.Mode == "auto"
    end
    return false
end

function Rect.Prototype:IsHeightAuto()
    local heightFunction = self:GetPropertyComputed("Height")
    if istable(heightFunction) then
        return heightFunction.Mode == "auto"
    end
    return false
end

function Rect.Prototype:IsSizingAuto()
    local boundaryFunctions = {self:GetPropertyComputed("X"), self:GetPropertyComputed("Y"), self:GetPropertyComputed("Width"), self:GetPropertyComputed("Height")}
    for k, v in pairs(boundaryFunctions) do
        if istable(v) then 
            if v.Mode == "auto" then 
                return true 
            end 
        else
            continue
        end
    end
    return false
end


function Rect.Prototype:StartStencil(invert)
    draw.NoTexture()

    render.SetStencilEnable(true)

    render.ClearStencil()
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)

    render.SetStencilReferenceValue(9)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    
    surface.SetDrawColor(color_black)
    self:DrawStencil()
    
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilCompareFunction(invert and STENCILCOMPARISONFUNCTION_NOTEQUAL or STENCILCOMPARISONFUNCTION_EQUAL)

    surface.SetDrawColor(255, 255, 255, 255)
end

function Rect.Prototype:DrawStencil()
    local poly = self:GetShape() and self.Poly
    if poly then
        surface.DrawPoly(poly)
    else
        surface.DrawRect(0, 0, self:GetWidth(), self:GetHeight())
    end
end

function Rect.Prototype:FinishStencil()
    render.SetStencilEnable(false)
end

function Rect.Prototype:GetChildrenSize()
    local x, y = 0, 0
    local w, h = 0, 0

    for k, v in pairs(self:GetChildren()) do
        if v:GetDisplay() then
            x = math.max(x, v:GetX())
            y = math.max(y, v:GetY())
            w = math.max(w, v:GetX() + v:GetWidth())
            h = math.max(h, v:GetY() + v:GetHeight())
        end
    end
    return w, h, x, y
end

function Rect.Prototype:IsAlignable()
    return self:GetDisplay() and not self:GetAbsolute()
end

function Rect.Prototype:IsWidthFill()
    local widthFunction = self:GetPropertyComputed("Width")
    if istable(widthFunction) then
        return widthFunction.Mode == "fill"
    end
    return false
end

function Rect.Prototype:IsHeightFill()
    local heightFunction = self:GetPropertyComputed("Height")
    if istable(heightFunction) then
        return heightFunction.Mode == "fill"
    end
    return false
end

function Rect.Prototype:CalculateBounds(force)
    local lw, lh = self:GetWidth(), self:GetHeight()

    local w, h = self:RenderProperty("Width"), self:RenderProperty("Height")
    local pl, pt, pr, pb = self:RenderProperty("PaddingLeft") or 0, self:RenderProperty("PaddingTop") or 0, self:RenderProperty("PaddingRight") or 0, self:RenderProperty("PaddingBottom") or 0
    local rerenderWidth, rerenderHeight

    -- Firstly, calculate bounds for all our children.
    for k, v in pairs(self:GetChildren()) do
        if v:GetDisplay() then
            v:CalculateBounds()
        end
    end

    local align = self:RenderProperty("Align")

    if align then
        assert(align <= 9 and align >= 1, "Invalid align: " .. tostring(align))
             
        local ltr = self:GetFlow() == "X"

        local gap = self:RenderProperty("Gap")
        
        local growElement
        local cw, ch, tw, th = 0, 0, -gap, -gap
        local numNonGrowElements = 0, 0

        for k, v in pairs(self:GetChildren()) do
            if not v:IsAlignable() then
                continue
            end

            v:RenderProperty("MarginTop")
            v:RenderProperty("MarginLeft")
            v:RenderProperty("MarginRight")
            v:RenderProperty("MarginBottom")

            if v:IsWidthFill() or v:IsHeightFill() then
                growElement = v

                if ltr then
                    assert(not v:IsHeightFill(), "Element with 'Fill' width cannot have 'fill' height in X flow")
                else
                    assert(not v:IsWidthFill(), "Element with 'Fill' height cannot have 'fill' width in Y flow")
                end
            else
                local vw = v:GetWidth() + v:GetMarginLeft() + v:GetMarginRight()
                local vh = v:GetHeight() + v:GetMarginTop() + v:GetMarginBottom()

                cw = math.max(cw, vw)
                ch = math.max(ch, vh)
                tw = tw + vw + gap
                th = th + vh + gap

                numNonGrowElements = numNonGrowElements + 1
            end
        end

        if self:IsWidthAuto() then
            w = ltr and tw + pl + pr or cw + pl + pr
        end

        if self:IsHeightAuto() then
            h = ltr and ch + pt + pb or th + pt + pb
        end

        if growElement then
            if ltr then
                local sz = w - tw - pl - pr - (gap * (numNonGrowElements - 1))

                growElement.Width = sz
                growElement:RenderProperty("Width")

                local vw = sz + growElement:GetMarginLeft() + growElement:GetMarginRight()
                cw = math.max(cw, vw)
                tw = tw + vw + gap
            else
                local sz = h - th - pt - pb - (gap * (numNonGrowElements - 1))

                growElement.Height = sz
                growElement:RenderProperty("Height")

                local vh = sz + growElement:GetMarginTop() + growElement:GetMarginBottom()
                ch = math.max(ch, vh)
                th = th + vh + gap
            end
        end

        local x, y
        if isany(align, 7, 4, 1) then
            x = pl
        elseif isany(align, 9, 6, 3) then
            x = w - pr
        else 
            x = w/2 - tw/2
        end

        if isany(align, 7, 8, 9) then
            y = pt
        elseif isany(align, 1, 2, 3) then
            y = h - pt
        else 
            y = h/2 - th/2
        end

        for k, v in pairs(self:GetChildren()) do
            if not v:IsAlignable() then
                continue
            end
            
            local ml, mt, mr, mb = v:RenderProperty("MarginLeft"), v:RenderProperty("MarginTop"), v:RenderProperty("MarginRight"), v:RenderProperty("MarginBottom")
            if ltr then
            
                if isany(align, 7, 4, 1, 8, 5, 2) then
                    x = x + ml
                    v:SetX(x)
                    x = x + v:GetWidth() + gap + mr
                    h = math.max(h, pt + v:GetHeight() + mb + mt)
                else
                    x = x - v:GetWidth() - mr
                    v:SetX(x)
                    x = x - ml - gap

                    h = math.max(h, pt + v:GetHeight() + mb + mt)
                end
                
                if isany(align, 4, 5, 6) then
                    v:SetY((h/2) - (v:GetHeight()/2))
                elseif isany(align, 1, 2, 3) then
                    v:SetY(h - v:GetHeight() - pb)
                else
                    v:SetY(y + mt)
                end
            else
                if isany(align, 7, 8, 9, 4, 5, 6) then
                    y = y + mt
                    v:SetY(y)
                    y = y + v:GetHeight() + gap + mb
                    w = math.max(w, pl + v:GetWidth() + mr + ml)
                else
                    y = y - v:GetHeight() - mb
                    v:SetY(y)
                    y = y - mt - gap

                    w = math.max(w, pl + v:GetWidth() + mr + ml)
                end
                
                if isany(align, 8, 5, 2) then
                    v:SetX((w/2) - (v:GetWidth()/2))
                elseif isany(align, 9, 6, 3) then
                    v:SetX(w - v:GetWidth() - pr - mr)
                else
                    v:SetX(x + ml)
                end
            end
        end
        
        if self:IsWidthAuto() then
            self.Width = w
            rerenderWidth = true
        end

        if self:IsHeightAuto() then
            self.Height = h
            rerenderHeight = true
        end
    else
        local cw, ch = self:GetChildrenSize()
        self.Width, self.Height = cw, ch
        rerenderWidth = true
        rerenderHeight = true
    end

    self:RenderProperty("X")
    self:RenderProperty("Y")
    
    if rerenderWidth then
        w = self:RenderProperty("Width") 
    end
    
    if rerenderHeight then
        h = self:RenderProperty("Height")
    end

    return w, h, w ~= lw or h ~= lh
end

function Rect.Prototype:LayoutChildren()
    if self:GetSuppressLayout() then 
        return 
    else
        return
    end
    
    self:SetSuppressLayout(true)
    local align = self:GetAlign()
    if not align then
        self:SetSuppressLayout(false)
        return true
    end

    local w, h = self:GetWidth(), self:GetHeight()
    local flowDirection = self:GetFlow()
    local gap = self:GetGap()
    local pl, pt, pr, pb = self:GetPadding()
    local children = self:GetChildren()
    local tw, th = 0, 0
    local growElement

    for k, child in pairs(children) do
        if child:GetAbsolute() or not child:GetDisplay() then continue end
        local cl, ct, cr, cb = child:GetMargin()
        if child:GetGrow() then
            assert(not growElement, "Can only have one element set to Grow within a child.")
            growElement = child
            tw = tw + cr + cl + gap
            th = th + ct + cb + gap
        else
            tw = tw + child:GetWidth() + cr + cl + gap
            th = th + child:GetHeight() + ct + cb + gap
        end
    end

    tw = tw - gap + pl + pr
    th = th - gap + pt + pb
    if growElement then
        local cl, ct, cr, cb = growElement:GetMargin()
        if flowDirection == "X" then
            growElement:SetWidth(w - tw)
            growElement:SetHeight(h - pt - pb - pt)
        else
            growElement:SetWidth(w - pl - pr)
            growElement:SetHeight(h - th)
        end

        growElement:RenderProperty("Width")
        growElement:RenderProperty("Height")
        tw = w
        th = h
    end

    local ChildPos = {}
    -- Horizontal align
    if isany(align, 1, 4, 7) then
        local wd = pl
        local x = wd
        local y = 0
        local mh = 0
        for k = 1, #children do
            local child = children[k]
            
            if not IsValid(child) then 
                continue 
            end
            
            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end

            local cl, ct, cr, cb = child:GetMargin()
            local cw, ch = child:GetWidth(), child:GetHeight()
            if flowDirection == "X" then
                ChildPos[child] = {x + cl, y}
                x = x + cw + cr + cl + gap
            else
                ChildPos[child] = {cl + pl, 0}
            end
        end
    elseif isany(align, 8, 5, 2) then
        local wd = self:GetWidth() / 2 - tw / 2
        local x = wd + pl
        for k = 1, #children do
            local child = children[k]
            if not IsValid(child) then 
                continue 
            end
            
            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end
            
            local cl, ct, cr, cb = child:GetMargin()
            if flowDirection == "X" then
                ChildPos[child] = {cl + x, 0}
                x = x + cl + child:GetWidth() + cr + gap
            else
                ChildPos[child] = {self:GetWidth() / 2 - child:GetWidth() / 2, 0}
            end
        end
    else
        local wd = self:GetWidth()
        local x = wd - pr
        for k = 1, #children do
            local child = children[k]
            
            if not IsValid(child) then continue end
            
            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end

            local cl, ct, cr, cb = child:GetMargin()
            if flowDirection == "X" then
                x = x - child:GetWidth() - cr
                ChildPos[child] = {x, 0}
                x = x - cl - gap
            else
                ChildPos[child] = {wd - child:GetWidth() - cr - pr}
            end
        end
    end

    -- Vertical align
    if isany(align, 7, 8, 9) then
        local t = pt
        local y = t
        for k = 1, #children do
            local child = children[k]
            
            if not IsValid(child) then 
                continue 
            end

            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end

            local cl, ct, cr, cb = child:GetMargin()
            local cp = ChildPos[child]
            if flowDirection == "Y" then
                ChildPos[child][2] = y + ct
                y = y + ct + child:GetHeight() + cb + gap
            else
                ChildPos[child][2] = y + ct
                y = t
            end
        end
    elseif isany(align, 4, 5, 6) then
        local t = self:GetHeight() / 2 - th / 2
        local y = t + pt
        for k = 1, #children do
            local child = children[k]
            if not IsValid(child) then continue end
            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end

            local cl, ct, cr, cb = child:GetMargin()
            local cp = ChildPos[child]
            if flowDirection == "Y" then
                ChildPos[child][2] = y + ct
                y = y + child:GetHeight() + cb + gap
            else
                y = h / 2 - child:GetHeight() / 2
                ChildPos[child][2] = y
            end
        end
    else
        local t = self:GetHeight() - pb
        local y = t
        for k = 1, #children do
            local child = children[k]
            
            if not IsValid(child) then continue end

            if child:GetAbsolute() or not child:GetDisplay() then 
                continue 
            end

            local cl, ct, cr, cb = child:GetMargin()
            local cp = ChildPos[child]
            if flowDirection == "Y" then
                y = y - child:GetHeight() - cb
                ChildPos[child][2] = y
                y = y - ct - gap
            else
                y = t - child:GetHeight() - cb
                ChildPos[child][2] = y
            end
        end
    end

    for k, v in pairs(ChildPos) do
        local x, y = unpack(v)
        k:SetX(x)
        k:SetY(y)
        k:RenderProperty("X")
        k:RenderProperty("Y")
    end

    self:SetSuppressLayout(false)
    return true
end

function Rect.Prototype:GetParent()
    local p = self:GetProperty("Parent")
    if p then
        return p
    end

    local wp = Interface.GetWorldPanel()
    if self == wp then
        return nil
    end

    return wp
end

function Rect.Prototype:Dispose()
    base(self, "Dispose")

    self:SetDisplay(false)
    self:SetParent(nil)
    if self:GetPanel() then
        self:GetPanel():Remove()
        self:SetPanel(nil)
    end

    for k, v in pairs(self.Hooked) do
        hook.Remove(k, v.key)
    end

    for k, v in pairs(self:GetChildren()) do
        v:Dispose()
    end

    return true
end


WorldPanel = Type.New(Rect)
WorldPanel.PerformLayout = function () end

local wp = vgui.GetWorldPanel()
wp.Controller = WorldPanel

WorldPanel:SetParent(nil)
WorldPanel:SetPanel(wp)
WorldPanel:SetName("GModBase")
WorldPanel:SetWidth(ScrW())
WorldPanel:SetHeight(ScrH())
WorldPanel:SetX(0)
WorldPanel:SetY(0)

WorldPanel:SetFontFamily("Tahoma")
WorldPanel:SetFontSize(6)
WorldPanel:SetFontWeight(300)
WorldPanel:SetFontColor(color_white)
WorldPanel:SetFontShadow(0)
WorldPanel:SetFontAdditive(false)

function bp:GetController()
    return self.Controller
end