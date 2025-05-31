AddCSLuaFile()
if SERVER then
    return
end

Interface.Components = weaktable(false, true)

local BasePanel = FindMetaTable("Panel")

-- TODO

-- Stencils ✓
-- Radiuses ✓
-- Borders/strokes ✓
-- Templates
-- Hover (& states)
-- Drag & drop
-- Keyboard shortcuts
-- Components
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

local Extent = Type.Register("Extent", nil, { AlwaysCalculated = true })
Extent:CreateProperty("Value")
Extent:CreateProperty("Mode", Type.String)

-- Return a number when called
function Extent.Metamethods:__call(el)
    if self:GetMode() == "ss" then
        return ScreenScale(self:GetValue())
    elseif self:GetMode() == "ssh" then
        return ScreenScaleH(self:GetValue())
    elseif self:GetMode() == "vw" then
        return ScrW() * (self:GetValue() / 100)
    elseif self:GetMode() == "vh" then
        return ScrH() * (self:GetValue() / 100)
    elseif self:GetMode() == "pw" then
        local p = el:GetParent()
        return (p and el:GetParent():GetWidth() or ScrW()) * self:GetValue()
    elseif self:GetMode() == "ph" then
        local p = el:GetParent()
        return (p and el:GetParent():GetHeight() or ScrH()) * self:GetValue()
    elseif self:GetMode() == "func" then
        return self:GetValue()(el)
    else
        return self:GetValue()
    end
end

function Extent.Metamethods:__tostring()
    local value = self:GetValue()
    if self:GetMode() == "px" then
        return tostring(value) .. "px"
    elseif self:GetMode() == "func" then
        return tostring(value) .. "<Func>"
    end

    return tostring(value) .. "px <" .. tostring(self:GetValue()) .. tostring(self:GetMode()) .. ">"
end

function Extent:Parse(value)
    local mode = "px"
    if string.EndsWith(value, "px") then
        value = tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "ss") then
        mode = "ss"
        value = tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "ssh") then
        mode = "ssh"
        value = tonumber(string.sub(value, 1, -4))
    elseif string.EndsWith(value, "vw") then
        mode = "vw"
        value = tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "vh") then
        mode = "vh"
        value = tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "pw") then
        mode = "pw"
        value = tonumber(string.sub(value, 1, -3))
    elseif string.EndsWith(value, "ph") then
        mode = "ph"
        value = tonumber(string.sub(value, 1, -3))
    end

    local ext = new(Extent)
    ext:SetValue(value)
    ext:SetMode(mode)
    return ext
end

local Panel = Type.Register("Rect", nil, { VGUI = "Panel" })
Panel:CreateProperty("Debug", Type.Boolean)
Panel:CreateProperty("SuppressLayout", Type.Boolean)

Panel:CreateProperty("Top", Type.Rect)

Panel:CreateProperty("Ref", Type.String)
Panel:CreateProperty("Parent", Panel)
Panel:CreateProperty("FullyQualifiedRef", Type.String) 
Panel:CreateProperty("Children", Type.Table)
Panel:CreateProperty("Panel", Type.Panel)
Panel:CreateProperty("Propagate", Type.Boolean)
Panel:CreateProperty("Hoverable", Type.Boolean)
Panel:CreateProperty("Hovered", Type.Boolean)
Panel:CreateProperty("EventsEnabled", Type.Boolean)

Panel:CreateProperty("Display", Type.Boolean, { Priority = 9999 } )
Panel:CreateProperty("Popup", Type.Boolean)

Panel:CreateProperty("FontName", Type.String)
Panel:CreateProperty("FontWeight", Type.Number)
Panel:CreateProperty("FontSize", Type.Number)
Panel:CreateProperty("FontColor", Type.Color)

