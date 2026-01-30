
Item = Item or {}
Item.All = {}
Item.Instances = {}

function Item.Create(name)
    return Type.New(Type.GetByName("Item<" .. name .. ">"))
end

function Item.GetById(id)
    local t = Type.GetInstanceById(id)
    print("_t", t)
    _t = t
    assert(Type.Is(t, Type.Item), "Instance is not an item")
    return t
end

function Item.Register(name, base)
    local t = Type.Register("Item<" .. name .. ">", base and Type.GetByName("Item<" .. base .. ">") or Type.Item)
    Item.All[name] = t
    return t
end

function Item.GetType(name)
    return Item.All[name]
end

local ITEM = Type.Register("Item", nil, { DatabaseType = "JSON" })
ITEM.Label = "Untitled Item"
ITEM.Description = "This is a great item!"
ITEM.Model = "models/props_junk/TrafficCone001a.mdl"
ITEM.Width = 1
ITEM.Height = 1
ITEM.Weight = 1


ITEM:CreateProperty("Index", nil, { Transient = true })
ITEM:CreateProperty("Rotate", Type.Boolean)
ITEM:CreateProperty("Data", Type.Table)

function ITEM.Prototype:GetLabel()
    return self:GetType().Label
end

function ITEM.Prototype:GetDescription()
    return self:GetType().Description
end

function ITEM.Prototype:GetModel()
    return self:GetType().Model
end

function ITEM.Prototype:GetWidth()
    if self:GetRotate() then
        return self:GetType().Height
    else
        return self:GetType().Width
    end
end

function ITEM.Prototype:GetHeight()
    if self:GetRotate() then
        return self:GetType().Width
    else
        return self:GetType().Height
    end
end

function ITEM.Prototype:GetWeight()
    return self:GetType().Weight
end

function ITEM.Prototype:GetCamData()
    return self:GetType().Cam or {
        ang	= Angle(0, 0, 0), 	
        fov = 20,
        pos = Vector(0, 0, 100)
    }
end

function ITEM.Prototype:Initialize()
    self:SetProperty("Data", self:GetProperty("Data") or {})
end

local pnl
function ITEM.Prototype:StartHover(parent)
end

function ITEM.Prototype:StopHover()
    if IsValid(pnl) then
        pnl:Remove()
    end
end

function ITEM.Prototype:GetData(key, value)
    local data = self:GetProperty("Data")
    return data[key]
end

function ITEM.Prototype:SetData(key, value)
    local data = self:GetProperty("Data")
    data[key] = value

    if SERVER then
        rtc.Start("Item.SetData")
            rtc.WriteString(self:GetId())
            rtc.WriteString(key)
            rtc.WriteObject(value)
        rtc.Send(self:GetInventory():GetRecipients())
    end
end

function ITEM.Prototype:GetInventory()
    return self.Inventory
end

function ITEM.Prototype:GetActions()
    return {
        "Destroy"
    }
end

function ITEM.Prototype:RunAction(ply, action)
    if action == "Destroy" then
        if SERVER then
            self:Remove()
        end
    end
    
    if CLIENT then
        self:SendAction(action)
    end
    return true 
end


function ITEM.Prototype:GetBackgroundMaterial(w, h)
    return LinearGradient(
        Color(60, 60, 80, 128),
        0.1,
        Color(0, 0, 0, 192),
        0.75,
        Color(0, 0, 0, 192),
        270
    )
end

function ITEM:GenerateIcon()
    local cellsize = Inventories.CellSize
    local w = self.Width * cellsize
    local h = self.Height * cellsize
    local camdata = self.Cam

    local ent = ents.CreateClientside("actor_part")
    ent:SetModel(self.Model)
    ent:SetPos(vector_origin)

    local mat = drawex.RenderMaterial("UnlitGeneric", w, h, function (w, h)

        render.SuppressEngineLighting(true)
        render.ResetModelLighting(0, 0, 0)

        render.SetLocalModelLights({
            {
                type = MATERIAL_LIGHT_SPOT,
                color = Vector(0.5, 0.5, 0.5),
                pos = camdata.pos + camdata.ang:Forward() * -512,
                dir = camdata.ang:Forward(),
                innerAngle = 40,
                outerAngle = 90,
                angularFalloff = 50
            },
        })

        render.Clear(0, 0, 0, 0, true, true)

        render.OverrideAlphaWriteEnable(true, true) -- some playermodel eyeballs will not render without this
        render.SetWriteDepthToDestAlpha(false)
        render.SetBlend(1)

        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)

        cam.Start3D(camdata.pos, camdata.ang, camdata.fov, 0, 0, w, h)
            ent:DrawModel()
        cam.End3D()

        render.PopFilterMag()
        render.PopFilterMin()

        render.SetWriteDepthToDestAlpha(true)
        render.OverrideAlphaWriteEnable(false)
        render.SuppressEngineLighting(false)
        timer.Simple(0, function ()
            ent:Remove()    
        end)
    end, { ["$translucent"] = 1 })

    self.Icon = mat

    return mat
end 

function ITEM.Prototype:GetIcon()
    return self:GetType().Icon
end

function ITEM.Prototype:GetStencil()
    return self:GetType().Stencil
end

local spinner = Material("sstrp25/v2/spinner256.png", "noclamp smooth")
function ITEM.Prototype:Paint(w, h)
    local mat = self:GetIcon()
    
    surface.SetDrawColor(255, 255, 255, 255)
    if not mat or not mat:IsLoaded() then
        
        if not mat then
            timer.Simple(0, function ()
                self:GetType():GenerateIcon()
            end)
        end

        surface.SetMaterial(spinner)
        local sz = math.min(w, h)
        surface.DrawTexturedRectRotated(w/2, h/2, sz * 0.5, sz * 0.5, 0)
    else
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end
end

function ITEM.Prototype:Remove()
    if self.Inventory then
        self.Inventory:RemoveItem(self:GetId())
    end
end

if SERVER then
    RPC.Register("Item.Run", function (ply, itemId, action, ...)
        local itm = Item.GetById(itemId)
        return itm:RunAction(ply, action, ...)
    end)
else
    function ITEM.Prototype:SendAction(action, ...)
        return RPC.Call("Item.Run", self:GetId(), action, ...)
    end

    rtc.Receive("Item.SetData", function (len, ply)
        local id = rtc.ReadString()
        local key = rtc.ReadString()
        local val = rtc.ReadObject()

        local itm = Item.GetById(id)
        assert(itm:GetInventory():GetRecipients()[ply], "Player is not a recipient of this item's inventory")
        if itm then
            itm:SetData(key, val)
        end
    end)
end

