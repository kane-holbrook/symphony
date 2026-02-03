AddCSLuaFile()


local LAYER = Type.Register("ProcMatLayer", nil, { Abstract = true })

local TEXLAYER = Type.Register("ProcMatTexture", LAYER)
TEXLAYER:CreateProperty("Path", Type.String)
TEXLAYER:CreateProperty("X", Type.Number, { Default = 0 })
TEXLAYER:CreateProperty("Y", Type.Number, { Default = 0 })
TEXLAYER:CreateProperty("Width", Type.Number, { Default = 256 })
TEXLAYER:CreateProperty("Height", Type.Number, { Default = 256 })
TEXLAYER:CreateProperty("Color", Type.Color, { Default = Color(255, 255, 255, 255) })

function TEXLAYER.Prototype:Draw(w, h)
    surface.SetDrawColor(self:GetColor())
    surface.SetMaterial(Material(self:GetPath()))

    surface.DrawTexturedRect(self:GetX(), self:GetY(), self:GetWidth(), self:GetHeight())
end


local COLORMODLAYER = Type.Register("ProcMatColorMod", LAYER)
COLORMODLAYER:CreateProperty("AddR", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("AddG", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("AddB", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("Brightness", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("Contrast", Type.Number, { Default = 1 })
COLORMODLAYER:CreateProperty("Color", Type.Number, { Default = 1 })
COLORMODLAYER:CreateProperty("MulR", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("MulG", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("MulB", Type.Number, { Default = 0 })
COLORMODLAYER:CreateProperty("Inv", Type.Number, { Default = 0 })


local cm = Material("pp/colour")
function COLORMODLAYER.Prototype:Draw(w, h)
    local tab = {}
    tab["$pp_colour_addr"] = self:GetAddR() * 0.02
    tab["$pp_colour_addg"] = self:GetAddG() * 0.02
    tab["$pp_colour_addb"] = self:GetAddB() * 0.02
    tab["$pp_colour_brightness"] = self:GetBrightness()
    tab["$pp_colour_contrast"] = self:GetContrast()
    tab["$pp_colour_colour"] = self:GetColor()
    tab["$pp_colour_mulr"] = self:GetMulR() * 0.1
    tab["$pp_colour_mulg"] = self:GetMulG() * 0.1 
    tab["$pp_colour_mulb"] = self:GetMulB() * 0.1
    tab["$pp_colour_inv"] = self:GetInv()


    render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
    for k, v in pairs(tab) do
        cm:SetFloat(k, v)
        print(k, v)
    end

    surface.SetMaterial(cm)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(0, 0, w, h)
end


local PROCMAT = Type.Register("ProceduralMaterial")
PROCMAT:CreateProperty("Name", Type.String)
PROCMAT:CreateProperty("Shader", Type.String, { Default = "UnlitGeneric" })
PROCMAT:CreateProperty("Width", Type.Number)
PROCMAT:CreateProperty("Height", Type.Number)
PROCMAT:CreateProperty("Data", Type.Table)
PROCMAT:CreateProperty("Layers", Type.Table)

if CLIENT then
    function PROCMAT.Prototype:Generate()        
        local data = self:GetData()
        local mat = CreateMaterial(self:GetName(), self:GetShader(), data)

        for k, v in pairs(data) do
            if IsColor(v) then
                mat:SetVector(k, Vector(v.r / 255, v.g / 255, v.b / 255))
            end
        end

        -- If we have no layers, just return the base material (with any VMT data applied)
        if not self:GetLayers() then
            return mat
        end

        local w, h = self:GetWidth(), self:GetHeight()
        local rt = GetRenderTarget("!" .. self:GetName(), w, h)

        render.PushRenderTarget(rt)
            render.Clear(0, 0, 0, 0, true, true)

            
            cam.Start2D()
                self:Draw(w, h)
            cam.End2D()

        render.PopRenderTarget()
        
        mat:SetTexture("$basetexture", rt)

        self.Material = mat
        
        return mat
    end

    function PROCMAT.Prototype:Draw(w, h)
        for k, v in pairs(self:GetLayers()) do
            v:Draw(w, h, self)
        end
    end

    function PROCMAT.Prototype:GetMaterial()
        return self.Material or self:Generate()
    end
end

function ProceduralMaterial(name)
    local pm = Type.New(PROCMAT)
    pm:SetName(name)
    return pm
end

function PROCMAT.Prototype:AddTexture(path, x, y, width, height, color)
    local layers = self:GetLayers()
    if not layers then
        layers = {}
        self:SetLayers(layers)
    end

    local layer = Type.New(Type.ProcMatTexture)
    layer:SetPath(path)
    layer:SetX(x)
    layer:SetY(y)
    layer:SetWidth(width)
    layer:SetHeight(height)
    layer:SetColor(color or color_white)
    table.insert(layers, layer)
    return layer
end

function PROCMAT.Prototype:AddColorMod(addr, addg, addb, brightness, contrast, color, mulr, mulg, mulb, inv)
    local layers = self:GetLayers()
    if not layers then
        layers = {}
        self:SetLayers(layers)
    end

    local layer = Type.New(Type.ProcMatColorMod)
    layer:SetAddR(addr or 0)
    layer:SetAddG(addg or 0)
    layer:SetAddB(addb or 0)
    layer:SetBrightness(brightness or 0)
    layer:SetContrast(contrast or 1)
    layer:SetColor(color or 1)
    layer:SetMulR(mulr or 0)
    layer:SetMulG(mulg or 0)
    layer:SetMulB(mulb or 0)
    layer:SetInv(inv or 0)
    table.insert(layers, layer)
    return layer
end