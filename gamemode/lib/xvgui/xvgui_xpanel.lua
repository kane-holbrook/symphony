AddCSLuaFile()
if SERVER then
    return
end 

local BasePanel = FindMetaTable("Panel")
XPanel = {}

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
PANEL.IsXPanel = true
PANEL.IsXVGUI = true

function PANEL:Init()
    self.Uuid = uuid()
    self.Children = {}
    self.Transitions = {}
    self.PropertyCache = {}

    self:SetProperty("Flex", 7)
    self:SetProperty("Direction", "X")
    self:SetProperty("Absolute", false)
end
XPanel.Init = PANEL.Init

function PANEL:SetProperty(name, value)
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
        p.Func = nil
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
    end

    self.Properties[name] = p
    self.PropertyCache[name] = nil
end
XPanel.SetProperty = PANEL.SetProperty

local empty = {}
function PANEL:GetProperty(name, noRecurse, ignoreSelectors)    
    if not noRecurse then
        local val = self.PropertyCache[name]
        if val then
            if val == empty then
                return nil
            else
                return val
            end
        end
    end

    if not ignoreSelectors then
        local hovered = self:GetProperty("Hovered", false, true)
        local selected = self:GetProperty("Selected", false, true)

        if hovered and selected then
            local r = xvgui.GetProperty(self, "Hover:Selected:" .. name, noRecurse) or xvgui.GetProperty(self, "Hover:" .. name, noRecurse) or xvgui.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        elseif hovered then
            local r = xvgui.GetProperty(self, "Hover:" .. name, noRecurse) or xvgui.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        elseif selected then
            local r = xvgui.GetProperty(self, "Selected:" .. name, noRecurse) or xvgui.GetProperty(self, name, noRecurse)
            self.PropertyCache[name] = r
            return r
        end
    end

    local r = xvgui.GetProperty(self, name, noRecurse)
    self.PropertyCache[name] = r or empty
    return r
end
XPanel.GetProperty = PANEL.GetProperty

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
XPanel.SetPropertyOption = PANEL.SetPropertyOption

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
XPanel.GenerateChildrenCache = PANEL.GenerateChildrenCache

function PANEL:GetChildren()
    local out = {}
    for k, v in pairs(self.Children) do
        if IsValid(v) then
            out[k] = v
        end
    end

    return out
end
XPanel.GetChildren = PANEL.GetChildren

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
XPanel.OnChildAdded = PANEL.OnChildAdded

function PANEL:OnChildRemoved(child)
    self:GenerateChildrenCache(nil, true)
    
    local p_w = self:GetProperty("Width", true)
    local p_h = self:GetProperty("Height", true)
end
XPanel.OnChildRemoved = PANEL.OnChildRemoved

function PANEL:CalculateChildrenSize()
    local tw, th = 0, 0

    local minx, miny = math.huge, math.huge
    for k, v in pairs(self:GetChildren()) do
        if not v:GetProperty("Display") or v:GetProperty("Absolute", true) then
            continue
        end

        local x, y = v:GetPos()
        minx = math.min(minx, x)
        miny = math.min(miny, y)
    end

    for k, v in pairs(self:GetChildren()) do
        if not v:GetProperty("Display") or v:GetProperty("Absolute", true) then
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
XPanel.CalculateChildrenSize = PANEL.CalculateChildrenSize

function PANEL:SizeToChildren(sizeW, sizeH)
    local w, h = self:CalculateChildrenSize()
    local pl, pt, pr, pb = self:CalculatePadding()

    self:SetSize(sizeW and w + pl + pr or self:GetWide(), sizeH and h + pt + pb or self:GetTall())
end
XPanel.SizeToChildren = PANEL.SizeToChildren

function PANEL:PerformLayout(w, h, noSet)
    w, h = xvgui.PerformLayout(self, w, h)

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
XPanel.PerformLayout = PANEL.PerformLayout

function PANEL:CalculateName()
    local ref = self:GetProperty("Ref", true)
    if ref then
        return ref .. "<" .. self.ClassName .. ">"
    end

    return self.ClassName
