AddCSLuaFile()
if SERVER then
    return
end 

local BasePanel = FindMetaTable("Panel")
Rect = {}

--[[
    Properties ✓
    SizeToChildren: ✓
    Background: ✓
    Flex: ✓
        Absolute:
            Flex: ✓
            Margin: ✓
            Padding: ✓
            Gap: ✓
        Auto:
            Flex: ✓
            Margin: ✓
            Padding: ✓
            Gap: ✓
    Borders: 
    Stencils: 
    Labels: ✓
    XML: ✓
    Ref: ✓
    Hook: ✓
    For: ✓
    Hover: ✓
    Emit: ✓
    Click: ✓
    ContextMenu: ✓

    Bugs:
    - DLabels aren't sizing properly.
    - Cursor
    - Transitions
    - Why aren't FuncEnvs propagating to components? Works from pure XML.

    Where I want to get to:
    - Borders and border radius (eugh).
]]

local PANEL = {}
PANEL.IsRect = true
PANEL.SymInitialized = true

function PANEL:Init()
    self.Uuid = uuid()
    self.Children = {}
    self.Transitions = {}
    self.LastPaint = CurTime()
    self.PropertyCache = {}
    
    self:SetProperty("Flex", 7)
    self:SetProperty("Direction", "X")
    self:SetProperty("Background", color_transparent)
    self.EventBus = new(Type.EventBus)
end
Rect.Init = PANEL.Init

function PANEL:SetProperty(name, value, transient)
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
        self.PropertyCache[name] = nil
    else
        p.Value = value

        local FuncEnv = self.FuncEnv
        if not FuncEnv then
            FuncEnv = {
                __index = self
            }
            FuncEnv.self = self
            self.FuncEnv = FuncEnv
        end
        FuncEnv[name] = value

        if value ~= old then
            self:OnPropertyChanged(name, value, old)
        end
        self.PropertyCache[name] = p.Value
    end

    self.Properties[name] = p
end
Rect.SetProperty = PANEL.SetProperty

function PANEL:GetProperty(name, noRecurse, ignoreSelectors)    
    local val = self.PropertyCache[name]
    if val ~= nil then
        return val
    end

    if not ignoreSelectors then
        local hovered = self:GetProperty("Hovered", true, true)
        local selected = self:GetProperty("Selected", false, true)

        if hovered and selected then
            local r = Interface.GetProperty(self, "Hover:Selected:" .. name, noRecurse) or Interface.GetProperty(self, "Hover:" .. name, noRecurse) or Interface.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        elseif hovered then
            local r = Interface.GetProperty(self, "Hover:" .. name, noRecurse) or Interface.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        elseif selected then
            local r = Interface.GetProperty(self, "Selected:" .. name, noRecurse) or Interface.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        end
    end

    local r = Interface.GetProperty(self, name, noRecurse)
    
    self.PropertyCache[name] = r or empty
    return r
end
Rect.GetProperty = PANEL.GetProperty

function PANEL:SetPropertyOption(name, key, value)
    assert(name, "Must provide a property name")
    
    self.Properties = self.Properties or {} 

    local p = self.Properties[name]
    if not p then
        p = {}
        p.Options = {}
    end

    p.Options[key] = value

    self.Properties[name] = p
end
Rect.SetPropertyOption = PANEL.SetPropertyOption

function PANEL:Transition(property, to, duration, easing)
    local t= {}
    t.value = self:GetProperty(property, true)
    t.tween = neonate.new(duration, t.value, to, easing)
    self.Transitions[property] = t
end
Rect.Transition = PANEL.Transition

-- Children management
function PANEL:GenerateChildrenCache(child, force)
    if not self.Children or force then
        self.Children = {}
        for k, v in pairs(BasePanel.GetChildren(self)) do
            self.Children[k] = v
            v.Index = k
        end
    end

    if child then
        if not table.HasValue(self.Children, child) then
            child.Index = table.insert(self.Children, child)
        end
    end
end
Rect.GenerateChildrenCache = PANEL.GenerateChildrenCache

function PANEL:GetChildren()
    local out = {}
    for k, v in pairs(self.Children) do
        if IsValid(v) then
            out[k] = v
        end
    end

    return out
end
Rect.GetChildren = PANEL.GetChildren

