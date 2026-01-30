AddCSLuaFile()

if SERVER then
    return
end

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

    return function (pnl, w, h) 
        
        Radial:SetFloat("$c0_x", math.Round(color1.r / 255, dp))
        Radial:SetFloat("$c0_y", math.Round(color1.g / 255, dp))
        Radial:SetFloat("$c0_z", math.Round(color1.b / 255, dp))
        Radial:SetFloat("$c0_w", math.Round(color1.a / 255, dp))
        
        Radial:SetFloat("$c1_x", math.Round(color2.r / 255, dp))
        Radial:SetFloat("$c1_y", math.Round(color2.g / 255, dp))
        Radial:SetFloat("$c1_z", math.Round(color2.b / 255, dp))
        Radial:SetFloat("$c1_w", math.Round(color2.a / 255, dp))

        Radial:SetFloat("$c2_x", math.Round(color3.r / 255, dp))
        Radial:SetFloat("$c2_y", math.Round(color3.g / 255, dp))
        Radial:SetFloat("$c2_z", math.Round(color3.b / 255, dp))
        Radial:SetFloat("$c2_w", math.Round(color3.a / 255, dp))
        
        Radial:SetFloat("$c3_x", math.Round(offset1, dp))
        Radial:SetFloat("$c3_y", math.Round(offset2, dp))

        return Radial
    end
end

LG_OFFSET = 0

-- Factory: returns a paint‐closure
-- rotDeg: 0 = left→right, 90 = bottom→top
local mat = Material("sstrp25/shaders/lineargradientv2")
function LinearGradient(col1, off1, col2, off2, col3, rotDeg)
    
    local colA = col1
    local colB = col3 or colA
    
    local rad = math.rad((rotDeg or 0) + LG_OFFSET)

    return function(pnl, w, h)
        -- aspect-correct the direction in UV space
        local ax = w / math.max(h, 1)
        local dx, dy = math.Round(math.cos(rad), 2), math.Round(math.sin(rad), 2)
        local len = math.sqrt(dx*dx + dy*dy)
        if len > 0 then dx, dy = dx/len, dy/len end

        -- colours
        mat:SetFloat("$c0_x", colA.r/255) mat:SetFloat("$c0_y", colA.g/255)
        mat:SetFloat("$c0_z", colA.b/255) mat:SetFloat("$c0_w", colA.a/255)
        mat:SetFloat("$c1_x", colB.r/255) mat:SetFloat("$c1_y", colB.g/255)
        mat:SetFloat("$c1_z", colB.b/255) mat:SetFloat("$c1_w", colB.a/255)

        -- pack direction (xy); the shader ignores z/w now
        mat:SetFloat("$c3_x", dx)
        mat:SetFloat("$c3_y", dy)
        mat:SetFloat("$c3_z", 0)
        mat:SetFloat("$c3_w", 0)

        return mat
    end
end

--[[
local mat = Material("sstrp25/shaders/lineargradient")
function LinearGradient(col1, off1, col2, off2, col3, rotDeg)

    off1 = off1 or 0.25
    off2 = off2 or 0.75
    col2 = col2 or col1
    col3 = col3 or col2

    return function(pnl, w, h)

        local rad = math.rad((rotDeg or 0) + LG_OFFSET)
        local dx, dy = math.Round(math.cos(rad), 2), math.Round(math.sin(rad), 2)

        -- set your three colors
        mat:SetFloat("$c0_x", math.Round(col1.r/255, dp))
        mat:SetFloat("$c0_y", math.Round(col1.g/255, dp))
        mat:SetFloat("$c0_z", math.Round(col1.b/255, dp))
        mat:SetFloat("$c0_w", math.Round(col1.a/255, dp))

        mat:SetFloat("$c1_x", math.Round(col2.r/255, dp))
        mat:SetFloat("$c1_y", math.Round(col2.g/255, dp))
        mat:SetFloat("$c1_z", math.Round(col2.b/255, dp))
        mat:SetFloat("$c1_w", math.Round(col2.a/255, dp))

        mat:SetFloat("$c2_x", math.Round(col3.r/255, dp))
        mat:SetFloat("$c2_y", math.Round(col3.g/255, dp))
        mat:SetFloat("$c2_z", math.Round(col3.b/255, dp))
        mat:SetFloat("$c2_w", math.Round(col3.a/255, dp))

        -- pack direction in .x/.y, thresholds in .z/.w
        mat:SetFloat("$c3_x", dx)
        mat:SetFloat("$c3_y", dy)
        mat:SetFloat("$c3_z", off1)
        mat:SetFloat("$c3_w", off2)


        return mat
    end
end--]]
