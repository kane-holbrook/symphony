

local CHARINV = Type.Register("CharacterInventory", Type.Inventory)
function CHARINV.Prototype:Initialize(id)
    base(self, "Initialize", id)
    self:SetWidth(10)
    self:SetHeight(15)
end

function CHARINV.Prototype:OnEquip(index, item)
    print("Equipped", item, "to", index)
end

function CHARINV.Prototype:OnUnequip(index, item)
    print("Unequipped", item, "from", index)
end

--[[
function CHARINV:DatabaseEncode(value)
    return string.format("%q", util.TableToJSON(Type.Serialize({
        Items = value.Items
    })))
end

function CHARINV:DatabaseDecode(value)
    local t = Type.Deserialize(util.JSONToTable(value))

    local inv = Type.New(CHARINV)
    inv.Items = t.Items
    inv.Items.Id = nil

    for k, v in pairs(inv.Items) do
        v.Inventory = inv
    end
    
    return inv
end--]]

function CHARINV.Prototype:GetCharacter()
    return self.Character
end

function CHARINV.Prototype:CanFit(item, x, y, w, h)
    if x == "Weapon" then
        return true
    end
    
    return base(self, "CanFit", item, x, y, w, h)
end
    
function CHARINV.Prototype:BuildVGUI(parent)
    local p = vguix.CreateFromXML(parent, [[
        <Rect Name="Component" Width="100%" Height="100%" Gap="16">
            <Rect Width="768" Height="100%" Fill="0, 0, 0, 128" Blur="2" Padding="16">
                <Inventory.Slot Absolute="true" :X="16" Y="16" Name="Headwear" Label="Headwear" Icon="sstrp25/v2/helmet256.png" Width="128" Height="128" />
                <Inventory.Slot Absolute="true" :X="16" :Y="16 + 128 + 16" Name="Torso" Label="Torso" Icon="sstrp25/v2/torso256.png" Width="128" Height="128" />
                <Inventory.Slot Absolute="true" :X="16" :Y="16 + 128 + 128 + 16 + 16" Name="Legs" Label="Legs" Icon="sstrp25/v2/legs256.png" Width="128" Height="128" />

                <Inventory.Slot Absolute="true" :X="16 + 128 + 16" Y="16" Name="Weapon" Label="Primary" Icon="sstrp25/v2/morita256.png" Width="384" Height="192" />
                <Inventory.Slot Absolute="true" :X="16 + 128 + 384 + 16 + 16" Y="16" Name="Throwable" Label="Throwable" Icon="sstrp25/v2/grenade256.png" Width="192" Height="192" />
                <Inventory.Slot Absolute="true" :X="16 + 128 + 16" :Y="16 + 192 + 16" Name="Sidearm" Label="Sidearm" Icon="sstrp25/v2/sidearm256.png" Width="384" Height="192" />
                <Inventory.Slot Absolute="true" :X="16 + 128 + 384 + 16 + 16" :Y="16 + 192 + 16" Name="Melee" Label="Melee" Icon="sstrp25/v2/melee256.png" Width="192" Height="288" />

            </Rect>
            <Rect Grow="true" Height="100%" Padding="16" Fill="0, 0, 0, 128" Blur="2" Flow="Y" Align="7">
                <Rect Fill="255, 255, 255, 8" Width="100%" MarginBottom="16" Padding="8" :Shape="RoundedBox(Width, Height, 8, 8, 8, 8)" Gap="8" Align="4">
                    <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/locker64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" />Storage Locker</SSTRP.SecondaryButton>
                    <Rect MarginLeft="8" MarginRight="8" Fill="255, 255, 255, 16" Width="2" Height="100%" />
                    
                    <Rect MarginRight="16" :Fill="Color(255, 255, 255, IsHovered and 255 or 128)" Cursor="hand" Hover="true" Mat="sstrp25/v2/left64.png" Width="0.5ph" Height="0.5ph" />
                    <Rect Name="OtherInventories" Grow="true" Height="100%" Gap="8">
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                        <SSTRP.SecondaryButton><Rect Fill="white" Mat="sstrp25/v2/logo64.png" Width="0.8ch" Height="0.8ch" MarginRight="16" /> A nearby inventory</SSTRP.SecondaryButton>
                    </Rect>
                    <Rect MarginLeft="16" :Fill="Color(255, 255, 255, IsHovered and 255 or 128)" Cursor="hand" Hover="true" Mat="sstrp25/v2/right64.png" Width="0.5ph" Height="0.5ph" />
                </Rect>

                <Inventory Name="Inventory" />
            </Rect>
        </Rect>
    ]])
    p.Weapon:LoadInventory(self)
    p.Inventory:LoadInventory(self)
    return p
