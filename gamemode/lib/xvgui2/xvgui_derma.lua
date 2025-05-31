AddCSLuaFile()

if SERVER then 
    return 
end

local PANEL = FindMetaTable("Panel")


-- Computed
PANEL.Computed = {}
function PANEL:SetComputed(property, func)
end

function PANEL:IsComputed(property)
end

function PANEL:PerformLayout(w, h)
end

-- Events
function PANEL:Listen(name, func)
end

function PANEL:Emit(event, ...)
end

function PANEL:EmitChildren(event, ...)
end