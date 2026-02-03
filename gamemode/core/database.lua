Database = {}

require("mysqloo")

local query = Type.Register("Query", Type.Promise)
query:CreateProperty("Query")

function query.Prototype:wait()
    self:GetQuery():wait()
    return self
end

function Database.Connect()
    return Promise.Run(function ()
        local credentials = util.JSONToTable(file.Read("symphony/mysql.json", "DATA") or "{}") 

        local host = credentials.host
        local user = credentials.user
        local pass = credentials.pass
        local db = credentials.db
        

        if not host then
            credentials.host = "localhost"
            credentials.user = "root"
            credentials.pass = ""
            credentials.db = "symphony"
            file.Write("symphony/mysql.json", util.TableToJSON(credentials, true))
            Log.Write(LOG_ERROR, "DATABASE", "MySQL credentials not found! A default file has been created in garrysmod/data/symphony/mysql.json. Please edit it and restart the server.")
            error("MySQL credentials not found! A default file has been created in garrysmod/data/symphony/mysql.json. Please edit it and restart the server.")
        end

        Database.hndl = mysqloo.connect(host, user, pass, db)
        
        function Database.hndl:onConnected()
            Database.Connected = true
        end

        function Database.hndl:onConnectionFailed(err)

            Database.hndl = false
            Database.Error = err
            Database.Connected = false
            Log.Write(LOG_ERROR, "DATABASE", "Failed to connect to database: " .. err)
            error("Failed to connect to database:" .. err)
            return false
        end

        Database.hndl:connect()
        Database.hndl:wait()

        if Database.Connected then
            
            Log.Write(LOG_INFO, "DATABASE", "Connected to database (" .. user .. "@" .. host .. ").")

            -- Create the tables
            local p = Database.Query("SHOW TABLES;")
            p:wait()

            local existing = {}
            for k, v in pairs(p:GetResult()) do
                local t = tablex.GetFirst(v)
                existing[t] = true
            end
            Database.Tables = existing

            for k, v in pairs(Type.GetAll()) do
                if v:GetDatabaseTable() then
                    v:CreateDatabaseTable()
                end
            end
            
            hook.Run("DatabaseConnected")
        end
    end)
end

function Database.Query(q)
    assert(Database.hndl, "Database not yet connected")

    local p = Type.New(Type.Query)
    p:SetTTL(30)
    local q = Database.hndl:query(q)
    function q:onSuccess(data)
        p:Complete(data)
    end

    function q:onError(err)
        p:ThrowError(err)
        error(err)
    end
    p:SetQuery(q)
    q:start()

    _qry = q

    return p
end

function Database.Escape(str)
    return Database.hndl:escape(str)
end

hook.Add("Symphony:Initialize", function (promises)
    table.insert(promises, Database.Connect())
end)