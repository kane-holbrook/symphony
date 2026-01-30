if SERVER then
else

    local PANEL = {}
    function PANEL:Init()
        self:SetTitle("Entity Inspector")
        self:SetSizable(true)
        self:SetDraggable(true)
        self:SetSize(ScrW() * 0.5, ScrH() * 0.75)

        local divLeft = vgui.Create("DHorizontalDivider", self)
        divLeft:Dock(FILL)

        self.Left = vgui.Create("EditablePanel", self)
        divLeft:SetLeft(self.Left)
        divLeft:SetLeftMin(100)
        divLeft:SetLeftWidth(self:GetWide() * 0.2)

        local top = vgui.Create("DPanel", self.Left)
        top:Dock(TOP)

        self.Search = vgui.Create("DTextEntry", top)
        self.Search:Dock(FILL)
        self.Search:SetPlaceholderText("Search...")

        top:SizeToChildren(true, true)

        
        self.Tree = vgui.Create("DTree", self.Left)
        self.Tree:Dock(FILL)


        local divRight = vgui.Create("DHorizontalDivider", self)
        divLeft:SetRight(divRight)

        self:RefreshTree()
    end

    function PANEL:NodeDetails(ent)
        local path

        local name = ent:GetClass() .. " [" .. ent:EntIndex() .. "]"
        local mdl = ent:GetModel()

        if mdl and isstring(mdl) and string.EndsWith(mdl, ".mdl") then
            name = name .. " [" .. mdl .. "]"
        end

        if ent:EntIndex() < 0 then
            path = "icon16/bullet_orange.png"
        end

        return name, path or "icon16/bullet_blue.png"
    end

    function PANEL:RefreshTree()
        for k, v in pairs(self.Tree:Root():GetChildNodes()) do
            v:Remove()
        end
        
        local rootName = self:NodeDetails(game.GetWorld())
        local root = self.Tree:AddNode(rootName, "icon16/world.png")
        root.Entity = game.GetWorld()
        root:SetExpanded(true)

        local function iterateEntity(ent, node)
            for k, v in pairs(ent:GetChildren()) do
                local childNode = node:AddNode(self:NodeDetails(v))
                childNode.Entity = v
                childNode.DoClick = function(s)
                    self:InspectEntity(s.Entity)
                end

                iterateEntity(v, childNode)
            end
        end

        local sorted = {}

        for k, v in pairs(ents.GetAll()) do
            -- Skip children entities
            if IsValid(v:GetParent()) then
                print(v:GetParent())
                continue
            end

            if v == root.Entity then
                continue
            end

            local childNode = root:AddNode(self:NodeDetails(v))
            childNode.Entity = v
            childNode.DoClick = function(s)
                self:InspectEntity(s.Entity)
            end

            iterateEntity(v, childNode)
        end
    end

    vgui.Register("EntityInspector", PANEL, "DFrame")
end