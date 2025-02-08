AddCSLuaFile()
if SERVER then
    return true
end

-- VGUI rewrite
do
    local PanelFactory
    rawvgui = rawvgui or vgui
    vgui = setmetatable({}, {
        __index = rawvgui
    })

    -- Firstly, let's leak the PanelFactory variable from vgui.Register!
    assert(debug.getupvalue, "Rubat removed debug.getupvalue >:(")
    for i = 1, debug.getinfo(vgui.Register, "u").nups do
        local k, v = debug.getupvalue(vgui.Register, i)
        if k == "PanelFactory" then
            PanelFactory = v
            break
        end
    end

    function Interface.GetPanelFactory()
        return PanelFactory
    end

    
    function vgui.Register(classname, panelTable, baseName)
        local out = rawvgui.Register(classname, panelTable, baseName)
        return out
    end
end


for k, v in pairs(Interface.GetPanelFactory()) do
    --local t = Type.Register(k, )
    --print(k)
end