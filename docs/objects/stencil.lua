-- 2D mask.

render.SetStencilEnable(true)

render.ClearStencil()
render.SetStencilTestMask(255)
render.SetStencilWriteMask(255)
render.SetStencilPassOperation(STENCILOPERATION_KEEP)
render.SetStencilFailOperation(STENCILOPERATION_KEEP)
render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)

render.SetStencilReferenceValue(9)
render.SetStencilFailOperation(STENCILOPERATION_REPLACE)

surface.SetDrawColor(0, 0, 0, 255)
surface.DrawRect(w*0.25, h*0.25, w*0.5, h*0.5, 45)

render.SetStencilFailOperation(STENCILOPERATION_KEEP)
render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL)

surface.SetMaterial(bg)
surface.SetDrawColor(color_white)
surface.DrawTexturedRect(0, 0, w, h)

render.SetStencilEnable(false)