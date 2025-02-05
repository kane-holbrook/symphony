include("shared.lua")


if IsValid(p) then
    p:Remove()
end

p = Interface.CreateFromXML(nil, [[
    <DPanel X="5" Y="5" Width="100" Height="100" BackgroundColor="255 0 0 255">
        <DPanel X="25" Y="25" Width="50" Height="50" BackgroundColor="0 255 0 255" />
    </DPanel>
]])