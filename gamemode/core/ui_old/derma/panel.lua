AddCSLuaFile()
if SERVER then
    return
end

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

local BasePanel = FindMetaTable("Panel")

local PANEL = {}
PANEL.IsSymPanel = true
PANEL.HasSymPerformLayout = true

-- Properties implementation
do
    function BasePanel:InitDefaultProperties()
        if not self.Properties then
            local p = self:GetParent()
            self.Properties = setmetatable({}, { __index = p and p.Properties })

            -- These are reset for every panel - because they shouldn't propagate.
            -- Some properties like the fonts SHOULD propagate.
            self:RegisterProperty("Ref", nil)
            self:RegisterProperty("RefParent", nil)

            self:RegisterProperty("Name", nil) -- ✓

            self:RegisterProperty("X", nil) -- ✓
            self:RegisterProperty("Y", nil) -- ✓
            self:RegisterProperty("Width", nil) -- ✓
            self:RegisterProperty("Height", nil) -- ✓
            self:RegisterProperty("Display", true)
            self:RegisterProperty("Absolute", false)

            self:RegisterProperty("Background", nil) -- ✓
            self:RegisterProperty("Border", nil)
            self:RegisterProperty("BorderSize", nil)
            self:RegisterProperty("BorderRadius", nil)
            self:RegisterProperty("ShadowSize", nil)
            self:RegisterProperty("ShadowColor", Color(0, 0, 0, 64))
            self:RegisterProperty("Blur", nil)

            self:RegisterProperty("Margin", nil)
            self:RegisterProperty("MarginLeft", 0)
            self:RegisterProperty("MarginTop", 0)
            self:RegisterProperty("MarginRight", 0)
            self:RegisterProperty("MarginBottom", 0)
            self:RegisterProperty("Padding", nil)
            self:RegisterProperty("PaddingX", nil)
            self:RegisterProperty("PaddingY", nil)
            self:RegisterProperty("PaddingLeft", 0)
            self:RegisterProperty("PaddingTop", 0)
            self:RegisterProperty("PaddingRight", 0)
            self:RegisterProperty("PaddingBottom", 0)

            -- Display modes
            self:RegisterProperty("Flex", 7)
            self:RegisterProperty("Gap", 0)
            self:RegisterProperty("Direction", "X")
            self:RegisterProperty("Grow", false)
            self:RegisterProperty("Wrap", false)
        end
    end

    function BasePanel:RegisterProperty(name, value)
        self:InitDefaultProperties()

        local p = {}
        self.Properties[name] = p

        --[[self["Set" .. name] = function (p, value)
            self:SetProperty(name, value)
        end

        self["Get" .. name] = function (p)
            return self:GetProperty(name)
        end--]]

        
        if isfunction(value) then
            p.Func = value
        else
            p.Func = nil
            p.Value = value
        end
    end

    function BasePanel:SetProperty(name, value, forceFunc)
        self:InitDefaultProperties()

        --assert(not self.Properties[name], tostring(self) .. ": Property " .. name .. " does not exist.")
        local p = rawget(self.Properties, name)
        if not p then
            p = {}
            self.Properties[name] = p
        end

        if isfunction(value) and not forceFunc then
            p.Func = value
        else
            p.Func = nil
            local old = p.Value
            p.Value = value

            if value ~= old then
                self:OnPropertyChanged(name, value, old)
            end
        end
        self:InvalidateLayout()
    end

    function BasePanel:SetProperties(t)
        self:InitDefaultProperties()
        
        for k, v in pairs(t) do
            self:SetProperty(k, v)
        end
    end

    function BasePanel:IsPropertyNil(name)
        self:InitDefaultProperties()

        local p = self.Properties[name]
        if not p then
            return nil
        end

        return not p.Value and not p.Func
    end

    function BasePanel:GetRawProperty(name, ...)
        self:InitDefaultProperties()
        
        local p = self.Properties[name]
        if not p then
            return nil
        end

        return p.Value
    end

    function BasePanel:GetProperty(name, ...)
        if self:IsHovered() or self:IsChildHovered() then
            return self:GetRawProperty("Hover:" .. name, ...) or self:GetRawProperty(name, ...) 
        else
            return self:GetRawProperty(name, ...)
        end
    end

    function BasePanel:GetProperties(t)
        self:InitDefaultProperties()
        return self.Properties
    end

    function BasePanel:OnPropertyChanged(prop, value, old)
        local p = self:GetParent()

        if not self.IsSymPanel and self["Set" .. prop] then
            self["Set" .. prop](self, value)
        end

        if prop == "Ref" then
            assert(not old, "Can't change a ref once it has been set.")
            
            if p == vgui.GetWorldPanel() then
                return
            end
            
            local tgt
            while true do 
                tgt = p
                if not p or p:GetProperty("Ref") or p == vgui.GetWorldPanel() then
                    break
                end

                p = p:GetParent()
            end
            tgt[value] = self
            
            self.Root = tgt

            self:SetProperty("RefParent", tgt)            
            return
        end

        if prop == "Name" then
            self:SetName(value)
            return
        end

        if prop == "Padding" then
            self:SetProperty("PaddingLeft", value)
            self:SetProperty("PaddingTop", value)
            self:SetProperty("PaddingRight", value)
            self:SetProperty("PaddingBottom", value)
            self.Properties["Padding"] = nil
            return
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
        end

        if prop == "Margin" then
            self:SetProperty("MarginLeft", value)
            self:SetProperty("MarginTop", value)
            self:SetProperty("MarginRight", value)
            self:SetProperty("MarginBottom", value)
            self.Properties["Margin"] = nil
            return
        end

        if prop == "MarginX" then
            self:SetProperty("MarginLeft", value)
            self:SetProperty("MarginRight", value)
            self.Properties["MarginX"] = nil
            return
        end

        if prop == "MarginY" then
            self:SetProperty("MarginTop", value)
            self:SetProperty("MarginBottom", value)
            self.Properties["MarginY"] = nil
            return
        end

        if p.IsSymPanel and (prop == "Display" or prop == "X" or prop == "Y" or prop == "Width" or prop == "Height") then
            -- For positionals, do nothing if the value is set to nil.
            if prop ~= "Display" and not value then
                return
            end

            local p_w = p:GetProperty("Width")
            local p_h = p:GetProperty("Height")

            self:InvalidateLayout(true)
            return
        end
    end

    function BasePanel:XMLHandleText(...)
        local args = {...}

        for k, v in pairs(args) do
            local e = vgui.Create("DLabel", self)
            e:SetProperty("Text", string.Replace(v, "&nbsp;", " "))
            e:InvalidateLayout(true)
            e:SizeToContents()
            args[k] = e
        end

        if self:IsPropertyNil("Flex") then
            self:SetProperty("Flex", 4)
        end

        return args
    end
