local WEAPON = Item.Register("Weapon")
WEAPON.Abstract = true
WEAPON.BackgroundColor = Color(255, 60, 60, 128)

function WEAPON.Prototype:IsEquipped()
    return self.Inventory and self.Inventory:GetItemAt("Weapon") == self
end

function WEAPON.Prototype:Equip(ply)
    print("Give weapon")
end

function WEAPON.Prototype:Unequip(ply)
    print("Take weapon")
end

function WEAPON.Prototype:GetBackgroundMaterial(w, h)
    return LinearGradient(
        Color(104, 55, 0, 128),
        0.1,
        Color(0, 0, 0, 192),
        0.75,
        Color(0, 0, 0, 192),
        270
    )
end

local MAG = Item.Register("Magazine")
MAG.Abstract = true

function MAG.Prototype:GetBackgroundMaterial(w, h)
    return LinearGradient(
        Color(88, 104, 0, 128),
        0.1,
        Color(0, 0, 0, 192),
        0.75,
        Color(0, 0, 0, 192),
        270
    )
end

local MEDKIT = Item.Register("Medkit")
-- models/items/healthkit.mdl
-- {"ang":"{85.8409 -180.1337 0}","pos":"[17.444 0.0609 200.1031]","mdl_ang":"{0 0 0}","fov":6.575433597096581}
MEDKIT.Width = 4
MEDKIT.Height = 4
MEDKIT.Weight = 500
MEDKIT.Label = "Medkit"
MEDKIT.Model = "models/items/healthkit.mdl"
MEDKIT.Cam = {
    ang	= Angle(85.8409, -180.1337, 0), 	
    fov = 6.5754,
    pos = Vector(17.444, 0.0609, 200.1031)
}

function MEDKIT.Prototype:GetBackgroundMaterial(w, h)
    return LinearGradient(
        Color(0, 88, 104, 128),
        0.1,
        Color(0, 0, 0, 192),
        0.75,
        Color(0, 0, 0, 192),
        270
    )
end


local SODA = Item.Register("Soda")
SODA.Width = 2
SODA.Height = 2
SODA.Weight = 300
SODA.Label = "Soda Can"
SODA.Model = "models/props_junk/PopCan01a.mdl"
-- {"ang":"{0.7977 235.4753 0}","pos":"[62.1094 90.2008 1.6554]","mdl_ang":"{0 0 0}","fov":4.292031810357026}
SODA.Cam = {
    ang	= Angle(0.7977, 235.4753, 0), 	
    fov = 4.2920,
    pos = Vector(62.1094, 90.2008, 1.6554)
}