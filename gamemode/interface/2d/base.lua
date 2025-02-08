AddCSLuaFile()
if SERVER then
    return
end

Interface.Components = weaktable(false, true)

local BasePanel = FindMetaTable("Panel")

local Panel = Type.Register("ShadowPanel", nil, { VGUI = "Panel" })
Panel:CreateProperty("Parent", Panel)
Panel:CreateProperty("Children", Type.Table)
Panel:CreateProperty("Panel", Type.Panel)
Panel:CreateProperty("Display", Type.Boolean)

-- BasePanel properties
do
    Panel:CreateProperty("X", Type.Number, { Set = BasePanel.SetX, Get = BasePanel.GetX })
    Panel:CreateProperty("Y", Type.Number, { Set = BasePanel.SetY, Get = BasePanel.GetY })
    Panel:CreateProperty("Width", Type.Number, { Set = BasePanel.SetWide, Get = BasePanel.GetWide })
    Panel:CreateProperty("Height", Type.Number, { Set = BasePanel.SetTall, Get = BasePanel.GetTall })
    Panel:CreateProperty("Alpha", Type.Number, { Set = BasePanel.SetAlpha, Get = BasePanel.GetAlpha })
    Panel:CreateProperty("PaintDragging", Type.Boolean, { NoSetter = true, Get = function (p) return p.PaintDragging end })
    Panel:CreateProperty("DockMargin", Type.Table, { Set = function (p, t) 
        if t then
            p:DockMargin(unpack(t)) 
        end 
    end, Get = function (p) 
        return { p:GetDockMargin() } 
    end })
    Panel:CreateProperty("DockPadding", Type.Table, { Set = function (p, t) 
        if t then
            p:DockPadding(unpack(t)) 
        end 
    end, Get = function (p) 
        return { p:GetDockPadding() } 
    end })
    Panel:CreateProperty("Dock", Type.Number, { Set = BasePanel.Dock, Get = BasePanel.GetDock, NoNil = true })
    Panel:CreateProperty("Autodelete", Type.Boolean, { Set = BasePanel.SetAutoDelete, Get = BasePanel.GetAutoDelete, NoNil = true }) -- Does GetAutoDelete exist?
    Panel:CreateProperty("ConVar", Type.String, { Set = BasePanel.SetConVar, Get = BasePanel.GetConVar })
    Panel:CreateProperty("CookieName", Type.String, { Set = BasePanel.SetCookie, Get = BasePanel.GetCookie })
    Panel:CreateProperty("Cursor", Type.String, { Set = BasePanel.SetCursor, Get = BasePanel.GetCursor })
    Panel:CreateProperty("DragParent", Type.Panel, { Set = BasePanel.SetDragParent, Get = BasePanel.GetDragParent })
    Panel:CreateProperty("DrawOnTop", Type.Boolean, { Set = BasePanel.SetDrawOnTop, Get = BasePanel.GetDrawOnTop })
    Panel:CreateProperty("Enabled", Type.Boolean, { Set = BasePanel.SetEnabled, Get = BasePanel.GetEnabled })
    Panel:CreateProperty("FocusTopLevel", Type.Boolean, { Set = BasePanel.SetFocusTopLevel, Get = BasePanel.GetFocusTopLevel })
    Panel:CreateProperty("KeyboardInputEnabled", Type.Boolean, { Set = BasePanel.SetKeyboardInputEnabled, Get = BasePanel.GetKeyboardInputEnabled })
    Panel:CreateProperty("MouseInputEnabled", Type.Boolean, { Set = BasePanel.SetMouseInputEnabled, Get = BasePanel.GetMouseInputEnabled })
    Panel:CreateProperty("MinimumSize", Type.Table, { Set = function (p, t) return p:SetMinimumSize(unpack(t)) end, Get = BasePanel.GetMouseInputEnabled })
    Panel:CreateProperty("Name", Type.String, { Set = BasePanel.SetName, Get = BasePanel.GetName })
    Panel:CreateProperty("PaintedManually", Type.Boolean, { Set = BasePanel.SetPaintedManually, Get = BasePanel.GetPaintedManually })
    Panel:CreateProperty("RenderInScreenshots", Type.Boolean, { Set = BasePanel.SetRenderInScreenshots, Get = BasePanel.GetRenderInScreenshots })
    Panel:CreateProperty("Selected", Type.Boolean, { Set = BasePanel.SetSelected, Get = BasePanel.GetSelected })
    Panel:CreateProperty("Skin", Type.String, { Set = BasePanel.SetSkin, Get = BasePanel.GetSkin })
    Panel:CreateProperty("TabPosition", Type.Number, { Set = BasePanel.SetTabPosition, Get = BasePanel.GetTabPosition })
    Panel:CreateProperty("Tooltip", Type.String, { Set = BasePanel.SetTooltip, Get = BasePanel.GetTooltip })
    Panel:CreateProperty("TooltipDelay", Type.Number, { Set = BasePanel.SetTooltipDelay, Get = BasePanel.GetTooltipDelay })
    Panel:CreateProperty("TooltipPanel", Type.Panel, { Set = BasePanel.SetTooltipPanel, Get = BasePanel.GetTooltipPanel })
    Panel:CreateProperty("TooltipOverride", Type.String, { Set = BasePanel.SetTooltipOverride, Get = BasePanel.GetTooltipOverride })
    Panel:CreateProperty("Visible", Type.Boolean, { Set = BasePanel.SetVisible, Get = BasePanel.GetVisible })
    Panel:CreateProperty("ZPos", Type.Number, { Set = BasePanel.SetZPos, Get = BasePanel.GetZPos })
    Panel:CreateProperty("NoClipping", Type.Boolean, { Set = BasePanel.SetNoClipping, Get = BasePanel.GetNoClipping })
    Panel:CreateProperty("MouseCapture", Type.Boolean, { Set = BasePanel.SetMouseCapture, Get = BasePanel.GetMouseCapture })  
