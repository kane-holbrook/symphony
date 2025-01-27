

Interface.CreateRenderTarget()
Interface.CreateMaterial()
Interface.CreateMaterialFromHTML()
Interface.CreateGradient()

SymPanel
  X
  Y
  Width
  Height
  Positioning: Default, Ignore
  Sizing: Default, Parent, Children, Grow
  LayoutOn: Always, Resize, Event, Manual
  Transitions[]
  
  Alpha
  Cursor
  Visible
  Keyboard/Mouse
  Parent
  Refs = []
  Children[]
  Slots[]
  ZIndex

  LocalToScreen
  ScreenToLocal
  GetXML()

Flex: Default
Grid
Canvas (pannable canvas)


pnl = Interface.Create("Flex")
Flex:SetAlignment(4)
Flex:InvalidateLayout()

```xml
<Panel Align="5">
  <Grid :Items="player.GetAll()">
    <Listen Hook="PlayerConnect" />
    <Listen Hook="PlayerDisconnect" />

    <Row>
      <Column Properties="header">
        Name
      </Column>
      
      <Column Properties="header">
        Ping
      </Column>
    </Row>

    <Row :Display="#Items == 0">
      <Column Span="2">
        There are no players ingame.
      </Column>
    </Row>

    <For Each="_, ply in Items" :Display="#Items > 0">
      <Row>
        <Column><Label FontWeight="800" :Text="ply:Name()" /></Column>
        <Column><Label :Text="ply:Ping()" /> <VGUI:DTextEntry /></Column>
      </Row>
    </For>

  </Grid>
</Panel>```

```xml
  <!-- '(a, b) =>' becomes function (a, b) return ... end -->

  <Component Name="" On:Change="function (value)
    self:SetValue('Value')
    Emit('Change', self, value)
    return true
  end">    
    <Panel Size="PARENT" Background="Color(255, 255, 255, 192)" Shadow="1">
      
    </Panel>
  </Component>
```

Interface.Create(name, parent)
Interface.Register(name, base, panel)
Interface.CreateFromXML(parent, xml)
Interface.RegisterFromXML(parent, xml)

Panels will be their own FENV?

