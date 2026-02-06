AddCSLuaFile()

if SERVER then
    return
end

local VisualizeLayout = CreateConVar("sym_visualizelayout", "0")

if Interface and IsValid(Interface.VGUI) then
    Interface.VGUI:Remove()
end

local default_material = CreateMaterial("_default", "UnlitGeneric", { ["$translucent"] = 1 })

UP = TOP
DOWN = BOTTOM

-- Statics
Interface = {}
local Fonts = {}
do
    function Interface.Create(t, parent)
        if isstring(t) then
            t = "Interface." .. t
        end

        local el = Type.New(t)
        parent = parent or Interface.BasePanel
        el:SetParent(parent)
        el.Host = parent and parent:GetHost()

        return el
    end

    function Interface.Register(name, super, ...)
        name = "Interface." .. name

        if isstring(super) then
            super = Type.GetByName("Interface." .. super)
        end
        super = super or Type.GetByName("Interface.Panel")
        return Type.Register(name, super, ...)
    end

    function Interface.GetByName(name)
        return Type.GetByName("Interface." .. name)
    end

    function Interface.GetFont(font, size, weight, blursize, scanlines, antialias, underline, italic, strikeout, symbol, rotary, shadow, additive, outline, extended)    
        size = math.Round(size * ScrH()/480, 0)

        local key = table.concat({
            font, 
            size, 
            weight, 
            blursize or 0, 
            scanlines or 0, 
            antialias and 1 or 0, 
            underline and 1 or 0, 
            italic and 1 or 0, 
            strikeout and 1 or 0, 
            symbol and 1 or 0, 
            rotary and 1 or 0, 
            shadow and 1 or 0, 
            additive and 1 or 0, 
            outline and 1 or 0,
            extended and 1 or 0
        }, ";")
        
        local tgt = Fonts[key]
        if tgt then
            return tgt
        end

        local fontData = {
            font = font,
            extended = extended or false,
            size = size,
            weight = weight or 400,
            blursize = blursize or 0,
            scanlines = scanlines or 0,
            antialias = antialias or true,
            underline = underline or false,
            italic = italic or false,
            strikeout = strikeout or false,
            symbol = symbol or false,
            rotary = rotary or false,
            shadow = shadow or false,
            additive = additive or false,
            outline = outline or false
        }

        surface.CreateFont(key, fontData)
        Fonts[key] = key
        
        return key
    end

    function Interface.GetBasePanel()
        return Interface.BasePanel
    end

    function Interface.GetHoveredPanel()
        return Interface.GetBasePanel().HoveredPanel
    end
end

