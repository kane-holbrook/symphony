if SERVER then
    return
end

function Interface.Extent(value)
    print(Interface.Extent)
    return ScreenScale(value)
end

rawvgui = rawvgui or vgui
vgui = setmetatable({}, { __index = rawvgui })

local BasePanel = FindMetaTable("Panel")
BasePanel.Properties = {
    X = { Interface.Extent, BasePanel.SetX },
    Y = { Interface.Extent, BasePanel.SetY },
    Width = { Interface.Extent, BasePanel.SetWide },
    Height = { Interface.Extent, BasePanel.SetTall },
    Dock = { Type.Number, BasePanel.Dock },
    Achievement = { Type.Number, BasePanel.SetAchievement },
    AllowNonAsciiCharacters = { Type.Boolean, BasePanel.SetAllowNonAsciiCharacters },
    Alpha = { Type.Number, BasePanel.SetAlpha },
    AnimationEnabled = { Type.Boolean, BasePanel.SetAnimationEnabled },
    AutoDelete = { Type.Boolean, BasePanel.SetAutoDelete },
    BGColor = { Type.Color, BasePanel.SetBGColor },
    CaretPos = { Type.Number, BasePanel.SetCaretPos },
    ContentAlignment = { Type.Number, BasePanel.SetContentAlignment },
    ConVar = { Type.String, BasePanel.SetConVar },
    CookieName = { Type.String, BasePanel.SetCookieName },
    Cursor = { Type.Number, BasePanel.SetCursor },
    DrawLanguageID = { Type.Boolean, BasePanel.SetDrawLanguageID },
    DrawLanguageIDAtLeft = { Type.Boolean, BasePanel.SetDrawLanguageIDAtLeft },
    DrawOnTop = { Type.Boolean, BasePanel.SetDrawOnTop },
    Enabled = { Type.Boolean, BasePanel.SetEnabled },
    SetFGColor = { Type.Color, BasePanel.SetFGColor },
    FocusTopLevel = { Type.Boolean, BasePanel.SetFocusTopLevel },
    FontInternal = { Type.String, BasePanel.SetFontInternal },
    HTML = { Type.String, BasePanel.SetHTML },
    KeyboardInputEnabled = { Type.Boolean, BasePanel.SetKeyboardInputEnabled },
    LineHeight = { Type.Number, BasePanel.SetLineHeight },
    MaximumCharCount = { Type.Number, BasePanel.SetMaximumCharCount },
    MinimumSize = { Type.Vector, BasePanel.SetMinimumSize },
    MouseInputEnabled = { Type.Boolean, BasePanel.SetMouseInputEnabled },
    Multiline = { Type.Boolean, BasePanel.SetMultiline },
    Name = { Type.String, BasePanel.SetName },
    OpenLinksExternally = { Type.Boolean, BasePanel.SetOpenLinksExternally },
    PaintBackgroundEnabled = { Type.Boolean, BasePanel.SetPaintBackgroundEnabled },
    PaintBorderEnabled = { Type.Boolean, BasePanel.SetPaintBorderEnabled },
    PaintedManually = { Type.Boolean, BasePanel.SetPaintedManually },
    PopupStayAtBack = { Type.Boolean, BasePanel.SetPopupStayAtBack },
    RenderInScreenshots = { Type.Boolean, BasePanel.SetRenderInScreenshots },
    Selectable = { Type.Boolean, BasePanel.SetSelectable },
    Selected = { Type.Boolean, BasePanel.SetSelected },
    SelectionCanvas = { Type.Boolean, BasePanel.SetSelectionCanvas },
    Skin = { Type.String, BasePanel.SetSkin },
    SpawnIcon = { Type.String, BasePanel.SetSpawnIcon },
    TabPosition = { Type.Number, BasePanel.SetTabPosition },
    Term = { Type.Number, BasePanel.SetTerm },
    Text = { Type.String, BasePanel.SetText },
    Tooltip = { Type.String, BasePanel.SetTooltip },
    TooltipDelay = { Type.Number, BasePanel.SetTooltipDelay },
    TooltipPanelOverride = { Type.String, BasePanel.SetTooltipPanelOverride },
    UnderlineFont = { Type.String, BasePanel.SetUnderlineFont },
    URL = { Type.String, BasePanel.SetURL },
    VerticalScrollbarEnabled = { Type.Boolean, BasePanel.SetVerticalScrollbarEnabled },
    Visible = { Type.Boolean, BasePanel.SetVisible },
    Wrap = { Type.Boolean, BasePanel.SetWrap },
    ZPos = { Type.Number, BasePanel.SetZPos },
    DockPadding = { nil, function (self, value)
        local left, top, right, bottom = string.Split(value, " ")
        left = tonumber(left)
        
        if not top then
            top = left
            right = left
            bottom = left
        else
            top = tonumber(top)

            if not right then
                right = left
                bottom = top
            else
                right = tonumber(right)
                bottom = tonumber(bottom)
            end
        end

        assert(left and top and right and bottom, "DockPadding must be 1, 2 or 4 numbers.")
        self:DockPadding(left, top, right, bottom) 
    end },
}


-- Set up the default components
do
    for k, v in pairs(derma.GetControlList()) do
        local ct = vgui.GetControlTable(v.ClassName)
        local parent = vgui.GetControlTable(v.BaseClass) or BasePanel
        
        parent.Properties = parent.Properties or {}

        if v.Properties then 
            table.Empty(v.Properties)
        end
        
        v.Properties = setmetatable(v.Properties or {}, { __index = parent.Properties })
    end
end

local DPanel = vgui.GetControlTable("DPanel")
DPanel.Properties.BackgroundColor = { Type.Color, DPanel.SetBackgroundColor }
DPanel.Properties.IsMenu = { Type.Boolean, DPanel.SetIsMenu }
DPanel.Properties.Disabled = { Type.Boolean, DPanel.SetDisabled }

function BasePanel:ParseNode(parent, node)
    local el = vgui.Create(node.Tag, parent)

    for k, v in pairs(node.Attributes) do
        local p = self.Properties[k]
        
        if p then
            local t = p[1]
            local f = p[2]

            if isfunction(t) then
                local succ, val = t(v)
                if not succ then
                    ErrorNoHaltWithStack("Failed to parse\n")
                    continue
                end

                succ, val = pcall(f, el, val)

                if not succ then
                    ErrorNoHaltWithStack("Failed to set " .. k .. " on " .. tostring(el) .. "\n")
                end
            elseif t then
                local succ, val = t:TryParse(v)
                if not succ then
                    ErrorNoHaltWithStack("Failed to parse " .. k .. " as " .. t:GetName() .. "\n")
                    continue
                end

                succ, val = pcall(f, el, val)

                if not succ then
                    ErrorNoHaltWithStack("Failed to set " .. k .. " on " .. tostring(el) .. "\n")
                end
            end

        end
    end

    for k, v in pairs(node.Children) do
        Interface.CreateFromNode(el, v)
    end

    return el
end