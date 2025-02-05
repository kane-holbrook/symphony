# Types
Symphony Types are a Lua-based object-oriented programming (OOP) implementation. They are designed to loosely reflect how Entities look and feel in GMod. Types can be networked and written to the database.

## Terminology
- When I use the term *Type*, I mean the metadata associated with a type, such as its name, prototype, static methods, etc.
- When I use the term *Instance*, I mean an instance of a type that has generally been created using Type.New. Instances typically contain data that its Type has methods for manipulating or displaying. 
* When I use the term *Object*, I mean an instance of *any* type, as ultimately all types derive from Object (which is itself an implementation of the Type.Type class).
* When I use the term *ORM*, I'm referencing to the fact that objects can be written to and read from the database.

## Implementation
Types are a split into 3 components:
* The Type itself, which usually contains static methods, construction/serialization, and a prototype for any instances. For example *DateTime*. Types themselves are instances of the Type.Type class.
* Type.Prototype: This is the prototype for instances of this Type - for example, a *DateTime* prototype might include methods like *:addSeconds()*.
* Type.Metamethods: This defines the metamethods for instances, for example *__tostring*.


### Types
When using Type.Register, it returns an instance of Type; this should be used to define:
- Static methods
- Type properties
- Behaviour during construction or serialization.
- Any metadata pertaining to the type.

You can create a type using *Type.Register*:
```lua
local MyType = Type.Register("MyType", Type.ParentType, [options])
```

In this case, MyType will inherit all the functionality from Type.ParentType, and its parents, all the way up to the prototype of Type itself (which is called an Object).

In keeping to how GMod handles entities, the logic for what happens when an instance of a type is created should be defined in *Type.Prototype:Initialize*.



#### Options

The third optional parameter (options) to Type.Register is a table; they're used by other parts of the system to drive certain functionality, like what database table it should synchronize with.

The default options that come out of the box with Symphony are:
| Key           | Type     | Default      | Description                                       |
| ------------- | -------- | ------------ | ------------------------------------------------- |
| Table         | String   | nil          | Binds this type to a specific MySQL table         |
| DatabaseType  | String   | JSON or UUID | Defines what MySQL type to use when this type is used as a property on another type. If the type has an ORM binding, it defaults to the object's ID, i.e. a foreign key. |



### Properties
Properties define which parts of an instance's data should be networked or stored in the database. 

You can create a property like so:
```lua
MyType:CreateProperty("Name", Type.String, options)
```

Properties automatically create getters and setters - instance:SetName("Test") for example.

You can provide a table of options to a property via the third *options* parameter. 

By default, properties are strictly typed (i.e. they will throw an error if you try to set them to anything but an instance of their type/nil). You can override this behaviour by setting the NoValidate option to true.


### Instances (Type.New, MyType.Prototype and MyType.Metamethods)
Instances are individual realizations of the type; if you think of players, you can think of players in general being a type (i.e. FindMetaTable("Player")), and an instance being an individual player.

The Prototype table defines the implementation logic of a type once instanced i.e. the methods and functionality that will be available to an instance. 

You can create an instance of a type using ```new(MyType)``` or alternatively ```Type.New(Type.MyType)```.  

For example,

```lua
function MyType.Prototype:PrintMessage()
    print("My name is" .. self:GetName() .. "!")
end

local i = new(MyType)
i:SetName("Xalphox")
i:PrintMessage() --> Prints: My name is Xalphox!
```

The Metamethods table allows you to override metamethods on the type; this is separated as metatables can't inherit metamethods in the usual way. For example,

```lua
function MyType.Metamethods:__tostring()
    return "MyType!!!"
end
print(tostring(i)) --> Prints: MyType!!!
```

Once created, an instance will be assigned a unique 128-bit ID (specifically a UUIDv4). This can be considered unique in all circumstances including across reloads, and unless overridden, will be used as the primary key in any database tables.


## Using types to store data in the database (ORM)

When properly configured, instances of types can be written to and read from the database seamlessly.

**Only** properties are written to the database - never fields. If you want to exclude a property from being written to the database, set the option ```Transient``` to true.

We're going to split this into two parts: tables and properties.

### Tables
Say you want to create something that will store settings - simple key-value pairs. You could do this like so:

```lua
local SETTING = Type.Register("Setting", nil, { DatabaseTable = "Settings" })
SETTING:CreateProperty("Key", Type.String)
SETTING:CreateProperty("Value", Type.String)
```

This creates our new Setting type, tells Symphony it should be saved in the MySQL database table "Settings", and it tells Symphony that this table should have 2 fields: Key, which will be a string, and Object, which will be any type of Symphony object.

