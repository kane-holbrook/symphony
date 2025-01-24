Panel
  Child
    Child


- Panel
  - Classes: Array of strings
  - Background: Material
  - Border: Material
  - Stencil: Material
  - Display: True, false
  - Layout: Flex, Grid 
  - Pos: Vector2
  - Size: Vector2
  - Rotation: Float
  - Skew: Vector2
  - Scale: Vector2

Layouts -> Regenerate materials


Material
    Paint
    PaintChildren
    Stencil
    Update
    Children

For each material, 
1. Generate the stencil
2. Draw the paint, applied with the stencil
3. Draw each child, applied with the stencil


sym.Material()
    :Paint(w, h)
    :Stencil()
    :Render()


Notes: 
- Materials appear to have unique MTs!