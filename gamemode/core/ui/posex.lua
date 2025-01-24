AddCSLuaFile()

function SS(sz)
    return function ()
        return ScreenScale(sz)
    end
end

function SSH(sz)
    return function () 
        return ScreenScaleH(sz)
    end
end

function W(sz, offset)
    offset = offset or 0
    return function ()
        return Parent.Width * sz + offset
    end
end

function H(sz, offset)
    offset = offset or 0
    return function ()
        return Parent.Height * sz + offset
    end
end

function ABS(sz)
    return function ()
        return sz
    end
end

function CHRW(font, text)
    text = text or "0"
    return function ()
        local font = tostring(font)
        if not isstring(font) then
            return 0
        end
        
        local w, h = surface.GetTextSize(text)
        return w
    end
end

function CHRH(font, text)
    text = text or "0"
    return function ()
        local font = tostring(font)
        if not isstring(font) then
            return 0
        end

        surface.SetFont(font)
        local w, h = surface.GetTextSize(text)
        return h
    end
end
