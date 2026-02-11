include("shared.lua")
include("sh_hooks.lua")


function Symphony.Init()    
    
    GAMEMODE:SuppressHint("OpeningMenu")
    GAMEMODE:SuppressHint("OpeningContext")
    GAMEMODE:SuppressHint("EditingSpawnlists")
    GAMEMODE:SuppressHint("EditingSpawnlistsSave") 
    GAMEMODE:SuppressHint("Annoy1")
    GAMEMODE:SuppressHint("Annoy2")

    RPC.Call("InitializePlayer"):Then(function (data)
        Log.Write(LOG_INFO, "SYM", "Received startup data from server.")

        local lp = LocalPlayer()
        lp.User = data.User
        User = lp.User

        local promises = {}
        hook.Run("Symphony:Initialize", promises, data)
        Promise.AwaitAll(promises):Then(function ()
            local t = math.Round((SysTime() - Symphony.StartTime) * 1000, 1)
            Log.Write(LOG_INFO, "SYM", "Symphony initialized in " .. t .. "ms.", t)
            hook.Run("Symphony:Ready")
        end)
    end)
end

timer.Simple(0, function ()
    Symphony.Init()
end)



ele = Interface.CreateFromXML(nil, [[
    <Panel 
        Name="Test" 
        :X="self:GetParent():GetWidth() / 2 - self:GetOuterWidth() / 2"
        :Y="self:GetParent():GetHeight() / 2 - self:GetOuterHeight() / 2"
        :Shape="RoundedBox(self:GetWidth(), self:GetHeight(), 64, 64, 64, 64)"
        Fill="200 0 0 255"
        Hovered:Fill="255 0 0 255, 0.5"
        Align="8" 
        Direction="RIGHT" 
        Width="800" 
        Height="600" 
        Margin="16"
        Padding="32" 
        Hoverable="true" 
        Alpha="255" 
        Stroke="8"
        :StrokeMaterial="LinearGradient(
            Color(255, 60, 60, 192),
            1,
            Color(40, 42, 46, 0),
            90
        )"
        Gap="16"
    >
        <Panel 
            Name="Top"
            PaddingLeft="8"
            PaddingRight="8"
            Width="100%"
            Hoverable="true"
            Fill="255 255 255 32"
            Parent:Hovered:Fill="255 255 0 64, 0.5"
            Hovered:Fill="255 255 0 128, 0.5"
            Focused:Fill="255 255 0 192, 0.5"
            Align="4"
            Focusable="true"
            Func:ChangeValue="function (self, src, new, old)
                print('Value changed from', old, 'to', new)
                return true
            end"
        >
            <Textbox Placeholder="hi" />
        </Panel>
    </Panel>
]])