AddCSLuaFile()
DeriveGamemode("sandbox")

SYMPHONY = true

sym = sym or {}

SYM_START_TIME = SysTime()

include("utils.lua")
IncludeEx("lib/containers.lua", Realm.Shared)
IncludeEx("lib/stringex.lua", Realm.Shared)
IncludeEx("lib/mathex.lua", Realm.Shared)
IncludeEx("lib/tablex.lua", Realm.Shared)
IncludeEx("lib/uuid.lua", Realm.Shared)
IncludeEx("lib/drawex.lua", Realm.Shared)
IncludeEx("lib/materialex.lua", Realm.Shared)
IncludeEx("lib/vguix.lua", Realm.Shared)

-- core/sh_database.lua
IncludeEx("core/sh_net.lua", Realm.Shared)
IncludeEx("core/sh_types.lua", Realm.Shared)
IncludeEx("types/framework/proxy.lua", Realm.Shared)
IncludeEx("types/framework/primitives.lua", Realm.Shared)
IncludeEx("types/framework/promise.lua", Realm.Shared)
IncludeEx("types/framework/collections.lua", Realm.Shared)
IncludeEx("types/framework/datetime.lua", Realm.Shared)

IncludeEx("types/framework/account.lua", Realm.Shared)
IncludeEx("types/framework/connection.lua", Realm.Shared)
IncludeEx("types/framework/usergroup.lua", Realm.Shared)
IncludeEx("types/roleplay/item.lua", Realm.Shared)
IncludeEx("types/roleplay/inventory.lua", Realm.Shared)
IncludeEx("types/roleplay/weapon.lua", Realm.Shared)
IncludeEx("types/roleplay/clothes.lua", Realm.Shared)
IncludeEx("types/roleplay/character.lua", Realm.Shared)
IncludeEx("types/items/weapons/morita_mk1.lua", Realm.Shared)
IncludeEx("types/items/weapons/morita_saw.lua", Realm.Shared)

IncludeEx("core/sv_database.lua", Realm.Server)

IncludeEx("ui/sh_menubar.lua", Realm.Shared)

IncludeEx("ui/components/cl_circle.lua", Realm.Client)
IncludeEx("ui/components/cl_roundedbox.lua", Realm.Client)
IncludeEx("ui/components/sh_scrollpanel.lua", Realm.Shared)
IncludeEx("ui/components/sh_button.lua", Realm.Shared)
IncludeEx("ui/components/sh_textbox.lua", Realm.Shared)
IncludeEx("ui/components/sh_slider.lua", Realm.Shared)
IncludeEx("ui/components/sh_popover.lua", Realm.Shared)
IncludeEx("ui/components/sh_tooltip.lua", Realm.Shared)
IncludeEx("ui/components/sh_modal.lua", Realm.Shared)
IncludeEx("ui/components/sh_html.lua", Realm.Shared)
IncludeEx("ui/menu/sh_menu.lua", Realm.Shared)
IncludeEx("ui/menu/sh_select_character.lua", Realm.Shared)
IncludeEx("ui/menu/sh_create_character.lua", Realm.Shared)
IncludeEx("ui/config/sh_entity_inspector.lua", Realm.Shared)


function Xalphox()
    for k, v in pairs(player.GetAll()) do
        if v:Nick() == "Xalphox" then
            return v
        end
    end
end



function GM:PlayerDeathThink( pl )
    print("Player DeathThink")
end