local function ApplyProperties(pnl, node)
    local propertyMap = pnl:GetType():GetPropertiesMap()
    for _, t in pairs(node.Attributes) do
        local k = t.Name
        local v = t.Value

        local namespace = stringex.SubstringBefore(k, ":")
        if namespace then
            k = string.sub(k, #namespace + 2)
            
            if namespace == "" then
                namespace = "Computed"
            end

            local cont, result = hook.Run("Interface.XMLParseNamespace", pnl, namespace, k, v)
            if cont == nil then
                ErrorNoHalt(string.format("Failed to parse XML attribute '%s' on element <%s>: unrecognized namespace '%s'\n", t.Name, node.Tag, namespace))
            end

            if cont == false then
                continue
            else
                v = result
            end
        else
            local setter = pnl["Set" .. k]
            if setter then
                setter(pnl, v)
            else
                pnl[k] = v
            end
        end

    end
end

-- Panel
local PNL = Type.Register("Interface.Panel")
do
    PNL:CreateProperty("Name", Type.String)
    PNL:CreateProperty("Width", Type.Number, { Default = 0 })
    PNL:CreateProperty("Height", Type.Number, { Default = 0 })
    PNL:CreateProperty("X", Type.Number, { Default = 0 })
    PNL:CreateProperty("Y", Type.Number, { Default = 0 })
    PNL:CreateProperty("Cursor", Type.String)
    PNL:CreateProperty("RenderMode", Type.Number, { Default = 0 })
    PNL:CreateProperty("Fill", Type.Color, { Default = Color(0, 0, 0, 0) })
    PNL:CreateProperty("Material", Type.Material, { Default = default_material })
    PNL:CreateProperty("Alpha", Type.Number, { Default = 255 })
    PNL:CreateProperty("FontName", Type.String)
    PNL:CreateProperty("FontSize", Type.Number)
    PNL:CreateProperty("FontWeight", Type.Number)
    PNL:CreateProperty("TextColor", Type.Color)
    PNL:CreateProperty("Hoverable", Type.Bool, { Default = false })
    PNL:CreateProperty("Hovered", Type.Bool, { Default = false })
    PNL:CreateProperty("Shape", Type.Table)
    PNL:CreateProperty("Visible", Type.Bool, { Default = true })
    PNL:CreateProperty("Cull", Type.Bool, { Default = true })
    PNL:CreateProperty("Wrap", Type.Bool, { Default = false })

    PNL:CreateProperty("Stroke", Type.Number, { Default = 0 })
    PNL:CreateProperty("StrokeColor", Type.Color, { Default = Color(255, 255, 255) })
    PNL:CreateProperty("StrokeMaterial", Type.Material, { Default = default_material })

    PNL:CreateProperty("PaddingLeft", Type.Number, { Default = 0 })
    PNL:CreateProperty("PaddingRight", Type.Number, { Default = 0 })
    PNL:CreateProperty("PaddingTop", Type.Number, { Default = 0 })
    PNL:CreateProperty("PaddingBottom", Type.Number, { Default = 0 })

    PNL:CreateProperty("Absolute", Type.Bool, { Default = false })
    PNL:CreateProperty("Align", Type.Number, { Default = 7 })
    PNL:CreateProperty("Direction", Type.Number, { Default = RIGHT })
    PNL:CreateProperty("Gap", Type.Number, { Default = 0 })
    PNL:CreateProperty("MarginLeft", Type.Number, { Default = 0 })
    PNL:CreateProperty("MarginTop", Type.Number, { Default = 0 })
    PNL:CreateProperty("MarginRight", Type.Number, { Default = 0 })
    PNL:CreateProperty("MarginBottom", Type.Number, { Default = 0 })
    PNL:CreateProperty("Debug", Type.Bool, { Default = false })

    function PNL.Prototype:Initialize()
        self.Id = uuid()
        self.Computed = {}
        self.Children = {}
        self.Animations = {}
        self.FuncEnv = setmetatable({}, { __index = _G })
        self.RenderBounds = {}
        self.HoverProperties = {}
        self.Userdata = GC(function ()
            if not self:IsDisposed() then
                self:Dispose()
            end
        end)

        self:SetShape()
        self:SetWidth()
        self:SetHeight()
        self:InitXML()
        self:InvalidateLayout(nil, true)
    end

    function PNL.Prototype:DebugMessage(...)
        if self:GetDebug() then
            print(self, ...)
        end
    end

    local function DefaultShape(self)
        return {
            0, 0,
            self:GetWidth(), 0,
            self:GetWidth(), self:GetHeight(),
            0, self:GetHeight()
        }
    end
    
    function PNL.Prototype:InitXML()
        local xmlData = self:GetType().XML
        if xmlData then
            if xmlData.Attributes then
                ApplyProperties(self, xmlData)
            end

            for k, v in pairs(xmlData.Children) do
                Interface.CreateFromNode(self, v)
            end
        end
    end

    function PNL.Prototype:SetShape(shape)
        self.Mesh = nil
        if shape == nil then
            self:SetComputed("Shape", DefaultShape)
        elseif isfunction(shape) then
            self:SetComputed("Shape", shape)
        else
            self:SetComputed("Shape", nil)
            self:SetProperty("Shape", shape)
        end
        self:InvalidateLayout(nil, true)
        return self
    end

    function PNL.Prototype:SetAlign(align)
        self:SetProperty("Align", align)
        self:InvalidateLayout(nil, true, nil, true)
        return self
    end

    local DirectionMap = {
        ["right"] = RIGHT,
        ["left"] = LEFT,
        ["up"] = TOP,
        ["down"] = BOTTOM,
        ["top"] = TOP,
        ["bottom"] = BOTTOM
    }
    function PNL.Prototype:SetDirection(direction)
        if isstring(direction) then
            local dir = DirectionMap[string.lower(direction)]
            assert(dir, "Invalid direction string specified: " .. tostring(direction))
            direction = dir
        end

        self:SetProperty("Direction", direction)
        self:InvalidateLayout(nil, true)
        return self
    end

    function PNL.Prototype:SetWrap(wrap)
        self:SetProperty("Wrap", wrap)
        self:InvalidateLayout(nil, true)
        return self
    end

    function PNL.Prototype:SetMaterial(mat)
        if not mat then
            mat = default_material
        elseif isfunction(mat) then
            self:SetComputed("Material", mat)
            return self
        end
        
        self:SetProperty("Material", mat)
        return self
    end

    function PNL.Prototype:SetStrokeMaterial(mat)
        if not mat then
            mat = default_material
        elseif isfunction(mat) then
            self:SetComputed("StrokeMaterial", mat)
            return self
        end
        self:SetProperty("StrokeMaterial", mat)
        self:InvalidateLayout(nil, true)
        return self
    end

    function PNL.Prototype:GetFont()
        return Interface.GetFont(
            self:GetFontName(),
            self:GetFontSize(),
            self:GetFontWeight()
        )
    end

    function PNL.Prototype:GetFontName()
        return self:GetProperty("FontName") or self:GetParent():GetFontName()
    end

    function PNL.Prototype:GetFontSize()
        return self:GetProperty("FontSize") or self:GetParent():GetFontSize()
    end

    function PNL.Prototype:GetFontWeight()
        return self:GetProperty("FontWeight") or self:GetParent():GetFontWeight()
    end

    function PNL.Prototype:GetTextColor()
        return self:GetProperty("TextColor") or self:GetParent():GetTextColor()
    end

    function PNL.Prototype:GetCursor()
        return self:GetProperty("Cursor") or (self:GetParent() and self:GetParent():GetCursor()) or "_"
    end

    function PNL.Prototype:SetField(field, value)
        self[field] = value
        return self
    end

    function PNL.Prototype:GetField(field)
        return self[field] or self:GetParent() and self:GetParent():GetField(field)
    end

    function PNL.Prototype:SetHover(property, value, duration, easeFunc)
        if value == nil then
            self.HoverProperties[property] = nil
            return
        end

        self.HoverProperties[property] = {
            Value = value,
            Duration = duration,
            EaseFunc = easeFunc
        }
        return self
    end

    function PNL.Prototype:GetHover(property)
        return self.HoverProperties[property]
    end

    function PNL.Prototype:Animate(property, to, duration, repetitions, easeFunc)
        local p = Promise.Create()

        local old = self.Animations[property]
        if old then
            old:Complete(false)
        end

        assert(property, "No property specified")
        assert(to, "No target value specified")
        assert(duration, "No duration specified")

        repetitions = repetitions or 1
        easeFunc = easeFunc or math.ease.InOutCubic
        p.From = self:GetProperty(property)

        -- Do some parsing
        assert(Type.GetType(p.From) == Type.GetType(to) or not p.From or not to, "Property types do not match")
            
        p.To = to
        p.Duration = duration
        p.Start = CurTime()
        p.EaseFunc = easeFunc
        p.Repetitions = repetitions

        self:SetComputed(property, nil)
        self.Animations[property] = p
        return p
    end

    function PNL.Prototype:CancelAnimation(property)
        local anim = self.Animations[property]
        if anim then
            anim:Complete(false)
            self.Animations[property] = nil
        end
    end
    

    function PNL.Prototype:MoveTo(x, y, duration, repetitions, easeFunc)
        self:Animate("X", x, duration, repetitions, easeFunc)
        return self:Animate("Y", y, duration, repetitions, easeFunc) -- They'll both elapse at the same time so it doesn't really matter what promise we return.
    end

    function PNL.Prototype:SizeTo(width, height, duration, repetitions, easeFunc)
        self:Animate("Width", width, duration, repetitions, easeFunc)
        return self:Animate("Height", height, duration, repetitions, easeFunc) -- They'll both elapse at the same time so it doesn't really matter what promise we return.
    end

    function PNL.Prototype:AlphaTo(alpha, duration, repetitions, easeFunc)
        return self:Animate("Alpha", alpha, duration, repetitions, easeFunc)
    end

    function PNL.Prototype:FillTo(color, duration, repetitions, easeFunc)
        return self:Animate("Fill", color, duration, repetitions, easeFunc)
    end


    function PNL.Prototype:SetComputed(property, func)
        assert(property, "No property specified")
        assert(func == nil or isfunction(func), "Computed value must be a function or nil")
        if func then
            setfenv(func, setmetatable({ self = self }, { __index = self.FuncEnv }))
        end
        self.Computed[property] = func
        return self
    end

    function PNL.Prototype:GetComputed(property)
        return self.Computed[property]
    end

    function PNL.Prototype:Compute(property, skipCache)        
        if not self.CacheTime or self.CacheTime < engine.TickCount() then
            self.Cache = {} -- Reset the cache every tick
            self.CacheTime = engine.TickCount()
        end

        if self.Cache[property] and not skipCache then
            return self.Cache[property]
        end

        local func = self:GetComputed(property)
        if func then
            local rtn = func(self)
            self:SetProperty(property, rtn)
            self.Cache[property] = rtn
            return rtn
        else
            return self:GetProperty(property)
        end
    end

    function PNL.Prototype:SetWidthRaw(value)
        return self:SetProperty("Width", value)
    end

    function PNL.Prototype:OnPropertyChanged(property, new, old)

        self:DebugMessage("Property changed:", property, "from", old, "to", new)

        if property == "Visible" then
            if self:GetParent() then
                self:GetParent():InvalidateLayout(nil, nil, nil, true)
            end
            return
        end
    end 

    function PNL.Prototype:SetWidth(value)
        self:SetComputed("Width", nil)
        self.WidthMode = 0
        if value == nil then
            self:SetComputed("Width", function (self)
                local max = 0
                for k, v in pairs(self:GetChildren()) do
                    if not v:Compute("Visible") or v:IsRelativeWidth() then
                        continue
                    end

                    local childRight = v:Compute("X") + v:Compute("Width")
                    max = math.max(max, childRight)
                end
                self.WidthMode = 1

                local pl, pr = self:Compute("PaddingLeft"), self:Compute("PaddingRight")
                return max + pl + pr
            end)
            return self
        elseif isstring(value) then
            value = string.lower(value)

            if string.EndsWith(value, "%") then
                local perc = tonumber(string.sub(value, 1, -2)) or 0
                self:SetComputed("Width", function (self)
                    local parent = self:GetParent()
                    self.WidthMode = 2
                    return parent:GetInnerWidth() * (perc / 100)
                end)
                return self
            elseif value == "grow" then
                self:SetWidthRaw(0)
                self.WidthMode = 3
                return self
            end
        elseif isfunction(value) then
            self:SetComputed("Width", value)
            return self
        end

        return self:SetWidthRaw(value)
    end
    
    function PNL.Prototype:GetInnerWidth() 
        local pl, pr = self:GetPaddingLeft(), self:GetPaddingRight()
        return self:GetWidth() - pl - pr
    end

    function PNL.Prototype:GetOuterWidth()
        local ml, mr = self:GetMarginLeft(), self:GetMarginRight()-- self:Compute("MarginLeft"), self:Compute("MarginRight")
        return self:GetWidth() + ml + mr
    end
    
    function PNL.Prototype:SetHeightRaw(value)
        return self:SetProperty("Height", value)
    end

    function PNL.Prototype:SetHeight(value)
        self:SetComputed("Height", nil)
        self.HeightMode = 0
        
        if value == nil then
            self:SetComputed("Height", function (self)
                local max = 0
                for k, v in pairs(self:GetChildren()) do
                    if not v:Compute("Visible") or v:IsRelativeHeight() then
                        continue
                    end

                    local childBottom = v:Compute("Y") + v:Compute("Height")
                    max = math.max(max, childBottom)
                end
                self.HeightMode = 1
                local pt, pb = self:Compute("PaddingTop"), self:Compute("PaddingBottom")
                return max + pt + pb
            end)
            return self
        elseif isstring(value) then
            value = string.lower(value)
            if string.EndsWith(value, "%") then
                local perc = tonumber(string.sub(value, 1, -2)) or 0
                self:SetComputed("Height", function (self)
                    local parent = self:GetParent()
                    self.HeightMode = 2
                    return parent:GetInnerHeight() * (perc / 100)
                end)
                return self
            elseif value == "grow" then
                self:SetHeightRaw(0)
                self.HeightMode = 3
            end
        elseif isfunction(value) then
            self:SetComputed("Height", value)
            return self
        end

        return self:SetHeightRaw(value)
    end
    
    function PNL.Prototype:GetInnerHeight() 
        local pt, pb = self:GetPaddingTop(), self:GetPaddingBottom()
        return self:GetHeight() - pt - pb
    end

    function PNL.Prototype:GetOuterHeight()
        local mt, mb = self:GetMarginTop(), self:GetMarginBottom()
        return self:GetHeight() + mt + mb
    end

    function PNL.Prototype:SetX(value)
        self:SetComputed("X", nil)
        if isstring(value) then
            if string.EndsWith(value, "%") then
                local perc = tonumber(string.sub(value, 1, -2)) or 0
                self:SetComputed("X", function (self)
                    local parent = self:GetParent()
                    return parent:GetWidth() * (perc / 100)
                end)
                return self
            end
        elseif isfunction(value) then
            self:SetComputed("X", value)
            return self
        end

        return self:SetProperty("X", value)
    end

    function PNL.Prototype:SetY(value)
        self:SetComputed("Y", nil)
        if isstring(value) then
            if string.EndsWith(value, "%") then
                local perc = tonumber(string.sub(value, 1, -2)) or 0
                self:SetComputed("Y", function (self)
                    local parent = self:GetParent()
                    return parent:GetHeight() * (perc / 100)
                end)
                return self
            end
        elseif isfunction(value) then
            self:SetComputed("Y", value)
            return self
        end

        return self:SetProperty("Y", value)
    end

    function PNL.Prototype:SetPadding(l, t, r, b)
        assert(l, "Left padding not specified")
        t = t or l
        r = r or l
        b = b or t

        self:SetPaddingLeft(l)
        self:SetPaddingTop(t)
        self:SetPaddingRight(r)
        self:SetPaddingBottom(b)
        return self
    end

    function PNL.Prototype:SetMargin(l, t, r, b)
        assert(l, "Left margin not specified")
        t = t or l
        r = r or l
        b = b or t

        self:SetMarginLeft(l)
        self:SetMarginTop(t)
        self:SetMarginRight(r)
        self:SetMarginBottom(b)
        return self
    end

    function PNL.Prototype:IsRelativeWidth()
        return isany(self.WidthMode, 2, 3)
    end

    function PNL.Prototype:IsRelativeHeight()
        return isany(self.HeightMode, 2, 3)
    end

    function PNL.Prototype:IsSizeRelative()
        return self:IsRelativeWidth() or self:IsRelativeHeight() or self:IsSizeGrow()
    end


    function PNL.Prototype:IsWidthGrow()
        return self.WidthMode == 3
    end

    function PNL.Prototype:IsHeightGrow()
        return self.HeightMode == 3
    end

    function PNL.Prototype:IsSizeGrow()
        return self:IsWidthGrow() or self:IsHeightGrow()
    end

    function PNL.Prototype:IsWidthDerived()
        return self.WidthMode == 1
    end

    function PNL.Prototype:IsHeightDerived()
        return self.HeightMode == 1
    end

    function PNL.Prototype:IsSizeDerived()
        return self:IsWidthDerived() or self:IsHeightDerived()
    end

    function PNL.Prototype:SetVisible(value)
        if isfunction(value) then
            self:SetComputed("Visible", value)
        else
            self:SetProperty("Visible", value)
        end
        
        return self
    end

    function PNL.Prototype:SetParent(el)
        if self.Parent then
            self.Parent:OnChildRemoved(self)
        end

        self.Parent = el
        
        if el then
            el:OnChildAdded(self)
            table.insert(el.Children, self)
        end
        return self
    end

    function PNL.Prototype:GetParent()
        return self.Parent
    end
    PNL.Prototype.Finish = PNL.Prototype.GetParent

    function PNL.Prototype:Add(name, t)
        if not t then
            t = name
            name = nil
        end

        local el
        if istable(t) then
            t:SetParent(self)
            if name then
                t:SetName(name)
            end
            el = t
        else
            t = t or "Panel"
            el = Interface.Create(t, self)
            if name then
                el:SetName(name)
            end
        end
        self:InvalidateLayout(nil, nil, nil, true)
        return el
    end

    function PNL.Prototype:GetChildren()
        return self.Children
    end

    function PNL.Prototype:OnChildAdded(child)
    end

    function PNL.Prototype:OnChildRemoved(child)
    end

    function PNL.Prototype:InvalidateLayout(immediate, force, noPropagate, noChildren)
        if not immediate then
            local p = Promise.Create()
            debounce(0, self, function ()
                self:InvalidateLayout(true, force, noPropagate, noChildren)
                p:Complete()
            end)
            return p
        end
        
        self:PerformLayout(force, noPropagate, noChildren)
    end

    function PNL.Prototype:CancelLayout()
        cancelDebounce(self)
    end

    function PNL.Prototype:PerformLayout(force, noPropagate, noChildren)
        self.LastLayout = CurTime()


        if self:IsSizeDerived() and not noChildren then
            self:LayoutChildren()
            self:CancelLayout()
        end

        local oldWidth, oldHeight = self.LastWidth, self.LastHeight
        local w, h = self:Compute("Width"), self:Compute("Height")

        if not force and IsValid(self.Mesh) and oldWidth == w and oldHeight == h then
            self:DebugMessage("Skip", force, self.Mesh, oldWidth, oldHeight, w, h)
            -- Don't do anything if we're exactly the same size.
            return
        end

        self:DebugMessage("Calc", force, self.Mesh, oldWidth, oldHeight, w, h)
        self:RegenerateMesh()

        -- If we're not a relative size, we need to propagate invalidation upwards.
        if not noPropagate then
            if not self:IsSizeRelative() then
                local parent = self:GetParent()
                if parent and parent:IsSizeDerived() then
                    parent:InvalidateLayout(nil, true)
                end
            else
                -- Otherwise, propagate it downwards to relative sized children.
                for k, v in pairs(self:GetChildren()) do
                    if v:IsSizeRelative() then
                        v:InvalidateLayout(nil, true)
                    end
                end
            end
        end
        

        -- If we're derived size (we size to children), we run the layout after we've derived our size
        if not self:IsSizeDerived() and not noChildren then
            self:LayoutChildren()
        end

        self.LastWidth = w
        self.LastHeight = h
    end

    function PNL.Prototype:RegenerateMesh()
        if IsValid(self.Mesh) then
            self.Mesh:Destroy()
        end

        local w, h = self:Compute("Width"), self:Compute("Height")
        local shape = self:Compute("Shape")
        self.Mesh = Mesh()        
        mesh.Begin(self.Mesh, MATERIAL_TRIANGLES, #shape/2 + 1)
            local cx, cy = w/2, h/2
            local lx, ly = nil

            for i=1, #shape, 2 do
                local x2 = shape[i]
                local y2 = shape[i + 1]     

                mesh.Position(cx, cy, 0)
                mesh.TexCoord(0, 0.5, 0.5)
                mesh.Color(255, 255, 255, 255)
                mesh.AdvanceVertex()

                if lx then
                    mesh.Position(lx, ly, 0)
                    mesh.TexCoord(0, lx/w, ly/h)
                    mesh.Color(255, 255, 255, 255)
                    mesh.AdvanceVertex()
                end

                mesh.Position(x2, y2, 0)
                mesh.TexCoord(0, x2/w, y2/h)
                mesh.Color(255, 255, 255, 255)
                mesh.AdvanceVertex()

                lx = x2
                ly = y2

            end
            
            mesh.Position(cx, cy, 0)
            mesh.TexCoord(0, cx/w, cy/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            local x2, y2 = shape[1], shape[2]

            mesh.Position(cx, cy, 0)
            mesh.TexCoord(0, cx/w, cy/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            
            mesh.Position(lx, ly, 0)
            mesh.TexCoord(0, lx/w, ly/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            mesh.Position(x2, y2, 0)
            mesh.TexCoord(0, x2/w, y2/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

        mesh.End()
    end

    function PNL.Prototype:LayoutChildren(x, y)
        x = x or 0
        y = y or 0

        local align = self:Compute("Align")
        local children = {}

        if align then

            local offset = 0
            local direction = self:Compute("Direction")
            local ltr = isany(direction, RIGHT, LEFT)
            local reverse = isany(direction, LEFT, TOP)

            local gap = self:Compute("Gap")
            local wrap = self:Compute("Wrap")

            -- Firstly, find our candidates
            local num = #self.Children
            if not reverse then
                for i=1,  num do
                    local v = self.Children[i]
                    if v:Compute("Visible") and not v:Compute("Absolute") and v:Compute("X") >= x and v:Compute("Y") >= y then
                        v:Compute("Width")
                        v:Compute("Height")
                        v:Compute("MarginLeft")
                        v:Compute("MarginTop")
                        v:Compute("MarginRight")
                        v:Compute("MarginBottom")

                        table.insert(children, v)
                    end
                end
            else
                for i=num, 1, -1 do
                    local v = self.Children[i]
                    if v:Compute("Visible") and not v:Compute("Absolute") and v:Compute("X") >= x and v:Compute("Y") >= y then
                        v:Compute("Width")
                        v:Compute("Height")
                        v:Compute("MarginLeft")
                        v:Compute("MarginTop")
                        v:Compute("MarginRight")
                        v:Compute("MarginBottom")
                        
                        table.insert(children, v)
                    end
                end
            end

            -- Secondly, place them next to eachother
            local growElements = {}
            local tw, th = 0, 0
            for k, v in pairs(children) do
                if ltr then
                    v:SetX(offset)

                    if v:IsWidthGrow() then
                        growElements[k] = v
                        offset = offset + gap
                        tw = tw + gap
                    else
                        offset = offset + v:GetOuterWidth() + gap
                        tw = tw + v:GetOuterWidth() + gap
                    end

                    if v:IsHeightGrow() then
                        ErrorNoHalt("Warning: Height Grow used in horizontal layout. Forcing to full height.\n")
                        v:SetHeightRaw(self:GetInnerHeight())
                    end

                    th = math.max(th, v:GetOuterHeight())
                else
                    v:SetY(offset)
                    if v:IsHeightGrow() then
                        growElements[k] = v
                        offset = offset + gap
                        th = th + gap
                    else 
                        offset = offset + v:GetOuterHeight() + gap
                        th = th + v:GetOuterHeight() + gap
                    end
                    

                    if v:IsWidthGrow() then
                        ErrorNoHalt("Warning: Width Grow used in vertical layout. Forcing to full height.\n")
                        v:SetWidthRaw(self:GetInnerWidth())
                    end

                    tw = math.max(tw, v:GetOuterWidth())
                end
            end
            
            if ltr then 
                tw = tw - gap
            else
                th = th - gap
            end

            -- Thirdly, handle the grow elements
            local numGrowElements = table.Count(growElements)
            local min = 0
            local otw, oth = tw, th
            for k, v in pairs(growElements) do
                if ltr then
                    if v:IsWidthGrow() then
                        local gw = (self:GetInnerWidth() - otw) / numGrowElements
                        v:SetWidthRaw(gw)
                        tw = tw + gw

                        for i=k+1, #children do
                            local cv = children[i]
                            cv:SetX(cv:GetX() + gw)
                        end
                    else
                        v:SetWidthRaw(tw)
                    end
                else
                    if v:IsHeightGrow() then
                        local gh = (self:GetInnerHeight() - oth) / numGrowElements
                        v:SetHeightRaw(gh)
                        th = th + gh

                        for i=k+1, #children do
                            local cv = children[i]
                            cv:SetY(cv:GetY() + gh)
                        end
                    else
                        v:SetHeightRaw(th)
                    end
                end
            end

            -- Thirdly, apply wrapping
            if wrap then
                if ltr then
                    -- Horizontal wrapping (wrap to new rows)
                    local rows = {{}}
                    local currentRow = 1
                    local rowWidth = 0
                    local rowHeights = {0}
                    
                    for k, v in pairs(children) do
                        local vw = v:GetOuterWidth()
                        
                        if rowWidth + vw > self:GetInnerWidth() and rowWidth > 0 then
                            -- Start new row
                            currentRow = currentRow + 1
                            rows[currentRow] = {}
                            rowHeights[currentRow] = 0
                            rowWidth = 0
                        end
                        
                        table.insert(rows[currentRow], v)
                        rowWidth = rowWidth + vw + gap
                        rowHeights[currentRow] = math.max(rowHeights[currentRow], v:GetOuterHeight())
                    end
                    
                    -- Reposition children in rows
                    local yOffset = 0
                    tw = 0
                    for rowNum, row in pairs(rows) do
                        local xOffset = 0
                        for _, v in pairs(row) do
                            v:SetX(xOffset)
                            v:SetY(yOffset)
                            xOffset = xOffset + v:GetOuterWidth() + gap
                        end
                        tw = math.max(tw, xOffset - gap)
                        yOffset = yOffset + rowHeights[rowNum] + gap
                    end
                    th = yOffset - gap
                else
                    -- Vertical wrapping (wrap to new columns)
                    local cols = {{}}
                    local currentCol = 1
                    local colHeight = 0
                    local colWidths = {0}
                    
                    for k, v in pairs(children) do
                        local vh = v:GetOuterHeight()
                        
                        if colHeight + vh > self:GetInnerHeight() and colHeight > 0 then
                            -- Start new column
                            currentCol = currentCol + 1
                            cols[currentCol] = {}
                            colWidths[currentCol] = 0
                            colHeight = 0
                        end
                        
                        table.insert(cols[currentCol], v)
                        colHeight = colHeight + vh + gap
                        colWidths[currentCol] = math.max(colWidths[currentCol], v:GetOuterWidth())
                    end
                    
                    -- Reposition children in columns
                    local xOffset = 0
                    th = 0
                    for colNum, col in pairs(cols) do
                        local yOffset = 0
                        for _, v in pairs(col) do
                            v:SetX(xOffset)
                            v:SetY(yOffset)
                            yOffset = yOffset + v:GetOuterHeight() + gap
                        end
                        th = math.max(th, yOffset - gap)
                        xOffset = xOffset + colWidths[colNum] + gap
                    end
                    tw = xOffset - gap
                end
            end

            -- Fourthly, apply the alignment
            local offsetX, offsetY = 0, 0
            if isany(align, 8, 5, 2) then
                offsetX = self:GetInnerWidth()/2 - tw/2
            elseif isany(align, 9, 6, 3) then
                offsetX = self:GetInnerWidth() - tw
            end

            if isany(align, 4, 5, 6) then
                offsetY = self:GetInnerHeight()/2 - th/2
            elseif isany(align, 1, 2, 3) then
                offsetY = self:GetInnerHeight() - th
            end

            for k, v in pairs(children) do
                if not ltr then
                    if isany(align, 9, 6, 3) then
                        v:SetX(self:GetInnerWidth() - v:GetOuterWidth())
                    elseif isany(align, 8, 5, 2) then
                        v:SetX(self:GetInnerWidth()/2 - v:GetOuterWidth()/2)
                    end
                    v:SetY(offsetY + v:GetY())
                else
                    if isany(align, 1, 2, 3) then
                        v:SetY(self:GetInnerHeight() - v:GetOuterHeight())
                    elseif isany(align, 4, 5, 6) then
                        v:SetY(self:GetInnerHeight()/2 - v:GetOuterHeight()/2)
                    end
                    v:SetX(offsetX + v:GetX())
                end
            end

            self.ContentWidth = tw
            self.ContentHeight = th            
        end
    end

    function PNL.Prototype:Flash()
        self.LastLayout = CurTime()
    end

    function PNL.Prototype:Paint()

        self.AbsolutePos = cam.GetModelMatrix():GetTranslation()
        self.AbsolutePos.x = self.AbsolutePos.x + self:GetMarginLeft()
        self.AbsolutePos.y = self.AbsolutePos.y + self:GetMarginTop()

        -- Handle animations first.
        for k, v in pairs(self.Animations) do
            local p = (CurTime() - v.Start) / v.Duration
            if p >= 1 then
                self:SetProperty(k, v.To)
                
                if isany(k, "Width", "Height") then
                    self:InvalidateLayout()
                end

                if v.Repetitions > 1 then
                    v.Repetitions = v.Repetitions - 1
                    v.Start = CurTime()
                    v.From, v.To = v.To, v.From
                else
                    self.Animations[k] = nil
                    v:Complete(true)
                end
            else
                local from = v.From
                local to = v.To
                local val
                
                if istable(from) then
                    val = table.Copy(from)

                    for k2, v2 in pairs(from) do
                        if not isnumber(v2) then
                            continue
                        end
                        val[k2] = v2 + (to[k2] - v2) * v.EaseFunc(p)
                    end
                else
                    val = v.From + (v.To - v.From) * v.EaseFunc(p)
                end

                self:SetProperty(k, val)
            end

            if isany(k, "Width", "Height") then
                self:InvalidateLayout()
            end
        end

        local parent = self:GetParent()
        local pw, ph = parent and parent:GetWidth(), parent and parent:GetHeight()
        local w, h = self:GetWidth(), self:GetHeight()
        local x, y = self:GetX(), self:GetY()

        if not w or not h then
            return
        end
        self:Compute("Visible")

        local alpha = surface.GetAlphaMultiplier()
        local newAlpha = alpha * (self:Compute("Alpha") / 255)

        surface.SetAlphaMultiplier(newAlpha)

        self.RenderBounds.x = math.max(self.AbsolutePos.x, (parent and parent.RenderBounds.x + parent:GetPaddingLeft()) or 0)
        self.RenderBounds.y = math.max(self.AbsolutePos.y, (parent and parent.RenderBounds.y + parent:GetPaddingTop()) or 0)
        self.RenderBounds.w = math.min(self.AbsolutePos.x + w, (parent and parent.RenderBounds.w - parent.PaddingRight) or ScrW())
        self.RenderBounds.h = math.min(self.AbsolutePos.y + h, (parent and parent.RenderBounds.h - parent.PaddingBottom) or ScrH())

        if IsValid(self.Mesh) then

            if self:GetCull() then
                self:SetScissorRect()
            end

                local m = Matrix()
                m:Translate(Vector(self:GetMarginLeft(),  self:GetMarginTop(), 0))

                cam.PushModelMatrix(m, true)
                    self:PaintMesh()
                    self:PaintStroke()

                    self:PaintChildren()
                cam.PopModelMatrix()

                render.SetScissorRect(0, 0, 0, 0, false)
            
                
                if VisualizeLayout:GetBool() then
                    
                    surface.SetAlphaMultiplier(self:GetVisible() and 1 or 0.05)

                    surface.SetDrawColor(Color(128, 255, 255, 225))
                    surface.DrawOutlinedRect(
                        0, 0,
                        self:GetOuterWidth(),
                        self:GetOuterHeight(),
                        2
                    )
                    
                    -- Margin bounds
                    cam.PushModelMatrix(m, true)
                        surface.SetDrawColor(Color(255, 255, 0, 225))
                        surface.DrawOutlinedRect(
                            0, 0,
                            self:GetWidth(),
                            self:GetHeight(),
                            2
                        )

                        -- Inner bounds
                        m = Matrix()
                        m:Translate(Vector(
                            self:GetPaddingLeft(),
                            self:GetPaddingTop(),
                            0
                        ))
                        cam.PushModelMatrix(m, true)
                            surface.SetDrawColor(Color(255, 0, 255, 225))
                            surface.DrawOutlinedRect(
                                0, 0,
                                self:GetInnerWidth(),
                                self:GetInnerHeight(),
                                2
                            )
                            

                            if self.ContentWidth and self.ContentHeight then
                                surface.SetDrawColor(Color(0, 255, 0, 100))
                                local align = self:GetAlign()
                                
                                local x, y = 0, 0
                                if isany(align, 8, 5, 2) then
                                    x = self:GetInnerWidth()/2 - self.ContentWidth/2
                                elseif isany(align, 9, 6, 3) then
                                    x = self:GetInnerWidth() - self.ContentWidth
                                end

                                if isany(align, 4, 5, 6) then
                                    y = self:GetInnerHeight()/2 - self.ContentHeight/2
                                elseif isany(align, 1, 2, 3) then
                                    y = self:GetInnerHeight() - self.ContentHeight
                                end

                                surface.DrawOutlinedRect(
                                    x,
                                    y,
                                    self.ContentWidth,
                                    self.ContentHeight,
                                    2
                                )
                            end
                        cam.PopModelMatrix()
                    cam.PopModelMatrix()

                    
                    surface.SetAlphaMultiplier(1)
                    if CurTime() - self.LastLayout < 0.5 then
                        local elapsed = CurTime() - self.LastLayout
                        local alpha = math.Clamp(1 - (elapsed * 2), 0, 1) * 255

                        surface.SetDrawColor(Color(255, 255, 0, alpha))
                        surface.DrawOutlinedRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight(), 2)
                        surface.SetDrawColor(Color(255, 0, 0, alpha))
                        surface.DrawRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight())
                    end
                end
            surface.SetAlphaMultiplier(alpha)
        end
    end

    function PNL.Prototype:PaintMesh()
        local fill = self:Compute("Fill")
        local material = self:Compute("Material")
        if isfunction(material) then
            material = material(self:GetWidth(), self:GetHeight())
        end
        render.SetMaterial(material)

        material:SetVector("$color", fill:ToVector())
        material:SetFloat("$alpha", (fill.a / 255) * surface.GetAlphaMultiplier())
        
        self.Mesh:Draw()
    end

    function PNL.Prototype:PaintStroke()
        local strokeW = self:Compute("Stroke")
        if strokeW > 0 then
            
            mat = self:Compute("StrokeMaterial")
            if isfunction(mat) then
                mat = mat(self:GetWidth(), self:GetHeight())
            end
            
            color = self:Compute("StrokeColor")
            mat:SetVector("$color", color:ToVector())
            mat:SetFloat("$alpha", (color.a / 255) * surface.GetAlphaMultiplier())
            
            render.SetMaterial(mat)

            --surface.SetDrawColor(self:GetStroke())
            local s = self:GetShape()
            local count = #s / 2

            local pts   = {}   -- original points
            local norms  = {}  -- unit normals for each edge
            local joins = {}   -- mitered corner points

            -- 1) Build pts[]
            for i = 1, count do
                pts[i] = Vector(s[2*i-1], s[2*i], 0)
            end

            -- 2) Compute edge normals (90° yaw in Source = 2D perp)
            for i = 1, count do
                local a = pts[i]
                local b = pts[i % count + 1]
                local dir = (b - a):GetNormalized() * strokeW
                dir:Rotate(Angle(0, 90, 0))        -- yaw by +90° gives CW perp in screen XY
                norms[i] = dir:GetNormalized()     -- store just the unit perp
            end

            -- 3) Compute miter at each vertex
            for i = 1, count do
                local prev = (i - 2) % count + 1
                local n1 = norms[prev]
                local n2 = norms[i]
                
                -- sum the two normals to get bisector direction
                local bis = (n1 + n2)
                local bisLen = bis:Length()
                
                if bisLen < 1e-6 then
                    -- 180° turn: just offset along one normal
                    joins[i] = pts[i] + n2 * strokeW
                else
                    bis:Normalize()
                    -- scale so that both offset edges actually meet at this point
                    -- cosθ = bis·n2  ⇒  miterLength = strokeW / cosθ
                    local scale = strokeW / bis:Dot(n2)
                    joins[i] = pts[i] + bis * scale
                end
            end

            -- 4) Draw one quad per edge between the original edge and its mitered caps
            for i = 1, count do
                local ni = i % count + 1
                
                local a = pts[i]
                local b = pts[ni]
                local jA = joins[i]
                local jB = joins[ni]

                -- order: a→b→jB→jA
                render.DrawQuad(a, b, jB, jA, self:GetStroke())
            end

        end
    end

    function PNL.Prototype:SetScissorRect()
        render.SetScissorRect(self.RenderBounds.x, self.RenderBounds.y, self.RenderBounds.w, self.RenderBounds.h, true)
    end

    function PNL.Prototype:GetRenderBounds()
        return self.RenderBounds.x, self.RenderBounds.y, self.RenderBounds.w, self.RenderBounds.h
    end

    function PNL.Prototype:Find(name, noRecurse)
        for k, v in pairs(self.Children) do
            if v:GetName() == name then
                return v
            end

            if not noRecurse then
                local found = v:Find(name)
                if found then
                    return found
                end
            end
        end
    end

    function PNL.Prototype:FindParent(name)
        local p = self:GetParent()
        while p do
            if p:GetName() == name then
                return p
            end
            p = p:GetParent()
        end
    end

    function PNL.Prototype:GetHoverParent()
        local p = self:GetParent()
        while p do
            if p:GetHoverable() then
                return p
            end
            p = p:GetParent()
        end
    end

    function PNL.Prototype:PaintChildren()
        local children = self:GetChildren()

        local pl, pt = self:Compute("PaddingLeft"), self:Compute("PaddingTop")
        for k, v in pairs(children) do
            if not IsValid(v) then
                children[k] = nil
                continue
            end
            local m = Matrix()
            m:Translate(Vector(v:Compute("X") + pl, v:Compute("Y") + pt, 0))
            cam.PushModelMatrix(m, true)
                xpcall(v.Paint, ErrorNoHaltWithStack, v)
            cam.PopModelMatrix()
        end
    end

    function PNL.Prototype:GetAbsolutePos()
        if not self.AbsolutePos then
            self:Paint()
        end
        return self.AbsolutePos.x, self.AbsolutePos.y
    end

    function PNL.Prototype:ScreenToLocal(x, y)
        local absX, absY = self:GetAbsolutePos()
        return x - absX, y - absY
    end

    function PNL.Prototype:LocalToScreen(x, y)
        local absX, absY = self:GetAbsolutePos()
        return x + absX, y + absY
    end

    function PNL.Prototype:GetHost()
        if not self:GetParent() then
            return self
        end
        return self:GetParent():GetHost()
    end

    function PNL.Prototype:CursorPos()
        return self:ScreenToLocal(self:GetHost():GetCursorPos())
    end

    function PNL.Prototype:TestHover(x, y)
        local absX, absY = self:GetAbsolutePos()
        local w, h = self:GetWidth(), self:GetHeight()
        
        local hovered = (x >= absX and x <= absX + w and y >= absY and y <= absY + h)
        if hovered then
            for k, v in pairs(self:GetChildren()) do
                local el = v:TestHover(x, y)
                if el then
                    return el
                end
            end
            return self
        end
    end

    function PNL.Prototype:InvokeChildren(method, ...)
        for k, v in pairs(self.Children) do
            if isfunction(v[method]) then
                v[method](v, ...)
            end
        end
    end

    function PNL.Prototype:InvokeParent(method, ...)
        local p = self:GetParent()
        while p do
            if isfunction(p[method]) then
                local rtn = { p[method](p, ...) }
                if rtn[1] ~= nil then
                    return unpack(rtn)
                end
            end
            p = p:GetParent()
        end
    end

    function PNL.Prototype:OnCursorEntered(old)
        self:StartHover(self, old)
    end

    function PNL.Prototype:OnCursorExited(new)
        self:EndHover(self, new)
    end

    function PNL.Prototype:IsChildOf(pnl)
        local p = self:GetParent()
        while p do
            if p == pnl then
                return true
            end
            p = p:GetParent()
        end
        return false
    end

    function PNL.Prototype:IsParentOf(p)        
        return p:IsChildOf(self)
    end 

    function PNL.Prototype:StartHover(src, last)
        
        if (self:GetHoverable() and src ~= self) then
            return
        end

        if not self:GetHoverable() and self == src then
            local p = self:GetHoverParent()
            if p then
                p:StartHover(p, last)
            end
            return
        end

        -- Do nothing if we're already hovered and the new hovered panel is a child of us (we're still effectively hovered in this case).
        if self:GetHovered() then
            return
        end

        self:SetHovered(true)
        
        for k, v in pairs(self.HoverProperties) do
            v.Initial = v.Initial or self:GetProperty(k)
            
            local progress = 1

            if v.Duration then
                if v.Animation then
                    local elapsed = CurTime() - v.Animation.Start
                    progress = math.Clamp(elapsed / v.Duration, 0, 1)

                    v.Animation:Complete(false)
                    v.Animation = nil 
                    self:CancelAnimation(k)
                end
                
                local duration = v.Duration * progress
                v.Animation = self:Animate(k, v.Value, duration, 1, v.EaseFunc):Then(function (succ)
                    v.Animation = nil
                end)
            else
                self:SetProperty(k, v.Value)
            end
        end

        -- Propagate to children
        self:InvokeChildren("StartHover", self:GetHoverable() and self or src, last)
    end

    function PNL.Prototype:EndHover(src, new)
        if (self:GetHoverable() and src ~= self) then
            return
        end

        if not self:GetHoverable() and self == src then
            local p = self:GetHoverParent()
            if p then
                p:EndHover(p)
                return
            end
        end

        -- If we're hoverable, check to see if the new hovered panel is a child of us; if so, do nothing.
        local hovered = self:GetHost():GetHoveredPanel()
        if hovered == self then
            return
        end

        if hovered and hovered ~= self then
            local p = hovered
            while p do
                if p ~= self and p:GetHoverable() then
                    break
                end

                -- We are the next hoverable parent of the hovered panel, so we stay hovered.
                if p == self then
                    return
                end
                p = p:GetParent()
            end
        end
        self:SetHovered(false)

        for k, v in pairs(self.HoverProperties) do
            local progress = 1

            if v.Duration then
                if v.Animation then
                    local elapsed = CurTime() - v.Animation.Start
                    progress = math.Clamp(elapsed / v.Duration, 0, 1)

                    v.Animation:Complete(false)
                    self:CancelAnimation(k)
                end
                
                local duration = v.Duration * progress
                v.Animation = self:Animate(k, v.Initial, duration, 1, v.EaseFunc):Then(function (succ)
                    if not succ then
                        return
                    end

                    v.Animation = nil
                end)
            else
                self:CancelAnimation(k)
                self:SetProperty(k, v.Initial)
            end
        end

        -- Propagate to children
        self:InvokeChildren("EndHover", self:GetHoverable() and self or src)
    end

    function PNL.Prototype:OnCursorMoved(x, y)
    end

    function PNL.Prototype:OnMousePressed(button, src)

        if button == MOUSE_LEFT and self.LeftClick then
            self:LeftClick()
            return true
        elseif button == MOUSE_RIGHT and self.RightClick then
            self:RightClick()
            return true
        elseif button == MOUSE_MIDDLE and self.MiddleClick then
            self:MiddleClick()
            return true
        end

        local p = self:GetParent()
        if p then
            p:OnMousePressed(button, self)
        end
    end

    function PNL.Prototype:OnMouseReleased(button, src)
        local p = self:GetParent()
        if p then
            p:OnMouseReleased(button, self)
        end
    end

    function PNL.Prototype:OnMouseWheeled(delta)
        local p = self:GetParent()
        if p then
            p:OnMouseWheeled(delta, self)
        end
    end

    function PNL.Prototype:OnDisposed()
        for k, v in pairs(self.Children) do
            v:Dispose()
        end

        if IsValid(self.Mesh) then
            self.Mesh:Destroy()
        end
        
        if self:GetParent() then
            table.RemoveByValue(self:GetParent().Children, self)
        end
    end

    function PNL.Metamethods:__tostring()
        return self:GetType():GetName() .. "[" .. (self:GetName() or self.Id) .. "][" .. tostring(self.X) .. "," .. tostring(self.Y) .. "," .. tostring(self.Width) .. "," .. tostring(self.Height) .. "]"
    end
