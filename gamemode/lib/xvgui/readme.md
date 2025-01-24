# XVGUI 1.0

## XML parsing
There are two methods for XML parsing:

- xvgui.CreateFromXML(parent, xml): Parses the XML and creates elements directly against a parent.
  - parent: The panel to parent the new element(s) to.
  - xml: The XML string to parse into a VGUI tree.
- xvgui.RegisterFromXML(xml): Returns a panel.


## XPanel
### Properties
- Properties are values or functions that are set when the panel is laid out (i.e. in PerformLayout).
- Properties can either be a value (i.e. a primitive or a table), or a function. If they're a function, they are reevaluated.
- Property functions have a special function environment set where the following global variables are accessible:
  - Parent: The parent element.
  - PW: The width of the parent element.
  - PH: The height of the parent element.
  - Properties cascade down from parents, meaning if you set a property in a parent element, you can use it in a child element.
  - References also cascade down from parents.  
- You can intercept when a property is changed by overriding PANEL:OnPropertyChanged(new, old). Make sure to trigger BaseClass.OnPropertyChanged(self, new, old).

### References (Ref)
- The Ref property 

## TODO
- Set default fonts