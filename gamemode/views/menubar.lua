AddCSLuaFile()

if SERVER then
    return
end

hook.Add("PopulateMenuBar", "Symphony:MenuBar", function (mb)
    local m = mb:AddOrGetMenu("Symphony")
    m:AddOption("Console", function () end)
    m:AddOption("Database", function() end)
    m:AddOption("Performance", function() end)
    m:AddOption("Objects", function() end)
    m:AddOption("Settings", function() end)
end)