AddCSLuaFile()
if SERVER then
    return
end

XVGUI_RENDER = XVGUI_RENDER or true 
XVGUI_RT_CACHE = XVGUI_RT_CACHE or {}

local BASE_MAT = FindMetaTable("IMaterial")

function BASE_MAT:IsXVGUI()
    return self.xvgui == true
end

local MAT = setmetatable({}, { 
    __index = BASE_MAT
})
MAT.__index = MAT
MAT.__gc = function (m)

    -- Release the RT
    if m.RT then
        XGUI_RT_CACHE[m:Width() .. ":" .. m:Height()] = self
    end

    BASE_MAT.__gc(m)
end

function xvgui.CreateMaterial(name, shaderName, materialData)
    local mat = CreateMaterial(name, shaderName, materialData)
    local mt = setmetatable({}, MAT)
    mt.__index = mt
    mt.__eq = BASE_MAT.__eq
    mt.__gc = BASE_MAT.__gc
    mt.__newindex = BASE_MAT.__newindex
    mt.__tostring = BASE_MAT.__tostring

    mt.xvgui = true
    mt.Children = {}
    mt.Callbacks = {}

    debug.setmetatable(mat, mt)

    return mat
end

function MAT:GetMetatable()
    return getmetatable(self)
end

function MAT:SetStencil(mat)
    local mt = self:GetMetatable()
    mt.Stencil = mat
end

function MAT:GetStencil()
    local mt = self.GetMetatable()
    return mt
end

function MAT:SetPaint(func)
    local mt = self:GetMetatable()
    mt.Paint = func
end

function MAT:GetCallbacks()
    local mt = self:GetMetatable()
    return mt.Callbacks
end

function MAT:AddCallback(func, name, ...)
    assert(func, "Function must be provided")

    local callbacks = self:GetCallbacks()
    return table.insert(callbacks, { func = func, name = name, data = {...} })
end

function MAT:RemoveCallback(name)
    local callbacks = self:GetCallbacks()
    for k, v in pairs(callbacks) do
        if callbacks.name == name then
            callbacks[k] = nil
            return true
        end
    end
    return false
end

function MAT:GetPaint()
    local mt = self:GetMetatable()
    return mt.Paint
end

function MAT:IsGenerating()
    local mt = self:GetMetatable()
    return mt.Generating
end

function MAT:GetTimeGenerated()
    local mt = self:GetMetatable()
    return mt.Generated
end

function MAT:IsGenerated()
    return self:GetGenerateTime() ~= nil
end

function MAT:AddChild(material, index)
    return table.insert(self:GetChildren(), index, material) 
end

function MAT:RemoveChild(material)
    table.RemoveByValue(self:GetChildren(), material)
end

function MAT:GetChildren()
    return self.Children
end

local RTCache = {}
function MAT:Generate(w, h)
    local mt = self:GetMetatable()
    mt.Generating = true

    local key = tostring(self) -- Always unique because it's userdata
    if not XVGUI_RENDER then
        hook.Add("PostRender", key, function () self:Generate(w, h) end)
        return
    end

    local rt_size = RT_SIZE_LITERAL
    local material_depth = MATERIAL_RT_DEPTH_SHARED
    local texture_flags = 8192
    local rt_flags = 0
    local image_format = IMAGE_FORMAT_RGBA8888
    

    local stencil = mt.Stencil
    local paint = mt.Paint

    local rt = self.RT
    if not self.RT then
        local key = w .. ":" .. h
        
        rt = XGUI_RT_CACHE[key]
        if rt then
            XVGUI_RT_CACHE[key] = nil
        else
            rt = GetRenderTargetEx(tostring(self), w, h, rt_size, material_depth, texture_flags, rt_flags, image_format)
        end         
        self.RT = rt
    end

    render.PushRenderTarget(rt)
        render.OverrideAlphaWriteEnable(true, true)
        render.ClearDepth()
        render.Clear(0, 0, 0, 0)

            cam.Start2D()
                
                surface.SetDrawColor(color_white)
                local succ, msg = true, nil
                if paint then
                    succ, msg = pcall(self:GetPaint(), w, h, self)
                end

                
                if stencil then
                    render.OverrideBlend(true, BLEND_SRC_ALPHA_SATURATE, BLEND_DST_ALPHA, BLENDFUNC_REVERSE_SUBTRACT)
                    draw.NoTexture()
                    surface.SetMaterial(stencil)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRectRotated(w/2, h/2, w/2, h/2, 0)
                    surface.DrawTexturedRectRotated(w/2, h/2, w/2, h/2, 90)
                    render.OverrideBlend(false)
                end
                

                if not succ then
                    ErrorNoHaltWithStack(msg)
                end

                if stencil then
                    render.SetStencilEnable(false)
                end
            cam.End2D()

        render.OverrideAlphaWriteEnable( false )
    render.PopRenderTarget()

    self:SetTexture("$basetexture", rt)

    for k, v in pairs(self:GetCallbacks()) do
        if v.data then
            v.func(self, unpack(v.data))
        else
            v.func(self)
        end
    end

    mt.Generating = false
    mt.Generated = CurTime()
    return true
end


xvgui_transparent = xvgui_transparent or xvgui.CreateMaterial("Transparent", "UnlitGeneric", { ["$translucent"] = 1 })
xvgui_transparent:SetPaint(function (w, h)
end)
xvgui_transparent:Generate(1, 1)

-- If we try to generate materials before the first render, it'll fail and they'll just be
-- white.
hook.Add("PostRender", "xvgui_material", function ()
    XVGUI_RENDER = true
    hook.Remove("PostRender", "xvgui_material")
end)