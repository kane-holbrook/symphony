AddCSLuaFile()

sym.ui = {}
sym.ui.MaterialQueue = sym.queue()

local MATCACHE = {}
local MATQUEUE = sym.ui.MaterialQueue

local SYMMAT = sym.RegisterType("proceduralmaterial")
SYMMAT:AddProperty("Parent")
SYMMAT:AddProperty("Pos", sym.types.vector)
SYMMAT:AddProperty("Size", sym.types.vector)
SYMMAT:AddProperty("Shader", sym.types.string, { Default = "UnlitGeneric" })
SYMMAT:AddProperty("Path", sym.types.string)
SYMMAT:AddProperty("Parameters", sym.types.table, { Default = { ["$translucent"] = 1 } })
SYMMAT:AddProperty("Layers", sym.types.table, { Default = {} })
SYMMAT:AddProperty("RtSize", sym.types.number, { Default = RT_SIZE_LITERAL })
SYMMAT:AddProperty("MaterialDepth", sym.types.number, { Default = MATERIAL_RT_DEPTH_SHARED })
SYMMAT:AddProperty("TextureFlags", sym.types.number, { Default = 8192 })
SYMMAT:AddProperty("RtFlags", sym.types.number, { Default = 0 })
SYMMAT:AddProperty("ImageFormat", sym.types.number, { Default = IMAGE_FORMAT_RGBA16161616 })

function SYMMAT:Init(out)
    out.ready = sym.promise()
    if CLIENT then
        out.dirty = true
        out.OnPropChanged:Hook(function (ev, ...) self:MarkDirty() end)
        out.OnComplete = sym.event()
    end

    return out
end

function SYMMAT:__gc()
    print("SYMMAT GC")
end

function SYMMAT:Set(key, value)
    self:GetParameters()[key] = value
end

function SYMMAT:Get(key)
    return self:GetParameters()[key]
end

function SYMMAT:GetParameters()
    return self:GetProperty("Parameters")
end

function SYMMAT:Add(layer, order)
    assert(sym.IsType(layer, SYMMAT), "Layer must be a function, SYMMAT or derivative.")
    assert(layer ~= self, "Cannot add self as a layer, you dipshit.")
    
    local layers = self:GetLayers()
    order = order or #layers + 1

    table.insert(layers, order, layer)
end

function SYMMAT:SetAlpha(alpha, bNoSetParam)
    self:GetMaterial():SetFloat("$alpha", alpha)
    if not bNoSetParam then
        self:GetParameters()["$alpha"] = alpha
    end
end

function SYMMAT:GetAlpha()
    return IsValid(self:GetMaterial()) and self:GetFloat("$alpha") or self:GetParameters()["$alpha"] or 1
end

function SYMMAT:FadeIn(time)
    local start = CurTime()
    local fin = start + time
    hook.Add("Think", self:GetObjectId(), function ()
        local ct = CurTime()
        local e = ct - start
        local dur = fin - start
        local progress = math.Clamp(e/dur, 0, 1)

        self:SetAlpha((self:GetParameters()["$alpha"] or 1) * progress, true)

        if progress == 1 then
            hook.Remove("Think", self:GetObjectId())
        end
    end)
end


function SYMMAT:FadeOut(time)
    local start = CurTime()
    local fin = start + time
    hook.Add("Think", self:GetObjectId(), function ()
        local ct = CurTime()
        local e = ct - start
        local dur = fin - start
        local progress = math.Clamp(e/dur, 0, 1)

        self:SetAlpha(1 - (self:GetParameters()["$alpha"] or 1) * progress, true)

        if progress == 1 then
            hook.Remove("Think", self:GetObjectId())
        end
    end)
end

function SYMMAT:Remove(layer)
    if isnumber(layer) then
        table.remove(self:GetLayers(), layer)
    else
        table.RemoveByValue(self:GetLayers(), layer)
    end
end

