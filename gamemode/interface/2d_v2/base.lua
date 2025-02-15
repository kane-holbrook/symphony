AddCSLuaFile()
if SERVER then
    return
end

Interface.Components = weaktable(false, true)

local BasePanel = FindMetaTable("Panel")

-- TODO
-- Refs
-- Extents
-- Size To Children
-- Layouts
  -- Align
  -- Direction
  -- Gap
  -- Margin
  -- Padding
-- Stencils
-- Radiuses
-- Borders/strokes
-- Fills
-- Shadows
-- Registration
-- Dynamic properties
-- Templates
-- Hover (& states)
-- Drag & drop
-- Keyboard shortcuts
-- Components
  -- Text
  -- Image
  -- Gradients
  -- For loops
  -- Timers
  -- Hooks
  -- Slots
  -- ScrollPanel
  -- HazardStrip
  -- Window
  -- Modal
  -- MenuBar
  -- Split views
  -- Collapsible panels
  -- Breadcrumbs
  -- Spinners
  -- PopOver
  -- Tooltip
  -- Details
  -- ContextMenu
  -- Button
  -- Checkbox
  -- List Groups
  -- Data table
  -- Toggle
  -- Radio
  -- Slider
  -- Sounds
  -- TextEntry
  -- Picklist
  -- Color picker
  -- Tree
  -- Tabs
  -- Accordions
  -- Keys
  -- Sortable
  -- Canvas
  -- Grid
  -- Item

--[[
    <Template Id="TemplateName"  />
    </Template>
]]


local function DefaultExtent(el, value)
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
            return Parent.Width * (tonumber(string.sub(value, 1, -3)))
        end
    end

    if string.EndsWith(value, "ph") then
        return function ()
            return Parent.Height * (tonumber(string.sub(value, 1, -3)))
        end
    end

    -- Why isn't Interface.Font working

    if string.EndsWith(value, "cw") then
        return function ()
            local font = el.Env.Font
            surface.SetFont(font)
            local x2, y2 = surface.GetTextSize("0")
            return x2 * tonumber(string.sub(value, 1, -3))
        end
    end

    if string.EndsWith(value, "ch") then
        return function ()
            local font = el.Env.Font
            surface.SetFont(font)
            local x2, y2 = surface.GetTextSize("0")
            return y2 * tonumber(string.sub(value, 1, -3))
        end
    end

    error("Invalid extent: " .. value)
end

function Interface.ExtentW(el, property, value)
    local tn = tonumber(value)
    if tn then
        el:SetPropertyComputed(property, function ()
            return ScreenScale(value)
        end)
        return true
    end
    
    if string.EndsWith(value, "%") then
        el:SetPropertyComputed(property, function ()
            return Parent.Width * (tonumber(string.sub(value, 1, -2)) / 100)
        end)
        return true
    end

    el:SetPropertyComputed(property, DefaultExtent(el, value))
    return true
end

function Interface.ExtentH(el, property, value)
    local tn = tonumber(value)
    if tn then
        el:SetPropertyComputed(property, function ()
            return ScreenScale(value)
        end)
        return true
    end
    
    if string.EndsWith(value, "%") then
        el:SetPropertyComputed(property, function ()
            return Parent.Height * (tonumber(string.sub(value, 1, -2)) / 100)
        end)
        return true
    end

    el:SetPropertyComputed(property, DefaultExtent(el, value))
    return true
end

local Panel = Type.Register("Rect", nil, { VGUI = "Panel" })
Panel:CreateProperty("Parent", Panel)
Panel:CreateProperty("Ref", Type.String)
Panel:CreateProperty("FullyQualifiedRef", Type.String) 
Panel:CreateProperty("Children", Type.Table)
Panel:CreateProperty("Panel", Type.Panel)
Panel:CreateProperty("Propagate", Type.Boolean)
Panel:CreateProperty("EventsEnabled", Type.Boolean)

Panel:CreateProperty("Display", Type.Boolean, { Priority = 9999 } )
Panel:CreateProperty("Scale", Type.Vector)
Panel:CreateProperty("Angle", Type.Angle)

Panel:CreateProperty("FontName", Type.String)
Panel:CreateProperty("FontWeight", Type.Number)
Panel:CreateProperty("FontSize", Type.Number)
Panel:CreateProperty("Font", nil, { Listen = { "Change:FontName", "Change:FontWeight", "Change:FontSize", "ResolutionChange" } })