end

-- PanelHost
do
    local PanelHost = Interface.Register("Host", PNL)
    function PanelHost.Prototype:Initialize()
        base(self, "Initialize")

        self.Popovers = {}

        self:SetFontName("Tahoma")
        self:SetFontSize(14)
        self:SetFontWeight(500)
        self:SetTextColor(color_white)
    end

    function PanelHost.Prototype:GetHost()
        return self
    end 
    
    function PanelHost.Prototype:PaintChildren()
        local children = self:GetChildren()

        local pl, pt = self:Compute("PaddingLeft"), self:Compute("PaddingTop")
        for k, v in pairs(children) do
            if not IsValid(v) then
                children[k] = nil
                continue
            end
            local m = Matrix()
            m:Translate(Vector(v:Compute("X") + pl, v:Compute("Y") + pt, 0))
            cam.PushModelMatrix(m, true)
                xpcall(v.Paint, ErrorNoHaltWithStack, v, true)
            cam.PopModelMatrix()
        end
    end

    function PanelHost.Prototype:OnCursorEntered()
    end

    function PanelHost.Prototype:OnCursorMoved(x, y)
        self.CursorX = x
        self.CursorY = y

        local old = self:GetHoveredPanel()

        for i=#self.Children, 1, -1 do
            local v = self.Children[i]
            local hovered = v:TestHover(x, y)
            if hovered then
                hover = hovered
                break
            end
        end

        if old ~= hover then
            self.HoveredPanel = hover

            if old then
                old:OnCursorExited(hover)
            end

            self:OnHoverChanged(self.HoveredPanel, old)

            if self.HoveredPanel then
                self.HoveredPanel:OnCursorEntered(old)
            end 
        end
    end

    function PanelHost.Prototype:OnHoverChanged(new, old)
    end

    function PanelHost.Prototype:GetHoveredPanel()
        return self.HoveredPanel
    end

    function PanelHost.Prototype:GetCursorPos()
        return self.CursorX, self.CursorY
    end

    function PanelHost.Prototype:OnCursorExited()
        self.CursorX = nil
        self.CursorY = nil

        local old = self:GetHoveredPanel()
        if old then
            self.HoveredPanel = nil
            old:OnCursorExited()
            self:OnHoverChanged(nil, old)
        end
    end

    function PanelHost.Prototype:OnMousePressed(button, src)
        if src then
            return
        end

        local pnl = self:GetHoveredPanel()
        if pnl then
            pnl:OnMousePressed(button)
        end
    end

    function PanelHost.Prototype:OnMouseReleased(button, src)
        if src then
            return
        end

        local pnl = self:GetHoveredPanel()
        if pnl then
            pnl:OnMouseReleased(button)
        end
    end

    function PanelHost.Prototype:OnMouseWheeled(delta, src)
        if src then
            return
        end

        local pnl = self:GetHoveredPanel()
        if pnl then
            pnl:OnMouseWheeled(delta)
        end
    end

    function PanelHost.Prototype:Paint()
        base(self, "Paint")

        --local x, y = self:GetCursorPos()
        --if x and y then
            --surface.DrawCircle(x, y, 5, Color(255, 0, 0, 255))
        --end
    end
