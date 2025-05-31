
pan = Interface.CreateFromXML(nil, [[
    <Rect Width="100%" Height="100%" Init:ChildAlign="9">
                
        <Rect Absolute="true" X="15" Y="15" FontSize="16" Width="100" Height="1ch">
            Flex:
        </Rect>

        <!-- Static -->
        <Rect Absolute="true" X="100" Y="100" Width="30ss" Height="30ss" Fill="Black">
            <Rect Absolute="true" X="10ss" Y="10ss" Width="10ss" Height="10ss" Fill="Yellow" />
        </Rect>
        
        <!-- Size to children, absolute -->
        <Rect Absolute="true" X="100" Y="250" Fill="Black">
            <Rect Absolute="true" X="10ss" Y="10ss" Width="20ss" Height="20ss" Fill="Cyan" />
        </Rect>

        <!-- Flex -->
        <Rect Name="Flex" Debug:Bounds="true" Absolute="true" X="100" Y="400" Fill="Black" :Align="ChildAlign" Padding="10" Gap="10"
            Flow="X">
            <Rect Name="R" Fill="Red" Width="100" Height="100" />
            <Rect Name="G" Fill="Green" Width="200" Height="200" />
            <Rect Name="B" Fill="Blue" Width="100" Height="100" />
        </Rect>
        
        <!-- Flex2 -->
        <Rect Name="Flex2" Debug:Bounds="true" Absolute="true" X="300" Y="700" Width="500" Height="500" Fill="Black" :Align="ChildAlign" Gap="10" Padding="10"
            Flow="X">
            <Rect Name="R" Fill="Red" Width="100" Height="100" />
            <Rect Name="G" Fill="Green" Width="200" Height="200" />
            <Rect Name="B" Fill="Blue" Width="100" Height="100" />
        </Rect>

        

        <!-- Flex3 -->
        <Rect Name="Flex3" Debug:Bounds="true" Absolute="true" X="1200" Y="200" Fill="Black" :Align="ChildAlign" Padding="10" Gap="10"
            Flow="Y">
            <Rect Name="R" Fill="Red" Width="100" Height="100" />
            <Rect Name="G" Fill="Green" Width="200" Height="200" />
            <Rect Name="B" Fill="Blue" Width="100" Height="100" />
        </Rect>
        
        <!-- Flex4 -->
        <Rect Name="Flex4" Debug:Bounds="true" Absolute="true" X="1200" Y="700" Width="500" Height="500" Fill="Black" :Align="ChildAlign" Gap="10" Padding="10"
            Flow="Y">
            <Rect Name="R" Fill="Red" Width="100" Height="100" />
            <Rect Name="G" Fill="Green" Width="200" Height="200" />
            <Rect Name="B" Fill="Blue" Width="100" Height="100" />
        </Rect>
    </Rect> 
]])
pan:InvalidateLayout()

local t = false
timer.Create("FlexFlip", 1, 0, function ()
    if not t then
        return
    end

    if IsValid(pan) then
        local al = pan:GetProperty("ChildAlign")
        al = al + 1
        if al > 9 then
            al = 1
        end
        print("ALIGN", al)

        pan:SetProperty("ChildAlign", al)
        pan:InvalidateLayout()
    end
end)