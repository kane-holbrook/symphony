
local ACC = Type.Register("Account", nil, { Table = "accounts", Key = "SteamID" })
ACC:CreateProperty("SteamID", Type.String, { DatabaseType = "VARCHAR(32)" })
ACC:CreateProperty("Name", Type.String, { DatabaseType = "VARCHAR(255)" })
ACC:CreateProperty("Points", Type.Number)
ACC:CreateProperty("Usergroups", Type.Table)
ACC:CreateProperty("IPAddress", Type.String, { DatabaseType = "VARCHAR(32)" })
ACC:CreateProperty("City", Type.String, { DatabaseType = "VARCHAR(255)" })
ACC:CreateProperty("Country", Type.String, { DatabaseType = "VARCHAR(255)" })
ACC:CreateProperty("Timezone", Type.String, { DatabaseType = "VARCHAR(255)" })
ACC:CreateProperty("Longitude", Type.Number)
ACC:CreateProperty("Latitude", Type.Number)
ACC:CreateProperty("Proxy", Type.Boolean)
ACC:CreateProperty("CreatedTime", Type.DateTime)
ACC:CreateProperty("LastJoinTime", Type.DateTime)




local PLY = FindMetaTable("Player")
AccessorFunc(PLY, "Account", "Account")