function PANEL:OnChildAdded(child)
    self:GenerateChildrenCache(child)

    local p_w = self:GetProperty("Width", true)
    local p_h = self:GetProperty("Height", true)
    --if IsValid(self) then
        --self:SizeToChildren(not p_w, not p_h)
    --end

    -- child isn't fully instantiated at this point if created by vgui.Create.
    --[[local uuid = uuid()
    hook.Add("PostRenderVGUI", uuid, function ()
        hook.Remove("PostRenderVGUI", uuid)

        local p_w = self:GetProperty("Width")
        local p_h = self:GetProperty("Height")
        if IsValid(self) then
            self:SizeToChildren(not p_w, not p_h)
        end
    end)--]]
end
Rect.OnChildAdded = PANEL.OnChildAdded

function PANEL:OnChildRemoved(child)
    self:GenerateChildrenCache(nil, true)
    
    local p_w = self:GetProperty("Width", true)
    local p_h = self:GetProperty("Height", true)
end
Rect.OnChildRemoved = PANEL.OnChildRemoved

function PANEL:CalculateChildrenSize()
    local tw, th = 0, 0

    local minx, miny = math.huge, math.huge
    for k, v in pairs(self:GetChildren()) do
        if not v:GetProperty("Display") then
            continue
        end

        local x, y = v:GetPos()
        minx = math.min(minx, x)
        miny = math.min(miny, y)
    end

    for k, v in pairs(self:GetChildren()) do
        if not v:GetProperty("Display") then
            continue
        end

        local x, y = v:GetPos()
        local w, h = v:GetSize()
        local ml, mt, mr, mb = 0, 0, 0, 0 -- v:CalculateFlexMargin() @TODO

        tw = math.max(tw, x + w + ml + mr - minx)
        th = math.max(th, y + h + mt + mb - miny)
    end

    return tw, th
end
Rect.CalculateChildrenSize = PANEL.CalculateChildrenSize

function PANEL:SizeToChildren(sizeW, sizeH)
    local w, h = self:CalculateChildrenSize()
    local pl, pt, pr, pb = self:CalculatePadding()

    self:SetSize(sizeW and w + pl + pr or self:GetWide(), sizeH and h + pt + pb or self:GetTall())
end
Rect.SizeToChildren = PANEL.SizeToChildren

function PANEL:PerformLayout(w, h, noSet)
    w, h = Interface.PerformLayout(self, w, h)

    if self:GetProperty("SuppressLayout") then
        return true
    end

    self.PropertyCache = {}

    local env = self:GetFuncEnv()
    local x, y
    if not self:GetProperty("Absolute", true) and self:GetParent():GetProperty("Flex") then
        x, y = self:GetPos()
    else
        x, y = self:CalculatePosition()
    end
    env.X = x
    env.Y = y
    env.LastW = self:GetWide()
    env.LastH = self:GetTall()

    local w, h = self:CalculateSize()
    env.Width = w
    env.Height = h
    
    self:CalculateFlex(w, h)

    if not self:GetProperty("Name", true) then
        self:SetName(self:CalculateName())
    end

    local cursor = self:GetProperty("Cursor")
    if cursor ~= self.Cursor then
        self:SetCursor(cursor)
    end

    if not noSet then
        if x ~= env.LastX or y ~= env.LastY then
            self:SetPos(x, y)
        end

        if w ~= env.LastW or h ~= env.LastH then
            self:SetSize(math.max(w or self:GetWide(), 1), math.max(h or self:GetTall(), 1))
        end
    end
    return w, h, x, y
end
Rect.PerformLayout = PANEL.PerformLayout

function PANEL:CalculateName()
    local ref = self:GetProperty("Ref", true)
    if ref then
        return ref .. "<" .. self.ClassName .. ">"
    end

    return self.ClassName
end
Rect.CalculateName = PANEL.CalculateName

function PANEL:CalculatePosition()
    return self:GetProperty("X", true), self:GetProperty("Y", true)

    --[[local env = self:GetFuncEnv()
    if not env.Parent.Flex or env.Absolute then
        if env.X ~= env.LastX or env.Y ~= env.LastY then
            self:SetPos(env.X, env.Y)
            return env.X, env.Y
        end
    end--]]
end
Rect.CalculatePosition = PANEL.CalculatePosition

