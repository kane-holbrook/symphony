AddCSLuaFile()
if SERVER then
    return
end


local Radial = Material("symphony/ui/radialgradient")
local dp = 3
function RadialGradient(color1, offset1, color2, offset2, color3)
    return function (pnl, w, h) 
        Radial:SetFloat("$c0_x", math.Round(color1.r / 255, dp))
        Radial:SetFloat("$c0_y", math.Round(color1.g / 255, dp))
        Radial:SetFloat("$c0_z", math.Round(color1.b / 255, dp))
        Radial:SetFloat("$c0_w", math.Round(color1.a / 255, dp))
        
        Radial:SetFloat("$c1_x", math.Round(color2.r / 255, dp))
        Radial:SetFloat("$c1_y", math.Round(color2.g / 255, dp))
        Radial:SetFloat("$c1_z", math.Round(color2.b / 255, dp))
        Radial:SetFloat("$c1_w", math.Round(color2.a / 255, dp))

        Radial:SetFloat("$c2_x", math.Round(color3.r / 255, dp))
        Radial:SetFloat("$c2_y", math.Round(color3.g / 255, dp))
        Radial:SetFloat("$c2_z", math.Round(color3.b / 255, dp))
        Radial:SetFloat("$c2_w", math.Round(color3.a / 255, dp))
        
        Radial:SetFloat("$c3_x", math.Round(offset1, dp))
        Radial:SetFloat("$c3_y", math.Round(offset2, dp))

        return Radial
    end
end