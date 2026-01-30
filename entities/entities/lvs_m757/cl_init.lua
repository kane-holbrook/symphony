include("shared.lua")

function ENT:UpdatePoseParameters( steer )
	self:SetPoseParameter( "steer", steer )

end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "kamaz/kamaz_start.wav", 75, 100,  LVS.EngineVolume )
	else
		self:EmitSound( "kamaz/kamaz_stop.wav", 75, 100,  LVS.EngineVolume )
	end
	

end