function PANEL:CalculatePadding()
    return self:GetProperty("PaddingLeft", true) or 0, self:GetProperty("PaddingTop", true) or 0, self:GetProperty("PaddingRight", true) or 0, self:GetProperty("PaddingBottom", true) or 0
end
Rect.CalculatePadding = PANEL.CalculatePadding

function PANEL:CalculateMargin()
    return self:GetProperty("MarginLeft", true) or 0, self:GetProperty("MarginTop", true) or 0, self:GetProperty("MarginRight", true) or 0, self:GetProperty("MarginBottom", true) or 0
end
Rect.CalculateMargin = PANEL.CalculateMargin

function PANEL:CalculateBorderRadius()
    return self:GetProperty("TopLeftRadius", true), self:GetProperty("TopRightRadius", true), self:GetProperty("BottomRightRadius", true), self:GetProperty("BottomLeftRadius", true)
end
Rect.CalculateMargin = PANEL.CalculateMargin

function PANEL:CalculateSize()
    if self:GetProperty("Grow", true) then
        return
    end

    if not self:GetProperty("Display") then
        return 0, 0
    end
    
    local w, h = self:GetProperty("Width", true), self:GetProperty("Height", true)
    if not w or not h then
        local w2, h2 = self:CalculateChildrenSize()
        local pl, pt, pr, pb = self:CalculatePadding()

        if not w then
            w = w2 + pl + pr
        end

        if not h then
            h = h2 + pt + pb
        end
    end

    local bg = self:GetProperty("Background", true)
    if isfunction(bg) then
        self.BackgroundInit = nil
        self:GenerateMaterial("Background", bg, w, h)
    end

    return math.Round(w, 0), math.Round(h, 0)
end
Rect.CalculateSize = PANEL.CalculateSize

function PANEL:GenerateMaterial(name, func, w, h)
    timer.Create(self.Uuid .. name, 1, 1, function ()
        if not IsValid(self) then
            return
        end

        local result = func(w, h)

        if istable(result) then
            for k, v in pairs(result) do
                if not IsColor(v) and v:GetInt("_loading") == 1 then
                    self:GenerateMaterial(name, func, w, h)
                    return
                end
            end

            self[name] = drawex.RenderMaterial("UnlitGeneric", self:GetWide(), self:GetTall(), function (w, h)
                for k, v in pairs(result) do
                    if IsColor(v) then
                        surface.SetDrawColor(v)
                        surface.DrawRect(0, 0, w, h)
                    elseif istable(v) then
                        print("Result is a table!")
                        for k2, v2 in pairs(v) do
                            if IsColor(v2) then
                                surface.SetDrawColor(v2)
                                surface.DrawRect(0, 0, w, h)
                            else
                                error("Material still loading")

                                surface.SetMaterial(v2)
                                surface.SetDrawColor(color_white)
                                surface.DrawTexturedRect(0, 0, w, h)
                            end
                        end
                    else
                        if v:GetInt("_loading") == 1 then
                            continue
                        end

                        surface.SetMaterial(v)
                        surface.SetDrawColor(color_white)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end
                end
            end, { ["$translucent"] = 1 })
        else
            self[name] = result
        end
    end)
end

