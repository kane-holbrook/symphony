AddCSLuaFile()


local xml2lua = include("xml2lua/xml2lua.lua")

if SERVER then
    return
end

local parser = {}
function parser:starttag(el, start, fin)
    local vguiElement = {}
    vguiElement.Tag = el.name
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
    local cp = vgui.GetControlTable(self.top.Tag)
    if cp and cp.ParseXMLText then
        self.top.Attributes = self.top.Attributes or {}
        cp:ParseXMLText(self.top, text)
    else
        local el = { name = "Text", attrs = { { Name = "Value", Value = string.Trim(text) } } }
        self:starttag(el)
        self:endtag(el)
    end
end
parser.__index = parser

local label = vgui.GetControlTable("DLabel")
function label:ParseXMLText(top, value)
    table.insert(top.Attributes, { Name = "Text", Value = value })
    table.insert(top.Attributes, { Name = "ContentAlignment", Value = 7 })
    table.insert(top.Attributes, { Name = "Wrap", Value = true })
    table.insert(top.Attributes, { Name = "Width", Value = "100%" })
end

local html = vgui.GetControlTable("DHTML")
function html:ParseXMLText(top, value)
    table.insert(top.Attributes, { Name = "HTML", Value = value })
end
html.OverrideXML = true

function vguix.ParseXML(xml)
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
        errorHandler = function(errMsg, pos) 
            if pos then
                local ln_start
                local ln_end

                for i=pos, 1, -1 do
                    if xml[i] == "\n" then
                        ln_start = i
                        break
                    end
                end

                for i=pos, #xml do
                    if xml[i] == "\n" then
                        ln_end = i - 1
                        break
                    end
                end

                local ln = string.sub(xml, ln_start or 1, ln_end or #xml)
                error(string.format("%s [char=%d; %s]\n", errMsg or "Parse Error", pos, ln))
            else
                error(string.format("%s [char=%d]\n", errMsg or "Parse Error", pos)) 
            end
        end
    })

    eval:parse(xml)
    return p.top
end

local function SmartCompileString(str, name, handleError)
    str = string.Trim(str)
    if string.StartsWith(str, "function ") or string.StartsWith(str, "function(") then
        return CompileString("return " .. str, name, handleError)()
    else
        return CompileString("return " .. str, name, handleError)
    end
end

vguix.Namespaces = {
    { 
        { "Number", "n" }, 
        function (pnl, k, v)
            return tonumber(v)
        end
    },

    { 
        { "Boolean", "Bool", "b" }, 
        function (pnl, k, v)
            return v == "true" or v == "1"
        end
    },
    { 
        { "String" }, 
        function (pnl, k, v)
            return tostring(v)
        end
    },
    { 
        { "Color", "c" },
        function (pnl, k, v)
            if v == "white" then
                return Color(255, 255, 255, 255)
            end
            
            local parts = string.Split(v:Replace("Color", ""):Replace("(", ""):Replace(")", ""), ",")
            return Color(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]) or 255)
        end
    },
    { 
        { "Vector", "v" }, 
        function (pnl, k, v)
            local parts = string.Split(v, ",")
            return Vector(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
        end
    },
    {
        { "Function", "Func", "f" },
        function (pnl, k, v)
            local f = SmartCompileString(v, "vguix.ParseNode", true)
            setfenv(f, pnl:GetFuncEnv())
            pnl[k] = f
            return 
        end
    },
    {
        { "Hook", "Hook", "f" },
        function (pnl, k, v)
            local f = SmartCompileString(v, "vguix.ParseNode", true)
            setfenv(f, pnl:GetFuncEnv())
            hook.Add(k, self, f)
            return 
        end
    },
    {
        { "Init" },
        function (pnl, k, v)
            local f = SmartCompileString(v, string.format([[<%s Init:%s="%s">]], pnl.ClassName, k, v), true)
            setfenv(f, pnl:GetFuncEnv())
            local val = f()
            pnl.FuncEnv[k] = val 
            return val
        end
    },
    {
        { "First", "PostInit" },
        function (pnl, k, v)
            local f = SmartCompileString(v, string.format([[<%s First:%s="%s">]], pnl.ClassName, k, v), true)
            setfenv(f, pnl:GetFuncEnv())

            pnl.PostInitFuncs = pnl.PostInitFuncs or {}
            pnl.PostInitFuncs[k] = val 
            return val
        end
    },
    {
        { "", "Layout", tonumber }, -- ":", alias for Layout
        function (pnl, k, v, n)
            local f = SmartCompileString(v, string.format([[<%s ... :%s="%s">]], pnl.ClassName, k, v), true)
            pnl:SetComputed(k, f, tonumber(n))
        end
    },
    {
        { "Material", "Mat", "m" },
        function (pnl, k, v)
            local mat = Material(v, "noclamp smooth")
            if mat:IsError() then
                ErrorNoHalt(string.format("Invalid material '%s' for attribute '%s' in panel '%s'", v, k, pnl.ClassName))
            end
            return mat
        end
    },
    {
        { "X" },
        function (pnl, k, v)
            if isstring(v) then
                v = vguix.ParseExtent(v)
                if iscallable(v) then
                    pnl:SetComputed(k, v)
                    return nil
                end
            end

            return v
        end
    },
    {
        { "Y" },
        function (pnl, k, v)
            if isstring(v) then
                v = vguix.ParseExtent(v, true)
                if iscallable(v) then
                    pnl:SetComputed(k, v)
                    return nil
                end
            end

            return v
        end
    },
    {
        { "Debug" },
        function (pnl, k, v)
            if k == "Global" then
                _G[v] = pnl
            else
                pnl.Debug[k] = v
            end
            return nil
        end
    },
    {
        { "Receiver" },
        function (pnl, k, v)
            
            local f = SmartCompileString(v, string.format([[<%s Receiver:%s="%s">]], pnl.ClassName, k, v), true)
            setfenv(f, pnl:GetFuncEnv())
            pnl:Receiver(k, f)
            return nil
        end
    }
}

