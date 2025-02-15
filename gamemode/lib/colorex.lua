AddCSLuaFile()

colorex = {}

colorex.Colors = {
    aliceblue = {0.94117647058824, 0.97254901960784, 1},
    antiquewhite = {0.98039215686275, 0.92156862745098, 0.84313725490196},
    aqua = {0, 1, 1},
    aquamarine = {0.49803921568627, 1, 0.83137254901961},
    azure = {0.94117647058824, 1, 1},
    beige = {0.96078431372549, 0.96078431372549, 0.86274509803922},
    bisque = {1, 0.89411764705882, 0.76862745098039},
    black = {0, 0, 0},
    blanchedalmond = {1, 0.92156862745098, 0.80392156862745},
    blue = {0, 0, 1},
    blueviolet = {0.54117647058824, 0.16862745098039, 0.88627450980392},
    brown = {0.64705882352941, 0.16470588235294, 0.16470588235294},
    burlywood = {0.87058823529412, 0.72156862745098, 0.52941176470588},
    cadetblue = {0.37254901960784, 0.61960784313725, 0.62745098039216},
    chartreuse = {0.49803921568627, 1, 0},
    chocolate = {0.82352941176471, 0.41176470588235, 0.11764705882353},
    coral = {1, 0.49803921568627, 0.31372549019608},
    cornflowerblue = {0.3921568627451, 0.5843137254902, 0.92941176470588},
    cornsilk = {1, 0.97254901960784, 0.86274509803922},
    crimson = {0.86274509803922, 0.07843137254902, 0.23529411764706},
    cyan = {0, 1, 1},
    darkblue = {0, 0, 0.54509803921569},
    darkcyan = {0, 0.54509803921569, 0.54509803921569},
    darkgoldenrod = {0.72156862745098, 0.52549019607843, 0.043137254901961},
    darkgray = {0.66274509803922, 0.66274509803922, 0.66274509803922},
    darkgreen = {0, 0.3921568627451, 0},
    darkgrey = {0.66274509803922, 0.66274509803922, 0.66274509803922},
    darkkhaki = {0.74117647058824, 0.71764705882353, 0.41960784313725},
    darkmagenta = {0.54509803921569, 0, 0.54509803921569},
    darkolivegreen = {0.33333333333333, 0.41960784313725, 0.1843137254902},
    darkorange = {1, 0.54901960784314, 0},
    darkorchid = {0.6, 0.19607843137255, 0.8},
    darkred = {0.54509803921569, 0, 0},
    darksalmon = {0.91372549019608, 0.58823529411765, 0.47843137254902},
    darkseagreen = {0.56078431372549, 0.73725490196078, 0.56078431372549},
    darkslateblue = {0.28235294117647, 0.23921568627451, 0.54509803921569},
    darkslategray = {0.1843137254902, 0.30980392156863, 0.30980392156863},
    darkslategrey = {0.1843137254902, 0.30980392156863, 0.30980392156863},
    darkturquoise = {0, 0.8078431372549, 0.81960784313725},
    darkviolet = {0.58039215686275, 0, 0.82745098039216},
    deeppink = {1, 0.07843137254902, 0.57647058823529},
    deepskyblue = {0, 0.74901960784314, 1},
    dimgray = {0.41176470588235, 0.41176470588235, 0.41176470588235},
    dimgrey = {0.41176470588235, 0.41176470588235, 0.41176470588235},
    dodgerblue = {0.11764705882353, 0.56470588235294, 1},
    firebrick = {0.69803921568627, 0.13333333333333, 0.13333333333333},
    floralwhite = {1, 0.98039215686275, 0.94117647058824},
    forestgreen = {0.13333333333333, 0.54509803921569, 0.13333333333333},
    fuchsia = {1, 0, 1},
    gainsboro = {0.86274509803922, 0.86274509803922, 0.86274509803922},
    ghostwhite = {0.97254901960784, 0.97254901960784, 1},
    gold = {1, 0.84313725490196, 0},
    goldenrod = {0.85490196078431, 0.64705882352941, 0.12549019607843},
    gray = {0.50196078431373, 0.50196078431373, 0.50196078431373},
    green = {0, 0.50196078431373, 0},
    greenyellow = {0.67843137254902, 1, 0.1843137254902},
    grey = {0.50196078431373, 0.50196078431373, 0.50196078431373},
    honeydew = {0.94117647058824, 1, 0.94117647058824},
    hotpink = {1, 0.41176470588235, 0.70588235294118},
    indianred = {0.80392156862745, 0.36078431372549, 0.36078431372549},
    indigo = {0.29411764705882, 0, 0.50980392156863},
    ivory = {1, 1, 0.94117647058824},
    khaki = {0.94117647058824, 0.90196078431373, 0.54901960784314},
    lavender = {0.90196078431373, 0.90196078431373, 0.98039215686275},
    lavenderblush = {1, 0.94117647058824, 0.96078431372549},
    lawngreen = {0.48627450980392, 0.98823529411765, 0},
    lemonchiffon = {1, 0.98039215686275, 0.80392156862745},
    lightblue = {0.67843137254902, 0.84705882352941, 0.90196078431373},
    lightcoral = {0.94117647058824, 0.50196078431373, 0.50196078431373},
    lightcyan = {0.87843137254902, 1, 1},
    lightgoldenrodyellow = {0.98039215686275, 0.98039215686275, 0.82352941176471},
    lightgray = {0.82745098039216, 0.82745098039216, 0.82745098039216},
    lightgreen = {0.56470588235294, 0.93333333333333, 0.56470588235294},
    lightgrey = {0.82745098039216, 0.82745098039216, 0.82745098039216},
    lightpink = {1, 0.71372549019608, 0.75686274509804},
    lightsalmon = {1, 0.62745098039216, 0.47843137254902},
    lightseagreen = {0.12549019607843, 0.69803921568627, 0.66666666666667},
    lightskyblue = {0.52941176470588, 0.8078431372549, 0.98039215686275},
    lightslategray = {0.46666666666667, 0.53333333333333, 0.6},
    lightslategrey = {0.46666666666667, 0.53333333333333, 0.6},
    lightsteelblue = {0.69019607843137, 0.76862745098039, 0.87058823529412},
    lightyellow = {1, 1, 0.87843137254902},
    lime = {0, 1, 0},
    limegreen = {0.19607843137255, 0.80392156862745, 0.19607843137255},
    linen = {0.98039215686275, 0.94117647058824, 0.90196078431373},
    magenta = {1, 0, 1},
    maroon = {0.50196078431373, 0, 0},
    mediumaquamarine = {0.4, 0.80392156862745, 0.66666666666667},
    mediumblue = {0, 0, 0.80392156862745},
    mediumorchid = {0.72941176470588, 0.33333333333333, 0.82745098039216},
    mediumpurple = {0.57647058823529, 0.43921568627451, 0.85882352941176},
    mediumseagreen = {0.23529411764706, 0.70196078431373, 0.44313725490196},
    mediumslateblue = {0.48235294117647, 0.4078431372549, 0.93333333333333},
    mediumspringgreen = {0, 0.98039215686275, 0.60392156862745},
    mediumturquoise = {0.28235294117647, 0.81960784313725, 0.8},
    mediumvioletred = {0.78039215686275, 0.082352941176471, 0.52156862745098},
    midnightblue = {0.098039215686275, 0.098039215686275, 0.43921568627451},
    mintcream = {0.96078431372549, 1, 0.98039215686275},
    mistyrose = {1, 0.89411764705882, 0.88235294117647},
    moccasin = {1, 0.89411764705882, 0.70980392156863},
    navajowhite = {1, 0.87058823529412, 0.67843137254902},
    navy = {0, 0, 0.50196078431373},
    oldlace = {0.9921568627451, 0.96078431372549, 0.90196078431373},
    olive = {0.50196078431373, 0.50196078431373, 0},
    olivedrab = {0.41960784313725, 0.55686274509804, 0.13725490196078},
    orange = {1, 0.64705882352941, 0},
    orangered = {1, 0.27058823529412, 0},
    orchid = {0.85490196078431, 0.43921568627451, 0.83921568627451},
    palegoldenrod = {0.93333333333333, 0.90980392156863, 0.66666666666667},
    palegreen = {0.59607843137255, 0.9843137254902, 0.59607843137255},
    paleturquoise = {0.68627450980392, 0.93333333333333, 0.93333333333333},
    palevioletred = {0.85882352941176, 0.43921568627451, 0.57647058823529},
    papayawhip = {1, 0.93725490196078, 0.83529411764706},
    peachpuff = {1, 0.85490196078431, 0.72549019607843},
    peru = {0.80392156862745, 0.52156862745098, 0.24705882352941},
    pink = {1, 0.75294117647059, 0.79607843137255},
    plum = {0.86666666666667, 0.62745098039216, 0.86666666666667},
    powderblue = {0.69019607843137, 0.87843137254902, 0.90196078431373},
    purple = {0.50196078431373, 0, 0.50196078431373},
    red = {1, 0, 0},
    rosybrown = {0.73725490196078, 0.56078431372549, 0.56078431372549},
    royalblue = {0.25490196078431, 0.41176470588235, 0.88235294117647},
    saddlebrown = {0.54509803921569, 0.27058823529412, 0.074509803921569},
    salmon = {0.98039215686275, 0.50196078431373, 0.44705882352941},
    sandybrown = {0.95686274509804, 0.64313725490196, 0.37647058823529},
    seagreen = {0.18039215686275, 0.54509803921569, 0.34117647058824},
    seashell = {1, 0.96078431372549, 0.93333333333333},
    sienna = {0.62745098039216, 0.32156862745098, 0.17647058823529},
    silver = {0.75294117647059, 0.75294117647059, 0.75294117647059},
    skyblue = {0.52941176470588, 0.8078431372549, 0.92156862745098},
    slateblue = {0.4156862745098, 0.35294117647059, 0.80392156862745},
    slategray = {0.43921568627451, 0.50196078431373, 0.56470588235294},
    slategrey = {0.43921568627451, 0.50196078431373, 0.56470588235294},
    snow = {1, 0.98039215686275, 0.98039215686275},
    springgreen = {0, 1, 0.49803921568627},
    steelblue = {0.27450980392157, 0.50980392156863, 0.70588235294118},
    tan = {0.82352941176471, 0.70588235294118, 0.54901960784314},
    teal = {0, 0.50196078431373, 0.50196078431373},
    thistle = {0.84705882352941, 0.74901960784314, 0.84705882352941},
    tomato = {1, 0.38823529411765, 0.27843137254902},
    turquoise = {0.25098039215686, 0.87843137254902, 0.8156862745098},
    violet = {0.93333333333333, 0.50980392156863, 0.93333333333333},
    wheat = {0.96078431372549, 0.87058823529412, 0.70196078431373},
    white = {1, 1, 1},
    whitesmoke = {0.96078431372549, 0.96078431372549, 0.96078431372549},
    yellow = {1, 1, 0},
    yellowgreen = {0.60392156862745, 0.80392156862745, 0.19607843137255}
}

function colorex.GetByName(name)
    local col = colorex.Colors[string.lower(name)]
    if col then
        return Color(col[1] * 255, col[2] * 255, col[3] * 255, 255)
    end
end

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