function SYMMAT:Generate(regenerate, parent)
    local p = sym.promise()
    p.symmat = self
    
    if not self:IsDirty() and not regenerate then
        p:Complete(self:GetMaterial())
        return self, p
    end
    self.dirty = false
    self.generating = true
    local mat = self:GetMaterial()

    p:SetFunction(function ()
        local skip = false
        for k, v in pairs(self:GetLayers()) do
            if v.MustGenerate and v.dirty then
                if not v.generating then
                    local _, p = v:Generate(nil, self)
                    p:Await()
                end 
            end
        end
        
        local rt_size = RT_SIZE_LITERAL
        local material_depth = MATERIAL_RT_DEPTH_SHARED
        local texture_flags = 8192
        local rt_flags = 0
        local image_format = IMAGE_FORMAT_RGBA16161616
        local sz = self:GetSize() 
        if not sz then
            sz = Vector(ScrW(), ScrH())
        end

        cam.Start2D()
            local rt = GetRenderTargetEx(self:GetObjectId(), sz.x, sz.y, rt_size, material_depth, texture_flags, rt_flags, image_format)
            render.PushRenderTarget(rt)
                render.OverrideAlphaWriteEnable(true, true)
                render.ClearDepth()
                render.Clear(255, 255, 255, 0)
                    local succ, data = pcall(self.Draw, self, nil, sz.x, sz.y)
                    if not succ then
                        ErrorNoHaltWithStack(data)
                    end
                render.OverrideAlphaWriteEnable( false )
            render.PopRenderTarget()
        cam.End2D()

        mat:SetTexture("$basetexture", rt)
        
        local param = self:GetParameters()
        self:SetAlpha(param["$alpha"] or 1)

        for k, v in pairs(param) do
            mat:SetKeyValue(k, v)
        end

        self.generating = false
        self.Generated = true

        return mat
    end)

    local idx = MATQUEUE:enqueue(p)

    return self, p
end


function SYMMAT:IsGenerating()
    return self.generating
end

function SYMMAT:IsGenerated()
    return self.Generated
end


-- @notworking
function SYMMAT:Capture(format, quality)
    assert(self.Generated, "Attempt to ToPNG a non-generated procedural material.")

    format = format or "png"

    local rt_size = self:GetRtSize()
    local material_depth = self:GetMaterialDepth()
    local texture_flags = self:GetTextureFlags()
    local rt_flags = self:GetRtFlags()
    local image_format = self:GetImageFormat()
    local sz = self:GetSize() or Vector(ScrW(), ScrH())

    local data
    cam.Start2D()
        local rt = GetRenderTargetEx(self:GetObjectId() .. "-CAPTURE", sz.x, sz.y, rt_size, material_depth, texture_flags, rt_flags, image_format)
        render.PushRenderTarget(rt)
            render.OverrideAlphaWriteEnable(true, true)
            render.Clear(255, 255, 0, 0)

                surface.SetMaterial(self:GetMaterial())
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(0, 0, sz.x, sz.y)

                data = render.Capture({
                    format = format,
                    x = 0,
                    y = 0,
                    w = sz.x,
                    h = sz.y,
                    alpha = false
                })
                
            render.OverrideAlphaWriteEnable( false )
        render.PopRenderTarget()
    cam.End2D()

    return data
end

function SYMMAT:GetMaterial()
    if not self.material then
        self.material = CreateMaterial(self:GetObjectId(), self:GetShader(), self:GetParameters())
        self.material:SetFloat("$alpha", 0)
    end
    
    return self.material
end

function SYMMAT:Draw(parent, w, h)
    local path = self:GetPath()
    if path then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material(path))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    for k, v in pairs(self:GetLayers()) do
        if v.Generated then
            local mat = v:GetMaterial()
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, w, h)
        else
            v:Draw(self, w, h)
        end
    end
end


function SYMMAT:MarkDirty()
    self.dirty = true
end

function SYMMAT:IsDirty()
    return self.dirty
end

function SYMMAT:VGUI()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(self:GetObjectId())
    local w, h = ScrW(), ScrH()
    if self:GetSize() then
        w = self:GetSize().x
        h = self:GetSize().y
    end
    w = math.min(w, ScrW() * 0.9)
    h = math.min(h, ScrH() * 0.9)
    frame:SetSize(w, h)
    frame:Center()

    local p = vgui.Create("Panel", frame)
    p:Dock(FILL)
    function p.Paint(panel, w, h)
        surface.SetMaterial(self:GetMaterial())
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    frame:MakePopup()

    if self:IsDirty() then
        self:Generate()
    end
end

function SYMMAT:OnScreenSizeChanged(func)
    hook.Add("OnScreenSizeChanged", self:GetObjectId(), function ()
        func(self)
    end)
