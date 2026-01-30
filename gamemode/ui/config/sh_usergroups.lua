

if SERVER then

    local PANEL = {}
    function PANEL:Init()
        self:SetTitle("Configure: Usergroups & Permissions")
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


        function self.Tree:DoClick(node)
            print(node)
        end

        function self.Tree:DoRightClick(node)
            local m = DermaMenu(false, node)
            
            m:AddOption("Clone", function ()
            end)
            m:AddOption("Remove", function ()
            end)
            m:Open()
        end

        local divRight = vgui.Create("DHorizontalDivider", self)
        divLeft:SetRight(divRight)

        self:RefreshTree()
    end

    function PANEL:RefreshTree()
        for k, v in pairs(self.Tree:Root():GetChildNodes()) do
            v:Remove()
        end
        
        local root = self.Tree:AddNode("Usergroups", "icon16/group.png")
        root:SetExpanded(true)

        for k, v in pairs(Usergroups.GetAll()) do
            local node = root:AddNode(v:GetName(), "icon16/user.png")
            node.Usergroup = v
        end

    end

    vgui.Register("Usergroups", PANEL, "DFrame")
end