function PANEL:CalculateFlex(w, h)
    local align = self:GetProperty("Flex", true)
    if not align then
        return
    end

    if not w and not h then
        w, h = self:GetSize()
    end

    local flowDirection = self:GetProperty("Direction", true)
    local gap = self:GetProperty("Gap", true) or 0
    local pl, pt, pr, pb = self:CalculatePadding()


    local children = self:GetChildren()
    local tw, th = 0, 0
    local growElement
    for k, child in pairs(children) do
        if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
            continue
        end

        local cl, ct, cr, cb = child:CalculateMargin()

        if child:GetProperty("Grow", true) then
            assert(not growElement, "Can only have one element set to Grow within a child.")

            growElement = child
            tw = tw + cr + cl + gap            
            th = th + ct + cb + gap
        else
            child:InvalidateLayout(true)
            tw = tw + child:GetWide() + cr + cl + gap            
            th = th + child:GetTall() + ct + cb + gap
        end
    end
    tw = tw - gap + pl + pr
    th = th - gap + pt + pb

    if growElement then
        local cl, ct, cr, cb = growElement:CalculateMargin()
        if flowDirection == "X" then
            growElement:SetSize(w - tw, h - pt - pb)
        else
            growElement:SetSize(w - pr - pl, h - th)
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
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end

            local cl, ct, cr, cb = child:CalculateMargin()
            local cw, ch = child:GetSize()
            
            if flowDirection == "X" then
                ChildPos[child] = { x + cl, y }
                x = x + cw + cr + cl + gap
            else
                ChildPos[child] = { cl + pl, 0 }
            end
        end
    elseif isany(align, 8, 5, 2) then
        local wd = self:GetWide()/2 - tw/2
        local x = wd + pl
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end

            local cl, ct, cr, cb = child:CalculateMargin()
                            
            if flowDirection == "X" then
                ChildPos[child] = { cl + x, 0 }
                x = x + cl + child:GetWide() + cr + gap
            else
                ChildPos[child] = { self:GetWide()/2 - child:GetWide()/2, 0 }
            end
        end
    else
        local wd = self:GetWide()
        local x = wd - pr
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end

            local cl, ct, cr, cb = child:CalculateMargin()

            if flowDirection == "X" then
                x = x - child:GetWide() - cr
                ChildPos[child] = { x, 0 }
                x = x - cl - gap
            else
                ChildPos[child] = { wd - child:GetWide() - cr - pr }
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
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end
            
            local cl, ct, cr, cb = child:CalculateMargin()
            local cp = ChildPos[child]
                                            
            if flowDirection == "Y" then
                
                ChildPos[child][2] = y + ct
                y = y + ct + child:GetTall() + cb + gap
            else
                ChildPos[child][2] = y + ct
                y = t
            end
        end
    elseif isany(align, 4, 5, 6) then
        local t = self:GetTall()/2 - th/2
        local y = t + pt
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end

            local cl, ct, cr, cb = child:CalculateMargin()
            local cp = ChildPos[child]

            if flowDirection == "Y" then               
                ChildPos[child][2] = y + ct
                y = y + child:GetTall() + cb + gap
            else
                y = h/2 - child:GetTall()/2
                ChildPos[child][2] = y
            end
        end
    else
        local t = self:GetTall() - pb
        local y = t
        for k=1, #children do
            local child = children[k]

            if not IsValid(child) then
                continue
            end
            
            if child:GetProperty("Absolute", true) or not child:GetProperty("Display") then
                continue
            end

            local cl, ct, cr, cb = child:CalculateMargin()
            local cp = ChildPos[child]

            if flowDirection == "Y" then
                y = y - child:GetTall() - cb
                ChildPos[child][2] = y
                y = y - ct - gap
            else
                y = t - child:GetTall() - cb
                ChildPos[child][2] = y
            end

        end
    end        

    for k, v in pairs(ChildPos) do
        local x, y = unpack(v)
        local cenv = k:GetFuncEnv()

        if not cenv or cenv.LastX ~= x or cenv.LastY ~= y then
            k:SetPos(x, y)
        end
    end
end
Rect.CalculateFlex = PANEL.CalculateFlex

function PANEL:OnCursorEntered()
    self:Emit("Hover")
end
Rect.OnCursorEntered = PANEL.OnCursorEntered

function PANEL:OnCursorExited()
    self:Emit("StopHover")
end
Rect.OnCursorExited = PANEL.OnCursorExited

function PANEL:OnStartHover(child)
    self:SetProperty("Hovered", true)
    self:InvalidateLayout()
end

function PANEL:OnStopHover(child)
    self:SetProperty("Hovered", false)
    self:InvalidateLayout()
end

function PANEL:HandleEmit(panel, event, ...)
    BasePanel.HandleEmit(self, panel, event, ...)

    local r = self.EventBus:Run("Emit", self, panel, event, ...)

    if r:GetCancelled() then
        return true
    end
    
    r = self.EventBus:Run(event, self, panel, ...)
    if r:GetCancelled() then
        return
    end

    if event == "Hover" and self:GetProperty("Hover", true) then
        self:OnStartHover(panel, ...)
        return true
    end

    if event == "StopHover" and self:GetProperty("Hover", true) then
        self:OnStopHover(panel, ...)
        return true
    end