end
XPanel.CalculateName = PANEL.CalculateName

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
XPanel.CalculatePosition = PANEL.CalculatePosition

function PANEL:CalculatePadding()
    return self:GetProperty("PaddingLeft", true) or 0, self:GetProperty("PaddingTop", true) or 0, self:GetProperty("PaddingRight", true) or 0, self:GetProperty("PaddingBottom", true) or 0
end
XPanel.CalculatePadding = PANEL.CalculatePadding

function PANEL:CalculateMargin()
    return self:GetProperty("MarginLeft", true) or 0, self:GetProperty("MarginTop", true) or 0, self:GetProperty("MarginRight", true) or 0, self:GetProperty("MarginBottom", true) or 0
end
XPanel.CalculateMargin = PANEL.CalculateMargin

function PANEL:CalculateRadius()
    return self:GetProperty("TopLeftRadius", true), self:GetProperty("TopRightRadius", true), self:GetProperty("BottomRightRadius", true), self:GetProperty("BottomLeftRadius", true)
end
XPanel.CalculateMargin = PANEL.CalculateMargin

function PANEL:CalculateSize()
    if self:GetProperty("Grow", true) then
        return
    end

    if self:GetProperty("Display") == false then
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

    return math.Round(w, 0), math.Round(h, 0)
end
XPanel.CalculateSize = PANEL.CalculateSize

function PANEL:GenerateMaterial(name, func, w, h)
    timer.Create(self.Uuid .. name, 1, 1, function ()
        print("Generating", self.Uuid, name)
        local result = func(w, h)

        if istable(result) then
            for k, v in pairs(result) do
                if not IsColor(v) and v:GetInt("_loading") == 1 then
                    self:GenerateMaterial(name, func, w, h)
                    print(" -> Skip")
                    return
                end
            end

            self[name] = drawex.RenderMaterial("UnlitGeneric", self:GetWide(), self:GetTall(), function (w, h)
                for k, v in pairs(result) do
                    if IsColor(v) then
                        surface.SetDrawColor(v)
                        surface.DrawRect(0, 0, w, h)
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
XPanel.CalculateFlex = PANEL.CalculateFlex


function PANEL:OnCursorEntered()
    if self:GetProperty("Hover", true) then
        self:SetProperty("Hovered", true)
        self:Emit("StartHover")
        self:InvalidateChildren(true)
    else
        self:Emit("CursorEntered")
    end
end

function PANEL:OnCursorExited()
    if not self:GetFuncEnv().Hovered then
        return
    end

    if self:GetProperty("Hover", true) then
        self:SetProperty("Hovered", false)
        self:Emit("StopHover")
        self:InvalidateChildren()
    else
        self:Emit("CursorExited")
    end
end

function PANEL:OnMousePressed(code)
    if code == MOUSE_LEFT then
        self:Emit("Click")
    else
        self:Emit("RightClick")
    end
end
XPanel.OnMousePressed = PANEL.OnMousePressed

function PANEL:CalculateFont()
    local font = self:GetProperty("FontName")
    local size = self:GetProperty("FontSize")
    local weight = self:GetProperty("FontWeight")

    local p = xvgui.Font(font, size, weight)
    self:SetProperty("Font", p)
    
    return xvgui.Font(font, size, weight)
end
XPanel.CalculateFont = PANEL.CalculateFont

local blurtex = Material("pp/blurscreen")
local notex = Material("vgui/white")
function PANEL:Paint(w, h)
    local ct = CurTime()
    --local dt = ct - self._LastPaint

    --[[for k, v in pairs(self.Transitions) do
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
    end--]]

    local blur = self:GetProperty("Blur", true) or 0
    if blur > 0 then
        local x, y = self:ScreenToLocal(0, 0)

        self:StartStencil(w, h, 0, 0, false)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(blurtex)
            blurtex:SetFloat("$blur", blur)
            blurtex:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x, y, ScrW(), ScrH())
        self:FinishStencil()
    end

    local sw = self:GetProperty("StrokeWidth", true) or 0
    if sw > 0 then
        local w2 = w - sw * 2
        local h2 = h - sw * 2
        
        self:StartStencil(w2, h2, sw, sw, true)
            surface.SetMaterial(self:GetProperty("Stroke", true) or notex)
            surface.SetDrawColor(self:GetProperty("StrokeColor", true) or color_white)
            self:DrawStencil(0, 0, w, h)
        self:FinishStencil()
        
        self:StartStencil(w2, h2, sw, sw)
            local fillUnder = self:GetProperty("FillUnder", true)
            if fillUnder then
                surface.SetDrawColor(fillUnder)
                surface.DrawRect(0, 0, w, h)
            end

            local fillMaterial = self:GetProperty("Fill", true) or notex

            if isfunction(fillMaterial) then
                fillMaterial(w2, h2, sw, sw)
            else
                surface.SetMaterial(fillMaterial)
                surface.SetDrawColor(self:GetProperty("FillColor", true) or color_transparent)
                            

                local repeatX = self:GetProperty("FillRepeatX", true) and (w / (fillMaterial:Width() * (self:GetProperty("FillRepeatScale", true) or 1))) or 1
                local repeatY = self:GetProperty("FillRepeatY", true) and (h / (fillMaterial:Height() * (self:GetProperty("FillRepeatScale", true) or 1))) or 1

                local u = self:GetProperty("U", true)
                local v = self:GetProperty("V", true)
                if u and v then
                    print(u, v)
                end
                
                surface.DrawTexturedRectUV(0, 0, w, h, u or 0, v or 0, repeatX, repeatY)
            end
        self:FinishStencil()
    else
        self:StartStencil(w, h)
            local fillMaterial = self:GetProperty("Fill", true) or notex

            if isfunction(fillMaterial) then
                fillMaterial(w, h, 0, 0)
            else
                surface.SetMaterial(fillMaterial)
                surface.SetDrawColor(self:GetProperty("FillColor", true) or color_transparent)

                local repeatX = self:GetProperty("FillRepeatX", true) and (w / (fillMaterial:Width() * (self:GetProperty("FillRepeatScale", true) or 1))) or 1
                local repeatY = self:GetProperty("FillRepeatY", true) and (h / (fillMaterial:Height() * (self:GetProperty("FillRepeatScale", true) or 1))) or 1

                surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, repeatX, repeatY)
            end
        self:FinishStencil()
    end

    self._LastPaint = ct
