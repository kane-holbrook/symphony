AddCSLuaFile()

if SERVER then
    return
end

local FuncCache = weaktable(false, true)

Interface.Attributes = { Panel = {} }
Interface.Attributes.EditablePanel = setmetatable({}, { __index = Interface.Attributes.Panel })
Interface.Attributes.Label = setmetatable({}, { __index = Interface.Attributes.Panel })

Interface.SpecialTags = {}
Interface.SpecialAttributes = {}
Interface.SpecialPrefixes = {}

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
    local el = { name = "Content", attrs = { Text = text } }
    self:starttag(el)
    self:endtag(el)
end
parser.__index = parser
Interface.parser = parser


local function CreateAttributeTable(name)
    local cp = vgui.GetControlTable(name)
    local bc = cp and cp.Base or "Panel"

    if not Interface.Attributes[bc] then
        CreateAttributeTable(bc)
    end

    local bp = Interface.Attributes[bc]

    Interface.Attributes[name] = setmetatable({}, { __index = bp })
    return Interface.Attributes[name]
end

function Interface.RegisterAttribute(name, attr, type)
    local t = Interface.Attributes[name]
    if not t then
        t = CreateAttributeTable(name)
    end

    t[attr] = type
    t["Hover:" .. attr] = type
    t["Selected:" .. attr] = type
    t["Selected:Hover:" .. attr] = type
end

function Interface.GetAttributes(name)
    local t = Interface.Attributes[name]
    if not t then
        t = CreateAttributeTable(name)
    end

    return t
end

function Interface.RegisterSpecialTag(name, func)
    Interface.SpecialTags[name] = func
end

function Interface.RegisterSpecialAttribute(name, func)
    Interface.SpecialAttributes[name] = func
end

function Interface.RegisterSpecialPrefix(prefix, func)
    Interface.SpecialPrefixes[prefix] = func
end

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


    local ds = parent and parent.DefaultSlot
    if ds and (not ctx.IgnoreSlots or ctx.Root == parent) then
        parent = ds
    end

    local st = Interface.SpecialTags[node.Tag]
    local el
    if st then
        el = st(parent, node, ctx)
        
        if el == true then
            return
        end
    else
        local cls = vgui.GetControlTable(node.Tag)
        el = cls:ParseNode(parent, node, ctx)
    end

    if not el then
        return
    end
    
    el.Xml = node
    Interface.Apply(el)

    return el
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



function Interface.IsPanelInitialized(panel)
    return panel.SymInitialized
end

function Interface.Apply(panel)
    if Interface.IsPanelInitialized(panel) then
        return false
    end


    local pl = panel.PerformLayout
    if not pl then
        if istable(panel) then
            PrintTable(panel)
        end
        
        panel.PerformLayout = INTERFACE_PERFORM_LAYOUT
        return true
    end

    panel.PerformLayout = function (p, w, h)
        w, h = INTERFACE_PERFORM_LAYOUT(p, w, h)
        return pl(p, w, h)
    end

    panel.SymInitialized = true
end

Interface.RegisterSpecialTag("Listen", function (parent, node, ctx)
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

Interface.RegisterSpecialTag("For", function (parent, node, ctx)
    local run = node.Attributes["Run"]
    if run then
        parent.ForFunc = CompileString(run, "For")
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
        parent.ForXml = node.Children
    end

    return true
end)

Interface.RegisterSpecialPrefix("Set", function (el, key, value, splitted, node, ctx)
    Interface.SetProperty(el, key, value)
end)

Interface.RegisterSpecialPrefix("Override", function (el, key, value, splitted, node, ctx)
    local f = CompileString([[return ]] .. value, "Override")
    setfenv(f, setmetatable({ self = el }, { __index = _G }))
    el[key] = f()
end)

Interface.RegisterSpecialAttribute("Slot", function (el, value, node, ctx)
    local root = el:GetProperty("Root")

    root.Slots = root.Slots or {}
    root.Slots[value] = el

    if value == "Default" then
        root.DefaultSlot = el
    end
end)

Interface.RegisterSpecialTag("Slot", function (parent, node, ctx)
    local name = node.Attributes["Name"] or "Default"

    parent = parent:GetProperty("Root")
    assert(parent.Slots, "This component has no slots.")
    
    local slot = parent.Slots[name]
    assert(slot, "Invalid slot:" .. name)

    for k, v in pairs(node.Children) do
        local el = Interface.CreateFromNode(slot, v, ctx)
    end
    return true
end)

Interface.RegisterSpecialTag("Style", function (parent, node, ctx)
    
    local ref = node.Attributes["Ref"]
    assert(ref, "Must provide a Ref for <Style> elements.")

    node.Attributes["Ref"] = nil
    parent.Styles = parent.Styles or {}
    parent.Styles[ref] = node.Attributes

    return true
end)

Interface.RegisterSpecialAttribute("Style", function (el, value, node, ctx)
    -- Recurse parents to find the style 
    local p = el:GetParent()
    while p do
        if p.Styles then
            local s = p.Styles[value]
            if s then
                for k, v in pairs(s) do
                    el:SetProperty(k, v)
                end
                return true
            end
        end
        p = p:GetParent()
    end
end)

Interface.RegisterSpecialTag("Content", function (parent, node, ctx)
    return parent:ParseContent(node.Attributes["Text"], node, ctx)
end)

Interface.RegisterSpecialTag("Paint", function (parent, node, ctx)
    assert(#node.Children == 1, "Paint must only be text")

    local txt = node.Children[1].Attributes.Text
    parent.Paint = CompileString([[return function (self, w, h) 
        ]] .. txt .. [[
        end]], "Override:Paint")()
    return true
end)

Interface.RegisterSpecialTag("Think", function (parent, node, ctx)
    assert(#node.Children == 1, "Paint must only be text")

    local txt = node.Children[1].Attributes.Text
    parent.Think = CompileString([[return function (self) 
        ]] .. txt .. [[
        end]], "Override:Think")()
    return true
end)