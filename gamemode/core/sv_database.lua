Database = {}

require("mysqloo")

local query = Type.Register("Query", Type.Promise)
query:CreateProperty("Query")

function query.Prototype:wait()
    self:GetQuery():wait()
    return self
end

function Database.Connect()
    
    local credentials = util.JSONToTable(file.Read("symphony/mysql.json", "DATA") or "{}") 

    local host = credentials.host
    local user = credentials.user
    local pass = credentials.pass
    local db = credentials.db

    Database.hndl = mysqloo.connect(host, user, pass, db)
    
    function Database.hndl:onConnected()
        print("Connected to the database.")

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
            v:CreateDatabaseTable()
        end
    end

    function Database.hndl:onConnectionFailed(err)
        error("Failed to connect to database:" .. err)
        Database.hndl = false
        Database.Error = err
        return false
    end

    Database.hndl:connect()
    Database.hndl:wait()

    Database.Connected = true

    hook.Run("DatabaseConnected")
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

    return p
end

function Database.Escape(str)
    return Database.hndl:escape(str)
end


-- Disposable
-- UUID
-- CREATE TABLE/ALTER TABLE
-- Insert
-- Delete
-- Update
-- Select



local TRANS = Type.Register("DatabaseTransaction", Type.Disposable)
TRANS:CreateProperty("Open")
TRANS:CreateProperty("Trace")

function TRANS.Prototype:Initialize()
    self:SetOpen(true)
    self:SetTrace(debug.traceback())
    Database.Query("START TRANSACTION WITH CONSISTENT SNAPSHOT;")
end

function TRANS.Prototype:Rollback()
    Database.Query("ROLLBACK;")
    self:SetOpen(false)
    self:Dispose()
end

function TRANS.Prototype:Commit()
    Database.Query("COMMIT;")
    self:SetOpen(false)
    self:Dispose()
end

function TRANS.Prototype:Dispose()
    if self:GetOpen() then
        self:Rollback()
        error("Transaction garbage collected without being closed; rolling back. Remember to do trans:Commit()! Initially created: " .. self:GetTrace())
    end
end

function Database.CreateTransaction()
    return Type.New(TRANS)
end


Database.Connect()