end

-- Materials, shaders and helpers
do
    local dp = 3

    function RoundedBox(w, h, tl, tr, br, bl, sz)
        if not tr then
            tr = tl
            br = tl
            bl = tl
        end

        local x, y = 0, 0
        local t = {}
        local idx = 1

        local function append(pt)
            t[idx] = pt.x
            t[idx + 1] = pt.y
            idx = idx + 2
        end

        sz = sz or 8

        -- top-left corner
        if tl > 0 then
            table.insert(t, { x = x, y = y + tl })
            for i = 1, sz do
                local ang = 90 / sz * i
                local x2 = math.cos(math.rad(ang)) * tl
                local y2 = math.sin(math.rad(ang)) * tl
                append({ x = x + tl - x2, y = y + tl - y2 })
            end
        else
            append({ x = x, y = y })  -- sharp corner
        end

        -- top-right corner
        if tr > 0 then
            append({ x = x + w - tr, y = y })
            for i = 1, sz do
                local ang = 90 + 90 / sz * i
                local x2 = math.cos(math.rad(ang)) * tr
                local y2 = math.sin(math.rad(ang)) * tr
                append({ x = x + w - tr - x2, y = y + tr - y2 })
            end
        else
            append({ x = x + w, y = y }) -- sharp corner
        end

        -- bottom-right corner
        if br > 0 then
            append({ x = x + w, y = y + h - br })
            for i = 1, sz do
                local ang = 0 + 90 / sz * i
                local x2 = math.cos(math.rad(ang)) * br
                local y2 = math.sin(math.rad(ang)) * br
                append({ x = x + w - br + x2, y = y + h - br + y2 })
            end
        else
            append({ x = x + w, y = y + h }) -- sharp corner
        end

        -- bottom-left corner
        if bl > 0 then
            append({ x = x + bl, y = y + h })
            for i = 1, sz do
                local ang = 90 + 90 / sz * i
                local x2 = math.cos(math.rad(ang)) * bl
                local y2 = math.sin(math.rad(ang)) * bl
                append({ x = x + bl + x2, y = y + h - bl + y2 })
            end
        else
            append({ x = x, y = y + h }) -- sharp corner
        end

        return t
    end

    local Radial = Material("sstrp25/shaders/radialgradient")
    function RadialGradient(color1, offset1, color2, offset2, color3)
        if not offset1 then
            offset1 = 0.25
            color2 = color1
        end

        if not offset2 then
            offset2 = 0.75
            color3 = color2
        end

        return function (w, h) 

            local alpha = surface.GetAlphaMultiplier()

            Radial:SetFloat("$c0_x", math.Round(color1.r / 255, dp))
            Radial:SetFloat("$c0_y", math.Round(color1.g / 255, dp))
            Radial:SetFloat("$c0_z", math.Round(color1.b / 255, dp))
            Radial:SetFloat("$c0_w", math.Round((color1.a / 255) * alpha, dp))
            
            Radial:SetFloat("$c1_x", math.Round(color2.r / 255, dp))
            Radial:SetFloat("$c1_y", math.Round(color2.g / 255, dp))
            Radial:SetFloat("$c1_z", math.Round(color2.b / 255, dp))
            Radial:SetFloat("$c1_w", math.Round((color2.a / 255) * alpha, dp))

            Radial:SetFloat("$c2_x", math.Round(color3.r / 255, dp))
            Radial:SetFloat("$c2_y", math.Round(color3.g / 255, dp))
            Radial:SetFloat("$c2_z", math.Round(color3.b / 255, dp))
            Radial:SetFloat("$c2_w", math.Round((color3.a / 255) * alpha, dp))
            
            Radial:SetFloat("$c3_x", math.Round(offset1, dp))
            Radial:SetFloat("$c3_y", math.Round(offset2, dp))

            return Radial
        end
    end

    local mat = Material("sstrp25/shaders/lineargradientv2")
    function LinearGradient(col1, off1, col3, rotDeg)
        
        local colA = col1
        local colB = col3 or colA
        

        local alpha = surface.GetAlphaMultiplier()
        colA.a = colA.a * alpha
        colB.a = colB.a * alpha

        local rad = math.rad((rotDeg or 0) + LG_OFFSET)

        return function (w, h)
            -- aspect-correct the direction in UV space
            local ax = w / math.max(h, 1)
            local dx, dy = math.Round(math.cos(rad), 2), math.Round(math.sin(rad), 2)
            local len = math.sqrt(dx*dx + dy*dy)
            if len > 0 then dx, dy = dx/len, dy/len end

            -- colours
            local alpha = surface.GetAlphaMultiplier()
            mat:SetFloat("$c0_x", colA.r/255) 
            mat:SetFloat("$c0_y", colA.g/255)
            mat:SetFloat("$c0_z", colA.b/255) 
            mat:SetFloat("$c0_w", (colA.a/255) * alpha)
            mat:SetFloat("$c1_x", colB.r/255) 
            mat:SetFloat("$c1_y", colB.g/255)
            mat:SetFloat("$c1_z", colB.b/255) 
            mat:SetFloat("$c1_w", (colB.a/255) * alpha)

            -- pack direction (xy); the shader ignores z/w now
            mat:SetFloat("$c3_x", dx)
            mat:SetFloat("$c3_y", dy)
            mat:SetFloat("$c3_z", off1)
            mat:SetFloat("$c3_w", off1)

            return mat
        end
    end
