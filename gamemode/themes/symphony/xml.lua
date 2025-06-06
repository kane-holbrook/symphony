AddCSLuaFile()

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
    local el = { name = "Label", attrs = { Text = string.Trim(text) } }
    self:starttag(el)
    self:endtag(el)
end
parser.__index = parser

function Interface.Parse(xml)
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

local Rect = Theme.Default:GetControl("Rect")
function Rect:CreateFromNode(parent, node, obj)
    obj = obj or self.Theme:Create(self, parent)

    for k, v in pairs(node.Attributes) do
        obj:ParseAttribute(k, v)
    end

    for k, v in pairs(node.Children) do
        obj:ParseChildNode(v)
    end

    return obj
end

function Rect.Prototype:ParseAttribute(name, value)
    local ns = stringex.SubstringBefore(name, ":")
    local pm = self:GetType():GetProperty(name)

    if ns ~= name then
        return self:ParseNamespace(ns, string.sub(name, #ns + 2, -1), value)
    else
        if not pm then
            local f = self["Set" .. name]
            if f then
                f(self, value)
                return true
            end
        else
            local v2 = pm.Type:Parse(value)
            if v2 ~= nil then
                value = v2
            end
        end

        if value ~= nil then
            self:SetProperty(name, value)
        end
    end
    return true
end

function Rect.Prototype:ParseNamespace(ns, name, value)
    if ns == "" then -- ":abc"
        local f = CompileString("return " .. value, "", false)
        if isstring(f) then
            error("Failed to compile expression for " .. ns .. ":" .. name .. f .. "\n[\n" .. value .. "\n]")
        end

        self:SetPropertyComputed(name, f)
        return true
    end

    if ns == "Init" then
        local f = CompileString("return " .. value, "", false)
        if isstring(f) then
            error("Failed to compile expression for " .. ns .. ":" .. name .. ": " .. f .. "\n[\n" .. value .. "\n]")
        end

        setfenv(f, self.Cache)
        self:SetProperty(name, f())
        return true
    elseif ns == "Debug" then
        if name == "Global" then
            _G[value] = self
        end

        self.DebugProperties[name] = value == "true"
        return true
    elseif ns == "Hook" then
        local f = CompileString("return " .. value, "", false)
        if isstring(f) then
            error("Failed to compile expression for " .. ns .. ":" .. name .. ": " .. f .. "\n[\n" .. value .. "\n]")
        end

        setfenv(f, self.Cache)
      
        if string.StartsWith(string.Trim(value), "function") then
            f = f()
        end

        local key = self:GetId() .. ":" .. name
        self.Hooked[name] = { key = key, func = f }

        return true
    elseif ns == "On" then        
        local f = CompileString("return " .. value, "", true)
        setfenv(f, self.Cache)

        if string.StartsWith(string.Trim(value), "function") then
            f = f()
        end

        self:Listen(name, f)
        return true
    end

    error("Unknown namespace: " .. ns)
end

function Rect.Prototype:ParseChildNode(child)
    local typ = self:GetTheme():GetControl(child.Tag)
    assert(typ, child.Tag .. " is not a valid interface component.")

    local e = typ:CreateFromNode(self, child)
    return e
end

local ThemeObj = Type.Theme
function ThemeObj:CreateFromXML(parent, xml)
    local t = Interface.Parse(xml)
    return ThemeObj:CreateFromNode(parent, t)
end

function ThemeObj:RegisterFromXML(name, xml, options)
    local d = Interface.Parse(xml)

    assert(d and d.Children and #d.Children == 1, "Registered components must contain exactly one root XML element")

    d = d.Children[1]

    local base = self:GetControl(d.Tag)
    assert(base, d.Tag .. " does not exist on theme '" .. self.Label .. "'.")

    local t = self:Register(name, base, options)
    t.Xml = d
    return t
end

function ThemeObj:CreateFromNode(parent, t)
    local rtn = {}
    for k, v in pairs(t.Children) do
        local typ = self:GetControl(v.Tag)
        assert(typ, v.Tag .. " is not a valid interface component.")

        local e = typ:CreateFromNode(parent, v)
        if e then
            table.insert(rtn, e)
        end    
    end
    return unpack(rtn)
end