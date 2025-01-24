sym.db = {}
sym.db.tables = {}

require("mysqloo")
if not mysqloo then
    error("MySQLOO failed to load.")
end

function sym.db.Connect()
    local credentials = util.JSONToTable(file.Read("symphony/mysql.json", "DATA") or "{}") 

    if not credentials then
        return
    end

    local host = credentials.host
    local port = credentials.port

    local user = credentials.user
    local pass = credentials.pass
    local db = credentials.db

    hndl = mysqloo.connect(host, user, pass, db)
    
    function hndl:onConnected()
        sym.print("Connected to the database.")
        sym.db.hndl = hndl

        sym.OnDatabaseConnected:Invoke()

        -- Create the tables
        local p = sym.db.Query("SHOW TABLES;")
        p.query:wait()

        local existing = {}
        for k, v in pairs(p:GetResult()) do
            local t = tablex.GetFirst(v)
            existing[t] = true
        end
        sym.debug("FOUND_EXISTING_TABLES", table.concat(table.GetKeys(existing), ";"))

        for k, v in pairs(sym.types) do
            v:CreateDatabaseTable(existing)
        end
        
        sym.OnSetupDatabase:Invoke()
    end

    function hndl:onConnectionFailed(err)
        sym.error("Failed to connect to the database: " .. err)
        error("Fatal error in database connect")
        sym.db.hndl = false
        sym.db.err = err
        return false
    end

    hndl:connect()
    hndl:wait()
end

function sym.db.Query(query, p, bManualStart)
    local p = p or sym.promise()

    sym.fine("QUERY", query)
    if not sym.db.hndl then
        sym.finer("QRY_DELAY", "Database not yet connected. Scheduling...")
        sym.OnDatabaseConnected:Hook(function (ev)
            sym.db.Query(query, p)
        end)
        return p
    end

    local q = sym.db.hndl:query(query)
    
    function q:onSuccess(data)
        sym.finer("QRY_RESULT", "Query ran successfully. Rows returned: ", #data)
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


function sym.db.SetPreparedQuery(query, ...)
    for i, v in ipairs({...}) do
        local t = TypeID(value)
        if t == TYPE_NIL then
            query:setNull(i)
        elseif t == TYPE_BOOL then
            query:setBoolean(i, value)
        elseif t == TYPE_NUMBER then
            query:setNumber(i, value)
        elseif t == TYPE_TABLE then
            query:setString(i, util.TableToJSON(value))
        else
            query:setString(i, value)
        end
    end
end

function sym.db.escape(value)
    local t = TypeID(value)
    if t == TYPE_NIL then
        return "NULL"
    elseif t == TYPE_BOOL then
        return value and "TRUE" or "FALSE"
    elseif t == TYPE_NUMBER then
        return value
    elseif t == TYPE_TABLE then
        return "\"" .. hndl:escape(util.TableToJSON(value)) .. "\""
    else
        return "\"" .. hndl:escape(value) .. "\""
    end
end


function sym.db.StartTransaction()
    return sym.db.query("START TRANSACTION WITH CONSISTENT SNAPSHOT;")
end

function sym.db.Commit()
    return sym.db.query("COMMIT;")
end

function sym.db.Rollback()
    return sym.db.query("ROLLBACK;")
end
