AddCSLuaFile()

if SERVER then
    return
end

Interface = Interface or {}

local PanelFactory

function vguix.GetControlTable()
    if not PanelFactory then
        local f = vgui.GetControlTable
        local nups = debug.getinfo(f, "u").nups

        for i=1, nups do
            local k, v = debug.getupvalue(f, i)
            if k == "PanelFactory" then
                PanelFactory = v
                break
            end
        end
    end

    assert(PanelFactory, "Could not find PanelFactory; Rubat probably broke debug.getupvalue in a GMod update.")
    return PanelFactory
end

local Fonts = {}

function vguix.Font(font, size, weight, blursize, scanlines, antialias, underline, italic, strikeout, symbol, rotary, shadow, additive, outline, extended)    
    size = math.Round(size * ScrH()/480, 0)

    local key = table.concat({
        font, 
        size, 
        weight, 
        blursize or 0, 
        scanlines or 0, 
        antialias and 1 or 0, 
        underline and 1 or 0, 
        italic and 1 or 0, 
        strikeout and 1 or 0, 
        symbol and 1 or 0, 
        rotary and 1 or 0, 
        shadow and 1 or 0, 
        additive and 1 or 0, 
        outline and 1 or 0,
        extended and 1 or 0
    }, ";")
    
    local tgt = Fonts[key]
    if tgt then
        return tgt
    end

    local fontData = {
        font = font,
        extended = extended or false,
        size = size,
        weight = weight or 400,
        blursize = blursize or 0,
        scanlines = scanlines or 0,
        antialias = antialias or true,
        underline = underline or false,
        italic = italic or false,
        strikeout = strikeout or false,
        symbol = symbol or false,
        rotary = rotary or false,
        shadow = shadow or false,
        additive = additive or false,
        outline = outline or false
    }

    surface.CreateFont(key, fontData)
    Fonts[key] = key
    
    return key
end

local function PerformLayout(pnl, w, h)
    hook.Run("Panel.PerformLayout", pnl, w, h)

    if pnl.Debug and pnl.Debug["Layout"] then
        print(pnl, "Layout", engine.TickCount())
    end

    local ow, oh = w, h
    local fe = pnl:GetFuncEnv()

    local f = pnl:GetComputed("Eval")
    if f then
        local r = f.Func(pnl, w, h)
        fe["Eval"] = r
        pnl.Eval = r

        if not r then
            return w, h
        end
    end 

    if not pnl:GetFuncEnv("Eval") then
        return w, h
    end
    
    fe.Width = w
    fe.Height = h

    local x, y = pnl:GetPos()

    if pnl.BeforeLayout then
        local w2, h2 = pnl:BeforeLayout(w, h)

        if w2 then
            w = w2
        end

        if h2 then
            h = h2
        end
    end
    
    if pnl.Computed then

        local computed = pnl:GetComputed()

        for _, t in pairs(computed) do
            local n = t.Name
            local f = t.Func

            if n == "Eval" then
                continue
            end
            
            local value = { f(pnl, w, h) }
            local val = value[1]

            if pnl.Debug[n] then
                print(pnl, n, val, engine.TickCount())
            end

            if val == NO_OP then
                continue
            end

            if n == "Wide" then
                w = val
                fe.Width = val
                continue
            end

            if n == "Tall" then
                h = val
                fe.Height = val
                continue
            end

            local getter = pnl["Get" .. n] or pnl[n]
            local setter = pnl["Set" .. n] or pnl[n]
            if isfunction(getter) and isfunction(setter) and getter ~= setter then
                local current = getter(pnl)
                if current ~= val then
                    setter(pnl, unpack(value))
                end
            elseif isfunction(setter) then
                setter(pnl, unpack(value))
            else
                pnl[n] = val
                fe[n] = val
            end
        end
    end

    if pnl._PerformLayout then
        local w2, h2 = pnl:_PerformLayout(w, h)

        if w2 then
            w = w2
        end

        if h2 then
            h = h2
        end
    end

    if pnl.AfterLayout then
        local w2, h2 = pnl:AfterLayout(w, h)

        if w2 then
            w = w2
        end

        if h2 then
            h = h2
        end
    end

    fe.Width = w
    fe.Height = h

    pnl._LayoutInvalidated = false
    if not pnl.SuppressSize and (ow ~= w or oh ~= h) then
        pnl:SetSize(w, h)
    end
    return w, h
end