end

function SYMMAT:OnDisposed()
    hook.Remove("OnScreenSizeChanged", self:GetObjectId())
end

function SYMMAT:AddMaterial(path, pos, size, rot, order)
    local img = sym.types.mat_local()
    img:SetPath(path)
    img:SetPos(pos)
    img:SetSize(size)
    img:SetRotation(rot)
    self:Add(img)
    self:MarkDirty()
    return self, img
end

function SYMMAT:AddWebImage(path, pos, size, rotation, order)
    -- @todo
end

function SYMMAT:AddRect(pos, size, color, rotation, order)
    local f = sym.types.mat_rect
    f:SetPos(pos)
    f:SetSize(size)
    f:SetColor(color)
    f:SetRotation(rotation)

    self:Add(f)
    self:MarkDirty()
    return self
end


function SYMMAT:AddBoxGradient(stops)
    local box = sym.types.mat_boxgradient()
    box:SetStops(stops)
    self:Add(box)
    self:MarkDirty()
    return self, box
end

function SYMMAT:AddLinearGradient(stops, pos, size, rot, order)
    local grad = sym.CreateUninitializedInstance(sym.types.mat_lineargradient)
    rot = rot or 0

    grad:SetPos(x, y)
    grad:SetStops(stops)
    grad:SetRotation(rot)
    grad:SetParameters({
        ["$translucent"] = 1,
        ["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate " .. rot .. " translate 0 0"
    })
    
    sym.types.mat_lineargradient:Init(grad)

    self:Add(grad)
    self:MarkDirty()
    return self, grad
end

function SYMMAT:AddFunction(func, order)
    local f = sym.types.mat_function
    f.func = func

    self:Add(f)
    self:MarkDirty()
    return self
end


local FUNCMAT = sym.RegisterType("mat_function", SYMMAT)
function FUNCMAT:Draw(parent, w, h)
    return self.func(w, h, parent)
end

local LOCALMAT = sym.RegisterType("mat_local", SYMMAT)
LOCALMAT:AddProperty("Rotation", sym.types.number, { Default = 0 })

function LOCALMAT:Draw(parent, w, h)
    local mat = Material(self:GetPath())
    
    local pos = self:GetPos() or Vector(0, 0)
    local sz = self:GetSize() or Vector(mat:Width(), mat:Height())
    local rotation = self:GetRotation() or 0

    local x, y = pos.x, pos.y
    local w2, h2 = sz.x, sz.y
    if w2 < 1 then
        x = w * x
        y = h * y
        w2 = w * w2
        h2 = h * h2
    end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x + w2/2, y + h2/2, w2, h2, rotation)
end


local RECT = sym.RegisterType("mat_rect", SYMMAT)
RECT:AddProperty("Color", sym.types.color, { Default = color_white })
RECT:AddProperty("Rotation", sym.types.number, { Default = 0 })

function RECT:Draw(parent, w, h)    
    local pos = self:GetPos() or Vector(0, 0)
    local sz = self:GetSize() or Vector(w, h)
    local rotation = self:GetRotation() or 0
    local color = self:GetColor() or color_white

    local x, y = pos.x, pos.y
    local w2, h2 = sz.x, sz.y
    if w2 < 1 then
        x = w * x
        y = h * y
        w2 = w * w2
        h2 = h * h2
    end

    draw.NoTexture()
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x + w2/2, y + h2/2, w2, h2, rotation)
end

local CIRCLE = sym.RegisterType("mat_circle", SYMMAT)
CIRCLE:AddProperty("Color", sym.types.color, { Default = color_white })
CIRCLE:AddProperty("Rotation", sym.types.number, { Default = 0 })

function CIRCLE:Draw(parent, w, h)    
    error("mat_circle: not implemented")
end

local BOXGRADIENT = sym.RegisterType("mat_boxgradient", SYMMAT)
BOXGRADIENT:AddProperty("Stops", sym.types.table)

