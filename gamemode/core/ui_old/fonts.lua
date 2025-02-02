AddCSLuaFile()

if SERVER then
    return
end

FONT_CACHE = FONT_CACHE or {}
function sym.Font(font, sz, weight)

    if isnumber(font) then
        sz = font
        font = nil
    end

    font = font or "Oxanium"
    sz = sz or 9
    weight = weight or 500

    local key = font .. ":" .. sz .. ":" .. weight
    if FONT_CACHE[key] then
        return key
    end

    surface.CreateFont(key, {
        font = font,
        size = ScreenScaleH(sz),
        weight = weight,
        antialias = true
    })

    FONT_CACHE[key] = true

    return key
end
