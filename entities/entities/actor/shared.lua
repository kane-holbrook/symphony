DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.PrintName = "Symphony Entity"
ENT.Author = "Xalphox"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/male_02.mdl") -- Example model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end