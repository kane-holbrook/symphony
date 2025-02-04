Interface = {}

function Interface.Create()
end

function Interface.Register()
end


Interface.Themes = {}

local THEME = Type.Register("Theme")
THEME:CreateProperty("Name", String)
THEME:CreateProperty("Parent", THEME)