Panel:CreateProperty("Align", Type.Number)
Panel:CreateProperty("Flow", Type.String)
Panel:CreateProperty("Gap", Type.Extent)
Panel:CreateProperty("PaddingLeft", Type.Extent)
Panel:CreateProperty("PaddingTop", Type.Extent)
Panel:CreateProperty("PaddingRight", Type.Extent)
Panel:CreateProperty("PaddingBottom", Type.Extent)
Panel:CreateProperty("MarginLeft", Type.Extent)
Panel:CreateProperty("MarginTop", Type.Extent)
Panel:CreateProperty("MarginRight", Type.Extent)
Panel:CreateProperty("MarginBottom", Type.Extent)
Panel:CreateProperty("Absolute", Type.Boolean)
Panel:CreateProperty("Grow", Type.Boolean)

Panel:CreateProperty("Fill", Type.Material, { Parse = function (el, k, v)
    el:SetFillColor(color_white)
    el:SetProperty("Fill", Type.Material:Parse(v))
end })

Panel:CreateProperty("FillColor", Type.Color)
Panel:CreateProperty("FillRepeatX", Type.Boolean)
Panel:CreateProperty("FillRepeatY", Type.Boolean)
Panel:CreateProperty("FillRepeatScale", Type.Number)

Panel:CreateProperty("Stroke", Type.Material)
Panel:CreateProperty("StrokeColor", Type.Color)
Panel:CreateProperty("StrokeWidth", Type.Extent)
Panel:CreateProperty("TopLeftRadius", Type.Extent)
Panel:CreateProperty("TopRightRadius", Type.Extent)
Panel:CreateProperty("BottomLeftRadius", Type.Extent)
Panel:CreateProperty("BottomRightRadius", Type.Extent)




function Panel.Metamethods:__tostring()
    return self:GetType():GetName() .. "[" .. tostring(self:GetRef() or self:GetId()) .. "][" .. tostring(self:GetX()) .. "," .. tostring(self:GetY()) .. "," .. tostring(self:GetWidth()) .. "," .. tostring(self:GetHeight()) .. "]"
end

-- BasePanel properties
do
    Panel:CreateProperty("WidthAuto", Type.Boolean)
    Panel:CreateProperty("HeightAuto", Type.Boolean)
    Panel:CreateProperty("Width", Type.Extent, { Set = BasePanel.SetWide, Get = BasePanel.GetWidth })
    Panel:CreateProperty("Height", Type.Extent, { Set = BasePanel.SetTall, Get = BasePanel.GetHeight })
    Panel:CreateProperty("X", Type.Extent, { Set = BasePanel.SetX, Get = BasePanel.GetX })
    Panel:CreateProperty("Y", Type.Extent, { Set = BasePanel.SetY, Get = BasePanel.GetY })
    Panel:CreateProperty("Cursor", Type.String, { Set = function (p, v)
        if v ~= "" then
            BasePanel.SetCursor(p, v)
        end
    end, Get = BasePanel.GetCursor })
end

function Interface.Create(classname, parent, name)
    assert(isstring(classname), "Classname must be the name of a panel i.e. DHTML")
    
    local p = new(Interface.Components[classname])
    p:SetParent(parent)

    return p
end

function Panel:CreateFromNode(parent, node, ctx)
    local el = Interface.Create(self:GetName(), parent)
    self:LoadFromNode(el, node, ctx)
    return el
end

function Panel:LoadFromNode(el, node, ctx)
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
            ErrorNoHalt("Only properties can have computed values:" .. k)
        elseif string.StartsWith(k, "Init:") then
            k = string.sub(k, 6)
            local f = CompileString("return " .. v, "Init:Property[" .. k .. "]")
            el[k] = f()(el)
        elseif string.StartsWith(k, "Transition:") then
            k = string.sub(k, 12)
            local easing, duration = unpack(string.Split(v, " "))
            if not duration then
                duration = tonumber(easing)
                easing = nil
            end
            el:SetPropertyTransition(k, tonumber(duration), easing)
        elseif string.StartsWith(k, "On:") then
            local name = string.sub(k, 4)
            local func = CompileString("return " .. v, k)
            local f = func()
            setfenv(f, el:GetEnv())

            el.Events:Hook(name, f)
        elseif string.StartsWith(k, "Set:") then
            local name = string.sub(k, 5)
            el[name] = v
        else
            error("Invalid property: " .. k)
        end
    end

    for k, v in pairs(node.Children) do
        self:ParseNodeChild(el, v, ctx)
    end

    return el
