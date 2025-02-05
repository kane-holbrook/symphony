Interface = {}

Interface.FuncCache = weaktable(false, true)

IncludeEx("derma/vgui.lua", Realm.Shared)
IncludeEx("derma/xml.lua", Realm.Shared)


--[[
    DoR:
    1. I can create Derma elements via XML.
    2. I can set their properties using attributes.
    3. Properties are validated using types.
    4. I can programmatically set properties.
]]