#### Inserting a record
We can now create a setting:
```lua
local inst = new(Type.Setting)
inst:SetKey("MySetting")
inst:SetValue("A Value") -- This can be anything
inst:Commit():Then(function ()
    print("Instance has been saved")
end) --> Prints "Instance has been saved" once the instance has been inserted into MySQL. 
```

Here, we create a new instance of Setting, set its key and value, and commit it (insert it into) to the database. If we looked at MySQL, we would see a new table called Setting, with 3 fields and 1 row:
- Id: This field is automatically added by Symphony - it's the UUID of the object.
- Key: MySetting
- Value: A Value

Note that Commit returns a promise - if you're in a coroutine or a promise, you can simply use :Await() to get the value without having to provide a function. See promises for more information.

#### Querying records
You can query records using Type.Setting.Select, like so:
```lua
-- This fetches ALL rows from the Settings table.
Type.Setting.Query():Then(function (rows)
    print(rows[1]:GetKey(), rows[1]:GetValue()) --> Prints: MySetting   A Value
end)
```

You can provide an ID if you only want to return one record:
```lua
Type.Setting.Query(myId):Then(...)
```

You can also query by a field like so:
```lua
Type.Setting.Query("Key", "MySetting"):Then(...)
```


#### Updating a record
The :Commit method is smart enough to know if a record already exists in the database, so if you want to update a record, just run Commit again.

```lua
inst:SetValue("TEST")
inst:Commit():Then(function ()
    print("Successfully updated")
end)
```


#### Deleting a record
Finally, if you want to delete a record from the database, you can use the :DeleteFromDatabase method like so:
```lua
inst:DeleteFromDatabase(function ()
    print("Row deleted from the database")
end)
```


#### Full example with async
```lua
Promise.Run(function ()
    local inst = new(Type.Setting)
    inst:SetKey("MySetting")
    inst:SetValue("A Value")
    inst:Commit():Await()

    local inst2 = Type.Setting.Query(inst:GetId()):Await() -- Pull the record out again
    inst2:SetValue("New Value")
    inst2:Commit():Await()

    inst:DeleteFromDatabase():Await() -- Delete the record.
end)
```


### Properties
When your type is used as a property in another type, by default it will write based on the standard object functionality (i.e. it will create a JSON string that Symphony can use to reconstruct an instance). You can override this behaviour by:
- Setting a DatabaseType: This directly aligns to the MySQL data types, for example LONGTEXT, BIGINT, etc.
- Overriding the :DatabaseEncode and :DatabaseDecode methods on the Type.

So for example, the type wrapper for strings is implemented as thus (from types/primitives.lua):
```lua
local STRING = Type.Register("String", PRIMITIVE, { Code = TYPE_STRING, DatabaseType = "TEXT" })

-- ...

function STRING:DatabaseEncode(value)
    return string.format("%q", value)
end

function STRING:DatabaseDecode(value)
    return value
end
```

This means when I create a String property on a type, it will be written to the database as a TEXT field, and will simply write the string to the field, rather than a Symphony object per default behaviour. You can prevent your type from _ever_ being written to the database by returning nil in DatabaseEncode.



## Networking a type
Types can be networked to players by default. Similar to ORM, this is driven by properties. You can write an object like thus:

```lua
-- On server
net.WriteObject(inst)

-- On client
net.ReadObject(inst)
```

IDs are maintained between both the client and server.

### Overriding who to network a property to
You can override when a property should be networked by setting the ShouldTransmit property option. ShouldTransmit can either be:
- A boolean, where false means the property should never be networked. True is default behaviour.
- A function that accepts a player and should return true if the property should network, or false if it shouldn't.

```lua
-- Create a property that never networks
MyType:CreateProperty("HiddenProperty", Type.String, { ShouldTransmit = false })

-- Create a property that only networks to admins
MyType:CreateProperty("HiddenProperty", Type.String, { ShouldTransmit = function (ply)
    return ply:IsAdmin()
end }) -- Would be more efficient if we just passed FindMetaTable("Player").IsAdmin but hey.
```


### Overriding how objects are serialized when networking
By default, Symphony serializes and deserializes objects in a JSON-safe circular reference-proof table structure that encodes the type ID, its properties, and the serialized version of any tables or sub-types stored within its properties.

In some cases, particularly for simple types like DateTimes, this can be overkill.

You can override this functionality by overriding Type:Serialize and Type:Deserialize:
```lua
local DateTime = Type.Register("DateTime")
DateTime:CreateProperty("UnixTime", Type.Number)

function DateTime:Serialize(obj, ply)
    return data:GetUnixTime()
end

function DateTime:Deserialize(data, ply)
    local dt = new(DateTime)
    dt:SetUnixTime(data)
    return dt
end
```

This can help you optimize database storage and networking overhead.



# Reference