end

function Panel.Prototype:GetFont()
    return Interface.Font(self.Env.FontName, self.Env.FontSize, self.Env.FontWeight)
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
    if child.Tag == "Inline" then
        local out = Interface.Create("Label", el)
        out:SetText(child.Attributes.Text)
        return out
    end

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
    self.Slots = {
        Default = self
    }
    self.Transitions = {}
    self.DefaultTransitions = {}
    self.ComputedProperties = {}
    self.HoverProperties = {}
    
    self._LastPaint = CurTime() 

    self:SetChildren({})
    self:SetProperty("Width", 0)
    self:SetProperty("Height", 0)
    self:SetX(0)
    self:SetY(0)
    self:SetPropagate(true)
    self:SetWidthAuto(true)
    self:SetHeightAuto(true)
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
    self:SetCursor("")
    self:SetFillColor(color_transparent)
    self:SetStrokeColor(color_white)
    self:SetStrokeWidth(0)
    self:SetFillRepeatX(false)
    self:SetFillRepeatY(false)
    self:SetFillRepeatScale(1)
    self:SetDisplay(true)
    self:SetEventsEnabled(true)
end

function Panel.Prototype:Setup()
    local type = self:GetType()
    local node = type.Node
    if node then
        type:LoadFromNode(self, node)
    end
end

function Panel.Prototype:GetPadding()
    return self:GetPaddingLeft(), self:GetPaddingTop(), self:GetPaddingRight(), self:GetPaddingBottom()
end

function Panel.Prototype:GetMargin()
    return self:GetMarginLeft(), self:GetMarginTop(), self:GetMarginRight(), self:GetMarginBottom()
end

local LayoutQueue = {}
function Panel.Prototype:InvalidateLayout()
    LayoutQueue[self] = true
end

hook.Add("Think", "Interface.Layout", function()
    for k, v in pairs(LayoutQueue) do
        if IsValid(k) and k:Layout() then
            LayoutQueue[k] = nil        
            print("Layout", k)    
        end
    end
end)


function Panel.Prototype:Layout(immediate)

    if self:GetSuppressLayout() then
        return
    end
    self:SetSuppressLayout(true)


    local parent = self:GetParent()
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

        
            if flowDirection == "X" then
                growElement:SetWidth(w - tw)
                growElement:SetHeight(h - pt - pb - pt)
            else
                growElement:SetWidth(w - pl - pr)
                growElement:SetHeight(h - th)
            end
            

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

    for k, v in pairs(ChildPos) do
        local x, y = unpack(v)
        k:SetX(x)
        k:SetY(y)
    end

    self:SetSuppressLayout(false)
    return true
end

function Panel.Prototype:StartStencil(w, h, x, y, invert)
    
    w = w or self:GetWidth()
    h = h or self:GetHeight()
    x = x or 0
    y = y or 0

    
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
    self:DrawStencil(x, y, w, h)
    
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilCompareFunction(invert and STENCILCOMPARISONFUNCTION_NOTEQUAL or STENCILCOMPARISONFUNCTION_EQUAL)

    surface.SetDrawColor(255, 255, 255, 255)

end

function Panel.Prototype:DrawStencil(x, y, w, h)
    
    local btl, btr, bbr, bbl = self:GetTopLeftRadius(), self:GetTopRightRadius(), self:GetBottomRightRadius(), self:GetBottomLeftRadius()
    if btl or btr or bbr or bbl then
        surface.DrawPoly(drawex.RoundedBox(x, y, w, h, btl or 0, btr or 0, bbr or 0, bbl or 0))
    else
        surface.DrawRect(x, y, w, h)
    end
end

