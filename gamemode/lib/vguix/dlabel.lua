AddCSLuaFile()

if SERVER then
    return
end

DEFINE_BASECLASS("DLabel")

local PANEL = {}
function PANEL:Init()
    self:SetComputed("Font", function ()
        return self:GetSurfaceFont()
    end, -1) -- We run this before everything else because this can change width/height!

    self:SetWrap(false)
    self:SetComputed("TextColor", function ()
        local fe = self:GetFuncEnv()
        return fe.FontColor
    end)
    self:SetSize("auto", "auto")
end

function PANEL:SetWrap(wrap)
    self.Wrap = wrap
    return BaseClass.SetWrap(self, wrap)
end

function PANEL:GetWrap()
    return self.Wrap
end

function PANEL:ChildrenSizeEx()

    return self:GetContentSize()

    --[[local font = self:GetSurfaceFont()
    
    surface.SetFont(font)
    return surface.GetTextSize(self:GetText())--]]
end

function PANEL:SetValue(val)
    self:SetText(val)
end

function PANEL:GetValue()
    return self:GetText()
end

vgui.Register("Text", PANEL, "DLabel")