--[[ I don't think this is necessary!
local function UpliftExistingVGUI(d)
    d.Computed = d.Computed or {}
    d.Debug = d.Debug or {}

    if not d._PerformLayout then
        d._PerformLayout = rawget(d:GetTable(), "PerformLayout")
        d.PerformLayout = PerformLayout
    end

    for k, v in pairs(d:GetChildren()) do
        UpliftExistingVGUI(v)
    end
end
UpliftExistingVGUI(vgui.GetWorldPanel())--]]

function vgui.Create(classname, parent, name, noLayout)
    local pf = vguix.GetControlTable()[classname]
    if pf then
        local panel = vgui.Create(pf.Base, parent, name or classname, true)
        if not panel then
            Error("Tried to create panel with invalid base '" .. pf.Base .. "'\n")
        end

        table.Merge(panel:GetTable(), pf)
        panel.BaseClass = PanelFactory[pf.Base]
        panel.ClassName = classname
        panel.Computed = panel.Computed or {}
        panel.Debug = panel.Debug or {}
        
        panel:SetMargin(0)
        panel:SetComputed("Cursor", function ()
            return Cursor
        end)
        panel:SetRow(0)
        panel:SetColumn(0)
        
        if panel.BeforeInit then
            panel:BeforeInit()
        end
        
        if panel.Init then
            panel:Init()
        end
        panel.Initialized = true

        if panel.PostInitFuncs then
            for k, v in pairs(panel.PostInitFuncs) do
                v(panel)
            end
            panel.PostInitFuncs = nil
        end

        if panel.PostInit then
            panel:PostInit()
        end
        
        if not noLayout then
            panel._PerformLayout = rawget(panel:GetTable(), "PerformLayout")
            panel.PerformLayout = PerformLayout
        end
        
        panel:Prepare()

        return panel
    else
        local pnl = vgui.CreateX(classname, parent, name or classname)
        pnl.ClassName = classname
        pnl.Computed = {}
        pnl.Debug = {}
        pnl:SetMargin(0)
        
        return pnl
    end
end

function vgui.CreateFromTable(metatable, parent, name)

	if not istable(metatable) then 
        return nil 
    end


	local panel = vgui.Create(metatable.Base, parent, name)

	table.Merge(panel:GetTable(), metatable)
	panel.BaseClass = vguix.GetControlTable()[metatable.Base]
        
	-- Call the Init function if we have it
	if (panel.Init) then
		panel:Init()
	end

	panel:Prepare()

	return panel
end

local LastHovered
hook.Add("Think", "vguix.Hover", function ()
    local tgt = vgui.GetHoveredPanel()
    local src = tgt
    
    while tgt and not tgt:GetHover() do
        tgt = tgt:GetParent()
    end

    if tgt == vgui.GetWorldPanel() then
        tgt = nil
    end
    
    if LastHovered ~= tgt then
        
        if IsValid(LastHovered) then
            LastHovered:SetFuncEnv("IsHovered", nil)
            if not LastHovered.HoverNoLayout then
                LastHovered:InvalidateChildren(true)
            end
            
            if LastHovered.StopHover then
                LastHovered:StopHover(src)
            end
        end

        if IsValid(tgt) then
            tgt:SetFuncEnv("IsHovered", tgt)
            if not tgt.HoverNoLayout then
                tgt:InvalidateChildren(true)
            end
            
            if tgt.StartHover then
                tgt:StartHover(src)
            end
        end

        LastHovered = tgt
    end
end)



hook.Add("VGUIMousePressed", "vguix.MousePressed", function(pnl, mousecode)
    -- Absent a timer, derma menus fuck up
    timer.Simple(0, function ()
        if mousecode == MOUSE_LEFT then
            if pnl.LeftClick then
                pnl:LeftClick()
            else
                pnl:InvokeParent("LeftClick")
            end
        end
        
        if mousecode == MOUSE_RIGHT then
            if pnl.RightClick then
                pnl:RightClick()
            else
                pnl:InvokeParent("RightClick")
            end
        end

        if mousecode == MOUSE_MIDDLE then
            if pnl.MiddleClick then
                pnl:MiddleClick()
            else
                pnl:InvokeParent("MiddleClick")
            end
        end
    end)
end)

local function DermaDetectMenuFocus( panel, mousecode )


	if ( IsValid( panel ) ) then

		if ( panel.m_bIsMenuComponent ) then return end

		-- Is the parent a menu?
		return DermaDetectMenuFocus( panel:GetParent(), mousecode )

	end

	CloseDermaMenus()

end

hook.Add( "VGUIMousePressed", "DermaDetectMenuFocus", DermaDetectMenuFocus )