end
Rect.HandleEmit = PANEL.HandleEmit

function PANEL:OnMousePressed(code)
    if code == MOUSE_LEFT then
        local cl = self:GetProperty("Click")
        if cl then
            cl(self)
        end
    else
        local cl = self:GetProperty("ContextMenu")
        if cl then
            cl(self)
        end
    end
end
Rect.OnMousePressed = PANEL.OnMousePressed

-- We delay the calculation of a func background (1) so we can get a size and (2) wait a little while
-- to ensure the size has stabilized.
function PANEL:CalculateBackground()

    if self.BackgroundScheduled then
        return
    end

    local env = self:GetFuncEnv()
    if not env then
        return
    end

    local p = self.Properties.Background
    if p.Value and env.LastW == env.Width and env.LastH == env.Height then
        return
    end

    if p.Func then
        self.BackgroundScheduled = true
        
        timer.Simple(0.1, function ()
            local env = self:GetFuncEnv()
            setfenv(p.Func, env)
            local old = p.Value
            local val = p.Func(val, old)
            p.Value = val
            env["Background"] = val

            if val ~= old then
                self:OnPropertyChanged("Background", val, old)
            end

            self.BackgroundScheduled = false
        end)
    end
end
Rect.CalculateBackground = PANEL.CalculateBackground

function PANEL:CalculateFont()
    local font = self:GetProperty("FontName")
    local size = self:GetProperty("FontSize")
    local weight = self:GetProperty("FontWeight")

    local p = Interface.Font(font, size, weight)
    self:SetProperty("Font", p)
    
    return Interface.Font(font, size, weight)
end
Rect.CalculateFont = PANEL.CalculateFont

NUM_STENCILS = 0

local matBlurScreen = Material("pp/blurscreen")
function PANEL:Paint(w, h)
    for k, v in pairs(self.Transitions) do
        local dt = CurTime() - self.LastPaint
        local finished = v.tween:update(dt)
        self:SetProperty(k, v.value)

        if finished then
            self.Transitions[k] = nil
        end
    end

    -- Stencils eat xxx frames 

    local stencil
    self:StartStencil(w, h)

    self:PaintBackground(w, h)

    self:FinishStencil()

    self.LastPaint = CurTime()
end

function PANEL:StartStencil(w, h, x, y)
    x = x or 0
    y = y or 0

    local btl, btr, bbr, bbl = self:CalculateBorderRadius()
    if btl or btr or bbr or bbl then
        stencil = true
        NUM_STENCILS = NUM_STENCILS + 1

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
        surface.DrawPoly(drawex.RoundedBox(0, 0, w, h, btl or 0, btr or 0, bbr or 0, bbl or 0))
        
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilCompareFunction(invert and STENCILCOMPARISONFUNCTION_NOTEQUAL or STENCILCOMPARISONFUNCTION_EQUAL)

        surface.SetDrawColor(255, 255, 255, 255)
    end
end

function PANEL:FinishStencil()
    render.SetStencilEnable(false)
end

function PANEL:PaintBorder(w, h)
    local border = self:GetProperty("Border")
    if border then
    end
end

function PANEL:PaintBackground(w, h)
    local bg = self:GetProperty("Background")
    if self:GetProperty("Background", true) then
        --local bg = self.Background
        if bg then
            if IsColor(bg) then
                surface.SetDrawColor(bg)
                surface.DrawRect(0, 0, w, h)
                self.BackgroundInit = 0
            else
                bg = self.Background
                if bg and bg.GetInt and bg:GetInt("_loading") ~= 1 then
                    surface.SetMaterial(bg)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(0, 0, w, h)
                    
                    if not self.BackgroundInit then 
                        self.BackgroundInit = CurTime()
                    end
                end
            end
        else
            surface.SetDrawColor(self:GetProperty("BackgroundFallback"))
            surface.DrawRect(0, 0, w, h)
        end

        if self.BackgroundInit then

            local elapsed = CurTime() - self.BackgroundInit
            local prog = (elapsed / 0.3)
            if prog < 1 then
                local col = self:GetProperty("BackgroundFallback")                
                col.a = 255 - math.Clamp(prog * 255, 0, 255)

                surface.SetDrawColor(col)
                surface.DrawRect(0, 0, w, h)
            end
        end

        
    end
