Blueprints = {}


function Blueprints.RegisterComponent(name, description, func, inputs, outputs)
end

local ply = FindMetaTable("Player")
Blueprints.Register("Set Player Health", "Set a players health.", ply.SetHealth, {
    { Name = "Player", Type = Player },
    { Name = "Health", Type = Number }
})

Blueprints.Register("Get Player Health", "Get a players health.", ply.Health, 
{
    { Name = "Player", Type = Player }
}, 
{
    { Name = "Health", Type = Number }
})