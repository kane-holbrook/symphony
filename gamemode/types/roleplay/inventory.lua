

Inventories = {}
Inventories.CellSize = 48

local INVENTORY = Type.Register("Inventory", nil, { DatabaseType = "JSON" })
INVENTORY:CreateProperty("Width", Type.Number)
INVENTORY:CreateProperty("Height", Type.Number)    

local function ToCoord(x, y)
    if not y then
        return nil
    end

    return x .. "," .. y
end

local function FromCoord(str)
    if not str then
        return nil
    end

    local x, y = unpack(string.Split(str, ","))
    x = tonumber(x)
    y = tonumber(y)

    if not x or not y then
        return nil
    end

    return x, y
end 
INVENTORY.FromCoord = FromCoord
INVENTORY.ToCoord = ToCoord

function INVENTORY.Prototype:Initialize()
    if SERVER then
        self.Receivers = {}
    end
    self.Items = {}
    self.Grid = {}

    self:SetWidth(1)
    self:SetHeight(1)

    self.Initialized = false
end

function INVENTORY.Prototype:RecalculateWeight()
    local total = 0
    for k, v in pairs(self.Items) do
        total = total + v:GetWeight()
    end
    self.Weight = total
    hook.Run("InventoryWeightRecalculated", self, total)
    return total
end

function INVENTORY.Prototype:GetWeight()
    return self.Weight or self:RecalculateWeight()
end

function INVENTORY.Prototype:IsInitialized()
    return self.Initialized
end

function INVENTORY.Prototype:GetItems()
    return self.Items
end

function INVENTORY.Prototype:GetItemAt(x, y)
    local pos = ToCoord(x, y)
    if not pos then
        return self.Items[x]
    end
    return self.Grid[pos]
end

function INVENTORY.Prototype:GetItemById(id)
    for k, v in pairs(self:GetItems()) do
        if v:GetId() == id then
            return v
        end
    end
end

function INVENTORY.Prototype:CanFit(item, x, y, width, height)
    if not y then
        return false
    end

    width = width or item:GetWidth()
    height = height or item:GetHeight()

    for x2=x, x + width - 1 do
        for y2=y, y + height - 1 do
            local el = self:GetItemAt(x2, y2)
            if el ~= nil and el ~= item then
                return false
            end
        end
    end 
    return true
end

function INVENTORY.Prototype:FindSlot(width, height)
    if width > self:GetWidth() or height > self:GetHeight() then
        return nil, nil
    end

    local maxX = self:GetWidth() - width + 1
    local maxY = self:GetHeight() - height + 1
    
    for y = 1, maxY do
        for x = 1, maxX do
            local canPlace = true
            
            for y2 = y, y + height - 1 do
                for x2 = x, x + width - 1 do
                    if self.Grid[ToCoord(x2, y2)] ~= nil then
                        canPlace = false
                        x = x2
                        break
                    end
                end
                if not canPlace then break end
            end
            
            if canPlace then
                return x, y
            end
        end
    end
    
    return nil, nil
end

function INVENTORY.Prototype:AddItem(item, index)
    local w
    local h
    if isstring(item) then
        local t = Item.All[item]
        assert(t, "Invalid item type: " .. item)

        w = t.Width
        h = t.Height
    else
        w, h = item:GetWidth(), item:GetHeight()
    end
    
    local skip = false
    if not index then
        x, y = self:FindSlot(w, h)
        if not x then 
            return false 
        end
        skip = true
    else
        x, y = FromCoord(index)
        if not x then
            x = index
        end
    end

    if not skip and not self:CanFit(nil, x, y, w, h) then
        return false
    end
    
    if isstring(item) then
        item = Item.Create(item)
    end

    local coord = x and ToCoord(x, y)
    self:GetItems()[coord or index] = item
    item:SetIndex(coord or index)
    item.Inventory = self

    if x and y then
        for x2 = x, x + item:GetWidth() - 1 do
            for y2 = y, y + item:GetHeight() - 1 do
                self.Grid[ToCoord(x2, y2)] = item
            end
        end
    else
        self:OnEquip(index, item)
    end

    if SERVER then
        self:NetStart("AddItem")
            rtc.WriteObject(item)
        self:NetSend()
    end

    self:RecalculateWeight()

    hook.Run("InventoryAddItem", self, item, index)
    return item