end

-- Children management
do
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

    function PANEL:GetChildren()
        local out = {}
        for k, v in pairs(self.Children) do
            if IsValid(v) then
                out[k] = v
            end
        end

        return out
    end

    function PANEL:OnChildAdded(child)
        self:GenerateChildrenCache(child)

        local p_w = self:GetProperty("Width")
        local p_h = self:GetProperty("Height")
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

    function PANEL:OnChildRemoved(child)
        self:GenerateChildrenCache(nil, true)
        
        local p_w = self:GetProperty("Width")
        local p_h = self:GetProperty("Height")
        --self:SizeToChildren(not p_w, not p_h)
    end
end

-- Func env
do
    function BasePanel:SetFuncEnv(env)
        self.FuncEnv = env
    end

    function BasePanel:GetFuncEnv()
        return self.FuncEnv
    end
end

function PANEL:Init()
    self.Uuid = uuid()
    self.Children = {}
    self.Transitions = {}
    
    self:InitDefaultProperties()
end


function PANEL:XMLHandleText(...)
    local args = {...}

    for k, v in pairs(args) do
        local e = vgui.Create("SymLabel", self)
        e:SetProperty("Text", string.Replace(v, "&nbsp;", " "))
        e:InvalidateLayout(true)
        args[k] = e
    end

    if self:IsPropertyNil("Flex") then
        self:SetProperty("Flex", 4)
    end

    return args
end


function PANEL:Think()


    --local cursor = self:GetProperty("Cursor")
    --if cursor ~= self.Cursor then
        --self.Cursor = cursor
        --self:SetCursor(cursor)
    --end
end

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

function PANEL:SizeToChildren(sizeW, sizeH)
    local w, h = self:CalculateChildrenSize()
    local pl, pt, pr, pb = self:CalculatePadding()

    self:SetSize(sizeW and w + pl + pr or self:GetWide(), sizeH and h + pt + pb or self:GetTall())
end

function PANEL:PerformLayout(w, h)
    if self:GetProperty("SuppressLayout") then
        return true
    end

    local env = self:CalculateProperties()
    local x, y
    if not self:GetProperty("Absolute") and self:GetParent():GetProperty("Flex") then
        x, y = self:GetPos()
    else
        x, y = self:CalculatePosition()
    end
    env.X = x
    env.Y = y

    local w, h = self:CalculateSize()
    env.Width = w
    env.Height = h
    
    self:CalculateFlex(w, h)

    if not self:GetRawProperty("name") then
        self:SetName(self:CalculateName())
    end
    --self:CalculateBackground()

    if x ~= env.LastX or y ~= env.LastY then
        self:SetPos(x, y)
    end

    if w ~= env.LastW or h ~= env.LastH then
        self:SetSize(math.max(w or self:GetWide(), 1), math.max(h or self:GetTall(), 1))
    end
    return w, h
