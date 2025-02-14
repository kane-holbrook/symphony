AddCSLuaFile()

if SERVER then
    return
end

local parser = {}
function parser:starttag(el, start, fin)
    local vguiElement = {}
    vguiElement.Tag = el.name --vgui.Create(el.name, self.top)
    vguiElement.Start = start
    vguiElement.Finish = fin
    vguiElement.Attributes = el.attrs
    vguiElement.Children = {}
    vguiElement.Parent = self.top

    local current = self.stack[#self.stack]
    if current then
        table.insert(current.Children, vguiElement)
    end

    table.insert(self.stack, vguiElement)
    self.top = vguiElement
end

function parser:endtag(el, s)
    -- Create children here.
    table.remove(self.stack, #self.stack)
    self.top = self.stack[#self.stack]
end

function parser:text(text)
    local el = { name = "Content", attrs = { Text = text } }
    self:starttag(el)
    self:endtag(el)
end
parser.__index = parser
Interface.parser = parser

function Interface.Parse(xml)
    local p = setmetatable({}, parser)
    p.root = {
        Children = {}
    }
    p.stack = { p.root }
    p.top = p.root
    
    local eval = xml2lua.parser(p, {
        --Indicates if whitespaces should be striped or not
        stripWS = 0,
        expandEntities = 1,
        errorHandler = function(errMsg, pos)
            error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos))
        end
    })

    eval:parse(xml)

    return p.top
end


function Interface.CreateFromNode(parent, node, ctx)
    ctx = ctx or {}

    local c = Interface.Components[node.Tag]
    assert(c, "Component " .. node.Tag .. " does not exist")

    return c:CreateFromNode(parent, node, ctx)
end

function Interface.CreateFromXML(parent, xml)
    assert(xml, "Must provide XML")
    local out = {}

    local t = Interface.Parse(xml)    
    for k, v in pairs(t.Children) do
        table.insert(out, Interface.CreateFromNode(parent, v))
    end

    return unpack(out)
end

function Interface.RegisterFromXML(classname, xml)
    assert(xml, "Must provide XML")

    local t = Interface.Parse(xml)
    assert(#t.Children == 1, "XML provided has no or multiple root nodes")
    local p = t.Children[1]
    local base = p.Tag

    local panel = {}
    panel.Xml = setmetatable({}, { __index = p })

    function panel:Init()
        Interface.Apply(self)
        self:LoadXML()
    end

    return vgui.Register(classname, panel, base)
end