end

function INVENTORY.Prototype:MoveItem(item, index)
    item = isstring(item) and self:GetItemById(item) or item
    assert(item, "Invalid item")
    assert(index, "Invalid index")

    local newX, newY = FromCoord(index)
    if not self:CanFit(item, newX or index, newY) then
        return false
    end

    local oldIndex = item:GetIndex()
    self:GetItems()[oldIndex] = nil
    item:SetIndex(index)
    self:GetItems()[index] = item

    local oldX, oldY = FromCoord(oldIndex)
    if oldX then
        for x2=oldX, oldX + item:GetWidth() - 1 do
            for y2=oldY, oldY + item:GetHeight() - 1 do
                self.Grid[ToCoord(x2, y2)] = nil
            end
        end
    elseif oldIndex then
        self:OnUnequip(oldIndex, item)
    end

    
    if newX then
        for x2=newX, newX + item:GetWidth() - 1 do
            for y2=newY, newY + item:GetHeight() - 1 do
                self.Grid[ToCoord(x2, y2)] = item
            end
        end
    else
        self:OnEquip(index, item)
    end

    if SERVER then
        self:NetStart("MoveItem")
            rtc.WriteString(item:GetId())
            rtc.WriteType(item:GetIndex())
        self:NetSend()
    end
    hook.Run("InventoryMoveItem", self, item, index, oldIndex)

    return true
end

-- Disallow special slots by default
function INVENTORY.Prototype:OnEquip(item, index)
    return false
end

function INVENTORY.Prototype:OnUnequip(item, index)
end

    
function INVENTORY.Prototype:BuildVGUI(parent)
    local p = vguix.CreateFromXML(parent, [[
        <Inventory Name="Inventory" Grow="true" Height="100%" />
    ]])
    p:LoadInventory(self)
    return p
end

function INVENTORY.Prototype:RemoveItem(id)
    local itm = isstring(id) and self:GetItemById(id) or id
    assert(itm, "Invalid item id")

    local index = itm:GetIndex()
    local sx, sy = FromCoord(index)
    if sx then
        for x=sx, sx + itm:GetWidth() - 1 do
            for y=sy, sy + itm:GetHeight() - 1 do
                self.Grid[ToCoord(x, y)] = nil
            end
        end
    else
        self:OnUnequip(index, itm)
    end
    self.Items[itm:GetIndex()] = nil
    itm.Inventory = nil

    if SERVER then
        self:NetStart("RemoveItem")
            rtc.WriteString(id)
        self:NetSend()
    end

    hook.Run("InventoryRemoveItem", self, itm)
end