end

-- Text
do
    local Text = Interface.Register("Text", PNL)
    Text:CreateProperty("Value", Type.String, { Default = "" })
    Text:CreateProperty("Wrap", Type.Boolean, { Default = false })

    function Text.Prototype:Initialize()
        base(self, "Initialize")
    end

    function Text.Prototype:PerformLayout(noPropagate)
        self.Lines = string.Split(self:Compute("Value"), "\n")

        if self:GetWrap() then
            local mw = self:Compute("Width")
            
            local out = {}
            surface.SetFont(self:GetFont())
            for _, l in pairs(self.Lines) do
                local current = {}
                local w = 0
                for _, word in pairs(string.Split(l, " ")) do
                    local tw, th = surface.GetTextSize(word .. " ")
                    if w + tw > mw then
                        table.insert(out, table.concat(current, " "))
                        current = { word }
                        w = tw
                    else
                        table.insert(current, word)
                        w = w + tw
                    end
                end

                if #current > 0 then
                    table.insert(out, table.concat(current, " "))
                end

                self.Lines = out
            end
        end

        return base(self, "PerformLayout", noPropagate)
    end

    function Text.Prototype:SetWidth(value)
        self:SetComputed("Width", nil)
        self.WidthMode = 0

        if value == nil then
            self:SetComputed("Width", function (self)
                if not self.Lines then
                    self:InvalidateLayout(true)
                end

                local w = 0
                for k, v in pairs(self.Lines) do
                    surface.SetFont(self:GetFont())
                    local tw, th = surface.GetTextSize(v)
                    w = math.max(w, tw)
                end

                self.WidthMode = 1
                return w 
            end)
            return self
        else
            return base(self, "SetWidth", value)
        end
    end

    function Text.Prototype:SetHeight(value)
        self:SetComputed("Height", nil)
        self.HeightMode = 0

        if value == nil then
            self:SetComputed("Height", function (self)
                if not self.Lines then
                    self:InvalidateLayout(true)
                end
                
                local h = 0
                for k, v in pairs(self.Lines) do
                    surface.SetFont(self:GetFont())
                    local tw, th = surface.GetTextSize(v)
                    h = h + th
                end

                self.HeightMode = 1
                return h 
            end)
            return self
        else
            return base(self, "SetHeight", value)
        end
    end

    function Text.Prototype:Paint()
        base(self, "Paint")

        local txt = self:Compute("Value")
        if txt ~= self.Last then
            self:InvalidateLayout(true)
        end

        self:SetScissorRect()
        if self.Lines then
            local y = 0
            surface.SetFont(self:GetFont())
            for k, v in pairs(self.Lines) do
                local _, th = surface.GetTextSize(v)
                surface.SetTextPos(0, y)
                surface.SetTextColor(self:GetTextColor())
                surface.DrawText(v)
                y = y + th
            end
        end
        render.SetScissorRect(0, 0, 0, 0, false)

        self.Last = txt
    end