end

local function DebounceCommit(chr)
    debounce(chr:GetId() .. "Commit", 1, function ()
        chr:Commit()
    end)
end

if SERVER then
    hook.Add("InventoryAddItem", "CharacterInventory", function (inv, item)
        if inv.Character then
            DebounceCommit(inv.Character)
        end
    end)

    hook.Add("InventoryRemoveItem", "CharacterInventory", function (inv, item)
        if inv.Character then
            DebounceCommit(inv.Character)
        end
    end)

    hook.Add("InventoryMoveItem", "CharacterInventory", function (inv, item, index)
        if inv.Character then
            DebounceCommit(inv.Character)
        end
    end)
end

local CHR = Type.Register("Character", nil, { Table = "characters", PrimaryKey = "Id" })
CHR:CreateProperty("SteamID", Type.String, { DatabaseType = "VARCHAR(32)" })
CHR:CreateProperty("Rank", Type.String, { DatabaseType = "VARCHAR(255)" })
CHR:CreateProperty("Forenames", Type.String, { DatabaseType = "VARCHAR(255)" })
CHR:CreateProperty("Surname", Type.String, { DatabaseType = "VARCHAR(255)" })
CHR:CreateProperty("Class", Type.String, { DatabaseType = "VARCHAR(255)" })
CHR:CreateProperty("Description", Type.String, { DatabaseType = "TEXT" })
CHR:CreateProperty("Appearance", Type.String)
CHR:CreateProperty("Attributes", Type.Table)
CHR:CreateProperty("Inventory", Type.CharacterInventory)
CHR:CreateProperty("Storage", Type.Inventory)
CHR:CreateProperty("XP", Type.Number)
CHR:CreateProperty("CreatedTime", Type.DateTime)
CHR:CreateProperty("LastJoinTime", Type.DateTime)

function CHR.Prototype:GetName()
    return (self:GetForenames() or "") .. " " .. (self:GetSurname() or "")
end

function CHR.Prototype:OnPropertyChanged(name, value, old)
    if name == "Inventory" then
        value.Character = self
    end
end

local PLY = FindMetaTable("Player")
AccessorFunc(PLY, "Character", "Character")

function PLY:Name()
    local chr = self:GetCharacter()
    if chr then
        return self:GetNW2String("CharName")
    end

    return self:Nick()
end

function PLY:GetCharacters()
    return self.Characters
end

function CHR.Validate(payload)
    local out = {}
    if not payload.Forenames then
        out["Forenames"] = "You must provide a first name."
    end

    if not payload.Surnames then
        out["Surnames"] = "You must provide a surname."
    end

    if not payload.Class then
        out["Class"] = "You must provide a class."
    end

    if not payload.Description then
        out["Description"] = "You must provide a description."
    end

    

    return out
end