-- Networking
do
    if SERVER then
        function INVENTORY.Prototype:GetReceivers()
            return self.Receivers
        end

        function INVENTORY.Prototype:IsReceiver(ply)
            return self.Receivers[ply] ~= nil
        end

        function INVENTORY.Prototype:AddReceiver(ply)
            if self.Receivers[ply] then return end

            self.Receivers[ply] = true
            rtc.Start("Inventory")
                rtc.WriteObject(self)
                rtc.WriteObject(self.Items)
            rtc.Send(ply)
        end

        function INVENTORY.Prototype:RemoveReceiver(ply)
            self.Receivers[ply] = nil
        end

        function INVENTORY.Prototype:ClearReceivers()
            self.Receivers = {}
        end

        function INVENTORY.Prototype:NetStart(event)
            rtc.Start("InventoryEvent")
                rtc.WriteString(self:GetId())
                rtc.WriteString(event)
        end

        function INVENTORY.Prototype:NetSend()
            rtc.Send(table.GetKeys(self:GetReceivers()))
        end
        

        RPC.Register("InventoryMoveItem", function (ply, invId, itemId, index)
            local inv = Type.GetInstanceById(invId)
            assert(Type.Is(inv, INVENTORY), "Invalid inventory type for move operation.")
            
            assert(inv.Receivers[ply], "Player tried to move item but not a valid Receiver.")

            local item
            for k, v in pairs(inv:GetItems()) do
                if v:GetId() == itemId then
                    item = v
                    break
                end
            end

            assert(item, "Item not found in inventory for move operation.")

            return inv:MoveItem(item, index)
        end)
    else
        rtc.Receive("Inventory", function (len, ply)
            local inv = rtc.ReadObject()
            local items = rtc.ReadObject()

            items.Id = nil
            for k, v in pairs(items) do
                inv:AddItem(v, v:GetIndex())
            end
            Inventories[inv:GetId()] = inv
        end)

        rtc.Receive("InventoryEvent", function(len, ply)
            local inv = Type.GetInstanceById(rtc.ReadString())
            assert(Type.Is(inv, INVENTORY), "Inventory event sent for invalid type.")

            if inv then
                if SERVER then
                    assert(inv.Receivers[ply], "Player sent inventory event but not a valid Receiver.")
                end

                local event = rtc.ReadString()
                inv:Receive(event, ply)
            end
        end)
        
        function INVENTORY.Prototype:Receive(event, ply)
            if event == "AddItem" then
                local item = rtc.ReadObject()
                self:AddItem(item, item:GetIndex())
                return true
            elseif event == "RemoveItem" then
                local itemId = rtc.ReadString()
                self:RemoveItem(itemId)
                return true
            elseif event == "MoveItem" then
                local itemId = rtc.ReadString()
                local index = rtc.ReadType()
                self:MoveItem(itemId, index)
                return true
            end
        end
    end
end

-- Serialization
do
    function INVENTORY:DatabaseEncode(value)
        return string.format("%q", util.TableToJSON(Type.Serialize({
            Width = value:GetWidth(),
            Height = value:GetHeight(),
            Items = value.Items
        })))
    end

    function INVENTORY:DatabaseDecode(value)
        local t = Type.Deserialize(util.JSONToTable(value))

        local inv = Type.New(self)
        if t.Width then
            inv:SetWidth(t.Width)
        end
        
        if t.Height then
            inv:SetHeight(t.Height)
        end

        inv.Items = t.Items
        inv.Items.Id = nil

        for k, v in pairs(inv.Items) do
            v:SetIndex(k)
            v.Inventory = inv

            local x, y = FromCoord(k)
            if x and y then
                for x2 = x, x + v:GetWidth() - 1 do
                    for y2 = y, y + v:GetHeight() - 1 do
                        inv.Grid[ToCoord(x2, y2)] = v
                    end
                end
            else
                inv:OnEquip(k, v)
            end
        end
        
        return inv
    end
end