end

-- Overlay
local Overlay = Interface.Register("Overlay", PNL)
do
    Overlay:CreateProperty("ShowOnHover", Type.Boolean, { Default = true })
    function Overlay.Prototype:Initialize()
        base(self, "Initialize")

        self:SetAbsolute(true)
        self:SetVisible(false)
    end
    
    function Overlay.Prototype:Paint(asOverlay)
        local m = Matrix()
        local parent = self:GetParent()
        m:Translate(parent.AbsolutePos)
        m:Translate(Vector(self:Compute("X"), self:Compute("Y"), 0))

        cam.PushModelMatrix(m)

            self.AbsolutePos = cam.GetModelMatrix():GetTranslation()
            self.AbsolutePos.x = self.AbsolutePos.x + self:GetMarginLeft()
            self.AbsolutePos.y = self.AbsolutePos.y + self:GetMarginTop()

            -- Handle animations first.
            for k, v in pairs(self.Animations) do
                local p = (CurTime() - v.Start) / v.Duration
                if p >= 1 then
                    self:SetProperty(k, v.To)
                    
                    if isany(k, "Width", "Height") then
                        self:InvalidateLayout()
                    end

                    if v.Repetitions > 1 then
                        v.Repetitions = v.Repetitions - 1
                        v.Start = CurTime()
                        v.From, v.To = v.To, v.From
                    else
                        self.Animations[k] = nil
                        v:Complete(true)
                    end
                else
                    local from = v.From
                    local to = v.To
                    local val
                    
                    if istable(from) then
                        val = table.Copy(from)

                        for k2, v2 in pairs(from) do
                            if not isnumber(v2) then
                                continue
                            end
                            val[k2] = v2 + (to[k2] - v2) * v.EaseFunc(p)
                        end
                    else
                        val = v.From + (v.To - v.From) * v.EaseFunc(p)
                    end

                    self:SetProperty(k, val)
                end

                if isany(k, "Width", "Height") then
                    self:InvalidateLayout()
                end
            end

            local parent = self:GetParent()
            local pw, ph = parent and parent:GetWidth(), parent and parent:GetHeight()
            local w, h = self:GetWidth(), self:GetHeight()
            local x, y = self:GetX(), self:GetY()

            if not w or not h then
                return
            end
            self:Compute("Visible")

            local alpha = surface.GetAlphaMultiplier()
            local newAlpha = alpha * (self:Compute("Alpha") / 255)

            surface.SetAlphaMultiplier(newAlpha)

            self.RenderBounds.x = self.AbsolutePos.x --, (parent and parent.RenderBounds.x + parent:GetPaddingLeft()) or 0)
            self.RenderBounds.y = self.AbsolutePos.y -- math.max(self.AbsolutePos.y, (parent and parent.RenderBounds.y + parent:GetPaddingTop()) or 0)
            self.RenderBounds.w = self.AbsolutePos.x + w --, (parent and parent.RenderBounds.w - parent.PaddingRight) or ScrW())
            self.RenderBounds.h = self.AbsolutePos.y + h --, (parent and parent.RenderBounds.h - parent.PaddingBottom) or ScrH())

            if asOverlay and IsValid(self.Mesh) then

                if self:GetCull() then
                    self:SetScissorRect()
                end

                    local m = Matrix()
                    m:Translate(Vector(self:GetMarginLeft(),  self:GetMarginTop(), 0))

                    cam.PushModelMatrix(m, true)
                        self:PaintMesh()
                        self:PaintStroke()

                        self:PaintChildren()
                    cam.PopModelMatrix()

                    render.SetScissorRect(0, 0, 0, 0, false)
                
                    
                    if VisualizeLayout:GetBool() then
                        
                        surface.SetAlphaMultiplier(self:GetVisible() and 1 or 0.05)

                        surface.SetDrawColor(Color(128, 255, 255, 225))
                        surface.DrawOutlinedRect(
                            0, 0,
                            self:GetOuterWidth(),
                            self:GetOuterHeight(),
                            2
                        )
                        
                        -- Margin bounds
                        cam.PushModelMatrix(m, true)
                            surface.SetDrawColor(Color(255, 255, 0, 225))
                            surface.DrawOutlinedRect(
                                0, 0,
                                self:GetWidth(),
                                self:GetHeight(),
                                2
                            )

                            -- Inner bounds
                            m = Matrix()
                            m:Translate(Vector(
                                self:GetPaddingLeft(),
                                self:GetPaddingTop(),
                                0
                            ))
                            cam.PushModelMatrix(m, true)
                                surface.SetDrawColor(Color(255, 0, 255, 225))
                                surface.DrawOutlinedRect(
                                    0, 0,
                                    self:GetInnerWidth(),
                                    self:GetInnerHeight(),
                                    2
                                )
                                

                                if self.ContentWidth and self.ContentHeight then
                                    surface.SetDrawColor(Color(0, 255, 0, 100))
                                    local align = self:GetAlign()
                                    
                                    local x, y = 0, 0
                                    if isany(align, 8, 5, 2) then
                                        x = self:GetInnerWidth()/2 - self.ContentWidth/2
                                    elseif isany(align, 9, 6, 3) then
                                        x = self:GetInnerWidth() - self.ContentWidth
                                    end

                                    if isany(align, 4, 5, 6) then
                                        y = self:GetInnerHeight()/2 - self.ContentHeight/2
                                    elseif isany(align, 1, 2, 3) then
                                        y = self:GetInnerHeight() - self.ContentHeight
                                    end

                                    surface.DrawOutlinedRect(
                                        x,
                                        y,
                                        self.ContentWidth,
                                        self.ContentHeight,
                                        2
                                    )
                                end
                            cam.PopModelMatrix()
                        cam.PopModelMatrix()

                        
                        surface.SetAlphaMultiplier(1)
                        if CurTime() - self.LastLayout < 0.5 then
                            local elapsed = CurTime() - self.LastLayout
                            local alpha = math.Clamp(1 - (elapsed * 2), 0, 1) * 255

                            surface.SetDrawColor(Color(255, 255, 0, alpha))
                            surface.DrawOutlinedRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight(), 2)
                            surface.SetDrawColor(Color(255, 0, 0, alpha))
                            surface.DrawRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight())
                        end
                    end
                surface.SetAlphaMultiplier(alpha)
            end
        cam.PopModelMatrix()
    end

    function Overlay.Prototype:Open()
        if not self:IsOpen() then
            self:SetVisible(true)
            self:InvalidateLayout()
            table.insert(self:GetHost():GetChildren(), self)
        end
    end

    function Overlay.Prototype:CreatePanel()
        if IsValid(self.Panel) then
            return
        end
        
        self.Panel = Interface.Create("Panel", self:GetHost())
        local me = self
        local x, y = self:LocalToScreen(0, 0)
        
        self.Panel:SetComputed("X", function () local x, y = me:LocalToScreen(0, 0) return x end)
        self.Panel:SetComputed("Y", function () local x, y = me:LocalToScreen(0, 0) return y end)
        self.Panel:SetComputed("Width", function () return me:GetWidth() end)
        self.Panel:SetComputed("Height", function () return me:GetHeight() end)
        self.Panel:SetComputed("Fill", function () return me:Compute("Fill") end)

        self.Panel.Children = self.Children 
        return self.Panel
    end

    function Overlay.Prototype:IsOpen()
        return self:GetVisible()
    end

    function Overlay.Prototype:Toggle()
        if self:IsOpen() then
            self:Close()
        else
            self:Open()
        end
    end

    function Overlay.Prototype:GetPanel()
        return self.Panel
    end

    function Overlay.Prototype:RemovePanel()
        if IsValid(self.Panel) then
            self.Panel:Dispose()
            self.Panel = nil
        end
    end

    function Overlay.Prototype:Close()
        self:SetVisible(false)
        table.RemoveByValue(self:GetHost():GetChildren(), self)
    end

    function Overlay.Prototype:StartHover(src, last)
        if self:Compute("ShowOnHover") then
            self:Open()
        end
    end

    function Overlay.Prototype:EndHover(src, new)
        if not self:Compute("ShowOnHover") then
            return
        end

        local p = new
        while p do
            -- If it's the same panel or one of our children, we don't close the overlay since we're effectively still hovered.
            if p == self:GetParent() then
                return
            end
            p = p:GetParent()
        end

        self:Close()
    end

    function Overlay.Prototype:OnDisposed()
        base(self, "OnDisposed")
        table.RemoveByValue(self:GetHost():GetChildren(), self)
    end