Panel:CreateProperty("Align", Type.Number)
Panel:CreateProperty("Flow", Type.String)
Panel:CreateProperty("Gap", Type.Number, { Parse = Interface.ExtentW })

Panel:CreateProperty("PaddingLeft", Type.Number, { Parse = Interface.ExtentW })
Panel:CreateProperty("PaddingTop", Type.Number, { Parse = Interface.ExtentH })
Panel:CreateProperty("PaddingRight", Type.Number, { Parse = Interface.ExtentW })
Panel:CreateProperty("PaddingBottom", Type.Number, { Parse = Interface.ExtentH })

Panel:CreateProperty("MarginLeft", Type.Number, { Parse = Interface.ExtentW })
Panel:CreateProperty("MarginTop", Type.Number, { Parse = Interface.ExtentH })
Panel:CreateProperty("MarginRight", Type.Number, { Parse = Interface.ExtentW })
Panel:CreateProperty("MarginBottom", Type.Number, { Parse = Interface.ExtentH })

Panel:CreateProperty("Gap", Type.Number)
Panel:CreateProperty("Absolute", Type.Boolean)
Panel:CreateProperty("Grow", Type.Boolean)

function Panel.Metamethods:__tostring()
    return self:GetType():GetName() .. "[" .. (self:GetRef() or self:GetId()) .. "][" .. tostring(self:GetX()) .. "," .. tostring(self:GetY()) .. "," .. tostring(self:GetWidth()) .. "," .. tostring(self:GetHeight()) .. "]"
end

-- BasePanel properties
do
    Panel:CreateProperty("WidthAuto", Type.Boolean)
    Panel:CreateProperty("HeightAuto", Type.Boolean)
    Panel:CreateProperty("Width", Type.Number, { Set = BasePanel.SetWide, Get = BasePanel.GetWidth, Parse = function (el, k, v) 
        el:SetWidthAuto(false) 
        return Interface.ExtentW(el, k, v) 
    end, Emit = "Resize", Listen = { } })
    Panel:CreateProperty("Height", Type.Number, { Set = BasePanel.SetTall, Get = BasePanel.GetHeight, Parse = function (el, k, v) 
        el:SetHeightAuto(false) 
        return Interface.ExtentH(el, k, v) 
    end, Emit = "Resize", Listen = { } })
    Panel:CreateProperty("X", Type.Number, { Set = BasePanel.SetX, Get = BasePanel.GetX, Parse = Interface.ExtentW, Emit = "Reposition" })
    Panel:CreateProperty("Y", Type.Number, { Set = BasePanel.SetY, Get = BasePanel.GetY, Parse = Interface.ExtentH, Emit = "Reposition" })
    Panel:CreateProperty("Fill", Type.Color)
end

function Interface.Create(classname, parent, name)
    assert(isstring(classname), "Classname must be the name of a panel i.e. DHTML")
    
    local p = new(Interface.Components[classname])
    p:SetParent(parent)

    return p
end

function Panel:CreateFromNode(parent, node, ctx)
    local el = Interface.Create(self:GetName(), parent)

    node.Attributes = node.Attributes or {}
    node.Children = node.Children or {}

    local skip = {}

    for _, prop in pairs(self:GetProperties()) do
        local k = prop.Name
        local v = node.Attributes[k]

        if not v then
            v = node.Attributes[":" .. k]

            if not v then
                continue
            end

            skip[":" .. k] = true
            k = ":" .. k
        else
            skip[k] = true
        end

        -- : is computed
        if string.StartsWith(k, ":") then
            k = string.sub(k, 2)
            local f = CompileString("return " .. v, "Property[" .. k .. "]")
            el:SetPropertyComputed(k, f)
            el:ComputeProperty(k)
        elseif string.StartsWith(k, "Init:") then
            k = string.sub(k, 6)
            local f = CompileString("return " .. v, "Init:Property[" .. k .. "]")
            el:SetProperty(k, f()(el))
        elseif string.StartsWith(k, "Transition:") then
            k = string.sub(k, 11)
            local easing, duration = unpack(string.Split(v, " "))
            if not duration then
                duration = tonumber(easing)
                easing = nil
            end

            el:SetPropertyTransition(k, tonumber(duration), easing)
        elseif prop.Options.Parse then
            v = prop.Options.Parse(el, k, v)
        else
            if prop.Type then
                v = prop.Type:Parse(v)
            end

            el:SetProperty(k, v)
        end        
    end

    for k, v in pairs(node.Attributes) do
        if skip[k] then
            continue
        end

        if string.StartsWith(k, ":") then
            ErrorNoHalt("Only properties can have computed values")
        elseif string.StartsWith(k, "Init:") then
            k = string.sub(k, 6)
            local f = CompileString("return " .. v, "Init:Property[" .. k .. "]")
            el[k] = f()(el)
        elseif string.StartsWith(k, "Transition:") then
            error("Only properties can have transitions")
        elseif string.StartsWith(k, "On:") then
            local name = string.sub(k, 4)
            local func = CompileString("return " .. v, k)
            el.Events:Hook(name, func())
        else
            el[k] = v
        end
    end

    for k, v in pairs(node.Children) do
        self:ParseNodeChild(el, v, ctx)
    end

    return el
