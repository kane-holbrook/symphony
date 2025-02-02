if SERVER then
    return
end

local PANEL = {}
DEFINE_BASECLASS("Panel")

-- Backgrounds
-- Border radius
-- Size to children

function PANEL:FromXML(xml)
    local xml2lua = include("lib/xml2lua/xml2lua.lua")
    local tree = include("lib/xml2lua/tree.lua")
    local parser = xml2lua.parser(tree)
    parser:parse(xml)

    PrintTable(tree.root)
    return tree
end

function PANEL:Add(component, data)
    local comp = self:AddEx(component, data)
    return self, comp
end

function PANEL:Parent()
    return self:GetParent()
end

function PANEL:AddEx(component, data)
    if istable(component) then
        data = component
        component = "SymPanel"
    end

    
    data = data or {}
    local v = vgui.Create(component, self)

    if data.Ref then
        self[data.Ref] = v
        data.Ref = nil
    end

    SymPanel.Set(v, data)
    return v
end

function PANEL:GenerateChildrenCache(child, force)
    if not self.IndexedChildren or force then
        self.IndexedChildren = {}
        for k, v in pairs(self:GetChildren()) do
            self.IndexedChildren[k] = v
            v.Index = k
        end
    end

    if child then
        if not table.HasValue(self.IndexedChildren, child) then
            child.Index = table.insert(self.IndexedChildren, child)
        end
    end
end

function PANEL:GetOrderedChildren()
    local out = {}
    for k, v in pairs(self.IndexedChildren) do
        if IsValid(v) then
            out[k] = v
        end
    end

    return out
end

function PANEL:OnChildAdded(child)
    self:GenerateChildrenCache(child)
end

PANEL.Parent = PANEL.GetParent

function PANEL:Paint(w, h)
    local bg = self:IsHovered() and self:GetHover() or self:GetBackground()
    if bg then
        if IsColor(bg) then
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
        else
            surface.SetDrawColor(color_white)     
            surface.SetMaterial(bg)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    surface.SetDrawColor(255, 255, 255, 255)
    --surface.DrawLine(w/2, 0, w/2, h)
    --surface.DrawLine(0, h/2, w, h/2)
end

function PANEL:SetBackground(col)
    if col == true then
        col = 253
    end
    
    if isnumber(col) then
        return self:SetBackground(
            HTMLGradient([[radial-gradient(
                circle, 
                rgba(32, 40, 47, ]] .. col/255 .. [[) 0%,
                rgb(39, 44, 49, ]] .. col/255 .. [[) 50%
            )]], ScrW(), ScrH())
        )
    end

    self.Background = col
end

function PANEL:GetBackground()
    return self.Background
end

function PANEL:SetHover(col)
    if col == true then
        col = 253
    end
    
    if isnumber(col) then
        return self:SetHover(
            HTMLGradient([[radial-gradient(
                circle, 
                rgba(32, 40, 47, ]] .. col/255 .. [[) 0%,
                rgb(39, 44, 49, ]] .. col/255 .. [[) 50%
            )]], ScrW(), ScrH())
        )
    end

    self.Hover = col
end

function PANEL:GetHover()
    return self.Hover
end

function PANEL:SetNoHover(value)
    self.NoHover = value
end

function PANEL:GetNoHover()
    return self.NoHover
end

function PANEL:TestHover(x, y)
    x, y = self:ScreenToLocal(x, y)
    if self:GetNoHover() then
        return false
    else
        local sz = Vector(self:GetSize())

        return Vector(x, y):WithinAABox(vector_origin, sz)
    end
end

function PANEL:SetClick(func)
    self.OnMousePressed = func
end

function PANEL:SetPaintOver(func)
    self.PaintOver = func
end

function PANEL:SetPosEx(x, y)
    if x then
        self.PosEx = { x, y }
    else
        self.PosEx = nil
    end
end

function PANEL:GetPosEx()
    return self.PosEx and unpack(self.PosEx)
end

function PANEL:SetSizeEx(w, h)
    if w or h then
        self.SizeEx = { w, h }
    else
        self.SizeEx = nil
    end
end

function PANEL:GetSizeEx()
    return self.SizeEx and unpack(self.SizeEx)
end

