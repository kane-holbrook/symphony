## User interface
### Core
- I should be able to efficiently generate procedural materials. ✓
    - I should be able to check to see if a procedural material is generated or generating. ✓
    - I should be able to apply a stencil to a procedural material. ✓
    - I should be able to add and remove callbacks from a procedural material so I can hook when it is completed. ✓
    - I should be able to generate procedural materials asynchronously.
- I should be able to generate materials from HTML.
- I should be able to create XVGUI arbitrary contexts.
    - That work in 2D like a drop in for derma.
    - Or in other contexts (3D) where I can define arbitrary inputs (i.e. cam3d2d)
- I should be able to register new components.
- I should be able to create user interface elements.
- I should be able to append elements to a parent element.
- I should be able to create new properties
    - With strict typing
    - An order of execution
    - To only recalculate when a component has been resized.
- I should be able to set properties on elements
    - Directly by value
    - Calculated on layout via a function.
- I should be able to get properties on elements.
    - From the element, if the property exists
    - Inherited from a parent
        - Except where I've specifically asked not to.
- Elements should have properties for
    - Ref
    - A set of classes
        - Classes define defaults for properties
    - Position
    - Size
        - Arbitrarily
        - Based on my parent's bounds
        - To the size of my children
    - Z-index
    - Stencil
    - Background
    - Border
    - Radius
    - Font
    - Cursor
    - Whether or not it should be displayed
    - Draggable
    - Moveable
    - Resizable
    - Pannable
- I should be able to programmatically navigate the ref tree.
- I should be able to set a component to layout its children per a given alignment ("flex")
    - Flex elements should have properties for:
        - Align: the cardinal direction/anchor.
        - Gap: The gap between elements
        - Padding
        - Direction, determining whether or not it lays out on the X axis or the Y axis.
    - Children of flex elements should
        - Align sequentially per the parent's properties
        - Have properties for
            - Margin
            - Order/index
            - Growing to the remaining size of the parent.
- I should be able to set a component to layout its children in a grid
    - Grid elements properties for:
        - Direction
        - Padding
        - Gap
        - A property to define the number of rows or columns.
    - Children of grid elements should have properties for
        - Margin
        - Order/index
        - Column span
        - Row span
- I should be able to easily define properties to override when
    - A class is applied i.e. ClassName:FontSize=""
    - The element is being hovered over
    - The element is selected
- I should be able to emit events from elements
    - Recursively through parents
    - Recursively through children.
- I should be able to hook events and define functionality.
- I should be able to mark that an element should re-layout when a hook runs.
- I should be able to mark that an element should re-layout when another element lays out.
- I should be able to mark that an element should re-layout based on a timer.
- I should be able to define slots on components
    - I should be able to define a default slot where children are automatically added.
    - I should be able to define named slots that children can voluntarily attach themselves to.
- I should be able to create user interfaces semantically via XML.
    - I should be able to define Lua code for properties via :Prop=""
- I should be able to trigger that an element should re-layout in the next frame.



PANEL:RegisterProperty("Name", sym.types.string, options)
PANEL:GetProperty(name, inherit)
PANEL:SetProperty(name)
PANEL:GetPropertyMetadata(name)

.Properties = Inherited table of properties
.FuncEnv = Values of Properties