end

function Panel.Prototype:GetChildrenSize()
    local tw, th = 0, 0
    local minx, miny = math.huge, math.huge
    for k, v in pairs(self:GetChildren()) do
        if not v:GetDisplay() then continue end
        local x, y = v:GetX(), v:GetY()
        minx = math.min(minx, x)
        miny = math.min(miny, y)
    end

    for k, v in pairs(self:GetChildren()) do
        if not v:GetDisplay() then continue end
        local x, y = v:GetX(), v:GetY()
        local w, h = v:GetWidth() or 0, v:GetHeight() or 0
        local ml, mt, mr, mb = v:GetMargin()
        tw = math.max(tw, x + w)
        th = math.max(th, y + h)
    end
    return tw, th
end

function Panel:ParseNodeChild(el, child, ctx)
    return Interface.CreateFromNode(el, child)
end

function Panel:IsVirtual()
    return self:GetOptions().VGUI == false
end



local DefaultEnv = {
    FontName = "Tahoma",
    FontSize = 4.5,
    FontWeight = 400,
    FontColor = color_white,
    Parent = {
        Width = ScrW(),
        Height = ScrH()
    }
}
DefaultEnv.Font = Interface.Font(DefaultEnv.FontName, DefaultEnv.FontSize, DefaultEnv.FontWeight)
setmetatable(DefaultEnv, { __index = _G })

function Interface.GetDefaultEnv()
    return DefaultEnv
end

hook.Add("OnScreenSizeChanged", "Interface.OnScreenSizeChanged", function()
    DefaultEnv.Parent.Width = ScrW()
    DefaultEnv.Parent.Height = ScrH()
end)

function Panel.Prototype:Initialize()
    
    self.Env = setmetatable({
        self = self,
        Parent = Interface.GetDefaultEnv()
    }, { __index = Interface.GetDefaultEnv() })

    self.Events = new(Type.EventBus)
    self.Events:Hook("*", function (...)
        self:ReceiveEvent(...)
    end)
    self.Transitions = {}
    self.DefaultTransitions = {}
    self.ComputedProperties = {}
    self._LastPaint = CurTime() 

    self:SetChildren({})
    self:SetProperty("Width", 0)
    self:SetProperty("Height", 0)
    self:SetX(0)
    self:SetY(0)
    self:SetFill(color_transparent)
    self:SetDisplay(true)
    self:SetPropagate(true)
    self:SetWidthAuto(true)
    self:SetHeightAuto(true)
    self:SetScale(Vector(1, 1, 1))
    self:SetAngle(Angle(0, 0, 0))
    self:SetPropertyComputed("Font", function ()
        return Interface.Font(self.Env.FontName, self.Env.FontSize, self.Env.FontWeight)
    end, true)
    self:SetAlign(7)
    self:SetFlow("X")
    self:SetGap(0)
    self:SetPaddingLeft(0)
    self:SetPaddingTop(0)
    self:SetPaddingRight(0)
    self:SetPaddingBottom(0)
    self:SetMarginLeft(0)
    self:SetMarginTop(0)
    self:SetMarginRight(0)
    self:SetMarginBottom(0)
    self:SetAbsolute(false)
    self:SetGrow(false)
    self:SetEventsEnabled(true)
end

function Panel.Prototype:GetPadding()
    return self:GetPaddingLeft(), self:GetPaddingTop(), self:GetPaddingRight(), self:GetPaddingBottom()
end

function Panel.Prototype:GetMargin()
    return self:GetMarginLeft(), self:GetMarginTop(), self:GetMarginRight(), self:GetMarginBottom()
end

