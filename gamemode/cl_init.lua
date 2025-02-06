include("shared.lua")


if IsValid(p) then
    p:Remove()
end

p = Interface.CreateFromXML(nil, [[
    <Rect Flex="8" Direction="Y" X="0" Y="0" Width="100%" Height="100%" Background="0 0 0 200">
        <Rect Ref="Header" Width="100%" Height="10ssh" Background="0 0 0 225" Flex="4" Padding="1" PaddingLeft="2">
            <Img Material="symphony/logo.png" Height="8ssh" Width="8ssh" MarginRight="1" />

            <Style 
                Ref="Button"
                :Height="PH"
                Flex="5"
                :PaddingX="ScreenScale(2)"
                Cursor="hand"
                Hover="true" 
                :Background="color_transparent"
                :Hover:Background="Color(0, 0, 0, 128)"
                Transition:Background="math.ease.InOutQuart, 0.5"
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