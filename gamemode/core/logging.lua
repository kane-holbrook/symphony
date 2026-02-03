AddCSLuaFile()

local cvar = CreateConVar("sym_log", "3", FCVAR_ARCHIVE) 

Log = {}
Log.Table = "sym_logs"

LOG_ERROR = 1
LOG_WARN = 2
LOG_INFO = 3
LOG_DEBUG = 4

Log.Enum = {
    [LOG_ERROR] = "ERROR",
    [LOG_WARN] = "WARNING",
    [LOG_INFO] = "INFO",
    [LOG_DEBUG] = "DEBUG",
}


local gray = Color(192, 192, 192, 255)
local white = Color(255, 255, 255, 255)
local logcolors = {
    [LOG_ERROR] = { Color(255, 64, 64, 255), Color(255, 192, 192, 255) },
    [LOG_WARN] = { Color(255, 128, 0, 255), Color(255, 224, 192, 255) },
    [LOG_INFO] = { Color(225, 128, 193), Color(255, 192, 255, 255) },
    [LOG_DEBUG] = { Color(192, 192, 192, 255), Color(225, 225, 225, 255) },
}

function Log.Write(granularity, type, message, data)

    assert(isnumber(granularity), "Log granularity must be a number!")
    assert(isstring(type), "Log type must be a string!")
    assert(isstring(message), "Log message must be a string!")

    if data then
        if istable(data) then
            data = util.TableToJSON(data)
        else
            data = tostring(data)
        end
    end

    local time = os.time()
    local results = sql.QueryTyped("INSERT INTO " .. Log.Table .. " (server, session, datetime, granularity, type, message, data) VALUES (?, ?, ?, ?, ?, ?, ?);", game.GetIPAddress(), Log.Session, time, granularity, type, message, data)
    if not results then
        error("Failed to write log entry: " .. sql.LastError())
    end

    if cvar:GetInt() >= granularity then
        local logcolor = logcolors[granularity]
        MsgC(gray, os.date("%H:%M:%S", time), "|", logcolor[1], Log.Enum[granularity], gray, "|", logcolor[2], message, "\n")
    end

    return results
end



-- Set up the table
sql.Query([[
    CREATE TABLE IF NOT EXISTS ]] .. Log.Table .. [[ (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session INTEGER,
    server TEXT NOT NULL,
    datetime TEXT NOT NULL DEFAULT (datetime('now')),
    granularity INTEGER,
    type TEXT,
    message TEXT,
    data TEXT
);]])

-- Fetch the most recent session
local t = sql.Query("SELECT MAX(session) AS max FROM " .. Log.Table .. ";")
assert(t and t[1] and t[1].max, "Failed to fetch most recent log session: " .. tostring(sql.LastError()))
Log.Session = isnumber(t[1].max) and tonumber(t[1].max) + 1 or 1