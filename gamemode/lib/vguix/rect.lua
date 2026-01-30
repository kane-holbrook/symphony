AddCSLuaFile()

if SERVER then
    return
end

local bp = FindMetaTable("Panel")



-- Align
-- Gap
-- Flow/Axis
-- 

local PANEL = {}

vguix.AccessorFunc(PANEL, "Fill", "Fill", "Color")
vguix.AccessorFunc(PANEL, "Mat", "Mat", "Material")
AccessorFunc(PANEL, "Shape", "Shape")


PANEL.SetColor = PANEL.SetFill
PANEL.GetColor = PANEL.GetFill

vguix.AccessorFunc(PANEL, "Layout", "Layout", "String")
vguix.AccessorFunc(PANEL, "Align", "Align", "Number")
vguix.AccessorFunc(PANEL, "Gap", "Gap", "X")
AccessorFunc(PANEL, "Flow", "Flow")

AccessorFunc(PANEL, "Columns", "Columns", FORCE_NUMBER)
AccessorFunc(PANEL, "ColumnHeight", "ColumnHeight", FORCE_NUMBER)

AccessorFunc(PANEL, "Stencil", "Stencil", FORCE_BOOL)

vguix.AccessorFunc(PANEL, "StrokeWidth", "StrokeWidth", "X")
vguix.AccessorFunc(PANEL, "Stroke", "Stroke", "Color")
vguix.AccessorFunc(PANEL, "StrokeMat", "StrokeMat", "Material")
AccessorFunc(PANEL, "Mesh", "Mesh")
vguix.AccessorFunc(PANEL, "Blur", "Blur", "X")



vguix.AccessorFunc(PANEL, "PaddingLeft", "PaddingLeft", "X")
vguix.AccessorFunc(PANEL, "PaddingTop", "PaddingTop", "Y")
vguix.AccessorFunc(PANEL, "PaddingRight", "PaddingRight", "X")
vguix.AccessorFunc(PANEL, "PaddingBottom", "PaddingBottom", "Y")

local default_material = CreateMaterial("_default", "UnlitGeneric", { ["$translucent"] = 1 })
vguix.DefaultMaterial = default_material

