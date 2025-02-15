AddCSLuaFile()

if SERVER then
    return
end

local mat = CreateMaterial("test6", "UnlitGeneric", {
    ["$basetexture"] = "vgui/white",
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$translucent"] = 1
})

-- TODO: Fix rotation
function DrawLinearGradient(x, y, w, h, col1, col2, stop, rotation)
    assert(x)
    assert(y)
    assert(w)
    assert(h)
    assert(IsColor(col1))
    assert(IsColor(col2))
    stop = stop or 0.5
    rotation = rotation or 0

    render.SetMaterial(mat)
    render.SetScissorRect(x, y, x + w, y + h, true)

    local m = Matrix()
    m:Translate(Vector(x + w/2, y + h/2))
    m:Scale(Vector(1, 1/stop, 1))
    m:Rotate(Angle(0, rotation, 0))
    m:Translate(Vector(-(x + w/2), -(y + h/2)))
    cam.PushModelMatrix(m, true)

    mesh.Begin(MATERIAL_QUADS, 1)

    ProtectedCall(function ()
        local r, g, b, a = col1:Unpack()
        mesh.Position(Vector(x, y)) -- Top Left
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        mesh.Position(Vector(x + w, y)) -- Top Right
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        r, g, b, a = col2:Unpack()
        mesh.Position(Vector(x + w, y + h)) -- Bottom Right
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()

        mesh.Position(Vector(x, y + h)) -- Bottom Left
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()    
    end)

    mesh.End()

    cam.PopModelMatrix()

    render.SetScissorRect(0, 0, 0, 0, false)
end

function DrawCircularGradient(x, y, w, h, col1, col2, stop)
    assert(x)
    assert(y)
    assert(w)
    assert(h)
    assert(IsColor(col1))
    assert(IsColor(col2))
    stop = stop or 0.5

    local hw = w/2
    local hh = h/2

    render.SetMaterial(mat)
    render.SetScissorRect(x, y, x + w, y + h, true)

    local m = Matrix()
    m:Translate(Vector(x + w/2, y + h/2))
    m:Scale(Vector(1/stop, 1/stop, 1))

    cam.PushModelMatrix(m, true)

    local r, g, b, a = col1:Unpack()
    local r2, g2, b2, a2 = col2:Unpack()


    mesh.Begin(MATERIAL_TRIANGLES, 4)

    ProtectedCall(function ()
        
        -- L
        mesh.Position(Vector(0, 0))
        mesh.Color(r2, g2, b2, a2)
        mesh.AdvanceVertex()

        mesh.Position(Vector(-hw, hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        mesh.Position(Vector(-hw, -hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()

        -- T
        mesh.Position(Vector(0, 0))
        mesh.Color(r2, g2, b2, a2)
        mesh.AdvanceVertex()

        mesh.Position(Vector(-hw, -hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        mesh.Position(Vector(hw, -hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        

        -- R
        mesh.Position(Vector(0, 0))
        mesh.Color(r2, g2, b2, a2)
        mesh.AdvanceVertex()

        mesh.Position(Vector(hw, -hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        mesh.Position(Vector(hw, hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()

        -- B
        mesh.Position(Vector(0, 0))
        mesh.Color(r2, g2, b2, a2)
        mesh.AdvanceVertex()

        mesh.Position(Vector(hw, hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()
        
        mesh.Position(Vector(-hw, hh))
        mesh.Color(r, g, b, a)
        mesh.AdvanceVertex()

        
    end)

    mesh.End()

    cam.PopModelMatrix()

    render.SetScissorRect(0, 0, 0, 0, false)
end

local PANEL = Interface.Register("Gradient", "Rect")
PANEL:CreateProperty("Start", Type.Color)
PANEL:CreateProperty("Stop", Type.Color)
PANEL:CreateProperty("Mid", Type.Number)
PANEL:CreateProperty("Mode", Type.String)

function PANEL.Prototype:Initialize()
    base(self, "Initialize")
    self:SetStart(color_white)
    self:SetStop(color_black)
    self:SetMid(0.5)
    self:SetMode("Linear")
end

function PANEL.Prototype:Paint(w, h)
    base(self, "Paint", w, h)
    self:StartStencil(w, h)
    local x, y = self:GetPanel():LocalToScreen(0, 0)
    if self:GetMode() == "Linear" then
        DrawLinearGradient(x, y, w, h, self:GetStart(), self:GetStop(), self:GetMid())
    else
        DrawCircularGradient(x, y, w, h, self:GetStart(), self:GetStop(), self:GetMid())
    end
    self:FinishStencil()
end