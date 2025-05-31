AddCSLuaFile()
if SERVER then
    return
end

local FONTS = FONTS or {}
function Interface.Font(font, sz, weight)

    if isnumber(font) then
        sz = font
        font = nil
    end

    local ratio = ScrH()/480

    local wp = vgui.GetWorldPanel()
    font = font or "Tahoma"
    sz = sz or 4.5
    weight = weight or 400

    local key = font .. ":" .. sz .. ":" .. weight
    if FONTS[key] then
        return key
    end

    surface.CreateFont(key, {
        font = font,
        size = sz * ratio,
        weight = weight,
        antialias = true
    })

    FONTS[key] = true

    return key
end

hook.Add("OnScreenSizeChanged", "symphony/interface/2d/fonts.lua", function ()
    FONTS = {}
end)