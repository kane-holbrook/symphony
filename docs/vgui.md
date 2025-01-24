# XML
# SymPanel
- SymPanels are primarily controlled by properties - essentially a key-value table stored on the panel. This allows properties to be recomputed reliably in PerformLayout.
  - Properties can be created on the PANEL object using PANEL:Property(name, default)
  - Properties can be set using PANEL:SetProperty(name, value).
  - Properties can be get using PROPERTY:GetProperty(name).
  - Properties can be set to either a value (100.0) or a function that returns a value.
    - If the property is a function, it will be re-evaluated every layout.
    - If the property is a function, its function environment is set to contain globals for all the current property values on the object, as well as some from the parent.
  - When a property is changed, the PANEL:OnPropertyChange(name, new, old) method is invoked.
  - If the property is a function, this is evaluated at the next layout.
  - Setting a property triggers a re-layout.
- Additional notes:
  - The vgui_drawtree 1 cvar can be used to see a tree of all the VGUI elements, including SymPanels.
  - The vgui_visualizelayout 1 cvar can be used to visualize layouts (they flash red every layout). Properly constructed components should not re-layout constantly. 

## Mode: Flex
- The flex mode allows you to align a panel's horizontal and vertical alignment.
  - It's based on numpad keys, meaning a 7 means top left, a 3 means top right, and a 5 means centred.
  - When a parent element is set to flex, the X and Y of child elements is ignored unless the Absolute property is set to true.
  - You can set the direction the flex panel flows using Direction; either RIGHT (left-to-right) or BOTTOM (top-to-bottom) is valid.
  - You can set the gutters (gap) between each element using the Gap property.
  - Children with Grow set to true will automatically grow to take up any remaining space in the element.
    - Only one child per panel can be set to grow.
  - Children set to Absolute will not be positioned or included in the layout function.

## Properties
- X: The X position of the panel.
- Y: The Y position of the panel.
- Width: The width of the panel.
  - If set to nil or left empty, it will automatically size to its children.
- Height: The height of the panel.
  - If set to nil or left empty, it will automatically size to its children.
- Display: Whether or not to show the panel. Differs from Visible in that it will be removed from the flow if not Display = false.
- Background: A color or material that should be generated and painted as the background of this panel.
  - Note: If the background is a generated material, it will be evaluated once.
- Border: A color or material that should be generated and painted as the border of this panel.
- BorderSize: How many pixels @TODO - Expand out to the different sides.
- BorderRadius: 
- ShadowSize: 
- ShadowColor:
- ShadowOffset*:
- MarginLeft
- MarginTop
- MarginRight
- MarginBottom
- PaddingLeft
- PaddingTop
- PaddingRight
- PaddingBottom
- FontName
- FontSize
- FontWeight
- FontColor
- Absolute:
- Mode: Determine how positioning is calculated for this element and its children.
  - MODE_FLEX: 
  - MODE_ABSOLUTE:
  - MODE_
- Gap
- Direction
- Grow



PANEL:Property("X", nil) -- ✓
PANEL:Property("Y", nil) -- ✓
PANEL:Property("Width", nil) -- ✓
PANEL:Property("Height", nil) -- ✓
PANEL:Property("Display", true)

PANEL:Property("Background", nil) -- ✓
PANEL:Property("Border", nil)
PANEL:Property("BorderLeftSize", nil)
PANEL:Property("BorderRightSize", nil)
PANEL:Property("BorderBottomSize", nil)
PANEL:Property("BorderTopSize", nil)
PANEL:Property("BorderRadius", nil)
PANEL:Property("ShadowSize", nil)
PANEL:Property("ShadowColor", Color(0, 0, 0, 64))

PANEL:Property("MarginLeft", 0)
PANEL:Property("MarginTop", 0)
PANEL:Property("MarginRight", 0)
PANEL:Property("MarginBottom", 0)
PANEL:Property("PaddingLeft", 0)
PANEL:Property("PaddingTop", 0)
PANEL:Property("PaddingRight", 0)
PANEL:Property("PaddingBottom", 0)


-- Fonts -> probably need to only default this if there isn't a parent.
PANEL:Property("FontName", nil)
PANEL:Property("FontSize", nil)
PANEL:Property("FontWeight", nil)
PANEL:Property("FontColor", nil)

-- Display modes
MODE_DEFAULT = 0
MODE_ABSOLUTE = 1
MODE_FLEX = 2
MODE_GRID = 3
PANEL:Property("Mode", MODE_ABSOLUTE)
PANEL:Property("Gap", 0)
PANEL:Property("Flex", nil)
PANEL:Property("Direction", RIGHT)
PANEL:Property("Margin", { 0, 0, 0, 0 })
PANEL:Property("Padding", { 0, 0, 0, 0 })
PANEL:Property("Grow", false)