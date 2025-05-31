AddCSLuaFile()

local xml2lua = include("xml2lua.lua")

if SERVER then
    return
end

local parser = {}
function parser:starttag(el, start, fin)
    local vguiElement = {}
    vguiElement.Tag = el.name
    vguiElement.Start = start
    vguiElement.Finish = fin
    vguiElement.Attributes = {}
    vguiElement.Children = {}
    vguiElement.Parent = self.top

    -- Evaluate attributes here.
    local attrs = el.attrs
    if attrs then
        for k, v in pairs(attrs) do            
            vguiElement.Attributes[k] = v
        end
    end

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
    local el = { name = "Text", attrs = { Text = text } }
    self:starttag(el)
    self:endtag(el)
end
parser.__index = parser
xvgui.parser = parser

function xvgui.Parse(xml)
    local p = setmetatable({}, parser)
    p.root = {
        Children = {}
    }

    p.stack = {p.root}
    p.top = p.root
    local eval = xml2lua.parser(p, {
        --Indicates if whitespaces should be striped or not
        stripWS = 0,
        expandEntities = 1,
        errorHandler = function(errMsg, pos) error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos)) end
    })

    eval:parse(xml)
    return p.top
end

local PANEL = FindMetaTable("Panel")
function PANEL:CreateFromNode(parent, node)
    local e = vgui.Create(node.Tag, parent)
    assert(e, "Failed to create VGUI element: " .. node.Tag)

    for _, t in pairs(node.Attributes) do
        local k, v = xvgui.ParseAttribute(t.key, t.value, e)        
        if k == nil then
            continue
        end

        local set = e["Set" .. k] or e[k]
        if set then
            set(e, v)
        else
            e[k] = v
        end
    end

    return e
end

PANEL.FuncEnv = setmetatable({}, {
    __index = function (t, k, v)
        return k == "self" and rawget(t, k, v) or _G[k]
    end
})

function PANEL:Listen(event, func)
    self.Hooks = self.Hooks or {}

    if not self.Hooks[event] then
        self.Hooks[event] = {}
    end

    setfenv(func, self.FuncEnv)
    table.insert(self.Hooks[event], func)
end

function PANEL:Emit(event, ...)
    local p = self:GetParent()
    while p do
        if p.Hooks and p.Hooks[event] then
            if p.Hooks[event](self, ...) then
                return true
            end
        end
        p = p:GetParent()
    end
end


PANEL.Namespaces = {
    {
        Name = ":",
        function (el, name, value)
            
        end
    }
}

PANEL.Attributes = {}

function xvgui.ParsePositional(value)
    if string.EndsWith(value, "ss") then
        return function () return ScreenScale(tonumber(string.sub(value, 1, -3))) end
    elseif string.EndsWith(value, "ssh") then
        return function () return ScreenScale(tonumber(string.sub(value, 1, -4))) * ScrH() end
    elseif string.EndsWith(value, "pw") then
        return function () return self:GetParent():GetWide() * tonumber(string.sub(value, 1, -3)) end
    elseif string.EndsWith(value, "ph") then
        return function () return self:GetParent():GetTall() * tonumber(string.sub(value, 1, -3)) end
    end
end

function xvgui.ParseAttribute(name, value, el)
    for k, v in pairs(el.Namespaces) do
        if string.StartWith(name, k .. ":") then
            name = string.sub(name, #k + 2)
            value = v(el, name, value)
        end
    end

    print(name, value)
    
end

function xvgui.CreateFromNode(parent, node)
    local ct = vgui.GetControlTable(node.Tag)
    assert(ct, "VGUI element does not exist: " .. node.Tag)

    return ct:CreateFromNode(parent, node)
end

function xvgui.CreateFromXML(parent, xml)
    assert(xml, "XML is nil")

    local node = xvgui.Parse(xml)
    local out = {}

    for k, v in pairs(node.Children) do
        table.insert(out, xvgui.CreateFromNode(parent, v))
    end

    return unpack(out)
end