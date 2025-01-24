AddCSLuaFile()
AddCSLuaFile("xml2lua/xml2lua.lua")

if SERVER then
    return
end


xvgui = xvgui or {}
local xml2lua = include("xml2lua/xml2lua.lua")

local parser = {}

local skip = {
    ["Ref"] = true,
    [":Ref"] = true,
    ["For"] = true,
    [":For"] = true
}

local function PerformLayout(self, w, h)
    local attr = self.Attributes or {} 
    self.FuncEnv = self.FuncEnv or setmetatable({}, { __index = self:GetParent().FuncEnv or _G })

    local forAttr = attr["For"]
    if forAttr then
        local data = forAttr.Func()
        

        for k, v in pairs(forAttr.Children) do
            if v.RefParent then
                if istable(v.RefParent[v.Ref]) then
                    table.RemoveByValue(v.RefParent[v.Ref], v)
                end
            end
            
            if IsValid(v) then
                v:Remove()
            end
        end

        forAttr.Children = {}

        
        if #data == 0 then
            self:SetDisplay(DISPLAY_HIDDEN)
            return self:_PerformLayout(w, h)
        else
            self:SetDisplay(DISPLAY_VISIBLE)
        end

        local idx = 1
        local class = self:GetName()
        local parent = self:GetParent()

        local first = true
        for k, v in pairs(data) do
            if first then
                for k2, v2 in pairs(v) do
                    self.FuncEnv[k2] = v2
                end
                first = false
            else
                local el = self:Clone(self:GetParent(), v)
                forAttr.Children[idx] = el
                idx = idx + 1

                el:InvalidateLayout(true)
            end
        end
    end

    for k, v in pairs(attr) do
        if skip[k] then
            continue
        end

        local initial 
        if self["Get" .. k] then
            initial = { self["Get" .. k](self) }
        end

        local new
        if isfunction(v) then
            setfenv(v, self.FuncEnv)
            new = { v() }
        else
            new = { v }
        end

        if initial then
            local skip = true
            for k, v in pairs(new) do
                if initial[k] ~= v then
                    skip = false
                end
            end

            if skip then
                continue
            end
        end

        if isfunction(self["Set" .. k]) then
            self["Set" .. k](self, unpack(new))
        elseif isfunction(self[k]) then
            self[k](self, unpack(new))
        else
            error("No such method: Set" .. k .. "(...)/" .. k .. "(...)")
        end

    end

    if self._PerformLayout then
        return self:_PerformLayout(w, h)
    else
        return w, h
    end
end

function parser:starttag(el)
    local vguiElement = vgui.Create(el.name, self.top)
    --vguiElement._PerformLayout = vguiElement.PerformLayout
    --vguiElement.PerformLayout = PerformLayout

    if self.top == self.root then
        table.insert(self.first, vguiElement)
    end

    -- Evaluate attributes here.
    local attrs = el.attrs
    local calcAttr = {}
    if attrs then
        local refAttr = attrs["Ref"]
        if refAttr then
            vguiElement.Ref = refAttr
            
            local wp = vgui.GetWorldPanel()
            for i=#self.stack, 1, -1 do
                local p = self.stack[i]
                if p.Ref then
                    local t = p[refAttr]
                    if istable(t) then
                        table.insert(t, vguiElement)
                    elseif t then
                        p[refAttr] = { t, vguiElement }
                    else
                        p[refAttr] = vguiElement
                    end
                    vguiElement.RefParent = p
                    break
                elseif p == wp then
                    p = self.stack[i+1]
                    local t = p[refAttr]
                    if istable(t) then
                        table.insert(t, vguiElement)
                    elseif t then
                        p[refAttr] = { t, vguiElement }
                    else
                        p[refAttr] = vguiElement
                    end
                    vguiElement.RefParent = p
                    break
                end
            end
        end

        local forAttr = attrs[":For"]
        if forAttr then
            local splitted = string.Split(forAttr, " in ")
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

                calcAttr["For"] = { Func = CompileString(f), Children = {} }
            end
        end

        for k, v in pairs(attrs) do
            if skip[k] or skip[":" .. k] then
                continue
            end
            
            if string.StartsWith(k, ":") then
                k = string.sub(k, 2, string.len(k))
                local f = CompileString([[return ]] .. v)
                vguiElement:SetProperty(k, f)
                --calcAttr[k] = f
            else
                vguiElement:SetProperty(k, v)
                --calcAttr[k] = v
            end
        end
        
        --vguiElement.Attributes = calcAttr
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
    --[[local tag = {
        name = "Label",
        attrs = { [":Dock"] = "LEFT" }
    }--]]
    --[[local tag = {
        name = "SymLabel",
        attrs = { }
    }--]]

    tag.attrs.Text = text
    self:starttag(tag)
    self:endtag(tag)
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

function PANEL_META:Clone(parent, funcEnv)
    local parent = parent or self:GetParent()
    local el = vgui.Create(self:GetName(), parent)

    el.FuncEnv = setmetatable({}, { __index = parent.FuncEnv or _G })

    if funcEnv then
        for k2, v2 in pairs(funcEnv) do
            el.FuncEnv[k2] = v2
        end
    end

    local newAttr = table.Copy(self.Attributes)
    newAttr["For"] = nil
    el.Attributes = newAttr

    local Ref = self.Ref
    if Ref then 
        local p = self.RefParent
        el.Ref = Ref
        el.RefParent = p

        local t = p[Ref]
        if istable(t) then
            table.insert(t, el)
        elseif t then
            p[Ref] = { t, el }
        else
            p[Ref] = el
        end
    end

    el._PerformLayout = el.PerformLayout
    el.PerformLayout = PerformLayout

    for k, v in pairs(self:GetChildren()) do
        v:Clone(el)
    end
    return el
end

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