end

-- Achievement
-- AllowNonAsciiCharacters
-- BGColor - RichText, Label, DColorCube
-- SpawnIcon
-- PaintBackgroundEnabled, PaintBorderEnabled
-- ContentAlignment DLabel
-- CaretPos
-- DrawLanguageID
-- HTML
-- RichText: LineHeight
-- MaximumCharCount
-- MinimumSize?
-- Model
-- SteamID - AvatarImage
-- Multiline
-- Text
-- TextInset
-- TextSelectionColors
-- URL
-- VerticalScrollbarEnabled
-- URL
-- UnderlineFont
-- Wrap

-- Receiver and Droppable will need to be tags.



function Interface.Create(classname, parent, name)
    assert(isstring(classname), "Classname must be the name of a panel i.e. DHTML")
    
    local p = new(Type.ShadowPanel)
    p:SetParent(parent)

    return p
end

function Panel.Prototype:Initialize()
    base()

    self.Events = new(Type.EventBus)
    self.Transitions = {}
    self.DefaultTransitions = {}
    self.PropertyEnv = {
        self = self
    }
    self.ChangedProperties = {}
    self.CalculatedProperties = {}
    self._LastPaint = CurTime() 

    self:SetParent(nil)
    self:SetChildren({})
    self:SetX(0)
    self:SetY(0)
    self:SetWidth(0)
    self:SetHeight(0)
    self:SetAlpha(255)
    self:SetDisplay(true)
    self:Refresh({ Force = true })
end

function Panel.Prototype:GetValue(name)
    local p = self:GetPanel()
    if p then
        local prop = self:GetType():GetPropertiesMap()[name]
        if prop and prop.Options.Get then
            return prop.Options.Get(p)
        end
    end
    return self[name]
end

function Panel.Prototype:SetProperty(name, value, noTransition, noRefresh)
    self.Transitions[name] = nil

    local dt = self.DefaultTransitions[name]
    if dt and not noTransition then
        return self:Transition(name, value, dt[1], dt[2])
    end

    self:GetBase().SetProperty(self, name, value)
    self.ChangedProperties[name] = true
    
    if not noRefresh then
        self:Refresh()
    end
end

function Panel.Prototype:SetPropertyTransition(name, duration, easing)
    self.DefaultTransitions[name] = { duration, easing }
end

function Panel.Prototype:GetPropertyTransition(name)
    return self.DefaultTransitions[name]
end

function Panel.Prototype:SetCalculatedProperty(name, func)
    self.CalculatedProperties[name] = func
