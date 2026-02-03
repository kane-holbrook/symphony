AddCSLuaFile()

local MAT = FindMetaTable("IMaterial")

local TypeMap = 
{
    [TYPE_STRING] = function (self, k, v) self:SetString(k, v) end,
    [TYPE_NUMBER] = function (self, k, v) 
        if isinteger(v) then
            self:SetInt(k, v)
        else
            self:SetFloat(k, v) 
        end
    end,
    [TYPE_MATRIX] = function (self, k, v) self:SetMatrix(k, v) end,
    [TYPE_VECTOR] = function (self, k, v) self:SetVector(k, v) end,
    [TYPE_TEXTURE] = function (self, k, v) self:SetTexture(k, v) end,
    [TYPE_NIL] = function (self, k, v) self:SetUndefined(k) end
}

function MAT:SetKeyValue(key, value)
    if istable(value) then
        print(util.TableToKeyValues(value, ""))
        return
    end

    local typ = TypeID(value)
    local f = TypeMap[typ]
    assert(f, "Type " .. type(value) .. " is not valid value for IMaterial")

    f(self, key, value)
end

function MAT:Copy(shader, params, id)
    id = id or uuid()
    shader = shader or self:GetShader()
    local t = self:GetKeyValues()

    if params then
        for k, v in pairs(params) do
            t[k] = v
        end
    end

    local mat = CreateMaterial(id, shader, t)
    for k, v in pairs(t) do
        mat:SetKeyValue(k, v)
    end

    return mat
end

function MAT:Preview()
    local frame = vgui.Create("DFrame")
    frame:SetSize(math.max(self:Width(), 128), math.max(self:Height(), 128))
    frame:SetSizable(true)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle(tostring(self))

    local p = vgui.Create("Panel", frame)
    p:Dock(FILL)

    function p.Paint(pnl, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    PREV = frame
end

function MAT:IsLoaded()
    return self:GetInt("_loading") ~= 1
end

local HTMLMaterials = weaktable(false, true)
function HTMLMaterial(html, w, h, shader)
    if w == 0 or h == 0 or not w or not h then
        return nil
    end
    shader = shader or "UnlitGeneric"
    
    -- Reuse existing materials, if they already exist.
    local key = (shader .. ":" .. w .. ":" .. h .. ":" .. html)
    if HTMLMaterials[key] then
        return HTMLMaterials[key]
    end

    local mat = CreateMaterial(uuid(), shader, { 
        ["$translucent"] = "1",
        ["_loading"] = "1"
    })
    HTMLMaterials[key] = mat

    local dhtml = vgui.Create("DHTML")
    dhtml:SetSize(w, h)
    dhtml:SetAlpha(0)
    dhtml.StartTime = CurTime()

    function dhtml:Think()
        if self:GetHTMLMaterial() then
            self:Remove()

            local htmlMat = self:GetHTMLMaterial()
            
            mat:SetTexture("$basetexture", self:GetHTMLMaterial():GetString("$basetexture"))
            mat:SetMatrix("$basetexturetransform", Matrix({
                { w/htmlMat:Width(), 0, 0, 0 },
                { 0, h/htmlMat:Height(), 0, 0 },
                { 0, 0, 1, 0},
                { 0, 0, 0, 1 }
            }))
            
            mat:SetInt("_loading", 0)
        end

        if CurTime() - dhtml.StartTime > 5 then
            self:Remove()
            Error("DHTML took too long to render; cancelling.")
        end 
    end

    dhtml:SetHTML(html)
    
    html = dhtml

    return mat
end