
local UG = Type.Register("Usergroup", nil, { Table = "usergroups", Key = "Name" })
UG:CreateProperty("Name", Type.String, { DatabaseType = "VARCHAR(255)" })
UG:CreateProperty("Permissions", Type.Table)