function PANEL:CalculateChildrenSize()
    local tw, th = 0, 0
    self:InvalidateChildren(true)

    local minx, miny = math.huge, math.huge
    for k, v in pairs(self:GetOrderedChildren()) do
        if v:GetDisplay() == DISPLAY_NONE then
            continue
        end

        local x, y = v:GetPos()
        minx = math.min(minx, x)
        miny = math.min(miny, y)
    end

    for k, v in pairs(self:GetOrderedChildren()) do
        if v:GetDisplay() == DISPLAY_NONE then
            continue
        end

        local x, y = v:GetPos()
        local w, h = v:GetSize()
        local ml, mt, mr, mb = v:CalculateFlexMargin()

        tw = math.max(tw, x + w + ml + mr - minx)
        th = math.max(th, y + h + mt + mb - miny)
    end
    return tw, th
end



function PANEL:SizeToChildren(sizeW, sizeH, pl, pt, pr, pb)
    if not pt then
        pt = pl
        pr = pr
        pb = pb
    end

    if not pr then
        pr = pl
        pb = pt
    end

    pl = pl and pl(self:GetWide()) or 0
    pt = pt and pt(self:GetTall()) or 0
    pr = pr and pr(self:GetWide()) or 0
    pb = pb and pb(self:GetTall()) or 0
     
    local tw, th = self:CalculateChildrenSize()
    
    tw = tw + pl + pr
    th = th + pt + pb

    self.SizeEx = self.SizeEx or {}
    if sizeW then
        self.SizeEx[1] = ABS(tw)
    end

    if sizeH then
        self.SizeEx[2] = ABS(th)
    end
    self:InvalidateLayout()

    return self, tw, th
end

function PANEL:SetFlex(num)
    assert(num)
    self.Flex = num
end

function PANEL:GetFlex()
    return self.Flex
end

function PANEL:SetFlexGap(value)
    self.FlexGap = value
end 

function PANEL:GetFlexGap()
    return self.FlexGap
end

function PANEL:CalculateFlexGap(sz)
    return isfunction(self.FlexGap) and self.FlexGap(sz) or self.FlexGap or 0
end

FLEX_FLOW_X = 0
FLEX_FLOW_Y = 1
function PANEL:SetFlexFlow(val)
    assert(val)
    self.FlexFlow = val
end

function PANEL:GetFlexFlow()
    return self.FlexFlow or FLEX_FLOW_X
end

function PANEL:CalculatePosition(w, h) 
    
    local parent = self:GetParent()
    local pw, ph 
    if parent then
        pw = parent:GetWide()
        ph = parent:GetTall()
    else
        pw = ScrW()
        ph = ScrH()
    end

    if self.PosEx then
        return self.PosEx[1](pw, self), self.PosEx[1](ph, self)
    end
end

function PANEL:CalculateSize(w, h)
    local parent = self:GetParent()
    local pw, ph 
    if parent then
        pw = parent:GetWide()
        ph = parent:GetTall()
    else
        pw = ScrW()
        ph = ScrH()
    end
    
    if self.SizeEx then
        if self.SizeEx[1] then
            w = self.SizeEx[1](pw, self)
        end 
        
        if self.SizeEx[2] then
            h = self.SizeEx[2](ph, self)
        end

        if not self:GetFlexGrow() then
            return w, h
        end
    end
    return
end

