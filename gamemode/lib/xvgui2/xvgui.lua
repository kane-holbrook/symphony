AddCSLuaFile()

-- 1. Get stencils working
-- 2. Get DHTML working
-- 3. VGUI host component

xvgui = {}
include("xml2lua.lua") -- AddCSLuaFile when production
include("xmlparser.lua") -- As above
include("material.lua")

if SERVER then
    return
end

local Controls = {}

function xvgui.Create(classname, parent, name)
end

function xvgui.CreateFromNode(node)
end

function xvgui.CreateFromXML(xml, parent)
end

function xvgui.Register(classname, panelTable, baseName)
end

function xvgui.RegisterFromXML(xml)
end

function xvgui.GetControlTable(name)
    if not name then
        return Controls
    else
        assert(isstring(name), "Name must be a string.")
        return Controls[name]
    end
end

function xvgui.Exists(name)
    return Controls[name] ~= nil
end

function xvgui.FocusedHasParent()
end

function xvgui.GetAll()
end

function xvgui.GetHoveredPanel()
end

function xvgui.GetKeyboardFocus()
end



-- Hooks
-- PostRenderVGUI
-- VGUIMousePressAllowed
-- VGUIMousePressed