-- Interface
if CLIENT then
    DEFINE_BASECLASS("Rect")
    local CELL_SIZE = Inventories.CellSize

    local PANEL = {}
    vguix.AccessorFunc(PANEL, "Columns", "Columns", "Number")
    vguix.AccessorFunc(PANEL, "Rows", "Rows", "Number")
    vguix.AccessorFunc(PANEL, "CellSize", "CellSize", "Number")

    function PANEL:Init()
        self:SetCellSize(CELL_SIZE)

        self:SetComputed("Width", function ()
            return Columns * self.CellSize
        end)

        self:SetComputed("Height", function ()
            return Rows * self.CellSize
        end)

        self:Receiver("Item", function (...)
            self:OnDrop(...)
        end)

        hook.Add("InventoryAddItem", self, function (_, inv, itm)

            if inv ~= self.Inventory then
                return
            end

            self:OnAddItem(itm)
        end)

        hook.Add("InventoryRemoveItem", self, function (_, inv, itm)
            if inv ~= self.Inventory then
                return
            end            
            self:OnRemoveItem(itm)
        end)

        hook.Add("InventoryMoveItem", self, function (_, inv, itm, index, oldIndex)
            if self.Inventory and inv ~= self.Inventory then
                return
            end

            self:OnMoveItem(itm, index, oldIndex)
        end)
    end

    function PANEL:LoadInventory(inv)
        assert(inv, "Inventory is nil")
        self.Inventory = inv

        self:SetColumns(inv:GetWidth())
        self:SetRows(inv:GetHeight())

        for k, itm in pairs(inv:GetItems()) do
            self:LoadItem(itm)
        end
    end

    function PANEL:LoadItem(itm)
        local index = itm:GetIndex()
        local x, y = FromCoord(index)
        if not isnumber(x) then
            return false
        end

        local p = vgui.Create("Inventory.Item", self)
        p:LoadItem(itm)

        p:SetPos((x - 1) * self:GetCellSize(), (y - 1) * self:GetCellSize())
        p:SetWidth(itm:GetWidth() * self:GetCellSize())
        p:SetHeight(itm:GetHeight() * self:GetCellSize())

        p:InvalidateLayout()
    end

    function PANEL:OnAddItem(item)
        self:LoadItem(item)
    end

    function PANEL:OnRemoveItem(itm)
        local id = itm:GetId()
        for k, v in ipairs(self:GetChildren()) do
            if v.Item:GetId() == id then
                v:Remove()
                break
            end
        end
        return true
    end

    function PANEL:OnMoveItem(item)
            
        local id = item:GetId()
        local x, y = FromCoord(item:GetIndex())

        if x then
            for k, v in ipairs(self:GetChildren()) do
                if v.Item:GetId() == id then
                    v:SetPos((x - 1) * self:GetCellSize(), (y - 1) * self:GetCellSize())
                    v:InvalidateLayout(true)
                    return true
                end
            end
        end
        
        return true
    end


    function PANEL:GetInventory()
        return self.Inventory
    end

    function PANEL:OnDrop(pnl, tbl, dropped, menuIndex, x, y)
        
        local p = tbl[1]

        x = x + p.DragDropOffset.x - p:GetWide()/2
        y = y + p.DragDropOffset.y - p:GetTall()/2
        local cx, cy = self:LocalToCell(x, y)

        if not cx or not cy then
            return
        end
        

        if dropped then
            if not self:GetInventory():CanFit(p:GetItem(), cx, cy) then
                return
            end

            if cx < 1 or cx + p:GetItem():GetWidth() - 1 > self:GetColumns() or cy < 1 or cy + p:GetItem():GetHeight() - 1 > self:GetRows() then
                return
            end

            local op = p:GetParent()
            local od = p:GetDock()
            local ox, oy = p:GetX(), p:GetY()
            p:SetParent(self)
            p:Dock(NODOCK)
            p:SetX((cx - 1) * self:GetCellSize())
            p:SetY((cy - 1) * self:GetCellSize())
            p:SetWidth(p:GetItem():GetWidth() * self:GetCellSize())
            p:SetHeight(p:GetItem():GetHeight() * self:GetCellSize())
            p:InvalidateLayout(true)
            
            RPC.Call("InventoryMoveItem", self:GetInventory():GetId(), p:GetItem():GetId(), Type.Inventory.ToCoord(cx, cy)):Then(function (result)
                if not result then
                    p:SetParent(op)
                    p:Dock(od)
                    p:SetX(ox)
                    p:SetY(oy)
                    p:InvalidateLayout(true)
                end
            end)
        end
    end

    
    local mat = LinearGradient(
        Color(0, 0, 0, 128),
        0.1,
        Color(0, 0, 0, 192),
        0.5,
        Color(0, 0, 0, 0),
        45
    )
    local cell_bg = Material("sstrp25/v2/inv_cell_bg.png", "noclamp smooth")
    function PANEL:Paint(w, h)

        
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)

        surface.SetMaterial(cell_bg)
        surface.SetDrawColor(192, 192, 192, 128)
        surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w/(cell_bg:Width()*2), h/(cell_bg:Height()*2))


        surface.SetDrawColor(255, 255, 255, 16)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local lx, ly = self:LocalToScreen(0, 0)
        render.SetScissorRect(lx+1, ly+1, lx + w-1, ly + h-1, true)

        local gm = mat(self, self.CellSize, self.CellSize)

        for x=0, (self:GetColumns() - 1) * self.CellSize, self.CellSize do
            for y=0, (self:GetRows() - 1) * self.CellSize, self.CellSize do

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(gm)
                surface.DrawTexturedRect(x, y, self.CellSize, self.CellSize)
                
                surface.SetDrawColor(255, 255, 255, 16)
                surface.DrawOutlinedRect(x-1, y-1, self.CellSize+1, self.CellSize+1, 1)

            end
        end
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    function PANEL:PaintOver(w, h)
        if not self:IsHovered() then
            return
        end

        if dragndrop.m_Dragging then
            local p = dragndrop.m_Dragging[1]


            local cx, cy = self:CursorPos()
            
            cx = cx + p.DragDropOffset.x - p:GetWide()/2
            cy = cy + p.DragDropOffset.y - p:GetTall()/2

            local x, y = self:LocalToCell(cx, cy)
            if x and y then
                if x < 1 or x + p:GetItem():GetWidth() - 1 > self:GetColumns() or y < 1 or y + p:GetItem():GetHeight() - 1 > self:GetRows() or not self:GetInventory():CanFit(p:GetItem(), x, y) then
                    surface.SetDrawColor(255, 0, 0, 64)
                else
                    surface.SetDrawColor(0, 255, 0, 64)
                end
                surface.DrawRect((x - 1) * self:GetCellSize(), (y - 1) * self:GetCellSize(), p:GetItem():GetWidth() * self:GetCellSize(), p:GetItem():GetHeight() * self:GetCellSize())
            end
        end
        
    end

    function PANEL:LocalToCell(x, y)
        local cellSize = self:GetCellSize()
        local cx = math.Round(x / cellSize, 0) + 1
        local cy = math.Round(y / cellSize, 0) + 1
        return cx, cy
    end

    function PANEL:CellToLocal(x, y)
        local cellSize = self:GetCellSize()
        return (x - 1) * cellSize, (y - 1) * cellSize
    end
    vgui.Register("Inventory", PANEL, "Rect")



    PANEL = vguix.RegisterFromXML("Inventory.Item", [[
        <Rect Name="Component" Width="0" Height="0" Absolute="true" Align="7" Flow="Y"
            :Shape="{ 0, 0, Width, 0, Width, Height, 0, Height }"
            Hover="true"
            Cursor="hand"
            :Mat="self:GetItem():GetBackgroundMaterial(Width, Height)"
            Fill="white"
            Stroke="white"
            StrokeWidth="8"
            Blur="1"
            :StrokeMat="
            LinearGradient(
                Color(60, 60, 60, IsHovered and 255 or 150),
                0.1,
                Color(30, 30, 30, IsHovered and 150 or 100),
                1,
                Color(20, 20, 20, 0),
                90
            )"
            :Alpha="IsHovered and 255 or 64"
            Padding="2"
        >
            <Rect Width="100%" Padding="8" Flow="Y" Fill="0, 0, 0, 32" Func:TestHover="function () return false end">
                <Text Width="100%" :FontSize="math.Clamp(Component:GetWide()/40, 6, 12)" FontWeight="800" FontName="Orbitron" :Value="Deref(Item, 'GetLabel') or ''" />
            </Rect>
        </Rect>
    ]])
    
    vguix.AccessorFunc(PANEL, "Item", "Item")
    

    function PANEL:Init()
        self:Droppable("Item")

        hook.Add("ItemChanged", self, function (item)
            if item and item == self:GetItem() then
                self:InvalidateChildren(true)
            end
        end)
    end

    function PANEL:LoadItem(itm)
        self:SetItem(itm)
        
        self:InvalidateChildren(true)
    end

    function PANEL:OnStartDragging()
        self.Dragging = true
        self.TestHover = function () return false end
    end

    function PANEL:OnStopDragging()
        self.Dragging = false
        self.TestHover = nil
    end

    function PANEL:StartHover()
        if dragndrop.m_Dragging then
            return
        end

        local p = vgui.Create("Inventory.Item.Popover", self)
        p:SetItem(self.Item)

        p:SetMouseInputEnabled(false)
        p:SetKeyboardInputEnabled(false)

        function p:TestHover()
            return false
        end

        p:Think()
        p:InvalidateChildren(true)
        timer.Simple(0.05, function ()
            if IsValid(p) then
                p:MakePopup()
            end
        end)


        self.Popover = p
    end

    function PANEL:StopHover()
        if IsValid(self.Popover) then
            self.Popover:Remove()
        end
    end

    function PANEL:RightClick()

        if dragndrop.m_Dragging then
            return
        end

        local m = DermaMenu(false, self)
        for k, v in pairs(self.Item:GetActions()) do
            m:AddOption(v, function ()
                Promise.Run(function ()
                    self.Item:RunAction(LocalPlayer(), v)
                end)
            end)
        end
        m:Open()

        _m = m
    end

    function PANEL:DragMousePress(mcode)
        return FindMetaTable("Panel").DragMousePress(self, mcode)
    end

    function PANEL:Paint(w, h)
        if self.PaintingDragging then
        end

        BaseClass.Paint(self, w, h)

        if not self.Item then
            return
        end

        self.Item:Paint(w, h)
    end

    function PANEL:PaintOver(w, h)
    end


    PANEL = vguix.RegisterFromXML("Inventory.Item.Popover", [[
        <Rect Name="Component" Width="0.25vw" Align="7" Flow="Y"
            :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
            Fill="white"
            Hover="true"
            Blur="2"
            :Mat="RadialGradient(
                Color(0, 14, 30, 225),
                0.3,
                Color(0, 14, 30, 225),
                0.9,
                Color(0, 3, 10, 225)
            )"
            Stroke="white"
            StrokeWidth="4"
            :StrokeMat="
            LinearGradient(
                Color(0, 28, 60, 255),
                0.1,
                Color(0, 28, 60, 192),
                1,
                Color(0, 6, 20, 0),
                90
            )"
            Flow="Y"
            Padding="16"
        >
            <Rect Name="Icon" Fill="white" Width="100%" Height="128" MarginBottom="16" />
            <Text MarginBottom="8" Width="100%" Wrap="true" FontSize="12" FontWeight="400" FontName="Eurostile" Value="MORITA CORPORATION" />
    
            <Text MarginBottom="8" Width="100%" Wrap="true" FontSize="16" FontWeight="800" FontName="Orbitron" :Value="Item:GetLabel()" />
            <Text FontSize="8" FontName="Orbitron" Width="100%" Wrap="true" :Value="Item:GetDescription()" />
        </Rect>
    ]])
    vguix.AccessorFunc(PANEL, "Item", "Item")

    function PANEL:Init()
        function self.Icon.Paint(_, w, h)
            local icon = self:GetItem():GetIcon()
            if not icon then return end

            local iw, ih = icon:Width(), icon:Height()
            if iw == 0 or ih == 0 then return end

            -- Aspect ratios
            local iconAR = iw / ih
            local panelAR = w / h

            local drawW, drawH

            if iconAR > panelAR then
                -- Icon is wider than panel
                drawW = w
                drawH = w / iconAR
            else
                -- Icon is taller than panel
                drawH = h
                drawW = h * iconAR
            end

            -- Center the icon
            local x = (w - drawW) * 0.5
            local y = (h - drawH) * 0.5

            icon:SetVector4D("$color", 255, 255, 255, 255)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(x, y, drawW, drawH)
            icon:SetVector4D("$color", 1, 1, 1, 1)
        end
    end

    function PANEL:Think()
        local x, y = gui.MousePos()
        x = x + 32
        y = y - self:GetTall()/2 + 16
        
        self:SetPos(x, y)
        self:MoveToFront()

        if dragndrop.m_Dragging then
            self:Remove()
        end
    end



    local PANEL = vguix.RegisterFromXML("Inventory.Slot", [[
        <Rect Name="Component" Width="48" Height="48"
            :Shape="{ 0, 0, Width, 0, Width, Height, 0, Height }"
            Fill="0, 0, 0, 32"
            Blur="10"
            Stroke="white"
            StrokeWidth="4"
            Fill="0, 0, 0, 128"
            :StrokeMat="
            LinearGradient(
                Color(60, 60, 60, 150),
                0.1,
                Color(30, 30, 30, 100),
                1,
                Color(20, 20, 20, 0),
                90
            )"
        />
    ]])
    vguix.AccessorFunc(PANEL, "Icon", "Icon", "Material")
    vguix.AccessorFunc(PANEL, "Label", "Label", "String")


    function PANEL:Init()
        self:Receiver("Item", function (...)
            self:OnDrop(...)
        end)
        _slot = self
        

        hook.Add("InventoryAddItem", self, function (_, inv, itm)

            if inv ~= self.Inventory then
                return
            end

            self:OnAddItem(itm)
        end)

        hook.Add("InventoryRemoveItem", self, function (_, inv, itm)
            if inv ~= self.Inventory then
                return
            end            
            self:OnRemoveItem(itm)
        end)

        hook.Add("InventoryMoveItem", self, function (_, inv, itm, index, oldIndex)
            if self.Inventory and inv ~= self.Inventory then
                return
            end

            if not self.Item then
                return
            end

            if self.Item:GetItem():GetId() == itm:GetId() and index ~= self:GetName() then
                self.Item = nil
                self:OnMoveItem(itm, index, oldIndex)
            end
        end)
    end

    function PANEL:OnAddItem(item, index)
        if index == self:GetName() then
            self:LoadItem(item)
        end
    end

    function PANEL:OnRemoveItem(itm)
        if not self.Item then
            return
        end

        local id = itm:GetId()
        if self.Item:GetItem():GetId() == self.Item:GetItem():GetId() then
            self.Item:Remove()
            self.Item = nil
        end
    end

    function PANEL:OnMoveItem(item, oldIndex)        
    end


    function PANEL:LoadInventory(inv)
        self.Inventory = inv

        local item = inv:GetItemAt(self:GetName())
        if item then
            self:LoadItem(item)
        end
    end

    function PANEL:GetItem()
        return self.Item
    end

    function PANEL:LoadItem(itm)
        local p = vgui.Create("Inventory.Item", self)
        p:LoadItem(itm)
        
        
        p:Dock(FILL)
        p:InvalidateLayout()
        self.Item = p
    end

    function PANEL:GetInventory()
        return self.Inventory
    end

    function PANEL:OnDrop(pnl, tbl, dropped, menuIndex, x, y)
        
        local p = tbl[1]

        if dropped then
            if not self:ShouldAccept(p:GetItem()) then
                return
            end
            
            local op = p:GetParent()
            local ox, oy = p:GetX(), p:GetY()
            local od = p:GetDock()

            p:SetParent(self)
            p:Dock(FILL)
            p:InvalidateLayout(true)
            self.Item = p

            RPC.Call("InventoryMoveItem", self:GetInventory():GetId(), p:GetItem():GetId(), self:GetName()):Then(function (result)
                if not result then
                    p:SetParent(op)
                    p:Dock(od)
                    p:SetX(ox)
                    p:SetY(oy)
                    p:InvalidateLayout(true)
                end
            end)
        end
    end

    function PANEL:ShouldAccept(item)
        if self.Item then
            return false
        end
        return true
    end    

    function PANEL:Paint(w, h)
        BaseClass.Paint(self, w, h)

        local itm = self:GetItem()
        if itm then
            return
        end

        local lbl = self:GetLabel()
        if lbl and lbl ~= "" then
            draw.SimpleText(lbl, "DermaDefault", 8, 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local icon = self:GetIcon()
        if icon then
            surface.SetDrawColor(255, 255, 255, 64)
            surface.SetMaterial(icon)
            local sz = math.min(w, h) * 0.75
            surface.DrawTexturedRectRotated(w / 2, h / 2, sz, sz, 0)
        end
    end

    function PANEL:PaintOver(w, h)
        if not self:IsHovered() then
            return
        end

        if dragndrop.m_Dragging then
            local p = dragndrop.m_Dragging[1]

            if not self:ShouldAccept(item) then
                surface.SetDrawColor(255, 0, 0, 64)
            else
                surface.SetDrawColor(0, 255, 0, 64)
            end
            surface.DrawRect(0, 0, w, h)
        end        
    end

end