function Panel.Prototype:FinishStencil()
    render.SetStencilEnable(false)
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

local function EmitChildren(el, name, ...)
    if not IsValid(el) then
        return
    end

    el.Events:Run(name, ...)
    for k, v in pairs(el:GetChildren()) do
        EmitChildren(v, name, ...)
    end
end



function Panel.Prototype:EmitImmediate(name, ...)
    assert(name, "Event name must be provided")

    if not IsValid(self) then
        local er = Type.New(EventResult)
        er:SetCancelled(true)
        return er
    end

    if not self:GetEventsEnabled() then
        local er = Type.New(EventResult)
        er:SetCancelled(true)
        return er
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
        EmitChildren(v, "Parent:" .. name, self, ...)
    end
end

function Panel.Prototype:Emit(name, ...)
    assert(name, "Event name must be provided")

    local args = {...}

    debounce(self:GetId() .. ":Emit:" .. name, 0, function ()
        self:EmitImmediate(name, unpack(args))
    end)
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
        self:SetProperty("Width", w + self:GetPaddingRight())
    end
    
    if self:GetHeightAuto() then
        self:SetProperty("Height", h + self:GetPaddingBottom())
    end
end


function Panel.Prototype:ReceiveEvent(name, ...)
    local args = {...}

    -- SizeToChildren
    local el = args[1]
    if (name == "ChildAdded" or name == "ChildRemoved") 
            and el:GetParent() == self then            
        
        self:InvalidateLayout()
    end
    
    --[[
    if name == "ChildAdded" or name == "Child:Change:Ref" then
        local el = args[1]
        local el_ref = args[3]
        local old = args[4]
        
        local ref = self:GetRef()
        
        if el_ref and (ref or not self:GetParent()) then
            local propertyMap = self:GetType():GetPropertiesMap()
            assert(not propertyMap[el_ref], "Can't set reference to " .. el_ref .. "; it is already defined as a property!")

            self[el_ref] = el
            el.RefTarget = self
            Event:SetCancelled(true)
        end
    end

    if self:GetHoverable() and (name == "CursorEntered" or name == "Child:CursorEntered") then
        self:SetProperty("Hovered", true)
        self:EmitImmediate("StartHover")
    end

    if self:GetHoverable() and (name == "CursorExited" or name == "Child:CursorExited") then
        self:SetProperty("Hovered", false)
        self:EmitImmediate("StopHover")
    end

    if isany(name, "Parent:StartHover", "Parent:StopHover", "StartHover", "StopHover") then
        for k, v in pairs(self.ComputedProperties) do
            self:ComputeProperty(k)
        end
    end--]]
end

local function SetProperty(el, name, value)
    local old = el[name]
    el[name] = value
    el.Env[name] = value
    el:OnPropertyChanged(name, value, old)
end

function Panel.Prototype:SetProperty(name, value, immediate)
    
    local p = Type.GetType(self):GetPropertiesMap()[name]

    if p then
        if p.Options.Parse then
            value = p.Options.Parse(self, name, value)
            
            if value == true then
                return
            end
        elseif p.Type and p.Type.Parse then
            value = p.Type:Parse(value)
        end

        if p.Options.AlwaysCalculated or (p.Type and p.Type:GetOptions().AlwaysCalculated) then
            self:SetPropertyComputed(name, value)
            return
        end
    end

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
    assert(func == nil or isfunction(func) or getmetatable(func).__call, "Calculated property must be a function")
    if isfunction(func) then 
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
        local f = self.ComputedProperties[name]
        local succ, result = pcall(f, self)

        if not succ then
            ErrorNoHaltWithStack(result .. "\n")
            return
        end

        SetProperty(self, name, result)
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

