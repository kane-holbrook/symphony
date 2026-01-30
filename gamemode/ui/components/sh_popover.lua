AddCSLuaFile()

if SERVER then
    return
end

DEFINE_BASECLASS("Rect")

local Popovers = {}

local PANEL = {}
vguix.AccessorFunc(PANEL, "Interactive", "Interactive", "Boolean")
vguix.AccessorFunc(PANEL, "FollowCursor", "FollowCursor", "Boolean")
vguix.AccessorFunc(PANEL, "OffsetX", "OffsetX", "X")
vguix.AccessorFunc(PANEL, "OffsetY", "OffsetY", "Y")

function PANEL:Init()
    self:SetOffsetX(0)
    self:SetOffsetY(0)
    self:SetKeyboardInputEnabled(false)
    self:SetVisible(false)
    self:SetAbsolute(true)
    self:SetDrawOnTop(true)
    self:SetHoverNoLayout(true)
    self.NoLayout = true
end

function PANEL:SetInteractive(interactive)
    self.Interactive = interactive
    if interactive then
        self.TestHover = nil
    else
        self.TestHover = function() return false end
    end
end

function PANEL:Open()
    Popovers[self] = true
    self:SetVisible(true)
    self:InvalidateChildren(true)
    self:MakePopup()

    self.FirstPaint = true
end

function PANEL:Close()
    Popovers[self] = nil
    self:SetVisible(false)
end

function PANEL:Toggle()
    if self:IsVisible() then
        self:Close()
    else
        self:Open()
    end
end

function PANEL:PaintMesh(w, h)
    local p_mesh = self:GetMesh()    
    
    local mat = self:GetMat()
    if isfunction(mat) then
        mat = mat(self, w, h)
    end

    local color = self:GetFill()
    mat:SetVector("$color", color:ToVector())
    mat:SetFloat("$alpha", color.a / 255)

    if IsValid(p_mesh) then
        local m = Matrix()
        local x, y = self:LocalToScreen(0, 0)
        m:Translate(Vector(x, y, 0))
        render.SetMaterial(mat)
        
        cam.PushModelMatrix(m)
            p_mesh:Draw()

            local strokeW = self:GetStrokeWidth()
            if strokeW > 0 then
                
                mat = self:GetStrokeMat()
                if isfunction(mat) then
                    mat = mat(self, w, h)
                end
                
                color = self:GetStroke()
                mat:SetVector("$color", color:ToVector())
                mat:SetFloat("$alpha", color.a / 255)
                
                if mat then
                    render.SetMaterial(mat)
                else
                    render.SetColorMaterial()
                end

                --surface.SetDrawColor(self:GetStroke())
                local s = self:GetShape()
                local count = #s / 2

                local pts   = {}   -- original points
                local norms  = {}  -- unit normals for each edge
                local joins = {}   -- mitered corner points

                -- 1) Build pts[]
                for i = 1, count do
                    pts[i] = Vector(s[2*i-1], s[2*i], 0)
                end

                -- 2) Compute edge normals (90° yaw in Source = 2D perp)
                for i = 1, count do
                    local a = pts[i]
                    local b = pts[i % count + 1]
                    local dir = (b - a):GetNormalized() * strokeW
                    dir:Rotate(Angle(0, 90, 0))        -- yaw by +90° gives CW perp in screen XY
                    norms[i] = dir:GetNormalized()     -- store just the unit perp
                end

                -- 3) Compute miter at each vertex
                for i = 1, count do
                    local prev = (i - 2) % count + 1
                    local n1 = norms[prev]
                    local n2 = norms[i]
                    
                    -- sum the two normals to get bisector direction
                    local bis = (n1 + n2)
                    local bisLen = bis:Length()
                    
                    if bisLen < 1e-6 then
                        -- 180° turn: just offset along one normal
                        joins[i] = pts[i] + n2 * strokeW
                    else
                        bis:Normalize()
                        -- scale so that both offset edges actually meet at this point
                        -- cosθ = bis·n2  ⇒  miterLength = strokeW / cosθ
                        local scale = strokeW / bis:Dot(n2)
                        joins[i] = pts[i] + bis * scale
                    end
                end

                -- 4) Draw one quad per edge between the original edge and its mitered caps
                for i = 1, count do
                    local ni = i % count + 1
                    
                    local a = pts[i]
                    local b = pts[ni]
                    local jA = joins[i]
                    local jB = joins[ni]

                    -- order: a→b→jB→jA
                    render.DrawQuad(a, b, jB, jA, self:GetStroke())
                end

            end
            
        cam.PopModelMatrix()
        render.SetScissorRect(0, 0, 0, 0, false)

    else
        surface.SetMaterial(mat)
        surface.SetDrawColor(self:GetFill())
        surface.DrawTexturedRect(0, 0, w, h)
        
        local strokeW = self:GetStrokeWidth()
        if strokeW > 0 then

            surface.SetDrawColor(self:GetStroke())
            surface.DrawOutlinedRect(0, 0, w, h, strokeW)
        end
    end
end

function PANEL:AfterLayout(w, h)
    self:ChildrenSizeEx() 
    self:Reposition()
end

function PANEL:Reposition()
    if self:GetFollowCursor() then
        local mx, my = gui.MousePos()
        local x = mx + self:GetOffsetX()
        local y = my + self:GetOffsetY()
        
        self:SetPos(x, y)
    else
        local p = self:GetParent()
        local x, y = p:LocalToScreen(0, 0)
        x = x + self:GetOffsetX()
        y = y + self:GetOffsetY()

        self:SetPos(x, y)
    end
end

function PANEL:Paint(w, h) 
    self:Reposition()    
    return BaseClass.Paint(self, w, h)
end


vgui.Register("Popover", PANEL, "Rect")

function ClosePopovers()
    for k, v in pairs(Popovers) do
        if IsValid(k) then
            k:Close()
        end
    end
end

hook.Add("VGUIMousePressed", "PopoverClose", function(pnl, code)
    for k, v in pairs(Popovers) do
        if not IsValid(k) then
            Popovers[k] = nil
            continue
        end

        local p = k:GetParent()

        if p and (pnl == p or p:IsOurChild(pnl)) then
            continue
        end

        k:Close()
    end
end)