function BOXGRADIENT:Draw(parent, w, h)
    local args = self:GetStops()
    local stops = {}

    -- Process arguments two at a time: one for stop, one for color
    for i = 1, #args, 2 do
        local stop = args[i]
        local color = args[i + 1]
        table.insert(stops, {stop = stop, color = color})
    end

    local sz = math.min(w, h)/2 - 1

    for x = 1, sz do
        local progress = (x - 1) / (sz - 1)
        local prevStop, nextStop

        for i = 1, #stops - 1 do
            if progress >= stops[i].stop and progress <= stops[i + 1].stop then
                prevStop = stops[i]
                nextStop = stops[i + 1]
                break
            end
        end

        if prevStop and nextStop then
            local localProgress = (progress - prevStop.stop) / (nextStop.stop - prevStop.stop)
            local r = prevStop.color.r + (nextStop.color.r - prevStop.color.r) * localProgress
            local g = prevStop.color.g + (nextStop.color.g - prevStop.color.g) * localProgress
            local b = prevStop.color.b + (nextStop.color.b - prevStop.color.b) * localProgress
            local a = prevStop.color.a + (nextStop.color.a - prevStop.color.a) * localProgress

            surface.SetDrawColor(r, g, b, a)
            surface.DrawOutlinedRect(x, x, w-x*2, h-x*2, 1)
        end
    end
end


local LINEARGRADIENT = sym.RegisterType("mat_lineargradient", SYMMAT)
LINEARGRADIENT.MustGenerate = true
LINEARGRADIENT:AddProperty("Stops", sym.types.table)
LINEARGRADIENT:AddProperty("Rotation", sym.types.number, { Default = 0 })

function LINEARGRADIENT:Draw(parent, w, h)
    local args = self:GetStops()
    local stops = {}

    -- Process arguments two at a time: one for stop, one for color
    for i = 1, #args, 2 do
        local stop = args[i]
        local color = args[i + 1]
        table.insert(stops, {stop = stop, color = color})
    end

    for x = 1, w do
        local progress = (x - 1) / (w - 1)
        local prevStop, nextStop

        for i = 1, #stops - 1 do
            if progress >= stops[i].stop and progress <= stops[i + 1].stop then
                prevStop = stops[i]
                nextStop = stops[i + 1]
                break
            end
        end

        if prevStop and nextStop then
            local localProgress = (progress - prevStop.stop) / (nextStop.stop - prevStop.stop)
            local r = prevStop.color.r + (nextStop.color.r - prevStop.color.r) * localProgress
            local g = prevStop.color.g + (nextStop.color.g - prevStop.color.g) * localProgress
            local b = prevStop.color.b + (nextStop.color.b - prevStop.color.b) * localProgress
            local a = prevStop.color.a + (nextStop.color.a - prevStop.color.a) * localProgress

            surface.SetDrawColor(r, g, b, a)
            surface.DrawLine(x, 0, x, h)
        end
    end
    --end, { ["$translucent"] = 1, ["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate " .. rotation .. " translate 0 0" })

end

function LINEARGRADIENT:Generate(...)
    local p = self.__super.__super.Generate(self, regenerate, parent)
    print(p.Await)
    p.OnComplete:Hook(function (ev, mat)
        --print("LinearGradient", self:GetObjectId(), mat, self:GetRotation())
        mat:SetString("$basetexturetransform", "center .5 .5 scale 1 1 rotate " .. self:GetRotation() .. " translate 0 0")
        mat:Recompute()
    end, -9999)

    return self, p
end

function sym.CreateMaterial(id, shader, path)
    shader = shader or "UnlitGeneric"
    if id then
        local s = MATCACHE[id]
        if s then
            s:SetShader(shader)
            s:SetPath(path)
        end
        return s, true
    end

    local s = sym.CreateUninitializedInstance(SYMMAT)
    s:SetShader(shader)
    s:SetPath(path)
    SYMMAT:Init(s)
    return s, false
end

if CLIENT then
    hook.Add("Think", "SymphonyMaterialRenderQueue", function ()
        local n = 5

        for i=1, n do
            local p = MATQUEUE:dequeue()
            if p then
                if p:IsComplete() then
                    i = i - 1
                    sym.rdebug(PRINT_UI, LOG_DEBUG, "MATERIAL_GENERATE_SKIP", "Skipping custom material ", FromPrimitive(p.symmat:GetObjectId()), color_white, " as it has already completed (run synchronously?), ", FromPrimitive(MATQUEUE:count()), " left to generate.")
                    continue
                end

                p:Start()
            else
                return
            end
        end
    end)
end