end
Rect.Paint = PANEL.Paint
Rect.PaintBackground = PANEL.PaintBackground


function PANEL:OnPropertyChanged(prop, value, old)
    if Interface.OnPropertyChanged(self, prop, value, old) then
        return true
    end
    
    local p = self:GetParent()
    if prop == "Name" then
        self:SetName(value)
        return true
    end

    if prop == "Padding" then
        self:SetProperty("PaddingLeft", value)
        self:SetProperty("PaddingTop", value)
        self:SetProperty("PaddingRight", value)
        self:SetProperty("PaddingBottom", value)
        self.Properties["Padding"] = nil
        return true
    end

    if prop == "PaddingX" then
        self:SetProperty("PaddingLeft", value)
        self:SetProperty("PaddingRight", value)
        self.Properties["PaddingX"] = nil
    end

    if prop == "PaddingY" then
        self:SetProperty("PaddingTop", value)
        self:SetProperty("PaddingBottom", value)
        self.Properties["PaddingY"] = nil
        return true
    end

    if prop == "Margin" then
        self:SetProperty("MarginLeft", value)
        self:SetProperty("MarginTop", value)
        self:SetProperty("MarginRight", value)
        self:SetProperty("MarginBottom", value)
        self.Properties["Margin"] = nil
        return true
    end

    if prop == "Radius" then
        self:SetProperty("TopLeftRadius", value)
        self:SetProperty("TopRightRadius", value)
        self:SetProperty("BottomRightRadius", value)
        self:SetProperty("BottomLeftRadius", value)
        self.Properties["Radius"] = nil
        return true
    end

    if prop == "MarginX" then
        self:SetProperty("MarginLeft", value)
        self:SetProperty("MarginRight", value)
        self.Properties["MarginX"] = nil
        return true
    end

    if prop == "MarginY" then
        self:SetProperty("MarginTop", value)
        self:SetProperty("MarginBottom", value)
        self.Properties["MarginY"] = nil
        return true
    end

    if prop == "Background" then
        if isfunction(value) then
            self.Background = nil
            self.BackgroundInit = nil
            self:GenerateMaterial("Background", value, self:GetWide(), self:GetTall())
        else
            self.Background = value
        end
    end

    if p.IsRect and (prop == "Display" or prop == "X" or prop == "Y" or prop == "Width" or prop == "Height") then
        -- For positionals, do nothing if the value is set to nil.
        if prop ~= "Display" and not value then
            return true
        end

        local p_w = p:GetProperty("Width", true)
        local p_h = p:GetProperty("Height", true)

        --self:InvalidateLayout(true) -- Do I need this?
        return true
    end
end
Rect.OnPropertyChanged = PANEL.OnPropertyChanged
BasePanel.CalculateMargin = PANEL.CalculateMargin


local wp = vgui.GetWorldPanel()

-- GMod default: 13px Tahoma, anti-aliased.
wp:SetProperty("BackgroundFallback", color_black)
vgui.Register("Rect", PANEL, "EditablePanel")


Interface.RegisterAttribute("Panel", "BackgroundFallback", Type.Color)
Interface.RegisterAttribute("Rect", "Background", Type.Color)

Interface.RegisterAttribute("Rect", "Padding", Interface.Extent4)
Interface.RegisterAttribute("Rect", "PaddingLeft", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "PaddingTop", Interface.ExtentH)
Interface.RegisterAttribute("Rect", "PaddingRight", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "PaddingBottom", Interface.ExtentH)

Interface.RegisterAttribute("Rect", "Margin", Interface.Extent4)
Interface.RegisterAttribute("Rect", "MarginLeft", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "MarginTop", Interface.ExtentH)
Interface.RegisterAttribute("Rect", "MarginRight", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "MarginBottom", Interface.ExtentH)

Interface.RegisterAttribute("Rect", "Radius", Interface.Extent4)
Interface.RegisterAttribute("Rect", "TopLeftRadius", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "TopRightRadius", Interface.ExtentH)
Interface.RegisterAttribute("Rect", "BottomLeftRadius", Interface.ExtentW)
Interface.RegisterAttribute("Rect", "BottomRightRadius", Interface.ExtentH)

Interface.RegisterAttribute("Rect", "Gap", Interface.ExtentW)