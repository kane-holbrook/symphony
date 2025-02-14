# Interfaces
Interfaces are an abstraction layer built around VGUI that facilitates:
- event-driven lifecycle management,
- lazy-loading of VGUI elements,
- the creation and registration of VGUI elements via XML, 
- calculated properties,
- procedural generation of gradients, materials and polygons,
- seamless CSS-style transitions
- responsivity out of the box
- improved drag & drop

## Shadow tree
## Fonts
## Creating and registering components
## Calculated properties
## Transitions
## Rects
## Labels
## Images
## 3D
## Events
## XML

# Reference
## Panel
### Properties

| Name              | Type     | Default        | Description                                                                 |
| -------------     | -------- | ------------   | -------------------------------------------------                           |
| Ref               | String   | nil            | Short for "Reference". The name through which other elements should reference this. |
| FullyQualifedRef  | String   | nil            | Short for "Fully qualifed reference"; this is a unique ID.  |
| X                 | Number   | nil            | |
| Y                 | Number   | nil            | |
| Width             | Number   | nil            | The width of the element |
| Height            | Number   | nil            | |
| Display           | Boolean  | true           | Whether or not the element should draw. NOT if the element is drawn. |
| Propagate         | Boolean  | true           | Whether or not events should propagate |
