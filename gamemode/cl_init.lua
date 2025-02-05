include("shared.lua")


if IsValid(p) then
    p:Remove()
end

p = Interface.CreateFromXML(nil, [[
    <Rect Flex="8" Direction="Y" X="0" Y="0" Width="100%" Height="100%" Background="0 0 0 245">
        <Rect Ref="Header" Width="100%" Height="15ssh" Background="0 0 0 255">
            Hello <Text MarginLeft="1cw">there</Text>
        </Rect>

        <Rect Ref="Body" Grow="true" Padding="32">
            <Img Material="symphony/logo.png" Width="10" Height="10ss" />
        </Rect>
    </Rect>
]])