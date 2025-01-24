# Type
* Name 
* Super
* Prototype
* Properties

# Property
* Name: The name of the property
* Default: The default value of the property
* Type: The type of the property, i.e. String, Account

# Instance
## Properties
* ID: The UUID of the object.
* Type: The Type object.
* Source: A player if the source was a player, or false if it came from the server.
* Recipients: Who can see this object, and when it was last transmitted

## Methods
* Transmit(): Transmits the object.

## Events
* :OnInstance
* :OnTransmit
* :OnReceive
* :OnPropertyChange

# EventResult
* Source
* Data
* WasCancelled
* Cancel()