end

function Panel.Prototype:GetCalculatedProperty(name)
    return self.CalculatedProperties[name]
end

function Panel.Prototype:Transition(name, to, duration, easing)
    local t = {}
    t.Set = self:GetType():GetPropertiesMap()[name].Options.Set
    
    if IsColor(to) then
        to = { to:ToTable() }
    else
        to = istable(to) and table.Copy(to) or { to }
    end

    local value = self:GetValue(name)
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

function Panel.Prototype:Refresh(ctx)
    self._ctx = self._ctx or {}
    if ctx then
        table.Merge(self._ctx, ctx, true)
    end
    ctx = self._ctx

    if ctx.Immediate then
        timer.Remove(self:GetId())
        self:PerformRefresh(ctx)
        self._ctx = nil
    else
        if not timer.Exists(self:GetId()) then
            self._ctx = ctx
            timer.Create(self:GetId(), 0, 1, function ()
                timer.Remove(self:GetId()) -- In case the refresh was called again

                if self._Removed then
                    return
                end
                
                self:PerformRefresh(self._ctx)
                self._ctx = nil
            end)
        end
    end
end

function Panel.Prototype:PerformRefresh(ctx)
    local p = self:GetPanel()
    local type = self:GetType()

    if self:GetDisplay() and not p then
        local p = vgui.Create(self:GetClassName(), self:GetParent())
        p.Paint = self.Paint
        p._ShadowPanel = self

        self:SetPanel(p)
        self:Refresh()
        return
    elseif not self:GetDisplay() then
        if p then
            if IsValid(p) then
                self:GetPanel():Remove()
            end
            self:SetPanel(nil)
        end
        return
    end

    for _, prop in pairs(type:GetProperties()) do
        local k = prop.Name
        local opt = prop.Options

        if opt.Listen and not ctx.Force then
            local skip = true
            for k, v in pairs(opt.Listen) do
                if self.ChangedProperties[v] then
                    skip = false
                    break
                end
            end
        end

        local set = opt.Set
        local get = opt.Get

        -- Ignore properties that don't have a setter
        if not set then
            continue
        end

        local v = self[k]
        local curr = get and get(p) or p[k]

        -- If it has changed, set the value
        if curr ~= v then
            if v == nil and opt.NoNil then
                continue
            end

            set(p, v)
        end
    end

    self.ChangedProperties = {}
end

function Panel.Prototype:Paint(w, h)
    local shadow = self._ShadowPanel
    assert(shadow)

    local ct = CurTime()
    local dt = ct - shadow._LastPaint

    for k, v in pairs(shadow.Transitions) do
        local complete = v.Tween:update(dt)

        local val
        if v.IsColor then
            val = Color(unpack(unpack(v.Value)))
        else
            val = unpack(v.Value)
        end

        shadow[k] = val
        if v.Set then
            v.Set(self, val)
        end
        shadow:Refresh()

        if complete then
            v.Promise:Complete()
            shadow.Transitions[k] = nil
        end
    end

    shadow._LastPaint = ct
end

function Panel.Prototype:OnPropertyChanged(name, value, old)
    --local er = self.Events:Run("OnPropertyChanged", self, name, value, old)
    --if er:GetCancelled() then
    --    return false
    --end

    if name == "Parent" then
        if old then
            for k, v in pairs(old:GetChildren()) do
                if v == self then
                    old:GetChildren()[k] = nil
                    break
                end
            end
        end

        if value then
            value:GetChildren()[#value:GetChildren() + 1] = self
        end
        return
    end
end

function Panel.Prototype:IsValid()
    return true
end

function Panel.Prototype:Remove()
    if IsValid(self:GetPanel()) then
        self:GetPanel():Remove()
    end
    self._Removed = true
end
Interface.Components["Panel"] = Panel


function Interface.Register(classname, panelTable, baseName)
    local base = Interface.Components[baseName]
    assert(base, "Base panel " .. baseName .. " does not exist")

    local p = Type.Register(classname, base, panelTable)
    Interface.Components[classname] = p
    return p
end

-- Testing
if IsValid(p) then
    p:Remove()
end
p = Interface.Create("Panel")
p:SetX(500)
p:SetY(500)
p:SetWidth(100)
p:SetHeight(100)