function PANEL:CalculateFlex(w, h)
    if self.Flex then
        local align = self:GetFlex()
        local flowDirection = self:GetFlexFlow()
        local gap = self:CalculateFlexGap(w)
        local growElement

        local children = self:GetOrderedChildren()

        local tw, th = 0, 0
        for k, child in pairs(children) do

            if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                continue
            end

            local cl, ct, cr, cb = child:CalculateFlexMargin()

            if child:GetFlexGrow() then
                assert(not growElement, "Can only have one element set to FlexGrow within a child.")
                growElement = child

                tw = tw + cr + cl + gap
                th = th + ct + cb + gap
            else
                child:InvalidateLayout(true)
                tw = tw + child:GetWide() + cr + cl + gap
                th = th + child:GetTall() + ct + cb + gap
            end
        end
        tw = tw - gap
        th = th - gap

        if growElement then
            local cl, ct, cr, cb = growElement:CalculateFlexMargin()
            if flowDirection == FLEX_FLOW_X then
                growElement:SetSize(w - tw, h - ct - cb)
            else
                growElement:SetSize(w - cl - cr, h - th)
            end
            tw = w
            th = h
        end

        local ChildPos = {}

        -- Horizontal align
        if isany(align, 1, 4, 7) then
            local wd = 0
            local x = wd
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end

                local cl, ct, cr, cb = child:CalculateFlexMargin()
                                
                if flowDirection == FLEX_FLOW_X then
                    ChildPos[child] = { x + cl, 0 }
                    x = x + child:GetWide() + cr + cl + gap
                else
                    ChildPos[child] = { cl, 0 }
                end
            end
        elseif isany(align, 8, 5, 2) then
            local wd = self:GetWide()/2 - tw/2
            local x = wd
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end

                local cl, ct, cr, cb = child:CalculateFlexMargin()
                                
                if flowDirection == FLEX_FLOW_X then
                    ChildPos[child] = { cl + x, 0 }
                    x = x + cl + child:GetWide() + cr + gap
                else
                    ChildPos[child] = { self:GetWide()/2 - child:GetWide()/2, 0 }
                end
            end
        else
            local wd = self:GetWide()
            local x = wd
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end

                local cl, ct, cr, cb = child:CalculateFlexMargin()

                if flowDirection == FLEX_FLOW_X then
                    x = x - child:GetWide() - cr
                    ChildPos[child] = { x, 0 }
                    x = x - cl - gap
                else
                    ChildPos[child] = { wd - child:GetWide() - cr }
                end
            end
        end

        -- Vertical align
        if isany(align, 7, 8, 9) then
            local t = 0
            local y = t
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end
                
                local cl, ct, cr, cb = child:CalculateFlexMargin()
                local cp = ChildPos[child]
                                                
                if flowDirection == FLEX_FLOW_Y then
                    ChildPos[child][2] = y + ct
                    y = y + ct + child:GetTall() + cb + gap
                else
                    ChildPos[child][2] = y + ct
                    y = t
                end
            end
        elseif isany(align, 4, 5, 6) then
            local t = self:GetTall()/2 - th/2
            local y = t
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end

                local cl, ct, cr, cb = child:CalculateFlexMargin()
                local cp = ChildPos[child]

                if flowDirection == FLEX_FLOW_Y then               
                    ChildPos[child][2] = y + ct
                    y = y + child:GetTall() + ct + cb + gap
                else
                    y = self:GetTall()/2 - child:GetTall()/2
                    ChildPos[child][2] = y
                end
            end
        else
            local t = self:GetTall()
            local y = t
            for k=1, #children do
                local child = children[k]
                
                if child:GetFlexIgnore() or child:GetDisplay() == DISPLAY_NONE then
                    continue
                end

                local cl, ct, cr, cb = child:CalculateFlexMargin()
                local cp = ChildPos[child]

                if flowDirection == FLEX_FLOW_Y then
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
            k:SetPos(unpack(v))
        end
    end
end

function PANEL:PerformLayout(w, h, suppress)

    --self:InvalidateChildren(true)

    self:GenerateChildrenCache()

    local x, y = self:CalculatePosition(w, h)
    if x then
        self:SetPos(x, y)
    end

    local w2, h2 = self:CalculateSize(w, h)
    if w2 then
        if not suppress then
            self:SetSize(w2, h2)
        end
        w, h = w2, h2
    end

    self:CalculateFlex(w, h)    

    return w, h
end

function PANEL:ImportXML(xml)
end

SymPanel = table.Copy(PANEL)
setmetatable(SymPanel, SymPanel)
SymPanel.__index = SymPanel

function SymPanel:__call(parent, data)
    local p = vgui.Create("SymPanel", parent)
    SymPanel.Set(p, data)
    return p
end

function SymPanel.Set(p, data)    
    local sizeToContents = false
    for k, v in pairs(data) do

        -- Redirect so that it runs last
        if k == "SizeToContents" then
            sizeToContents = true
        end

        if p["Set" .. k] then
            if istable(v) and not IsColor(v) and not sym.IsType(v) then
                p["Set" .. k](p, unpack(v))
            else
                p["Set" .. k](p, v)
            end
        elseif p[k] then
            if istable(v) and not IsColor(v) then
                p[k](p, unpack(v))
            else
                p[k](p, v)
            end
        else
            error("Could not default property: " .. k)
        end
    end
    
    if sizeToContents then
        p:SizeToContents()
    end
end