local notex = Material("vgui/white")
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

    local sw = self:GetStrokeWidth() or 0
    if sw > 0 then
        local w2 = w - sw * 2
        local h2 = h - sw * 2
        
        self:StartStencil(w2, h2, sw, sw, true)
            surface.SetMaterial(self:GetStroke() or notex)
            surface.SetDrawColor(self:GetStrokeColor())
            self:DrawStencil(0, 0, w, h)
        self:FinishStencil()
        
        self:StartStencil(w2, h2, sw, sw)
            local fillMaterial = self:GetFill() or notex
            surface.SetMaterial(fillMaterial)
            surface.SetDrawColor(self:GetFillColor())
                        

            local repeatX = self:GetFillRepeatX() and (w / (fillMaterial:Width() * self:GetFillRepeatScale())) or 1
            local repeatY = self:GetFillRepeatY() and (h / (fillMaterial:Height() * self:GetFillRepeatScale())) or 1

            surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, repeatX, repeatY)
        self:FinishStencil()
    else
        self:StartStencil(w, h)
            local fillMaterial = self:GetFill() or notex
            surface.SetMaterial(fillMaterial)
            surface.SetDrawColor(self:GetFillColor())

            local repeatX = self:GetFillRepeatX() and (w / (fillMaterial:Width() * self:GetFillRepeatScale())) or 1
            local repeatY = self:GetFillRepeatY() and (h / (fillMaterial:Height() * self:GetFillRepeatScale())) or 1


            surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, repeatX, repeatY)
        self:FinishStencil()
    end


    --self:EmitNoPropagate("Paint")

    self._LastPaint = ct
end

-- LayoutQueue

function Panel.Prototype:PaintOver(w, h)
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
                return self:Paint(w, h)
            end
            el.InvalidateLayout = function (p, ...)
                --return self:Layout(...)
            end
            el.OnCursorEntered = function (...)
                return self:OnCursorEntered(...)
            end
            el.OnCursorExited = function ()
                return self:OnCursorExited()
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

            if self:GetPopup() then
                el:MakePopup(true)
            end
        else
            if IsValid(el) then
                el:Remove()
            end
            self:SetPanel(nil)
            self:SetParent(nil)
        end
    elseif name == "Width" or name == "Height" then
        local parent = self:GetParent()
        if parent then
            parent:InvalidateLayout()
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

            self:InvalidateLayout()

            setmetatable(self.Env, { __index = Interface.GetDefaultEnv() })
        end
        return
    elseif name == "Popup" and value and value ~= old then
        if IsValid(el) then
            self:GetPanel():MakePopup()
        end
    end

    if IsValid(el) and opt.Set then
        local get = opt.Get
        if get then
            old = get(el)
        end

        if old ~= value and not opt.AlwaysSet then
            opt.Set(el, value)
        end
    end

    if value ~= old then
        if opt.Emit then
            self:Emit(opt.Emit, name)
        elseif not opt.Silent then
            --self:Emit("Change:" .. name, name, value, old)
        end
    end
end

function Panel.Prototype:OnCursorEntered()
    self:EmitImmediate("CursorEntered")
end

function Panel.Prototype:OnCursorExited()
    self:EmitImmediate("CursorExited")
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
LISTEN:CreateProperty("Func", Type.String)

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

                if self:GetFunc() then
                    self.Func(name, ...)
                end
            end
        end, self:GetId())
    elseif name == "Properties" then
        local props = string.Split(value, ",")
        tablex.Trim(props)
        props = table.Flip(props)
        self.Props = props
    elseif name == "Func" then
        self.Func = CompileString("return " .. value, "Listen:Func")()
    end
end



local SLOT = Interface.Register("Slot", "Virtual", {
    VGUI = false
})

SLOT:CreateProperty("Name", Type.String)
function SLOT.Prototype:Initialize()
    base(self, "Initialize")
end

function SLOT.Prototype:OnPropertyChanged(name, value, old)
    if name == "Name" then
        local p = self:GetParent()
        p.Slots[name] = self
    end
end

hook.Add("VGUIMousePressed", "Interface.VGUIMousePressed", function (pnl, code)
    local el = pnl.Interface
    if not IsValid(el) then
        return
    end

    el:EmitImmediate("Click", code)
end)