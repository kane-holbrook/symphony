AddCSLuaFile()

xvgui = {}

include("xvgui_xml.lua")
include("xvgui_derma.lua")
include("xvgui_xpanel.lua")
include("xvgui_xlabel.lua")

if SERVER then
    return
end

-- XML ✓
-- Properties ✓
--   Inherit from parent ✓
--   Set defaults
-- Refs ✓
-- Emit ✓
-- <Listen Hook="" /> ✓
-- <Listen FQR="" /> ✓ 
-- <For :="i = 1, 32"> ✓
-- <For :="k, v in pairs(player.GetAll())" /> ✓


function xvgui.IsXVGUI(panel)
    return panel.IsXVGUI
end

function xvgui.Apply(panel)
    if xvgui.IsXVGUI(panel) then
        return false
    end


    local pl = panel.PerformLayout
    if not pl then
        if istable(panel) then
            PrintTable(panel)
        end
        
        panel.PerformLayout = XVGUI_PERFORM_LAYOUT
        return true
    end

    panel.PerformLayout = function (p, w, h)
        w, h = XVGUI_PERFORM_LAYOUT(p, w, h)
        return pl(p, w, h)
    end

    panel.IsXVGUI = true
end

xvgui.RegisterSpecialTag("Listen", function (parent, node, ctx)
    local fqr = node.Attributes["FQR"]

    if fqr then
        local delay = node.Attributes["Delay"] or 0
        hook.Add("PerformLayout:" .. fqr, parent, function ()
            timer.Simple(delay, function ()
                if not parent:IsValid() then
                    return
                end

                parent:InvalidateChildren()
            end)
        end)
        return true
    end

    local hk = node.Attributes["Hook"]
    if hk then
        local delay = node.Attributes["Delay"] or 0.25
        assert(hk, "Must provide a FQR or a Hook in a Listen tag.")

        hook.Add(hk, parent, function ()
            timer.Simple(delay, function ()
                if not parent:IsValid() then
                    return
                end

                parent:InvalidateChildren()
            end)
        end)
        return true
    end

    local delay = node.Attributes["Delay"]
    if delay then
        local id = uuid()
        timer.Create(id, delay, 0, function ()
            if not IsValid(parent) then
                timer.Remove(id)
                return
            end

            parent:InvalidateChildren()
        end)
        return true
    end

    error("Must provide a FQR=, Hook=, or Delay= attribute.")
end)

xvgui.RegisterSpecialTag("Style", function (parent, node, ctx)
    local style = node.Attributes["Ref"]

    local root = parent:GetProperty("Root")
    root = root or parent

    node.Attributes["Name"] = nil
    root.Styles = root.Styles or {}
    root.Styles[style] = node.Attributes    

    return true
end)

xvgui.RegisterSpecialAttribute("Style", function (el, value, node, ctx)
    assert(ctx.Scope, "Styles can only be specified for components")
    
    local root = ctx.Scope
    root = root or parent
    assert(root.Styles, "This component has no styles.")
    
    local style = root.Styles[value]
    assert(style, "Invalid style:" .. value)

    for k, v in pairs(style) do
        el:SetProperty(k, v)
    end
end)

xvgui.RegisterSpecialTag("For", function (parent, node, ctx)
    local run = node.Attributes["Run"]
    if run then
        parent.ForFunc = CompileString(run, "For")
        setfenv(parent.ForFunc, parent:GetFuncEnv())
        return
    end

    local value = node.Attributes["Each"]
    local splitted = string.Split(value, " in ")
    if #splitted > 1 then
        local func = splitted[2]
        local variables = string.Split(splitted[1], ",")

        local varMap = {}
        for k, v in pairs(variables) do
            local tr = string.Trim(v)
            variables[k] = tr
            table.insert(varMap, "[\"" .. tr .. "\"]" .. " = " .. tr)
        end
        
        local f = [[
            local data = {}
            for ]] .. table.concat(variables, ", ") .. [[ in ]] .. func .. [[ do 
                table.insert(data, {]] .. table.concat(varMap, ", ") .. [[})
            end
            return data
        ]]
        parent.ForFunc = CompileString(f, "For")
        setfenv(parent.ForFunc, parent:GetFuncEnv())
        parent.ForXml = node.Children
    else
        splitted = string.Split(value, ",")
        assert(#splitted > 1, "<For Each=> must be a valid Lua for loop.")

        local func = splitted[2]
        local var = string.Trim(string.Split(splitted[1], "=")[1])
        local incre = splitted[3] or 1
        
        local f = [[
            local data = {}
            for ]] .. splitted[1] .. [[, ]] .. func .. [[, ]] .. incre .. [[ do 
                table.insert(data, { [']] .. var .. [['] = ]] .. var .. [[ })
            end
            return data
        ]]
        parent.ForFunc = CompileString(f, "For")
        setfenv(parent.ForFunc, parent:GetFuncEnv())

        parent.ForXml = node.Children
    end

    return true
end)

xvgui.RegisterSpecialPrefix("Set", function (el, key, value, splitted, node, ctx)
    xvgui.SetProperty(el, key, value)
end)

xvgui.RegisterSpecialPrefix("Override", function (el, key, value, splitted, node, ctx)
    local f = CompileString([[return ]] .. value, "Override")
    setfenv(f, setmetatable({ self = el }, { __index = _G }))
    el[key] = f()
end)

xvgui.RegisterSpecialAttribute("Slot", function (el, value, node, ctx)
    assert(ctx.Scope, "Slots can only be specified for components")
    
    local root = ctx.Scope
    root.Slots[value] = el

    if value == "Default" then
        root.DefaultSlot = el
    end
end)

xvgui.RegisterSpecialTag("Slot", function (parent, node, ctx)
    local name = node.Attributes["Name"] or "Default"

    local root = parent:GetProperty("Root")
    root = root or parent
    assert(root.Slots, "This component has no slots.")
    
    local slot = root.Slots[name]
    assert(slot, "Invalid slot:" .. name)

    for k, v in pairs(node.Children) do
        local el = xvgui.CreateFromNode(slot, v, ctx)
    end
    return true
end)

xvgui.RegisterSpecialTag("Text", function (parent, node, ctx)
    return parent:XMLHandleText(node.Attributes["Text"], node, ctx)
end)

xvgui.RegisterSpecialTag("Paint", function (parent, node, ctx)
    assert(#node.Children == 1, "Paint must only be text")

    local txt = node.Children[1].Attributes.Text
    parent.Paint = CompileString([[return function (self, w, h) 
        ]] .. txt .. [[
        end]], "Override:Paint")()
    return true
end)

xvgui.RegisterSpecialTag("Think", function (parent, node, ctx)
    assert(#node.Children == 1, "Paint must only be text")

    local txt = node.Children[1].Attributes.Text
    parent.Think = CompileString([[return function (self) 
        ]] .. txt .. [[
        end]], "Override:Think")()
    return true
end)