function PANEL:Init()
    self:SetLayout("Flex")
    self:SetAlign(7)
    self:SetFlow("X")
    self:SetGrow(false)
    self:SetGap(0)
    self:SetAbsolute(false)
    self:SetMargin(0)
    self:SetPadding(0)

    self:SetFill(Color(0, 0, 0, 0))
    self:SetMat(default_material)
    self:SetStrokeWidth(0)
    self:SetStroke(Color(255, 255, 255, 255))
    self:SetComputed("Mesh", function ()
        local shape = self:GetShape()
        if not shape then
            return nil
        end

        local w, h = Width, Height


        -- Meshes
        local m = self:GetMesh() -- or Mesh()
        if IsValid(m) then
            m:Destroy()
        end

        m = Mesh()

        mesh.Begin(m, MATERIAL_TRIANGLES, #shape/2 + 1)
            local cx, cy = w/2, h/2
            local lx, ly = nil

            for i=1, #shape, 2 do
                local x2 = shape[i]
                local y2 = shape[i + 1]     

                mesh.Position(cx, cy, 0)
                mesh.TexCoord(0, 0.5, 0.5)
                mesh.Color(255, 255, 255, 255)
                mesh.AdvanceVertex()

                if lx then
                    mesh.Position(lx, ly, 0)
                    mesh.TexCoord(0, lx/w, ly/h)
                    mesh.Color(255, 255, 255, 255)
                    mesh.AdvanceVertex()
                end

                mesh.Position(x2, y2, 0)
                mesh.TexCoord(0, x2/w, y2/h)
                mesh.Color(255, 255, 255, 255)
                mesh.AdvanceVertex()

                lx = x2
                ly = y2

            end
            
            mesh.Position(cx, cy, 0)
            mesh.TexCoord(0, cx/w, cy/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            local x2, y2 = shape[1], shape[2]

            mesh.Position(cx, cy, 0)
            mesh.TexCoord(0, cx/w, cy/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            
            mesh.Position(lx, ly, 0)
            mesh.TexCoord(0, lx/w, ly/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

            mesh.Position(x2, y2, 0)
            mesh.TexCoord(0, x2/w, y2/h)
            mesh.Color(255, 255, 255, 255)
            mesh.AdvanceVertex()

        mesh.End()

        return m
    end, 10)

    self:SetWide("auto")
    self:SetTall("auto")
    
    self.RectInit = true
end

function PANEL:OnChildAdded(child)
    child:SetZPos(#self:GetChildren())
end

function PANEL:SetMat(mat)
    if isstring(mat) then
        mat = vguix.Parse(self, "Material", mat)
    end
    self.Mat = mat
end

local function IsAlignable(self)
    return self:GetVisible() and not self:GetAbsolute() and not self.NoLayout
end

function PANEL:DebugFlex(...)
    if self.Debug.Flex then
        print(self, ...)
    end
end

function PANEL:ChildrenSizeEx()
    if self:IsWidthAuto() or self:IsHeightAuto() then
        self:DebugFlex("Autosize")
        return self:LayoutChildren(self:GetWidth(), self:GetHeight())
    else
        self:DebugFlex("Predefined size")
        return bp.ChildrenSizeEx(self)
    end
end

function PANEL:LayoutChildren(w, h)

    local layout = self:GetLayout()
    local align = self:GetAlign()

    if layout == "Flex" and align then
        local children = self:GetChildren() -- tablex.SortByMemberEx(self:GetChildren(), "ZPos", true)

        local pl, pt, pr, pb = self:GetPadding()
        assert(isnumber(align) and align <= 9 and align >= 1, "Invalid align: " .. tostring(align))
                        
        local ltr = self:GetFlow() == "X"

        local gap = self:GetGap()
        
        local growElement
        local cw, ch, tw, th = 0, 0, -gap, -gap
        local numNonGrowElements = 0, 0

        for k, v in pairs(children) do
            if not IsAlignable(v) then
                continue
            end

            if v:GetGrow() then
                growElement = v
            else
                local vw = v:GetWidth() + v:GetMarginLeft() + v:GetMarginRight()
                local vh = v:GetHeight() + v:GetMarginTop() + v:GetMarginBottom()

                cw = math.max(cw, vw)
                ch = math.max(ch, vh)
                tw = tw + vw + gap
                th = th + vh + gap

                numNonGrowElements = numNonGrowElements + 1
            end
        end

        tw = math.max(tw, 0)
        th = math.max(th, 0)

        if self:IsWidthAuto() then
            w = ltr and tw + pl + pr or cw + pl + pr
        end

        if self:IsHeightAuto() then
            h = ltr and ch + pt + pb or th + pt + pb
        end

        if growElement then
            local dbg_grow = growElement.Debug["Grow"]
            if ltr then
                local sz = math.Round(w - tw - pl - pr - math.max(0, gap * (numNonGrowElements)), 0)

                if dbg_grow then
                    print(self, "GrowX", "sz: " .. sz, "w: " .. w, "tw: " .. tw, "pl: " .. pl, "pr: " .. pr, "gap: " .. (gap * (numNonGrowElements - 1)), numNonGrowElements)
                end

                growElement:SetWide(sz)
                growElement:SetComputed("Wide", nil)

                --growElement.Width = sz
                --growElement:CalculateBounds():Await()

                local vw = sz + growElement:GetMarginLeft() + growElement:GetMarginRight()
                cw = math.max(cw, vw)
                tw = tw + vw + gap
            else
                local sz = math.Round(h - th - pt - pb - math.max(0, gap * (numNonGrowElements)), 0)

                
                if dbg_grow then
                    print(self, "GrowY", "sz: " .. sz, "w: " .. w, "tw: " .. tw, "pl: " .. pl, "pr: " .. pr, "gap: " .. (gap * (numNonGrowElements - 1)), numNonGrowElements)
                end

                growElement:SetTall(sz)
                growElement:SetComputed("Tall", nil)
                --growElement.Height = sz
                --growElement:CalculateBounds():Await()

                local vh = sz + growElement:GetMarginTop() + growElement:GetMarginBottom()
                ch = math.max(ch, vh)
                th = th + vh + gap
            end
        end


        local x, y
        if isany(align, 7, 4, 1) then
            x = pl
        elseif isany(align, 9, 6, 3) then
            x = w - pr
        else 
            x = w/2 - tw/2
        end

        if isany(align, 7, 8, 9) then
            y = pt
        elseif isany(align, 1, 2, 3) then
            y = h - pt
        else 
            y = h/2 - th/2
        end

        for k, v in pairs(children) do
            if not IsAlignable(v) then
                continue
            end
            
            local ml, mt, mr, mb = v:GetMargin()
            if ltr then
            
                if isany(align, 7, 4, 1, 8, 5, 2) then
                    x = x + ml
                    v:SetX(x)
                    x = x + v:GetWidth() + gap + mr
                    h = math.max(h, pt + v:GetHeight() + mb + mt + pb)
                else
                    x = x - v:GetWidth() - mr
                    v:SetX(x)
                    x = x - ml - gap

                    h = math.max(h, pt + v:GetHeight() + mb + mt)
                end
                
                if isany(align, 4, 5, 6) then
                    v:SetY((h/2) - (v:GetHeight()/2))
                elseif isany(align, 1, 2, 3) then
                    v:SetY(h - v:GetHeight() - pb)
                else
                    v:SetY(y + mt)
                end
            else
                if isany(align, 7, 8, 9, 4, 5, 6) then
                    y = y + mt
                    v:SetY(y)
                    y = y + v:GetHeight() + gap + mb
                    w = math.max(w, pl + v:GetWidth() + mr + ml)
                else
                    y = y - v:GetHeight() - mb
                    v:SetY(y)
                    y = y - mt - gap

                    w = math.max(w, pl + v:GetWidth() + mr + ml)
                end
                
                if isany(align, 8, 5, 2) then
                    v:SetX((w/2) - (v:GetWidth()/2))
                elseif isany(align, 9, 6, 3) then
                    v:SetX(w - v:GetWidth() - pr - mr)
                else
                    v:SetX(x + ml)
                end
            end
        end
        self:DebugFlex("Flex result -", w, h, debug.getinfo(2).short_src, debug.getinfo(2).currentline)

        return w, h
    end
end

function PANEL:PerformLayout(w, h)
    if not self:IsWidthAuto() and not self:IsHeightAuto() then
        self:LayoutChildren(w, h)
    end
end

--[[function PANEL:SetFill(fill)
    if isstring(fill) then
        fill = vguix.Parse("Color", fill)
    end
    self.Fill = fill
end--]]

function PANEL:CopyShape(pnl, w, h)
    local f = self:GetComputed("Shape")
    if not f then
        error("No shape defined for parent panel")
    end

    return f.Func(self, w, h)
end

function PANEL:SetPadding(left, top, right, bottom)
    assert(left, "Padding requires at least a left value")

    if isstring(left) and not top then
        left, top, right, bottom = unpack(string.Split(left, ","))
    end

    top = top or left
    right = right or left
    bottom = bottom or top

    self:SetPaddingLeft(left)
    self:SetPaddingTop(top)
    self:SetPaddingRight(right)
    self:SetPaddingBottom(bottom)
end

function PANEL:GetPadding()
    return self:GetPaddingLeft(), self:GetPaddingTop(), self:GetPaddingRight(), self:GetPaddingBottom()
end

function PANEL:GetScissorRect()
    local x, y, w, h = 0, 0, ScrW(), ScrH()

    local tgt = self
    while tgt do
        local x2, y2 = tgt:LocalToScreen(0, 0)
        local w2, h2 = tgt:GetSize()
        
        w = math.min(w, x2 + w2 - x)
        h = math.min(h, y2 + h2 - y)
        x = math.max(x, x2)
        y = math.max(y, y2)

        if tgt:IsPopup() or tgt:IsModal() then
            break
        end

        tgt = tgt:GetParent()
    end

    return x, y, w, h
end

local blur = Material("pp/blurscreen")
function PANEL:PaintMesh(w, h)
    local p_mesh = self:GetMesh()    

    if self:GetStencil() then
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)

        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

        surface.SetDrawColor(255, 255, 255, 255)
        if IsValid(p_mesh) then
            local m = Matrix()
            local x, y = self:LocalToScreen(0, 0)
            m:Translate(Vector(x, y, 0))
            cam.PushModelMatrix(m, true)
                p_mesh:Draw()
            cam.PopModelMatrix()
        else
            surface.DrawRect(0, 0, w, h)
        end

        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    end
    
    
    local x, y = self:LocalToScreen(0, 0)
    
    local mat = self:GetMat()
    if isfunction(mat) then
        mat = mat(self, w, h)
    end

    local color = self:GetFill()
    assert(color, "No Fill color")

    mat:SetVector("$color", color:ToVector())
    mat:SetFloat("$alpha", color.a / 255)

    
    if self:GetBlur() then
        
        surface.SetMaterial(blur)
        surface.SetDrawColor(255, 255, 255, 255)
        blur:SetFloat("$blur", self:GetBlur())
        blur:Recompute()
        render.UpdateScreenEffectTexture()

        surface.DrawTexturedRectUV(0, 0, w, h, x / ScrW(), y / ScrH(), (x + w) / ScrW(), (y + h) / ScrH())
    end
    
    if IsValid(p_mesh) then
        local m = Matrix()
        m:Translate(Vector(x, y, 0))

        -- Sort out scissor rects.
        do
            local sx, sy, sw, sh = self:GetScissorRect()       
            render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
        end

        cam.PushModelMatrix(m, true)
        
            
            render.SetMaterial(mat)
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
        render.SetScissorRect(0, 0, ScrW(), ScrH(), false)

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

-- fuck you garbage collection >:()
function PANEL:Paint(w, h)
    self:PaintMesh(w, h)
end

function PANEL:PaintOver(w, h)
    render.SetStencilEnable(false)
end


function PANEL:OnMousePressed( mousecode )
	if ( self:IsSelectionCanvas() && !dragndrop.IsDragging() ) then
		self:StartBoxSelection()
		return
	end

	if ( self:IsDraggable() ) then

		self:MouseCapture( true )
		self:DragMousePress( mousecode )

	end


end

function PANEL:OnMouseReleased( mousecode )

    
	if ( self:EndBoxSelection() ) then return end

	self:MouseCapture( false )

	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end
    

end

function PANEL:OnRemove()
    if self:GetMesh() then
        self:GetMesh():Destroy()
    end
end

vgui.Register("Rect", PANEL, "EditablePanel")




local PANEL = {}
function PANEL:SetSrc(src)
    self:SetMat(src)
end

vgui.Register("Image", PANEL, "Panel")