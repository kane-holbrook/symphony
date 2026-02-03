AddCSLuaFile()

if SERVER then
    return
end

DEFINE_BASECLASS("Rect")

local PANEL = {}
AccessorFunc(PANEL, "Template", "Template")
AccessorFunc(PANEL, "Each", "Each")

function PANEL:Init()
    self.LastLayout = false
end

function PANEL:SetEach(value)
    self.Each = value

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
        self.Func = CompileString(f, "For")
        setfenv(self.Func, self:GetFuncEnv())
    end
end

function PANEL:BeforeInvalidateLayout(force)
    if self.Func and self.Template then
        self:Refresh()
    end
end

function PANEL:Refresh()
    local data = self.Func()
    self.LastLayout = LayoutMutex

    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    for k, v in pairs(data) do
        local el = vguix.CreateFromXML(self, self:GetTemplate())
        el:SetFuncEnv("Index", k)
        for key, val in pairs(v) do
            el:SetFuncEnv(key, val)
        end
    end
end

function PANEL:PerformLayout(w, h)
    if not self.LastLayout then
        debounce(self, 0, function ()
            self:InvalidateLayout(true)
        end)
        return
    end

    return BaseClass.PerformLayout(self, w, h)
end


function PANEL:ParseXMLText(top, value)
    table.insert(top.Attributes, { Name = "Template", Value = value })
end
PANEL.OverrideXML = true


-- Register the panel
vgui.Register("For", PANEL, "Rect")