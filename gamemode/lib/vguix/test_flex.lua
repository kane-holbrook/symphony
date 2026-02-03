AddCSLuaFile()

if SERVER then
    return
end


concommand.Add("test_flex", function (ply, cmd, args)
    if IsValid(pan) then
        pan:Remove()
        return
    end

    pan = vguix.CreateFromXML(nil, [[
        <Rect Width="100%" Height="100%" Init:ChildAlign="1" Color:FontColor="255, 0, 0, 255">
                    
            <Rect Absolute="true" X="15" Y="15" >
                Flex: <Text Global="AlignText" MarginLeft="1cw" :Value="tostring(ChildAlign)" />
            </Rect>

            <!-- Static -->
            <Rect Name="Static" Absolute="true" X="100" Y="100" Width="30ss" Height="30ss" Fill="0, 0, 0, 255">
                <Rect Absolute="true" X="10ss" Y="10ss" Width="10ss" Height="10ss" Fill="255, 255, 0, 255" />
            </Rect>
            
            <!-- Size to children, absolute -->
            <Rect Global="SizeToChildren" Align="false" Name="SizeToChildren" Absolute="true" X="100" Y="250" Fill="128, 128, 128, 255">
                <Rect Absolute="true" Align="false" X="50" Y="50" Global="Mid"  Width="auto" Height="auto" Fill="255, 0, 255, 255">
                    <Rect Absolute="true" X="25" Y="25" Global="Bottom" Name="W"  Width="50" Height="50" Fill="255, 255, 255, 255">
                    </Rect>
                </Rect>
            </Rect>

            <!-- Flex -->
            <Rect -10:Align="ChildAlign" Global="Flex" Name="Flex" Absolute="true"  X="100" Y="600" Fill="128, 128, 0, 255" 
                Flow="X" Padding="10" Gap="10">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Fill="0, 255, 0, 255" Width="200" Height="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>
            
            <!-- Flex2 -->
            <Rect -10:Align="ChildAlign" Name="Flex2" Global="Flex2"  Absolute="true" X="300" Y="900" Width="500" Height="500" Fill="0, 0, 128, 255" Gap="10" Padding="10"
                Flow="X">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Fill="0, 255, 0, 255" Width="200" Height="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>

            

            <!-- Flex3 -->
            <Rect -10:Align="ChildAlign" Name="Flex3" Global="Flex3" Absolute="true" X="1200" Y="200" Fill="0, 128, 0, 255" Padding="10" Gap="10"
                Flow="Y">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Fill="0, 255, 0, 255" Width="200" Height="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>
            
            <!-- Flex4 -->
            <Rect -10:Align="ChildAlign" Name="Flex4" Global="Flex4" Debug:Bounds="true" Absolute="true" X="1200" Y="700" Width="500" Height="500" Fill="0, 0, 0, 255" Gap="10" Padding="10"
                Flow="Y">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Fill="0, 255, 0, 255" Width="200" Height="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>
            
            <Rect -10:Align="ChildAlign" Name="FlexGrowY" Global="Flex4" Debug:Bounds="true" Absolute="true" X="2000" Y="800" Width="500" Height="500" Fill="0, 0, 0, 255" Gap="10" Padding="10"
                Flow="Y">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Grow="true" Fill="0, 255, 0, 255" Width="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>
            
            <Rect -10:Align="ChildAlign" Name="FlexGrowX" Global="Flex4" Debug:Bounds="true" Absolute="true" X="2000" Y="200" Width="500" Height="500" Fill="0, 0, 0, 255" Gap="10" Padding="10"
                Flow="X">
                <Rect Name="R" Fill="255, 0, 0, 255" Width="100" Height="100" -10:Align="ChildAlign" Padding="10">
                    <Rect Name="W" Fill="255, 255, 255, 255" Width="50" Height="50" />
                </Rect>
                <Rect Name="G" Global="GrowX" Grow="true" Fill="0, 255, 0, 255" Height="200" />
                <Rect Name="B" Fill="0, 0, 255, 255" Width="100" Height="100" />
            </Rect>
        </Rect> 
    ]])
    pan:InvalidateLayout()

    local t = tonumber(args[1])
    timer.Create("FlexFlip", 1, 0, function ()
        if not t then
            return
        end

        if IsValid(pan) then
            local al = pan:GetFuncEnv("ChildAlign")
            al = al + 1
            if al > 9 then
                al = 1
            end

            pan:SetFuncEnv("ChildAlign", al)
            pan:InvalidateChildren(true)
        end
    end)
end)