end

-- Setup
do
    Interface.BasePanel = Interface.Create("Host")
    Interface.BasePanel:SetFill(Color(0, 0, 0, 0))
    Interface.BasePanel:SetAlign(false)
    Interface.BasePanel:SetComputed("Width", function () return ScrW() end)
    Interface.BasePanel:SetComputed("Height", function () return ScrH() end)

    function Interface.BasePanel:OnHoverChanged(new, old)
        local cursor = new and new:GetCursor() or "none"
        if cursor == self.LastCursor then
            return
        end
        self.LastCursor = cursor
        
        Interface.VGUI:SetCursor(cursor)
    end

    Interface.VGUI = vgui.Create("EditablePanel")
    function Interface.VGUI:PerformLayout(w, h)
        self:SetSize(ScrW(), ScrH())
    end

    function Interface.VGUI:Paint(w, h)
        Interface.BasePanel:Paint()
    end

    function Interface.VGUI:OnCursorEntered()
        Interface.BasePanel:OnCursorEntered()
    end

    function Interface.VGUI:OnCursorMoved(x, y)
        return Interface.BasePanel:OnCursorMoved(x, y)
    end

    function Interface.VGUI:OnCursorExited()
        return Interface.BasePanel:OnCursorExited()
    end

    function Interface.VGUI:OnMousePressed(button)
        return Interface.BasePanel:OnMousePressed(button)
    end

    function Interface.VGUI:OnMouseReleased(button)
        return Interface.BasePanel:OnMouseReleased(button)
    end

    function Interface.VGUI:OnMouseWheeled(delta)
        return Interface.BasePanel:OnMouseWheeled(delta)
    end
