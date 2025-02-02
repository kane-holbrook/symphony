if SERVER then
    return
end

local PANEL = {}
PANEL.IsInput = true

local function BindToInput(name)
    local set = "Set" .. name
    PANEL[set] = function (panel, value)
        return panel.Input[set](panel.Input, value)
    end

    local get = "Get" .. name
    PANEL[get] = function (panel, value)
        return panel.Input[get](panel.Input)
    end
end

function PANEL:Init()
    self:SetBackground(Color(40, 40, 40, 255))
    self:SetHover(Color(40, 40, 40, 255))
    self:SetFlex(4)

    self.Left = vgui.Create("SymPanel", self)
    self.Left:SizeToChildren(true, true)

    self.Center = vgui.Create("SymPanel", self)
    self.Center:SetFlexGrow(true)
    self.Center:SetFlexMargin(SS(3), 0, 0, SS(3))

    self.Input = vgui.Create("DTextEntry", self.Center)
    self.Input:Dock(FILL)
    self.Input.Paint = self.PaintTextEntry
    
    self.Input:SetHighlightColor(Color(0, 0, 255, 64))
    self.Input:SetPaintBackground(false)
    self.Input:SetTextColor(color_white)
    self.Input:SetFont(tostring(sym.fonts.default))
    self.Input:SetCursorColor(color_white)
    
end
BindToInput("PlaceholderText")
BindToInput("Multiline")
BindToInput("Numeric")
BindToInput("MaximumCharCount")
BindToInput("Text")

-- Slight amendment to GMod's paint in order to fix placeholders continually re-rendering.
function PANEL:PaintTextEntry(w, h)
    if ( self.m_bBackground ) then

		if ( panel:GetDisabled() ) then
			self.tex.TextBox_Disabled( 0, 0, w, h )
		elseif ( panel:HasFocus() ) then
			self.tex.TextBox_Focus( 0, 0, w, h )
		else
			self.tex.TextBox( 0, 0, w, h )
		end

	end

	-- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() && ( !self:GetText() || self:GetText() == "" ) ) then

		local oldText = self:GetText()

		local str = self:GetPlaceholderText()
		if ( str:StartsWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

        draw.SimpleText(str, self:GetFont(), 2, h/2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
        --[[self:SetText( str )
		self:DrawTextEntryText( self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor() )
		self:SetText( oldText )--]]

		return
	end

	self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
end

function PANEL:SetFont(font)
    self.Input:SetFont(tostring(font))
end

function PANEL:GetFont()
    return self.Input:GetFont()
end

function PANEL:Paint(w, h)
    local ss = ScreenScale(0.75)
    local col = self:IsHovered() and self:GetHover() or self:GetBackground()
    draw.RoundedBox(ss, ss, ss, w-ss, h-ss, Color(0, 0, 0, 64))
    draw.RoundedBox(ss, 0, 0, w-ss, h-ss, col)
end
vgui.Register("SymInputText", PANEL, "SymPanel")