function SymPanel.CreateContent(panel, ...)    
    for k, v in pairs({...}) do
        if isstring(v) then
            panel:Add("SymLabel", { Font = sym.fonts.default, Text = v })
        elseif TypeID(v) == TYPE_MATERIAL then
            panel:Add("SymSprite", { Material = v, SizeEx = { CHRH(sym.fonts.default), CHRH(sym.fonts.default) } })
        elseif ispanel(v) then
            v:SetParent(panel)
        end
    end
end

function SymPanel.Apply(panel, Paint, PerformLayout)
    for k, v in pairs(SymPanel) do
        panel[k] = v
    end

    if Paint then
        Panel.Paint = function (self, w, h)
            SymPanel.Paint(self, w, h)
            Paint(self, w, h)
        end
    end

    if PerformLayout then
        Panel.PerformLayout = function (self, w, h)
            w, h = SymPanel.PerformLayout(self, w, h)
            Paint(self, w, h)
        end
    end
end


vgui.Register("SymPanel", PANEL, "EditablePanel")





local PANEL_META = FindMetaTable("Panel")
function PANEL:Open()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)
    self:MoveToFront()
end

function PANEL_META:SetFlexGrow(enable)
    self.FlexGrow = enable
end

function PANEL_META:GetFlexGrow()
    return self.FlexGrow == true
end

function PANEL_META:SetFlexIgnore(enable)
    self.FlexIgnore = enable
end

function PANEL_META:GetFlexIgnore()
    return self.FlexIgnore
end

function PANEL_META:SetFlexMargin(l, t, r, b)
    assert(l)

    if not t then
        t = l
        r = l
        b = l
    elseif not r then
        r = l
        b = t
    end

    self.FlexMargin = { l, t, r, b }
end

function PANEL_META:GetFlexMargin()
    if self.FlexMargin then
        return unpack(self.FlexMargin)
    end
end

function PANEL_META:CalculateFlexMargin(w, h)
    local l, t, r, b = self:GetFlexMargin()

    return 
        isfunction(l) and l(w) or l or 0, 
        isfunction(t) and t(h) or t or 0, 
        isfunction(r) and r(w) or r or 0, 
        isfunction(b) and b(h) or b or 0
end

DISPLAY_VISIBLE = 0
DISPLAY_HIDDEN = 1 -- Still affects the flow
DISPLAY_NONE = 2 -- Takes up zero space
function PANEL_META:SetDisplay(mode)
    assert(mode, "Mode must be a DISPLAY_ enum")

    self.Display = mode
    if isany(mode, DISPLAY_HIDDEN, DISPLAY_NONE) then
        if not self._Previous then
            self._Previous = {
                Size = Vector(self:GetSize()),
                TestHover = self.TestHover,
                PerformLayout = self.PerformLayout,
                Alpha = self:GetAlpha()
            }

            self.PerformLayout = function () end
            self.TestHover = function () return false end
            self:SetSize(0, 0)
            self:SetAlpha(0)
        end        
    else
        if self._Previous then
            self:SetSize(self._Previous.Size[1], self._Previous.Size[2])
            self:SetAlpha(self._Previous.Alpha)
            self.PerformLayout = self._Previous.PerformLayout
            self.TestHover = self._Previous.TestHover
            self._Previous = nil
        end
    end
end

function PANEL_META:GetDisplay()
    return self.Display or DISPLAY_VISIBLE
end

function PANEL_META:IsDrawn()
    -- Check if the panel is set to visible
    if not self:IsVisible() then
        return false
    end

    -- Check if the panel is within the screen bounds
    local x, y = self:LocalToScreen(0, 0)
    local w, h = self:GetSize()
    if x + w <= 0 or x >= ScrW() or y + h <= 0 or y >= ScrH() then
        return false
    end

    -- Traverse the parent hierarchy to ensure no parent is invisible or clips the panel
    local parent = self:GetParent()
    while parent do
        -- If a parent is not visible, the panel is not drawn
        if not parent:IsVisible() then
            return false
        end

        -- Check if the panel is within the parent's bounds
        local px, py = parent:LocalToScreen(0, 0)
        local pw, ph = parent:GetSize()
        if x + w <= px or x >= px + pw or y + h <= py or y >= py + ph then
            return false
        end

        parent = parent:GetParent()
    end

    -- All checks passed; the panel is drawn
    return true
end