AddCSLuaFile()
if SERVER then return end

print("Test")

-- Interface.Create
-- Interface.Register
-- Interface.CreateFromXML
-- Interface.RegisterFromXML

-- Interface.CreateContext
-- Context:Paint

-- vgui.Create("SymInterface")]

--[[
    <Rect Ref="test" Width="100%" Height="100%" Background="255 0 0" Align="8" Direction="Y">
        <!-- Header -->
        <Rect Ref="Header" X="0" Y="0" Width="100%" Height="50" Background="0 0 0" Align="5">
            <Label Font="Arial" FontSize="16">Hello!</Label>
        </Rect>

        <!-- Content -->
        <Rect Ref="Body" X="0" Y="50" Width="100%" Background="255 255 255" Align="4" Grow="true" Gap="3">
            <Rect Ref="Sidebar" Width="33%" Background="0 0 0" Align="8" Padding="3" Direction="Y">
                <!-- Items -->
            </Rect>

            <Rect Ref="Content" Grow="True">
                <Material />
                <Label />
                <For Each="" />
                <Listen Hook="" Event="" Target="Promise|EventBus" />
                <Slot />
            </Rect>
        </Rect>
    </Rect>

]]