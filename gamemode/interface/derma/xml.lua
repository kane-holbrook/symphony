
if SERVER then
    return
end


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
Interface.Parser = parser

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

function Interface.CreateFromNode(parent, node)
    local control = vgui.GetControlTable(node.Tag)
    assert(control, "Invalid VGUI type: " .. tostring(node.Tag))

    return control:ParseNode(parent, node)
end

function Interface.CreateFromXML(parent, xml)
    assert(xml, "Must provide XML string")

    local node = Interface.Parse(xml)
    local out = {}
    for k, v in pairs(node.Children) do
        out[k] = Interface.CreateFromNode(parent, v)
    end
    return unpack(out)
end