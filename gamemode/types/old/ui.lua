AddCSLuaFile()

if SERVER then
    return
end

--SYM_FONTS = SYM_FONTS or {}

sym.ui = sym.ui or {}
sym.ui.Fonts = {}

local FONT = sym.RegisterType("font")
FONT:AddProperty("Font", sym.types.string, { Default = "Oxanium" })
FONT:AddProperty("Extended", sym.types.boolean, { Default = true })
FONT:AddProperty("Size", sym.types.number, { Default = 13 })
FONT:AddProperty("Weight", sym.types.number, { Default = 500 })
FONT:AddProperty("BlurSize", sym.types.number, { Default = 0 })
FONT:AddProperty("ScanLines", sym.types.number, { Default = 0 })
FONT:AddProperty("Antialias", sym.types.boolean, { Default = true })
FONT:AddProperty("Underline", sym.types.boolean, { Default = false })
FONT:AddProperty("Italic", sym.types.boolean, { Default = false })
FONT:AddProperty("Strikeout", sym.types.boolean, { Default = false })
FONT:AddProperty("Symbol", sym.types.boolean, { Default = false })
FONT:AddProperty("Rotary", sym.types.boolean, { Default = false })
FONT:AddProperty("Shadow", sym.types.boolean, { Default = false })
FONT:AddProperty("Additive", sym.types.boolean, { Default = false })
FONT:AddProperty("Outline", sym.types.boolean, { Default = false })

function FONT:Render()
    local key = table.concat({
        tostring(self:GetFont()),
        tostring(self:GetExtended()),
        tostring(self:GetSize()),
        tostring(self:GetWeight()),
        tostring(self:GetBlurSize()),
        tostring(self:GetScanLines()),
        tostring(self:GetAntialias()),
        tostring(self:GetUnderline()),
        tostring(self:GetItalic()),
        tostring(self:GetStrikeout()),
        tostring(self:GetSymbol()),
        tostring(self:GetRotary()),
        tostring(self:GetShadow()),
        tostring(self:GetAdditive()),
        tostring(self:GetOutline())
    }, ";")

    local exists = sym.ui.Fonts[key]
    if exists then
        return key
    else
        surface.CreateFont(key, {
            font = self:GetFont(),
            size = self:GetSize(),
            weight = self:GetWeight(),
            blursize = self:GetBlurSize(),
            scanlines = self:GetScanLines(),
            antialias = self:GetAntialias(),
            underline = self:GetUnderline(),
            italic = self:GetItalic(),
            strikeout = self:GetStrikeout(),
            symbol = self:GetSymbol(),
            rotary = self:GetRotary(),
            shadow = self:GetShadow(),
            additive = self:GetAdditive(),
            outline = self:GetOutline()
        })

        sym.ui.Fonts[key] = true
        return uuid
    end
end

function FONT:__tostring()
    return self:Render()
end

function sym.Font(font, sz, weight)
    local f = FONT()

    if isnumber(font) then
        sz = font
        font = "Oxanium"
    end

    font = font or "Oxanium"
    sz = sz or 25

    local sh = ScrH()
    sz = math.Round(sz * (sh / 1440), 0)

    f:SetFont(font)
    f:SetSize(sz)
    f:SetWeight(weight or 500)
    return f
end



local RADIOGROUP = sym.RegisterType("radiogroup")
function RADIOGROUP:Init(t)
    t.Children = {}
    t.IndexedChildren = {}
    return t
end

function RADIOGROUP:GetValue()
    return self.Value
end

function RADIOGROUP:SetValue(value)
    self.Value = value

    local e
    for k, v in pairs(self.Children) do
        if value == k then
            v:SetValue(true)
            e = v
        else
            v:SetValue(false)
        end
    end

    self:OnChange(self.Value, e)
end

function RADIOGROUP:OnChange(value)
end

function RADIOGROUP:Add(ref, ele)
    self.Children[ref] = ele
    if not table.HasValue(self.IndexedChildren, ele) then
        ele.RadioIndex = table.insert(self.IndexedChildren, ele)
    end
end

function RADIOGROUP:GetChildren()
    return self.IndexedChildren
end


function RADIOGROUP:Previous()
    local children = self:GetChildren()
    local idx, curr = math.huge, nil 
    for k, v in pairs(children) do
        if v:GetValue() then
            idx = k
            curr = v
            break
        end
    end

    local c = children[idx - 1]
    if not c then
        c = children[#children]
    end
    self:SetValue(c.Key)
end

function RADIOGROUP:Next()
    local children = self:GetChildren()
    local idx, curr = -1, nil 
    for k, v in pairs(children) do
        if v:GetValue() then
            idx = k
            curr = v
            break
        end
    end

    local c = children[idx + 1]
    if not c then
        c = children[1]
    end
    self:SetValue(c.Key)
end

function sym.RadioGroup()
    return sym.CreateInstance(RADIOGROUP)
end

local CHKGROUP = sym.RegisterType("checkgroup")
function CHKGROUP:Init(t)
    t.Children = {}
    t.Value = {}
    return t
end

function CHKGROUP:GetValue()
    return self.Value
end

function CHKGROUP:SetValue(ref, value)
    self.Value[ref] = value

    for k, v in pairs(self.Children) do
        v:SetValue(self.Value[k])
    end
end

function CHKGROUP:Add(ref, ele)
    self.Children[ref] = ele
end

function sym.CheckboxGroup()
    return sym.CreateInstance(CHKGROUP)
end