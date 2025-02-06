include("shared.lua")


if IsValid(p) then
    p:Remove()
end

p = Interface.CreateFromXML(nil, [[
    <Rect Flex="8" Direction="Y" X="0" Y="0" Width="100%" Height="100%" Background="0 0 0 200">
        <Rect Ref="Header" Width="100%" Background="0 0 0 225" Flex="4" Gap="2" Padding="1" PaddingLeft="2">
            <Img Material="symphony/logo.png" Height="5ss" Width="5ss" MarginRight="2" />

            <Style 
                Ref="Button" 
                :Hover="true" 
                :Background="Color(255, 0, 0, 255)" 
                :Hover:Background="LinearGradient(Width, Height, 0, Color(0, 0, 0, 255), 0, Color(255, 255, 255, 255), 99)"
            />

            <Rect Style="Button">File</Rect>
            <Rect Style="Button">Edit</Rect>
            <Rect Style="Button">Debug</Rect>
            <Rect Style="Button">Tests</Rect>
            <Rect Style="Button">Windows</Rect>
            <Rect Style="Button">Help</Rect>

        </Rect>

        <Rect Ref="Body" Grow="true" Flex="5" Direction="Y" Gap="2">
        
        </Rect>
    </Rect>
]])
p:MakePopup()