function Panel.Prototype:Layout()

    if self.IsLayingOut then 
        return false
    end

    local align = self:GetAlign()
    if not align then
        return
    end

    local w, h = self:GetWidth(), self:GetHeight()

    local flowDirection = self:GetFlow()
    local gap = self:GetGap()
    local pl, pt, pr, pb = self:GetPadding()


    local children = self:GetChildren()
    local tw, th = 0, 0
    local growElement
    for k, child in pairs(children) do
        if child:GetAbsolute() or not child:GetDisplay() then
            continue
        end

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

        self.IsLayingOut = true
        
            if flowDirection == "X" then
                growElement:SetWidth(w - tw)
                growElement:SetHeight(h - pt - pb)
            else
                growElement:SetWidth(w - pl - pr)
                growElement:SetHeight(h - th)
            end
            
        self.IsLayingOut = false

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

        for k=1, #children do
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
                ChildPos[child] = { x + cl, y }
                x = x + cw + cr + cl + gap
            else
                ChildPos[child] = { cl + pl, 0 }
            end
        end
    elseif isany(align, 8, 5, 2) then
        local wd = self:GetWidth()/2 - tw/2
        local x = wd + pl
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetAbsolute() or not child:GetDisplay() then
                continue
            end

            local cl, ct, cr, cb = child:GetMargin()
                            
            if flowDirection == "X" then
                ChildPos[child] = { cl + x, 0 }
                x = x + cl + child:GetWidth() + cr + gap
            else
                ChildPos[child] = { self:GetWidth()/2 - child:GetWidth()/2, 0 }
            end
        end
    else
        local wd = self:GetWidth()
        local x = wd - pr
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetAbsolute() or not child:GetDisplay() then
                continue
            end

            local cl, ct, cr, cb = child:GetMargin()

            if flowDirection == "X" then
                x = x - child:GetWidth() - cr
                ChildPos[child] = { x, 0 }
                x = x - cl - gap
            else
                ChildPos[child] = { wd - child:GetWidth() - cr - pr }
            end
        end
    end

    -- Vertical align
    if isany(align, 7, 8, 9) then
        local t = pt
        local y = t


        for k=1, #children do
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
        local t = self:GetHeight()/2 - th/2
        local y = t + pt
        for k=1, #children do
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
                y = y + child:GetHeight() + cb + gap
            else
                y = h/2 - child:GetHeight()/2
                ChildPos[child][2] = y
            end
        end
    else
        local t = self:GetHeight() - pb
        local y = t
        for k=1, #children do
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
                y = y - child:GetHeight() - cb
                ChildPos[child][2] = y
                y = y - ct - gap
            else
                y = t - child:GetHeight() - cb
                ChildPos[child][2] = y
            end

        end
    end        

    self.IsLayingOut = true
        for k, v in pairs(ChildPos) do
            local x, y = unpack(v)
            k:SetX(x)
            k:SetY(y)
        end
    self.IsLayingOut = false
end

function Panel.Prototype:StartStencil(w, h)
end

function Panel.Prototype:FinishStencil()
end


function Panel.Prototype:IsValid()
    return self._Removed ~= true
end

function Panel.Prototype:GetEnv()
    return self.Env
end

function Panel.Prototype:EmitNoPropagate(name, ...)
    assert(name, "Event name must be provided")

    if not self:GetEventsEnabled() then
        return Type.New(EventResult)
    end

    local er = self.Events:Run(name, ...)
    return er
end

function Panel.Prototype:Emit(name, ...)
    assert(name, "Event name must be provided")

    if not self:GetEventsEnabled() then
        return Type.New(EventResult)
    end

    local er = self:EmitNoPropagate(name, ...)
    if er:GetCancelled() or not self:GetPropagate() then
        return er
    end
    
    local parent = self:GetParent()
    while IsValid(parent) do
        er = parent.Events:Run("Child:" .. name, self, ...)
        
        if er:GetCancelled() then
            return er
        end
        parent = parent:GetParent()
    end

    for k, v in pairs(self:GetChildren()) do
        if not IsValid(v) then
            continue
        end

        v.Events:Run("Parent:" .. name, self, ...)
    end
end

function Panel.Prototype:SetWidth(value)
    self:SetWidthAuto(false)
    self:SetProperty("Width", value)
end

function Panel.Prototype:SetHeight(value)
    self:SetHeightAuto(false)
    self:SetProperty("Height", value)
end

function Panel.Prototype:SizeToChildren()
    local w, h = self:GetChildrenSize()
    if self:GetWidthAuto() then
        self:SetProperty("Width", w)
    end
    
    if self:GetHeightAuto() then
        self:SetProperty("Height", h)
    end
end

