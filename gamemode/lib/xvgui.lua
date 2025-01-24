AddCSLuaFile()
AddCSLuaFile("xml2lua/xml2lua.lua")

if SERVER then
    return
end


xvgui = xvgui or {}
local xml2lua = include("xml2lua/xml2lua.lua")

local parser = {}

function parser:starttag(el, start, fin)
    local vguiElement = vgui.Create(el.name, self.top)
    vguiElement.XMLPos = { start, fin }
    
    if not vguiElement.IsSymPanel then
        SymPanel.Apply(vguiElement)
    end

    --vguiElement._PerformLayout = vguiElement.PerformLayout
    --vguiElement.PerformLayout = PerformLayout

    if self.top == self.root then
        table.insert(self.first, vguiElement)
    end

    -- Evaluate attributes here.
    local attrs = el.attrs
    if attrs then
        for k, v in pairs(attrs) do            
            if string.StartsWith(k, ":") then
                k = string.sub(k, 2, string.len(k))
                local f = CompileString([[return ]] .. v, k)
                vguiElement:SetProperty(k, f)
            else
                local tn = tonumber(v)
                if tn then
                    v = tn
                elseif v == "true" or v == "false" then
                    v = v == "true"
                end
                vguiElement:SetProperty(k, v)
            end
        end
    end

    table.insert(self.stack, vguiElement)
    self.top = vguiElement
    return el
end

function parser:endtag(el, s)
    -- Create children here.
    table.remove(self.stack, #self.stack)
    self.top = self.stack[#self.stack]
end

function parser:text(text)

    self.top:XMLHandleText(text)
    
    --[[local tag = {
        name = "Label",
        attrs = { [":Dock"] = "LEFT" }
    }
    --[[local tag = {
        name = "SymLabel",
        attrs = { }
    }

    tag.attrs.Text = text
    self:starttag(tag)
    self:endtag(tag)--]]
end
parser.__index = parser
xvgui.parser = parser


function xvgui.CreateFromXML(xml, parent)
    parent = parent or vgui.GetWorldPanel()

    local p = setmetatable({}, parser)
    p.root = parent
    p.stack = { p.root }
    p.top = p.root
    p.first = {}
    
    local eval = xml2lua.parser(p, {
        --Indicates if whitespaces should be striped or not
        stripWS = 0,
        expandEntities = 1,
        errorHandler = function(errMsg, pos)
            error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos))
        end
    })

    eval:parse(xml)

    return unpack(p.first)
end



local PANEL_META = FindMetaTable("Panel")

function PANEL_META:SetRefresh(callbacks)
    if isstring(callbacks) then
        callbacks = string.Split(callbacks, ",")
    end

    for k, v in pairs(callbacks) do
        hook.Add(string.Trim(v), self, function ()
            if self.ScheduledInvalidateLayout then
                return
            end

            self.ScheduledInvalidateLayout = true
            timer.Simple(0.1, function ()
                self.ScheduledInvalidateLayout = false
                self:InvalidateLayout() 
            end)
        end)
    end
    self.Refresh = callbacks
end

function PANEL_META:GetRefresh(callbacks)
    return self.Refresh 
end
