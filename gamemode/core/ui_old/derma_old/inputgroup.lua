if SERVER then
    return
end

local PANEL = {}

function PANEL:Init()
    self:SetFlex(7)
    self:SetFlexGap(SS(1))
    self:SetFlexFlow(FLEX_FLOW_Y)
    self.Values = {}
end

function PANEL:SetAllowMultiselect(enable)
    self.AllowMultiselect = true
end

function PANEL:GetAllowMultiselect()
    return self.AllowMultiselect
end

function PANEL:AddValue(key, data)
    if not self:GetAllowMultiselect() then
        self.Values = {}
    end
    self.Values[key] = data or true
    self:UpdateValues()
end

function PANEL:RemoveValue(key)
    self.Values[key] = nil
    self:UpdateValues()
end

function PANEL:GetValues()
    return self:GetAllowMultiselect() and self.Values or self.Values[1]
end

function PANEL:UpdateValues()
    for k, v in pairs(self:GetChildren()) do
        if not v.GetKey then
            continue
        end

        v:SetValue(self.Values[v:GetKey()], true)
    end
end

function PANEL:OnChildAdded(child)
    self:UpdateValues()
    self:SizeToChildren(true, true)
end

vgui.Register("SymInputGroup", PANEL, "SymPanel")