function Panel.Prototype:ReceiveEvent(name, ...)
    local args = {...}

    -- SizeToChildren
    if (name == "ChildAdded" or name == "ChildRemoved" or name == "Child:Resize" or name == "Child:Reposition") and not self.IsLayingOut then
        
        if self:GetAlign() then
            self:Layout()
        end

        if (self:GetWidthAuto() or self:GetHeightAuto()) then
            self:SizeToChildren()
        end
    end
        
    if name == "ChildAdded" or name == "Child:Change:Ref" then
        local el = args[1]
        local el_ref = args[2]
        local old = args[3]
        
        local ref = self:GetRef()
        
        if el_ref and (ref or not self:GetParent()) then
            self[el_ref] = el
            el.RefTarget = self
            Event:SetCancelled(true)
        end
    end
end

local function SetProperty(el, name, value)
    local old = el[name]
    el[name] = value
    el.Env[name] = value
    el:OnPropertyChanged(name, value, old)
end

function Panel.Prototype:SetProperty(name, value, immediate)
    
    local p = Type.GetType(self):GetPropertiesMap()[name]
    if p and p.Type and not p.Options.NoValidate then
        assert(value == nil or Type.Is(value, p.Type), "Property " .. name .. " expects " .. p.Type:GetName() .. " but got " .. Type.GetType(value):GetName())
    end
    
    local dt = self.DefaultTransitions[name]
    if dt and not immediate then
        return self:Transition(name, value, dt[1], dt[2])
    end

    self.Transitions[name] = nil
    SetProperty(self, name, value)
end

function Panel.Prototype:GetProperty(name)
    return self[name]
end

function Panel.Prototype:SetPropertyTransition(name, duration, easing)
    assert(isstring(name))
    assert(isnumber(duration))

    self.DefaultTransitions[name] = { duration, easing }
end

function Panel.Prototype:GetPropertyTransition(name)
    return self.DefaultTransitions[name]
end

function Panel.Prototype:IsWidthAuto()
    return self:GetWidthAuto() and not self.ComputedProperties["Width"]
end

function Panel.Prototype:IsHeightAuto()
    return self:GetHeightAuto() and not self.ComputedProperties["Height"]
end

function Panel.Prototype:SetPropertyComputed(name, func, dontRun)
    assert(isstring(name), "Calculated property name must be a string")
    assert(func == nil or isfunction(func), "Calculated property must be a function")
    if func then 
        setfenv(func, self.Env)
    end

    self.ComputedProperties[name] = func
    if not dontRun then
        self:ComputeProperty(name)
    end

    local prop = self:GetType():GetPropertiesMap()[name]
    local opt = prop.Options

    if opt.Listen then
        for k, v in pairs(opt.Listen) do
            self.Events:Hook(v, function (n)
                -- Avoid infinite limits!
                if n == name then
                    return
                end

                -- Recalculate whenever a parent property changes
                self:ComputeProperty(name)
            end)
        end
    end
end

function Panel.Prototype:IsPropertyComputed(name)
    return self.ComputedProperties[name] ~= nil
end

function Panel.Prototype:ComputeProperty(name)
    if self:IsPropertyComputed(name) then
        local succ, result = pcall(self.ComputedProperties[name], self)
        if not succ then
            ErrorNoHaltWithStack(result .. "\n")
            return
        end

        self:SetProperty(name, result)
    end
    return self[name]
end

function Panel.Prototype:Transition(name, to, duration, easing)
    assert(isstring(name), "Transition name must be a string")
    assert(to, "Transition value must be provided")
    assert(isnumber(duration), "Duration must be a number")

    local t = {}
    
    if IsColor(to) then
        to = { to:ToTable() }
    else
        to = istable(to) and table.Copy(to) or { to }
    end

    local value = self:GetProperty(name)
    if IsColor(value) then
        value = value:ToTable()
        t.IsColor = true
    end
    value = istable(value) and { table.Copy(value) } or { value }

    local target = istable(to) and table.Copy(to) or { to }

    t.Value = value
    t.Tween = neonate.new(duration, value, target, easing)
    
    t.Promise = Promise.Create()
    
    self.Transitions[name] = t
    return t.Promise
end

function Panel.Prototype:GetTransitions()
    return self.Transitions
end

function Panel.Prototype:GetClassName()
    return self:GetType():GetOptions().VGUI
end