end

function BasePanel:CalculateProperties()
    local parent = self:GetParent()
    local env = self:GetFuncEnv()
    if not env then
        env = {}
        env.__index = env

        env.X = false
        env.Y = false
        env.Width = false
        env.Height = false
        env.Refs = { __index = env }

        setmetatable(env, { __index = _G })
    end

    local lastX, lastY = self:GetPos()
    local lastW, lastH = self:GetSize()

    
    if parent then
        local pev = parent:GetFuncEnv() or { __index = _G }
        setmetatable(env, pev)
        setmetatable(env.Refs, pev.Refs)
    end
    
    env.self = self
    env.LastX = lastX
    env.LastY = lastY
    env.LastW = lastW
    env.LastH = lastH

    env.Parent = {
        Panel = parent,
        AbsoluteWidth = parent:GetWide(),
        AbsoluteHeight = parent:GetTall(),
        PaddingLeft = parent:GetProperty("PaddingLeft"),
        PaddingRight = parent:GetProperty("PaddingRight"),
        PaddingTop = parent:GetProperty("PaddingTop"),
        PaddingBottom = parent:GetProperty("PaddingBottom"),
        Width = parent:GetWide() - parent:GetProperty("PaddingLeft") - parent:GetProperty("PaddingRight"),
        Height = parent:GetTall() - parent:GetProperty("PaddingTop") - parent:GetProperty("PaddingBottom"),
        Hovered = parent:IsHovered(),
        Flex = parent:GetProperty("Flex")
    }
    env.PW = parent:GetWide()
    env.PH = parent:GetTall()

    if env.Ref then
        env.Refs[env.Ref] = self
    end


    for k, p in pairs(self:GetProperties()) do
        
        -- Skip background as it needs the size.
        --if k == "Background" then
        --    continue
        --end

        if p.Func then
            setfenv(p.Func, env)
            local val = p.Func()
            local old = p.Value
            p.Value = val
            env[k] = val
            

            if val ~= old then
                self:OnPropertyChanged(k, val, old)
            end
        else
            env[k] = p.Value ~= nil and p.Value or rawget(env, k)
        end
    end

    self:SetFuncEnv(env)

    return env
end

function BasePanel:CalculateName()
    local ref = self:GetRawProperty("Ref")
    if ref then
        return ref .. "<" .. self.ClassName .. ">"
    end

    return self.ClassName
end

function BasePanel:CalculatePosition()
    return self:GetProperty("X"), self:GetProperty("Y")

    --[[local env = self:GetFuncEnv()
    if not env.Parent.Flex or env.Absolute then
        if env.X ~= env.LastX or env.Y ~= env.LastY then
            self:SetPos(env.X, env.Y)
            return env.X, env.Y
        end
    end--]]
end

function BasePanel:CalculatePadding()
    return self:GetProperty("PaddingLeft") or 0, self:GetProperty("PaddingTop") or 0, self:GetProperty("PaddingRight") or 0, self:GetProperty("PaddingBottom") or 0
end

function BasePanel:CalculateMargin()
    return self:GetProperty("MarginLeft") or 0, self:GetProperty("MarginTop") or 0, self:GetProperty("MarginRight") or 0, self:GetProperty("MarginBottom") or 0
end

function BasePanel:CalculateSize()
    if self:GetProperty("Grow") then
        return
    end

    if not self:GetProperty("Display") then
        return 0, 0
    end
    
    local w, h = self:GetProperty("Width"), self:GetProperty("Height")
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

function BasePanel:CalculateFlex(w, h)
    local align = self:GetProperty("Flex")
    if not align then
        return
    end

    if not w and not h then
        w, h = self:GetSize()
    end

    local flowDirection = self:GetRawProperty("Direction")
    local gap = self:GetProperty("Gap")
    local pl, pt, pr, pb = self:CalculatePadding()


    local children = self:GetChildren()
    local tw, th = 0, 0
    local growElement
    for k, child in pairs(children) do
        if child:GetProperty("Absolute") or not child:GetProperty("Display") then
            continue
        end

        local cl, ct, cr, cb = child:CalculateMargin()

        if child:GetProperty("Grow") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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
            
            if child:GetProperty("Absolute") or not child:GetProperty("Display") then
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

function PANEL:OnCursorEntered()
end