end

-- XML
do
    local parser = {}
    function parser:starttag(el, start, fin)
        local vguiElement = {}
        vguiElement.Tag = el.name
        vguiElement.Start = start
        vguiElement.Finish = fin
        vguiElement.Attributes = el.attrs
        vguiElement.Children = {}
        vguiElement.Parent = self.top

        local current = self.stack[#self.stack]
        if current then
            table.insert(current.Children, vguiElement)
        end

        table.insert(self.stack, vguiElement)
        self.top = vguiElement
    end

    function parser:endtag(el, s)        
        -- Create children here.
        table.remove(self.stack, #self.stack)
        self.top = self.stack[#self.stack]
    end

    function parser:text(text)
        local cp = vgui.GetControlTable(self.top.Tag)
        if cp and cp.ParseXMLText then
            self.top.Attributes = self.top.Attributes or {}
            cp:ParseXMLText(self.top, text)
        else
            local el = { name = "Text", attrs = { { Name = "Value", Value = string.Trim(text) } } }
            self:starttag(el)
            self:endtag(el)
        end
    end
    parser.__index = parser


    
    local function SmartCompileString(str, name, key)
        str = string.Trim(str)
        if istable(name) then
            name = string.format("%s[%s][%s]", name:GetType():GetName(), name:GetName() or "", key)
        end

        if string.StartsWith(str, "function ") or string.StartsWith(str, "function(") then
            return CompileString("return " .. str, name, true)()
        else
            return CompileString("return " .. str, name, true)
        end
    end


    function Interface.ParseXML(xml)
        local p = setmetatable({}, parser)
        p.root = {
            Children = {}
        }

        p.stack = { p.root }
        p.top = p.root
        local eval = xml2lua.parser(p, {
            --Indicates if whitespaces should be striped or not
            stripWS = 0,
            expandEntities = 1,
            errorHandler = function(errMsg, pos) 
                if pos then
                    local ln_start
                    local ln_end

                    for i=pos, 1, -1 do
                        if xml[i] == "\n" then
                            ln_start = i
                            break
                        end
                    end

                    for i=pos, #xml do
                        if xml[i] == "\n" then
                            ln_end = i - 1
                            break
                        end
                    end

                    local ln = string.sub(xml, ln_start or 1, ln_end or #xml)
                    error(string.format("%s [char=%d; %s]\n", errMsg or "Parse Error", pos, ln))
                else
                    error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos)) 
                end
            end
        })

        eval:parse(xml)

        return p.top
    end

    local function SetProp(pnl, key, value)
        local setter = pnl["Set" .. key]
        if setter then
            setter(pnl, value)
        else
            pnl[key] = value
        end
    end

    hook.Add("Interface.XMLParseNamespace", function (self, namespace, key, value)
        if namespace == "Computed" then
            self:SetComputed(key, SmartCompileString(value, self, key))
            return false
        elseif namespace == "Hover" then
            local value, duration, easeFunc = unpack(string.Split(value, ","))
            
            assert(value, "Hover properties must have a value: " .. key)
            duration = tonumber(duration)
            if easeFunc then
                easeFunc = math.ease[string.Trim(easeFunc)]
            end

            local prop = self:GetType():GetProperty(key)
            value = prop.Type:Parse(value)

            self:SetHover(key, value, duration, easeFunc)

            return false
        elseif isany(namespace, "Func", "Function") then
            local func = SmartCompileString(value, self, key)
            if not isfunction(func) then
                error(string.format("Parsed function for '%s' is not a function (got %s)", key, type(func)))
            end

            self[key] = func
            return false
        end

        local typ = Type.GetByName(namespace)
        if typ then
            local parsed = typ:Parse(value)
            return true, parsed
        end
    end)
        
    function Interface.CreateFromNode(parent, node)    
        local pnl = Interface.Create(node.Tag, parent)

        if node.Attributes then
            ApplyProperties(pnl, node)
        end

        for k, v in pairs(node.Children) do
            Interface.CreateFromNode(pnl, v)
        end

        return pnl
    end

    function Interface.CreateFromXML(parent, xml)
        assert(xml, "XML string cannot be nil")
        local parsed = Interface.ParseXML(xml)

        local out = {}
        for k, v in pairs(parsed.Children) do
            local el = Interface.CreateFromNode(parent, v)
            if el then
                table.insert(out, el)
            end
        end

        return unpack(out)
    end

    function Interface.RegisterFromXML(name, xml)
        assert(name, "Name cannot be nil")
        assert(xml, "XML string cannot be nil")
        local parsed = Interface.ParseXML(xml)
        
        assert(#parsed.Children == 1, "Root XML element must have exactly one child")
        parsed = parsed.Children[1]

        local out = Interface.Register(name, parsed.Tag)
        out.XML = parsed
        return out
    end
end

Interface.RegisterFromXML("TestInside", [[
    <Panel Align="1" Direction="RIGHT" Gap="16">
        <Panel Name="Left" Width="128" Height="128" Fill="255 0 255 255" />
        <Panel Name="Mid" Width="Grow" Height="128" Padding="16" Hoverable="true" Fill="255 255 255 255" Alpha="32" Hover:Alpha="255, 0.25" Align="5"
            Func:LeftClick="function (self, src)
                ClickSound()
                self:Find('Overlay'):Toggle()
                return true
            end"
        >
            <Panel Name="Grandchild" Width="64" Height="64" Fill="255 255 0 255" Hoverable="true">
            </Panel>
            <Overlay 
                Name="Overlay"
                :Y="self:GetParent():GetHeight()" 
                :Width="self:GetParent():GetWidth()"
                :Shape="RoundedBox(self:GetWidth(), self:GetHeight(), 0, 0, 16, 16)"
                Fill="0 0 0 128" 
                ShowOnHover="false"
                PaddingBottom="16"
                Hoverable="true"
                Align="8"
                Direction="Down"
                Gap="8"
            >
                <Panel Width="100%" Fill="255 0 0 128" Hoverable="true" Hover:Fill="255 255 255 128, 0.2">
                    <Text Value="Test" />
                </Panel>
                <Panel Width="100%" Fill="255 0 0 128" Hoverable="true" Hover:Fill="255 255 255 128, 0.2">
                    <Text Value="Test" />
                </Panel>
                <Panel Width="100%" Fill="255 0 0 128" Hoverable="true" Hover:Fill="255 255 255 128, 0.2">
                    <Text Value="Test" />
                </Panel>
            </Overlay>
        </Panel>
        <Panel Name="Right" Width="128" Height="128" Fill="0 255 255 255" />
    </Panel>
]])

p = Interface.CreateFromXML(nil, [[
    <Panel 
        Name="Test" 
        :X="self:GetParent():GetWidth() / 2 - self:GetOuterWidth() / 2"
        :Y="self:GetParent():GetHeight() / 2 - self:GetOuterHeight() / 2"
        :Shape="RoundedBox(self:GetWidth(), self:GetHeight(), 64, 64, 64, 64)"
        :Material="RadialGradient(
            Color(0, 14, 30, 255),
            0.3,
            Color(0, 14, 30, 255),
            0.9,
            Color(0, 3, 10, 255)
        )"
        Fill="255 255 255 255"
        Align="5" 
        Direction="RIGHT" 
        Cursor="hand" 
        Width="800" 
        Height="600" 
        Margin="16"
        Padding="32" 
        Hoverable="true" 
        Alpha="225" 
        Stroke="8"
        :StrokeMaterial="LinearGradient(
            Color(255, 60, 60, 192),
            1,
            Color(40, 42, 46, 0),
            90
        )"
        Gap="16"
    >
        <TestInside Width="100%" Height="100%" />
    </Panel>
]])