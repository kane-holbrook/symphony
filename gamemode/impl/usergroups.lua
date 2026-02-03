AddCSLuaFile()

Usergroups = {}
Usergroups.Registry = {}
Usergroups.Permissions = {}

local Usergroup = Type.Register("Usergroup", Type.VirtualEnt, { Table = "Usergroups", Key = "Name" })
Usergroup:CreateProperty("Name", Type.String, { DatabaseType = "VARCHAR(255)" })
Usergroup:CreateProperty("Permissions", Type.Table, { Default = {} })
Usergroup:CreateProperty("Created", Type.DateTime, { Default = function () return DateTime() end })
Usergroup:CreateProperty("Modified", Type.DateTime, { Default = function () return DateTime() end })

function Usergroup.Prototype:OnPropertyChanged(prop, new, old)
    if prop == "Name" then
        if old and old ~= "" then
            Usergroups.Registry[old] = nil
        end
        Usergroups.Registry[new] = self
    end
    base(self, "OnPropertyChanged", prop, new, old)
end

function Usergroup.Prototype:HasPermission(perm)
    return self:GetPermissions()[perm] == true
end

function Usergroup.Prototype:GivePermission(perm)
    local perms = self:GetPermissions()
    perms[perm] = true
    self:SetPermissions(perms)
end

function Usergroup.Prototype:RevokePermission(perm)
    local perms = self:GetPermissions()
    perms[perm] = nil
    self:SetPermissions(perms)
end

function Usergroup.Prototype:ClearPermissions()
    self:SetPermissions({})
end

function Usergroups.Create(name, permissions)
    permissions = permissions or {}

    local ug = Type.New(Usergroup)
    ug:SetName(name)
    
    local perms = {}
    for k, v in pairs(permissions) do
        perms[v] = true
    end
    ug:SetPermissions(perms)

    return ug
end

function Usergroups.GetAll()
    return Usergroups.Registry
end

hook.Add("DatabaseConnected", function ()
    Usergroup:Select():Await()
     -- VirtualEnts, so they'll automatically transmit anyway.
end)

if CLIENT then
    local PANEL = vguix.RegisterFromXML("Usergroups", [[
        <DFrame Name="Component" X="25%" Y="12.5%" Width="50%" Height="75%" Title="Usergroups" Align="false">
            <Rect Dock="FILL" :Width="Parent.Width - 10" :Height="Parent.Height - 29 - 5" Gap="16">
                <Rect Width="33%" Height="100%" Flow="Y" Gap="8">
                    <Rect Width="100%" Flow="X" Align="4" Gap="8">
                        <DTextEntry PlaceholderText="Search..." Grow="true" Func:OnTextChanged="function (self) Component:Search(self:GetValue()) end" />
                        <DButton Text="New" Width="10cw" />
                    </Rect>
                    <DListView Debug:Global="Lst" Name="List" MultiSelect="false" Func:OnRowSelected="function (lst, index, row) Component:Select(row.Usergroup) end" Width="100%" Grow="true" />
                </Rect>

                <Rect Grow="true" Height="100%">
                    TEST
                </Rect>
            </Rect>
        </DFrame>
    ]])

    function PANEL:Init()
        self.SearchTerm = ""
        self.List:AddColumn("Name")
        self:RefreshList()
    end

    function PANEL:Search(name)
        self.SearchTerm = string.lower(name)
        self:RefreshList()
    end

    function PANEL:Select(ug)
        print(name)
    end

    function PANEL:RefreshList()
        local lst = self.List

        for k, v in pairs(lst:GetLines()) do
            v:Remove()
        end

        for k, v in pairs(Usergroups.GetAll()) do
            local name = string.lower(v:GetName())
            if self.SearchTerm ~= "" and not string.find(name, self.SearchTerm) then
                continue
            end

            local ln = lst:AddLine(v:GetName())
            ln.Usergroup = v
        end
    end
end