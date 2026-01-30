AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Actor Part"
ENT.Author = "Xalphox"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
end

function ENT:Draw(flags)
    
    local p = self:GetParent()
    if IsValid(p) and p:GetNoDraw() then
        self:DestroyShadow()
        return
    end
    
    local col = self:GetColor()
    render.SetColorModulation(col.r/255, col.g/255, col.b/255)
    self:DrawModel(flags)
    self:CreateShadow()
    render.SetColorModulation(1, 1, 1)
end
ENT.DrawTranslucent = ENT.Draw

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end