if SERVER then 
    function CHR.Prototype:Apply(ply, characterId)
        local chr
        for k, v in pairs(ply:GetCharacters()) do
            if v:GetId() == characterId then
                chr = v
                break
            end
        end
        
        if not chr then
            return false, "Character not found"
        end

        local old = ply:GetCharacter()
        if old and old:GetId() == chr:GetId() then
            return false, "You're already using that character"
        end

        if old then
            old:Commit():Await()
        end
        
        if not chr:GetInventory() then
            chr:SetInventory(Type.New(Type.CharacterInventory))
        end

        if not chr:GetStorage() then
            local inv = Type.New(Type.Inventory)
            inv:SetWidth(15)
            inv:SetHeight(60)
            chr:SetStorage(inv)
        end

        chr:SetLastJoinTime(DateTime())
        chr:Commit():Await()
        
        ply:SetCharacter(chr)
        ply:SetNW2String("CharId", tostring(chr:GetId()))
        ply:SetNW2String("CharName", chr:GetName())


        chr:GetInventory():AddReceiver(ply)
        chr:GetStorage():AddReceiver(ply)

        ply:Spawn()
        ply:SetModel("models/sstrp25/human/heads/male12_ref.mdl")
        ply:SetNoDraw(false)

        chr:Apply(ply)

        hook.Run("PlayerCharacterChanged", ply, chr, old)

        return true
    end

    RPC.Register("Character.Create", function (ply, payload)
        if ply.IsCreatingCharacter then
            return false, nil, "Already creating a character"
        end

        local chr = Type.New(CHR)
        chr:SetSteamID(ply:SteamID64())
        chr:SetForenames(payload.Forenames)
        chr:SetSurname(payload.Surname)
        chr:SetClass(payload.Class)
        chr:SetDescription(payload.Description)
        chr:SetXP(0)
        chr:SetInventory(Type.New(Type.CharacterInventory))

        local inv = Type.New(Type.Inventory)
        inv:SetWidth(15)
        inv:SetHeight(60)
        chr:SetStorage(inv)

        chr:SetAttributes({})
        chr:SetAppearance(payload.Appearance)
        chr:SetCreatedTime(DateTime())
        chr:SetLastJoinTime(DateTime())
        chr:Commit():Await()

        table.insert(ply.Characters, chr)        
        hook.Run("CharacterCreated", ply, chr)

        local old = ply:GetCharacter()
        if old then
            old:Commit():Await()
        end

        ply:SetCharacter(chr)
        ply:SetNW2String("CharId", tostring(chr:GetId()))
        ply:SetNW2String("CharName", chr:GetName())
        chr:GetInventory():AddReceiver(ply)
        
        ply:Spawn()
        ply:SetModel("models/sstrp25/human/heads/male12_ref.mdl")
        ply:SetNoDraw(false)

        hook.Run("PlayerCharacterChanged", ply, chr, old)

        ply.IsCreatingCharacter = false

        return true, chr
    end)

    
    function CHR.Prototype:Apply(ply)

        local appearance = self:GetAppearance()
        assert(appearance, "Character has no appearance data")
        appearance = util.JSONToTable(util.Decompress(util.Base64Decode(str)))

        ply:SetMaterial("engine/occlusionproxy")

        local head = ply.Head
        if not IsValid(head) then
            head = ents.Create("actor_part")
            
            head:SetMoveType(MOVETYPE_NONE)
            head:Spawn()
            ply.Head = head
        end        

        local base = Actor.Bases[appearance.Base]

        head:SetModel(base.Model)
        head:DrawShadow(true)
        head:SetPos(ply:GetPos())
        head:SetSolid(SOLID_NONE)
        head:SetParent(ply)
        head:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
        
        local face = base.Faces[appearance.Face]
        head:SetSubMaterial(base.TexFace, face[1])

        local eyes = base.Eyes[appearance.Eyes]
        head:SetSubMaterial(base.TexEyeL, "sstrp25/human/shared/eyeball_sst_l_" .. path)
        head:SetSubMaterial(base.TexEyeR, "sstrp25/human/shared/eyeball_sst_r_" .. path)

        for k, v in pairs(appearance.Flex) do
            head:SetFlexWeight(k, v)
        end

        if hook.Run("SuppressTorso", self, ply) then
        end

        if hook.Run("SuppressLegs", self, ply) then
        end
    end

    RPC.Register("Character.Select", CHR.Select)

    hook.Add("PlayerDisconnected", "CharacterSave", function (ply)
        local chr = ply:GetCharacter()
        if chr then
            chr:Commit()
        end
    end)

end



-- Player helpers
do
    local PLY = FindMetaTable("Player")
    function PLY:GetInventory()
        return Deref(self, "GetCharacter", "GetInventory")
    end

    function PLY:GetItems()
        local inv = self:GetInventory()
        if inv then
            return inv:GetItems()
        end
    end

    function PLY:GiveItem(...)
        local inv = self:GetInventory()
        if inv then
            return inv:AddItem(...)
        end
    end

    function PLY:RemoveItem(...)
        local inv = self:GetInventory()
        if inv then
            return inv:RemoveItem(...)
        end
    end
end