function vguix.Parse(pnl, name, value, key)
    assert(name, "Namespace name cannot be nil: " .. tostring(name) .. ":" .. tostring(key))
    for _, t in pairs(vguix.Namespaces) do
        for _, n in pairs(t[1]) do
            if isfunction(n) then
                if n(name) then
                    return t[2](pnl, key, value, name)
                end
            elseif string.lower(n) == string.lower(name) then
                return t[2](pnl, key, value, name)
            end
        end
    end
    error("Unknown namespace: '" .. name .. "' with value '" .. tostring(value) .. "'")
end

function vguix.AccessorFunc(tab, key, name, namespace, isBody)
    AccessorFunc(tab, key, name)

    local f = tab["Set" .. name]
    if f then
        if not tab["_Set" .. name] then
            tab["_Set" .. name] = f
        end
    end

    tab["Set" .. name] = function (pnl, value)
        if isstring(value) then
            value = vguix.Parse(pnl, namespace, value, name)
            
            if not value then
                local c = pnl.Computed[name]

                if c then
                    value = c.Func(pnl, pnl:GetWide(), pnl:GetTall())
                end
            end
        end

        pnl[key] = value
        pnl:GetFuncEnv()[key] = value
        if f then
            f(pnl, value)
        end
    end

    if isBody then 
        function tab:ParseXMLText(top, value)
            table.insert(top.Attributes, { Name = name, Value = value })
        end
    end
end

local function ApplyProperties(pnl, node)
    local fe = pnl:GetFuncEnv()
    for _, t in pairs(node.Attributes) do
        local k = t.Name
        local v = t.Value

        if k == "Width" then
            pnl:SetComputed("Wide", nil)
        elseif k == "Height" then
            pnl:SetComputed("Tall", nil)
        else
            pnl:SetComputed(k, nil)
        end

        local ns = string.Split(k, ":")[1]
        if ns ~= k then
            k = string.sub(k, #ns + 2) -- remove namespace prefix
            v = vguix.Parse(pnl, ns, v, k)
        else
            local tn = tonumber(v)
            if tn then
                v = tn
            elseif v == "true" then
                v = true
            elseif v == "false" then
                v = false
            end
        end

        if v == nil then
            continue
        end

        local f = pnl["Set" .. k] or pnl[k]
        if isfunction(f) then
            f(pnl, v)
        else
            pnl[k] = v
            fe[k] = v
        end
    end
end

function vguix.CreateFromNode(parent, node)    
    local pnl
    if node.Tag == "Override" then
        local tgt 
        for _, v in pairs(node.Attributes) do
            if v.Name == "Name" then
                tgt = v.Value
                break
            end
        end

        assert(tgt, "Override tag must have a 'Name' attribute")
        pnl = parent[tgt]
        assert(pnl, "Override tag must target an existing panel (" .. tgt .. ")")
    elseif node.Tag == "Remove" then
        local tgt 
        for _, v in pairs(node.Attributes) do
            if v.Name == "Name" then
                tgt = v.Value
                break
            end
        end

        assert(tgt, "Remove tag must have a 'Name' attribute")
        assert(parent[tgt], "Remove tag must target an existing panel (" .. tgt .. ")")
        parent[tgt]:Remove()
        return nil
    elseif node.Tag == "Listen" then
        local event, children, immediate, func
        for _, v in pairs(node.Attributes) do
            if v.Name == "Event" then
                event = v.Value
            elseif v.Name == "Immediate" then
                immediate = v.Value == "true" or v.Value == "1"
            elseif v.Name == "Children" then
                children = v.Value == "true" or v.Value == "1"
            elseif v.Name == "Func" then
                func = SmartCompileString(v.Value, "vguix.CreateFromNode.Listen", true)
            end
        end

        assert(event, "Listen tag must have an 'Event' attribute")
        hook.Add(event, parent, func or function ()
            if children then
                parent:InvalidateChildren(true, immediate)
            else
                parent:InvalidateLayout(immediate)
            end
        end)
        return nil
    else
        pnl = vgui.Create(node.Tag, parent)
    end

    if node.Attributes then
        ApplyProperties(pnl, node)
    end

    for k, v in pairs(node.Children) do
        vguix.CreateFromNode(pnl, v)
    end

    return pnl
end

function vguix.CreateFromXML(parent, xml)
    assert(xml, "XML string cannot be nil")
    local parsed = vguix.ParseXML(xml)

    local out = {}
    for k, v in pairs(parsed.Children) do
        local el = vguix.CreateFromNode(parent, v)
        if el then
            table.insert(out, el)
        end
    end

    return unpack(out)
end

function vguix.RegisterFromXML(name, xml)
    local t = vguix.ParseXML(xml)
    assert(#t.Children == 1, "XML must have exactly one root element")
    t = t.Children[1]

    local hasName = false
    for k, v in pairs(t.Attributes) do
        if v.Name == "Name" then
            hasName = true
            break
        end
    end
    assert(hasName, "XML must have a 'Name' attribute for the root element")

    local base = t.Tag

    local PANEL = {}
    function PANEL:BeforeInit()

        if t.Attributes then
            ApplyProperties(self, t)
        end

        for k, v in pairs(t.Children) do
            vguix.CreateFromNode(self, v)
        end
    end

    vgui.Register(name, PANEL, base)
    return PANEL
end