AddCSLuaFile()

colorex = {}

local COLOR = FindMetaTable("Color")
local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function RgbToHsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    local h, s, v = 0, 0, max
    
    if max ~= 0 then
        s = delta / max
    else
        return 0, 0, 0
    end

    if r == max then
        h = (g - b) / delta
    elseif g == max then
        h = 2 + (b - r) / delta
    else
        h = 4 + (r - g) / delta
    end

    h = h * 60
    if h < 0 then h = h + 360 end
    return h, s, v
end

function HsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h / 60) % 6
    local f = h / 60 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

function RgbToHsl(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2

    if max == min then
        h, s = 0, 0
    else
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, l
end

function HslToRgb(h, s, l)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return r, g, b
end

-- Color manipulation methods
function COLOR:Brighten(percent)
    local factor = 1 + percent 
    return Color(clamp(self.r * factor, 0, 255), clamp(self.g * factor, 0, 255), clamp(self.b * factor, 0, 255), self.a)
end

function COLOR:Darken(percent)
    local factor = 1 - percent
    return Color(clamp(self.r * factor, 0, 255), clamp(self.g * factor, 0, 255), clamp(self.b * factor, 0, 255), self.a)
end

function COLOR:Saturate(percent)
    local h, s, v = RgbToHsv(self.r / 255, self.g / 255, self.b / 255)
    s = clamp(s + percent / 100, 0, 1)
    self.r, self.g, self.b = HsvToRgb(h, s, v)
    self.r, self.g, self.b = self.r * 255, self.g * 255, self.b * 255
    return self
end

function COLOR:Desaturate(percent)
    self:Saturate(-percent)
    return self
end

function COLOR:Invert()
    self.r = 255 - self.r
    self.g = 255 - self.g
    self.b = 255 - self.b
    return self
end

function COLOR:Grayscale()
    local gray = 0.3 * self.r + 0.59 * self.g + 0.11 * self.b
    self.r, self.g, self.b = gray, gray, gray
    return self
end

function COLOR:Blend(otherColor, percent)
    local factor = percent / 100
    self.r = self.r * (1 - factor) + otherColor.r * factor
    self.g = self.g * (1 - factor) + otherColor.g * factor
    self.b = self.b * (1 - factor) + otherColor.b * factor
    return self
end

function COLOR:SetAlpha(alpha)
    self.a = clamp(alpha, 0, 255)
    return self
end

function COLOR:GetComplementary()
    return Color(255 - self.r, 255 - self.g, 255 - self.b, self.a)
end

function COLOR:ToHex()
    return string.format("#%02X%02X%02X%02X", self.r, self.g, self.b, self.a)
end

function colorex.FromHex(hexString)
    local r, g, b, a = hexString:match("#?(%x%x)(%x%x)(%x%x)(%x?%x?)")
    if not r or not g or not b then
        return nil
    end
    
    return Color(
        tonumber(r, 16),
        tonumber(g, 16),
        tonumber(b, 16),
        tonumber(a, 16) or 255
    )
end

function COLOR:ToRGB()
    return self.r, self.g, self.b
end

function colorex.FromRGB(r, g, b)
    self.r = clamp(r, 0, 255)
    self.g = clamp(g, 0, 255)
    self.b = clamp(b, 0, 255)
end

function COLOR:ToHSV()
    local h, s, v = RgbToHsv(self.r / 255, self.g / 255, self.b / 255)
    return h, s * 100, v * 100
end

function colorex.FromHSV(h, s, v)
    local r, g, b = HsvToRgb(h, s / 100, v / 100)
    self.r, self.g, self.b = r * 255, g * 255, b * 255
end

function COLOR:ToHSL()
    local h, s, l = RgbToHsl(self.r / 255, self.g / 255, self.b / 255)
    return h * 360, s * 100, l * 100
end

function colorex.FromHSL(h, s, l)
    local r, g, b = HslToRgb(h / 360, s / 100, l / 100)
    self.r, self.g, self.b = r * 255, g * 255, b * 255
end