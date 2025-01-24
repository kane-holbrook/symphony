AddCSLuaFile()

if SERVER then
    return
end

drawex = {}

function drawex.Stencil(drawFunc, stencil, invert, maskColor)
    maskColor = maskColor or color_black

    render.SetStencilEnable(true)

    render.ClearStencil()
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)

    render.SetStencilReferenceValue(9)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)

    surface.SetDrawColor(maskColor)
    stencil()

    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilCompareFunction(invert and STENCILCOMPARISONFUNCTION_NOTEQUAL or STENCILCOMPARISONFUNCTION_EQUAL)

    surface.SetDrawColor(255, 255, 255, 255)
    draw.NoTexture()
    drawFunc()

    render.SetStencilEnable(false)
end


function drawex.RenderMaterial(shader, w, h, func, materialData, uid, rt_size, material_depth, texture_flags, rt_flags, image_format)
    uid = uid or uuid()
    rt_size = rt_size or RT_SIZE_LITERAL
    material_depth = material_depth or MATERIAL_RT_DEPTH_SHARED
    texture_flags = texture_flags or 8192
    rt_flags = rt_flags or 0
    image_format = image_format or IMAGE_FORMAT_RGBA16161616
    
    local mat = CreateMaterial(uid, shader, materialData)
    mat:GetInt("_loading", 1)

    hook.Add("PostRender", uid, function ()   
        local data = nil

        local rt = GetRenderTargetEx(uid, w, h, rt_size, material_depth, texture_flags, rt_flags, image_format)

        render.PushRenderTarget(rt)
            render.OverrideAlphaWriteEnable(true, true)
            render.ClearDepth()
            render.Clear(0, 0, 0, 0)

                cam.Start2D()
                local succ, msg = pcall(func, w, h, mat)
                cam.End2D()

                if not succ then
                    ErrorNoHaltWithStack(msg)
                end
            render.OverrideAlphaWriteEnable( false )

        render.PopRenderTarget()

        mat:SetTexture("$basetexture", rt)
        timer.Simple(0, function ()
            mat:GetInt("_loading", 0)
        end)
        hook.Remove("PostRender", uid)
    end)
    return mat
end

local RoundedBoxCache = weaktable(false, true)
function drawex.RoundedBox(x, y, w, h, tl, tr, br, bl, sz)
    local key = table.concat({x, y, w, h, tl, tr, br, bl, sz}, ":")
    if RoundedBoxCache[key] then
        return RoundedBoxCache[key], key
    end

    -- Top left
    local tx, ty = x + w/2, y + h/2
    local t = {}
    
    table.insert(t, { x = x, y = y + tl })
    
    local sz = sz or 8
    for i = 1, sz do
        local ang = 90/sz * i
        local x2 = math.cos(math.rad(ang)) * tl
        local y2 = math.sin(math.rad(ang)) * tl

        table.insert(t, { x = x + tl - x2, y = y + tl - y2 })
    end
    
    table.insert(t, { x = x + w-tr, y = y })
    
    for i = 1, sz do
        local ang = 90 + 90/sz * i
        local x2 = math.cos(math.rad(ang)) * tr
        local y2 = math.sin(math.rad(ang)) * tr

        table.insert(t, { x = x + w - tr - x2, y = y + tr - y2 })
    end
    
    table.insert(t, { x = x + w, y = y + h - br })

    for i = 1, sz do
        local ang = 0 + 90/sz * i
        local x2 = math.cos(math.rad(ang)) * br
        local y2 = math.sin(math.rad(ang)) * br

        table.insert(t, { x = x + w - br + x2, y = y + h - br + y2 })
    end
    
    table.insert(t, { x = x + bl, y = y + h })
              
    for i = 1, sz do
        local ang = 90 + 90/sz * i
        local x2 = math.cos(math.rad(ang)) * bl
        local y2 = math.sin(math.rad(ang)) * bl

        table.insert(t, { x = x + bl + x2, y = y + h - bl + y2 })
    end

    RoundedBoxCache[key] = t
    return t
end


local RoundedBoxMaterialCache = weaktable(false, true)
function drawex.DrawPolyRoundedBox(x, y, w, h, tl, tr, br, bl, sz)
    local key = table.concat({x, y, w, h, tl, tr, br, bl, sz}, ":")
    
    local mat = RoundedBoxMaterialCache[key] 
    if mat then
        if mat:GetInt("_loading") == 1 then
            return false
        else
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(x, y, w, h)
            return mat
        end
    end

    local t = drawex.RoundedBox(0, 0, w, h, tl, tr, br, bl, sz)
    mat = drawex.RenderMaterial("UnlitGeneric", sz, sz, function (w, h)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawPoly(t)
    end, { ["$translucent"] = 1 })

    RoundedBoxMaterialCache[key] = mat
    return mat
end


local PolygonCache = weaktable(false, true)
function drawex.Polygon(x, y, sz, sides)
    local key = table.concat({x, y, sz, sides}, ":")
    if PolygonCache[key] then
        return PolygonCache[key]
    end

    -- Top left
    local tx, ty = x + sz/2, y + sz/2
    local t = {}
    
    local len = 360/sides
    print(sz,sides, len)

    for i = 1, sides do
        local ang = len * i
        local x2 = math.cos(math.rad(ang)) * sz/2
        local y2 = math.sin(math.rad(ang)) * sz/2

        table.insert(t, { x = tx + x2, y = ty + y2 })
    end

    PolygonCache[key] = t
    return t
end


local PolygonCacheMaterialCache = weaktable(false, true)
function drawex.DrawPolygon(x, y, sz, sides, rot)
    
    rot = rot or 0
    
    local key = table.concat({x, y, sz, sides}, ":")
    local mat = PolygonCacheMaterialCache[key] 
    if mat then
        if mat:GetInt("_loading") == 1 then
            return false
        else
            surface.SetMaterial(mat)
            surface.DrawTexturedRectRotated(x, y, w, h, rot)
            return mat
        end
    end

    local t = drawex.Polygon(0, 0, sz, sides)
    mat = drawex.RenderMaterial("UnlitGeneric", sz, sz, function (w, h)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawPoly(t)
    end, { ["$translucent"] = 1 })

    PolygonCacheMaterialCache[key] = mat
    return mat
end