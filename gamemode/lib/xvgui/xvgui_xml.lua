AddCSLuaFile()

local xml2lua = include("xml2lua.lua")

if SERVER then
    return
end

local FuncCache = weaktable(false, true)

xvgui.SpecialTags = {}
xvgui.SpecialAttributes = {}
xvgui.SpecialPrefixes = {}

local parser = {}
function parser:starttag(el, start, fin)
    local vguiElement = {}
    vguiElement.Tag = el.name --vgui.Create(el.name, self.top)
    vguiElement.Start = start
    vguiElement.Finish = fin
    vguiElement.Attributes = {}
    vguiElement.Children = {}
    vguiElement.Parent = self.top

    -- Evaluate attributes here.
    local attrs = el.attrs
    if attrs then
        for k, v in pairs(attrs) do            
            if string.StartsWith(k, ":") then
                k = string.sub(k, 2, string.len(k))
                
                local f
                local code = [[return ]] .. v, k
                if FuncCache[code] then
                    f = FuncCache[code]
                else 
                    f = CompileString(code)
                    FuncCache[code] = f
                end

                vguiElement.Attributes[k] = f
            else
                local tn = tonumber(v)
                if tn then
                    v = tn
                elseif v == "true" or v == "false" then
                    v = v == "true"
                end
                vguiElement.Attributes[k] = v
            end
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


function xvgui.RegisterSpecialTag(name, func)
    xvgui.SpecialTags[name] = func
end

function xvgui.RegisterSpecialAttribute(name, func)
    xvgui.SpecialAttributes[name] = func
end

function xvgui.RegisterSpecialPrefix(prefix, func)
    xvgui.SpecialPrefixes[prefix] = func
end

function xvgui.Parse(xml)
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


function xvgui.CreateFromNode(parent, node, ctx)
    ctx = ctx or {}

    local ds = parent and parent.DefaultSlot
    if ds and (not ctx.IgnoreSlots or ctx.Root == parent) then
        parent = ds
    end

    local st = xvgui.SpecialTags[node.Tag]
    local el
    if st then
        el = st(parent, node, ctx)
        
        if el == true then
            return
        end
    else
        el = vgui.Create(node.Tag, parent)
    end

    if not el then
        return
    end
    
    el.Xml = node
    xvgui.Apply(el)

    -- Attributes
    for k, v in pairs(node.Attributes) do
        local sa = xvgui.SpecialAttributes[k] 
        if sa then
            if sa(el, v, node, ctx) == true then
                continue
            end
        else
            local splitted = string.Split(k, ":")
            if #splitted > 1 then
                local sp = xvgui.SpecialPrefixes[splitted[1]]
                if sp then
                    if sp(el, splitted[2], v, splitted, node, ctx) then
                        continue
                    end
                end
            end

            el:SetProperty(k, v)
        end
    end

    -- Children
    for k, v in pairs(node.Children) do
        xvgui.CreateFromNode(el, v, ctx)
    end

    return el
end

function xvgui.CreateFromXML(parent, xml)
    assert(xml, "Must provide XML")
    local out = {}

    local t = xvgui.Parse(xml)    
    for k, v in pairs(t.Children) do
        table.insert(out, xvgui.CreateFromNode(parent, v))
    end

    return unpack(out)
end

function xvgui.RegisterFromXML(classname, xml)    
    assert(xml, "Must provide XML")

    local t = xvgui.Parse(xml)
    assert(#t.Children == 1, "XML provided has no or multiple root nodes")
    local p = t.Children[1]
    local base = p.Tag

    local panel = {}
    panel.Xml = setmetatable({}, { __index = p })

    function panel:Init()
        xvgui.Apply(self)
        self:LoadXML()
    end

    return vgui.Register(classname, panel, base)
end