function Panel.Prototype:Paint(w, h)
    local ct = CurTime()
    local dt = ct - self._LastPaint

    for k, v in pairs(self.Transitions) do
        local complete = v.Tween:update(dt)

        local val
        if v.IsColor then
            val = Color(unpack(unpack(v.Value)))
        else
            val = unpack(v.Value)
        end

        SetProperty(self, k, val, true)

        if complete then
            v.Promise:Complete()
            self.Transitions[k] = nil
        end
    end

    local m = Matrix()
    m:Rotate(self:GetAngle())
    m:Scale(self:GetScale())
    cam.PushModelMatrix(m, true)
    surface.SetDrawColor(self:GetFill())
    surface.DrawRect(0, 0, w, h)

    --self:EmitNoPropagate("Paint")

    self._LastPaint = ct
end

function Panel.Prototype:PaintOver(w, h)
    cam.PopModelMatrix()
end

function Panel.Prototype:OnPropertyChanged(name, value, old)
    local prop = self:GetType():GetPropertiesMap()[name]
    local opt = prop.Options
    local typeOpt = self:GetType():GetOptions()

    local el = self:GetPanel()

    if name == "Display" then
        if not typeOpt.VGUI then
            return
        end

        if value then
            if IsValid(el) then
                return
            end

            local parent = self:GetParent()
            if parent and not parent:GetPanel() then
                return
            end

            el = vgui.Create(self:GetClassName(), parent and parent:GetPanel() or nil)
            el.Paint = function (p, w, h)
                self:Paint(w, h)
            end
            el.PerformLayout = function (w, h)
                self:EmitNoPropagate("PerformLayout", w, h) 
                return w, h
            end
            el.Interface = self
            self:SetPanel(el)

            for _, p in pairs(self:GetType():GetProperties()) do
                local opt = p.Options
                local k = p.Name
                local v = self:ComputeProperty(k)

                if opt.Set then
                    opt.Set(el, v)
                end
            end

        else
            if IsValid(el) then
                el:Remove()
            end
            self:SetPanel(nil)
            self:SetParent(nil)
        end
    elseif name == "Parent" then
        if old then
            for k, v in pairs(old:GetChildren()) do
                if v == self then
                    old:GetChildren()[k] = nil
                    old:Emit("ChildRemoved", self)
                    break
                end
            end
        end

        if value then
            setmetatable(self.Env, { __index = value.Env })
            value:GetChildren()[#value:GetChildren() + 1] = self

            if IsValid(el) then
                el:SetParent(value:GetPanel())
            end
            self.Env.Parent = value.Env

            value:Emit("ChildAdded", self)
        else
            if IsValid(el) then
                el:SetParent(nil)
            end

            setmetatable(self.Env, { __index = Interface.GetDefaultEnv() })
        end
        return
    end

    if el and opt.Set then
        local get = opt.Get
        if get then
            old = get(el)
        end

        if old ~= value and not opt.AlwaysSet then
            opt.Set(el, value)
        end
    end

    if not opt.Silent then
        self:Emit("Change:" .. name, value, old)
    end

    if opt.Emit then
        self:Emit(opt.Emit, name)
    end
end

function Panel.Prototype:Remove()
    if IsValid(self:GetPanel()) then
        self:GetPanel():Remove()
    end
    
    if self.RefTarget then
        self.RefTarget[self:GetRef()] = nil
    end

    self._Removed = true
    self:Emit("Removed")
end
Interface.Components["Rect"] = Panel


function Interface.Register(classname, baseName, options)
    local base = Interface.Components[baseName]
    assert(base, "Base panel " .. baseName .. " does not exist")

    local p = Type.Register(classname, base, options)
    Interface.Components[classname] = p
    return p
end


local VIRTUAL = Interface.Register("Virtual", "Rect", { VGUI = false })

local LISTEN = Interface.Register("Listen", "Virtual", { VGUI = false })
LISTEN:CreateProperty("Event", Type.String)
LISTEN:CreateProperty("Properties", Type.String)

function LISTEN.Prototype:Initialize()
    base(self, "Initialize")
    self.Listen = {}
    self.Props = {}
end

function LISTEN.Prototype:OnPropertyChanged(name, value, old)
    if name == "Event" then
        local events = string.Split(value, ",")
        tablex.Trim(events)
        events = table.Flip(events)
        self.Listen = events

        self:GetParent().Events:Hook("*", function (name, ...)
            if self.Listen[name] then
                for k, v in pairs(self.Props) do
                    self:GetParent():ComputeProperty(k)
                end
            end
        end, self:GetId())
    elseif name == "Properties" then
        local props = string.Split(value, ",")
        tablex.Trim(props)
        props = table.Flip(props)
        self.Props = props
    end
end
