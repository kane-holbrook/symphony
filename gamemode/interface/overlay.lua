AddCSLuaFile()

if SERVER then
    return
end

-- Overlay
local Overlay = Interface.Register("Overlay", PNL)
do
    Overlay:CreateProperty("ShowOnHover", Type.Boolean, { Default = true })
    function Overlay.Prototype:Initialize()
        base(self, "Initialize")

        self:SetAbsolute(true)
        self:SetVisible(false)
    end
    
    function Overlay.Prototype:Paint(asOverlay)
        local m = Matrix()
        local parent = self:GetParent()
        m:Translate(parent.AbsolutePos)
        m:Translate(Vector(self:Compute("X"), self:Compute("Y"), 0))

        cam.PushModelMatrix(m)

            self.AbsolutePos = cam.GetModelMatrix():GetTranslation()
            self.AbsolutePos.x = self.AbsolutePos.x + self:GetMarginLeft()
            self.AbsolutePos.y = self.AbsolutePos.y + self:GetMarginTop()

            -- Handle animations first.
            for k, v in pairs(self.Animations) do
                local p = (CurTime() - v.Start) / v.Duration
                if p >= 1 then
                    self:SetProperty(k, v.To)
                    
                    if isany(k, "Width", "Height") then
                        self:InvalidateLayout()
                    end

                    if v.Repetitions > 1 then
                        v.Repetitions = v.Repetitions - 1
                        v.Start = CurTime()
                        v.From, v.To = v.To, v.From
                    else
                        self.Animations[k] = nil
                        v:Complete(true)
                    end
                else
                    local from = v.From
                    local to = v.To
                    local val
                    
                    if istable(from) then
                        val = table.Copy(from)

                        for k2, v2 in pairs(from) do
                            if not isnumber(v2) then
                                continue
                            end
                            val[k2] = v2 + (to[k2] - v2) * v.EaseFunc(p)
                        end
                    else
                        val = v.From + (v.To - v.From) * v.EaseFunc(p)
                    end

                    self:SetProperty(k, val)
                end

                if isany(k, "Width", "Height") then
                    self:InvalidateLayout()
                end
            end

            local parent = self:GetParent()
            local pw, ph = parent and parent:GetWidth(), parent and parent:GetHeight()
            local w, h = self:GetWidth(), self:GetHeight()
            local x, y = self:GetX(), self:GetY()

            if not w or not h then
                return
            end
            self:Compute("Visible")

            local alpha = surface.GetAlphaMultiplier()
            local newAlpha = alpha * (self:Compute("Alpha") / 255)

            surface.SetAlphaMultiplier(newAlpha)

            self.RenderBounds.x = self.AbsolutePos.x --, (parent and parent.RenderBounds.x + parent:GetPaddingLeft()) or 0)
            self.RenderBounds.y = self.AbsolutePos.y -- math.max(self.AbsolutePos.y, (parent and parent.RenderBounds.y + parent:GetPaddingTop()) or 0)
            self.RenderBounds.w = self.AbsolutePos.x + w --, (parent and parent.RenderBounds.w - parent.PaddingRight) or ScrW())
            self.RenderBounds.h = self.AbsolutePos.y + h --, (parent and parent.RenderBounds.h - parent.PaddingBottom) or ScrH())

            if asOverlay and IsValid(self.Mesh) then

                if self:GetCull() then
                    self:SetScissorRect()
                end

                    local m = Matrix()
                    m:Translate(Vector(self:GetMarginLeft(),  self:GetMarginTop(), 0))

                    cam.PushModelMatrix(m, true)
                        self:PaintMesh()
                        self:PaintStroke()

                        self:PaintChildren()
                    cam.PopModelMatrix()

                    render.SetScissorRect(0, 0, 0, 0, false)
                
                    
                    if VisualizeLayout:GetBool() then
                        
                        surface.SetAlphaMultiplier(self:GetVisible() and 1 or 0.05)

                        surface.SetDrawColor(Color(128, 255, 255, 225))
                        surface.DrawOutlinedRect(
                            0, 0,
                            self:GetOuterWidth(),
                            self:GetOuterHeight(),
                            2
                        )
                        
                        -- Margin bounds
                        cam.PushModelMatrix(m, true)
                            surface.SetDrawColor(Color(255, 255, 0, 225))
                            surface.DrawOutlinedRect(
                                0, 0,
                                self:GetWidth(),
                                self:GetHeight(),
                                2
                            )

                            -- Inner bounds
                            m = Matrix()
                            m:Translate(Vector(
                                self:GetPaddingLeft(),
                                self:GetPaddingTop(),
                                0
                            ))
                            cam.PushModelMatrix(m, true)
                                surface.SetDrawColor(Color(255, 0, 255, 225))
                                surface.DrawOutlinedRect(
                                    0, 0,
                                    self:GetInnerWidth(),
                                    self:GetInnerHeight(),
                                    2
                                )
                                

                                if self.ContentWidth and self.ContentHeight then
                                    surface.SetDrawColor(Color(0, 255, 0, 100))
                                    local align = self:GetAlign()
                                    
                                    local x, y = 0, 0
                                    if isany(align, 8, 5, 2) then
                                        x = self:GetInnerWidth()/2 - self.ContentWidth/2
                                    elseif isany(align, 9, 6, 3) then
                                        x = self:GetInnerWidth() - self.ContentWidth
                                    end

                                    if isany(align, 4, 5, 6) then
                                        y = self:GetInnerHeight()/2 - self.ContentHeight/2
                                    elseif isany(align, 1, 2, 3) then
                                        y = self:GetInnerHeight() - self.ContentHeight
                                    end

                                    surface.DrawOutlinedRect(
                                        x,
                                        y,
                                        self.ContentWidth,
                                        self.ContentHeight,
                                        2
                                    )
                                end
                            cam.PopModelMatrix()
                        cam.PopModelMatrix()

                        
                        surface.SetAlphaMultiplier(1)
                        if CurTime() - self.LastLayout < 0.5 then
                            local elapsed = CurTime() - self.LastLayout
                            local alpha = math.Clamp(1 - (elapsed * 2), 0, 1) * 255

                            surface.SetDrawColor(Color(255, 255, 0, alpha))
                            surface.DrawOutlinedRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight(), 2)
                            surface.SetDrawColor(Color(255, 0, 0, alpha))
                            surface.DrawRect(0, 0, self:GetOuterWidth(), self:GetOuterHeight())
                        end
                    end
                surface.SetAlphaMultiplier(alpha)
            end
        cam.PopModelMatrix()
    end


    function Overlay.Prototype:PreOpen()
    end

    function Overlay.Prototype:Open()
        return Promise.Run(function ()
            if not self:IsOpen() then
                self:PreOpen()

                self:SetVisible(true)
                self:InvalidateLayout(true, true)
                table.insert(self:GetHost().Overlays, self)
                table.insert(self:GetHost():GetChildren(), self)
                
                self:PostOpen()
            end
        end)
    end

    function Overlay.Prototype:PostOpen()
    end
    
    function Overlay.Prototype:IsOpen()
        return self:GetVisible()
    end

    function Overlay.Prototype:Toggle()
        if self:IsOpen() then
            self:Close()
        else
            self:Open()
        end
    end

    function Overlay.Prototype:PreClose()
    end

    function Overlay.Prototype:Close()
        return Promise.Run(function ()
            self:PreClose()
            self:SetVisible(false)
            table.RemoveByValue(self:GetHost():GetChildren(), self)
            table.RemoveByValue(self:GetHost().Overlays, self)
            self:PostClose()
        end)
    end

    function Overlay.Prototype:PostClose()
    end

    function Overlay.Prototype:StartHover(src, last)
        if self:Compute("ShowOnHover") then
            self:Open()
        end
    end

    function Overlay.Prototype:EndHover(src, new)
        if not self:Compute("ShowOnHover") then
            return
        end

        local p = new
        while p do
            -- If it's the same panel or one of our children, we don't close the overlay since we're effectively still hovered.
            if p == self:GetParent() then
                return
            end
            p = p:GetParent()
        end

        self:Close()
    end

    function Overlay.Prototype:OnDisposed()
        base(self, "OnDisposed")
        table.RemoveByValue(self:GetHost():GetChildren(), self)
    end
end