function PANEL:OnCursorExited()
end

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

-- We delay the calculation of a func background (1) so we can get a size and (2) wait a little while
-- to ensure the size has stabilized.
function BasePanel:CalculateBackground()

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

function BasePanel:CalculateFont()
    local font = self:GetProperty("FontName")
    local size = self:GetProperty("FontSize")
    local weight = self:GetProperty("FontWeight")

    return sym.Font(font, size, weight)
end

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

local function EmitChildren(self, panel, event, ...)
    self:HandleEmit(panel, event, ...)
    for k, v in pairs(self:GetChildren()) do
        Emit(v, panel, event, ...)
    end
end

function BasePanel:EmitChildren(event, ...)
    self:EmitChildren(self, self, event, ...)
end

function BasePanel:HandleEmit(panel, event, ...)
    hndl = self:GetProperty("On:" .. event)
    if hndl then
        hndl(panel, ...)
    end 
end

function PANEL:Transition(property, to, duration)
    local p = self.Transitions[property] or {}
    p.to = to
    p.from = self:GetProperty(property)
    p.start = CurTime()
    p.duration = duration
    p.velocity = p.velocity or 0

    self.Transitions[property] = p
end


-- Interpolate value (supporting tables or scalar values)
local function interpolate(value, target, t)
    if type(value) == "table" then
        local result = {}
        for i, v in ipairs(value) do
            result[i] = v + (target[i] - v) * t
        end
        return result
    else
        return value + (target - value) * t
    end
end

local matBlurScreen = Material("pp/blurscreen")
function PANEL:Paint(w, h)
    local blur = self:GetProperty("Blur")
    if blur then
        surface.SetMaterial(matBlurScreen)
        surface.SetDrawColor(color_white)
        matBlurScreen:SetFloat("$blur", blur)
        matBlurScreen:Recompute()
        render.UpdateScreenEffectTexture()

        local x, y = self:ScreenToLocal(0, 0)
        surface.DrawTexturedRect(x, y, ScrW(), ScrH())
    end
    
    local bg = self:GetProperty("Background")
    if bg then
        if IsColor(bg) then
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
        else
            if not istable(bg) then
                if bg:GetInt("_loading") ~= 1 then
                    surface.SetMaterial(bg)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(0, 0, w, h)
                end
            else
                for k, v in pairs(bg) do
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
            end
        end
    end
    
    for k, p in pairs(self.Transitions) do
        local current = self:GetProperty(k)
        local to = p.to
        local progress = (CurTime() - p.start) / p.duration

        if progress >= 1 then
            progress = 1
            self.Transitions[k] = nil
        end

        -- Apply easing function (single parameter for progress)
        local easedProgress = math.ease.InOutCubic(progress)

        local newValue = interpolate(current, to, easedProgress)
        self:SetProperty(k, newValue)

        -- Invalidate layout only when necessary
        if progress < 1 then
            self:InvalidateLayout()
        end
    end

end
vgui.Register("SymPanel", PANEL, "EditablePanel")

SymPanel = table.Copy(PANEL)
function SymPanel.Apply(panel)
    if panel.HasSymPerformLayout then
        return
    end
    
    if not panel.PerformLayout then
        local pl = panel.PerformLayout

        panel.PerformLayout = function (self, w, h)
            w, h = SymPanel.PerformLayout(self, w, h)
            return pl(self, w, h)
        end
    else
        panel.PerformLayout = SymPanel.PerformLayout
    end
    
    panel.HasSymPerformLayout = true
end

-- Initialize the world panel with the default props.
local wp = vgui.GetWorldPanel()
wp:InitDefaultProperties()
wp:SetProperty("Flex", nil)
wp:RegisterProperty("SuppressLayout", false)
wp:RegisterProperty("Absolute", true)
wp:RegisterProperty("FontName", "Oxanium")
wp:RegisterProperty("FontSize", 7)
wp:RegisterProperty("FontWeight", 400)
wp:RegisterProperty("TextColor", color_white)
wp:RegisterProperty("Cursor", "none")
wp:RegisterProperty("Click", false)
wp:RegisterProperty("ContextMenu", false)

function BasePanel:Clone(parent)
    local parent = parent or self:GetParent()
    local el = vgui.Create(self.ClassName, parent)
    el.Properties = setmetatable(table.Copy(self.Properties), { __index = parent.Properties })
    el:SetProperty("SuppressLayout", false)

    if not IsValid(el) then
        return
    end


    for k, v in pairs(self:GetChildren()) do
        v:Clone(el)
    end
    return el
end


local DLabel = vgui.GetControlTable("DLabel")
function DLabel:SizeToChildren()
    self:SizeToContents()
end