end
XPanel.Paint = PANEL.Paint


function PANEL:StartStencil(w, h, x, y, invert)
    
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
XPanel.StartStencil = PANEL.StartStencil

function PANEL:DrawStencil(x, y, w, h)
    
    local btl, btr, bbr, bbl = self:CalculateRadius()
    if btl or btr or bbr or bbl then
        surface.DrawPoly(drawex.RoundedBox(x, y, w, h, btl or 0, btr or 0, bbr or 0, bbl or 0))
    else
        surface.DrawRect(x, y, w, h)
    end
end
XPanel.DrawStencil = PANEL.DrawStencil

function PANEL:FinishStencil()
    render.SetStencilEnable(false)
end
XPanel.FinishStencil = PANEL.FinishStencil


function PANEL:OnPropertyChanged(prop, value, old)
    if xvgui.OnPropertyChanged(self, prop, value, old) then
        return true
    end
    
    local p = self:GetParent()
    if prop == "Name" then
        self:SetName(value)
        return true
    end

    if prop == "Hover" and value then
        self:SetProperty("Hovered", false)
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

    if p.IsXPanel and (prop == "Display" or prop == "X" or prop == "Y" or prop == "Width" or prop == "Height") then
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
XPanel.OnPropertyChanged = PANEL.OnPropertyChanged
BasePanel.CalculateMargin = PANEL.CalculateMargin


local wp = vgui.GetWorldPanel()

-- GMod default: 13px Tahoma, anti-aliased.

vgui.Register("XPanel", PANEL, "EditablePanel")
vgui.Register("Rect", PANEL, "EditablePanel")