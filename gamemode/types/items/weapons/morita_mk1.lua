
local MK1 = Item.Register("morita_mk1", "Weapon")
MK1.Label = "TW-203-A Morita Mk 1 Assault Rifle"
MK1.Description = "The TW-203-A Morita Mk 1 Assault Rifle is a high-powered, semi-automatic rifle designed for long-range combat. It features a compact design and a reliable firing mechanism, making it a favorite among soldiers and law enforcement agencies."
MK1.Width = 10
MK1.Height = 4
MK1.Weight = 680
MK1.Model = "models/weapons/arc9/mk1rifle.mdl"
MK1.Cam = {
    ang	= Angle(-6.6788, 87.9029, 0), 	
    fov = 4,
    pos = Vector(2.4014, -725.2421, -88.3711)
}


local MK1_MAG = Item.Register("morita_mk1_mag", "Magazine")
MK1_MAG.Label = "Morita Mk 1 30-Round Magazine"
MK1_MAG.Description = "A standard 30-round magazine for the TW-203-A Morita Mk 1 Assault Rifle."
MK1_MAG.Width = 3
MK1_MAG.Height = 4
MK1_MAG.Weight = 200
MK1_MAG.Model = "models/shared/mags/mk1r_mag.mdl"
MK1_MAG.Cam = {
    ang	= Angle(0, 270, 0), 	
    fov = 2.4267,
    pos = Vector(0, 200, 0)
}