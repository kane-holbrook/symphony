Database = {}
Database.Tables = {}

require("mysqloo")
if not mysqloo then
    error("MySQLOO failed to load.")
end

function Database.Connect()
    local credentials = util.JSONToTable(file.Read("symphony/mysql.json", "DATA") or "{}") 

    local host = credentials.host
    local user = credentials.user
    local pass = credentials.pass
    local db = credentials.db

    hndl = mysqloo.connect(host, user, pass, db)
    
    function hndl:onConnected()
        print("Connected to the database.")
        Database.hndl = hndl

        sym.OnDatabaseConnected:Invoke()

        -- Create the tables
        local p = Database.Query("SHOW TABLES;")
        p.query:wait()

        local existing = {}
        for k, v in pairs(p:GetResult()) do
            local t = tablex.GetFirst(v)
            existing[t] = true
        end
        print("FOUND_EXISTING_TABLES", table.concat(table.GetKeys(existing), ";"))
        Database.Tables = existing

        for k, v in pairs(Type.GetAll()) do
            v:CreateDatabaseTable(existing)
        end
        
        sym.OnSetupDatabase:Invoke()
    end

    function hndl:onConnectionFailed(err)
        sym.error("Failed to connect to the database: " .. err)
        error("Fatal error in database connect")
        Database.hndl = false
        Database.err = err
        return false
    end

    hndl:connect()
    hndl:wait()
end

function Database.Query(query, p, bManualStart)
    local p = p or Promise.Create()

    print("QUERY", query)
    if not Database.hndl then
        print("QRY_DELAY", "Database not yet connected. Scheduling...")
        sym.OnDatabaseConnected:Hook(function (ev)
            Database.Query(query, p)
        end)
        return p
    end

    local q = Database.hndl:query(query)
    
    function q:onSuccess(data)
        print("QRY_RESULT", "Query ran successfully. Rows returned: ", #data)
        p:Complete(data)
    end

    function q:onError(err, sql)
        p:ThrowError(err)

        sym.error("MySQL error: ", FromPrimitive(err))
        sym.debug("MYSQL_ERROR", sql)
    end

    if not bManualStart then
        q:start()
    end

    p.query = q

    return p
end 



hook.Add("Test.Register", "Database", function ()
end)

if SERVER then
    net.Receive("Test.Database", function (len, ply)
        local query = net.ReadString()
        Database.Query(query):wait()
    end)
    util.AddNetworkString("Test.Database")
end