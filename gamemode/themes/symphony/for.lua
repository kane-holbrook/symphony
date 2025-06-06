AddCSLuaFile()
if SERVER then
    return
end

local For = Theme.Default:Register("For")
For:CreateProperty("Each", Type.String, {
    Parse = function(pnl, name, value)
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
            pnl.Func = CompileString(f, "For")
            setfenv(pnl.Func, pnl.Cache)
        end
    end
})

function For.Prototype:Initialize()
    base(self, "Initialize")
    self:SetSize("auto", "auto")
    self:SetAlign(7)
    self:SetFlow("Y")
end

function For.Prototype:ParseChildNode(child)
    assert(not self.Template, "For loops must contain only one element")
    self.Template = child
    return nil
end

function For.Prototype:PerformLayout()
    
    local children = table.ClearKeys(self:GetChildren())
    for k, v in pairs(children) do
        v:Dispose()
    end

    assert(self.Template, "For loop without a template")
    if self.Func then
        self.Data = self.Func()

        for k, v in pairs(self.Data) do
            local typ = self.Cache.Theme:GetControl(self.Template.Tag)
            assert(typ, self.Template.Tag .. " is not a valid component within theme " .. self:GetTheme().Label)
            local obj = typ:CreateFromNode(self, self.Template)
            for k2, v2 in pairs(v) do
                if k2 == "_" then continue end
                obj[k2] = v2
                obj:SetProperty(k2, v2)
            end
        end
    end

    base(self, "PerformLayout")
end