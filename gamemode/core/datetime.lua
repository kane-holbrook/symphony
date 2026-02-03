AddCSLuaFile()


local TimeSpan = Type.Register("TimeSpan")
TimeSpan:CreateProperty("Seconds", Type.Number)

function TimeSpan.Prototype:Initialize()
    self:SetSeconds(0)
end

function TimeSpan.Prototype:GetMinutes()
    return self:GetSeconds() / 60
end

function TimeSpan.Prototype:GetHours()
    return self:GetSeconds() / 3600
end

function TimeSpan.Prototype:GetDays()
    return self:GetSeconds() / 86400
end

function TimeSpan.Prototype:GetYears()
    return self:GetSeconds() / 31536000
end


function TimeSpan.Metamethods:__tostring()
    local total = self:GetSeconds()
    local days = math.floor(total / 86400)
    total = total - (days * 86400)
    local hours = math.floor(total / 3600)
    total = total - (hours * 3600)
    local minutes = math.floor(total / 60)
    local seconds = total - (minutes * 60)
    return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
end

local DT = Type.Register("DateTime", nil, { DatabaseType = "BIGINT" })
DT:CreateProperty("UnixTime", Type.Number)

function DT.Prototype:Initialize()
    self:SetUnixTime(os.time())
end

function DT.Metamethods:__tostring()
    return os.date("%Y-%m-%dT%H:%M:%S", self:GetUnixTime())
end

function DT.Prototype:GetYear()
    return tonumber(os.date("%Y", self:GetUnixTime()))
end

function DT.Prototype:GetMonth()
    return tonumber(os.date("%m", self:GetUnixTime()))
end

function DT.Prototype:GetDay()
    return tonumber(os.date("%d", self:GetUnixTime()))
end

function DT.Prototype:GetHour()
    return tonumber(os.date("%H", self:GetUnixTime()))
end

function DT.Prototype:GetMinute()
    return tonumber(os.date("%M", self:GetUnixTime()))
end

function DT.Prototype:GetSecond()
    return tonumber(os.date("%S", self:GetUnixTime()))
end

function DT.Metamethods:__eq(other)
    return self:GetUnixTime() == other:GetUnixTime()
end

function DT.Metamethods:__lt(other)
    return self:GetUnixTime() < other:GetUnixTime()
end

function DT.Metamethods:__le(other)
    return self:GetUnixTime() <= other:GetUnixTime()
end

function DT.Metamethods:__add(other)
    if Type.Is(other, TimeSpan) then
        return DateTime(self:GetUnixTime() + other:GetSeconds())
    end
end

function DT.Metamethods:__sub(other)
    if Type.Is(other, DT) then
        local ts = Type.New(TimeSpan)
        ts:SetSeconds(self:GetUnixTime() - other:GetUnixTime())
        return ts
    elseif Type.Is(other, TimeSpan) then
        return DateTime(self:GetUnixTime() - other:GetSeconds())
    end
end

function DT.Prototype:AddSeconds(s)
    return DateTime(self:GetUnixTime() + s)
end

function DT.Prototype:AddMinutes(m)
    return self:AddSeconds(m * 60)
end

function DT.Prototype:AddHours(h)
    return self:AddSeconds(h * 3600)
end

function DT.Prototype:AddDays(d)
    return self:AddSeconds(d * 86400)
end

function DT:Encode(obj)
    return tonumber(obj:GetUnixTime())
end

function DT:Decode(value)
    return DateTime(tonumber(value))
end



function DateTime(unix)
    local dt = DT:New()
    if isnumber(unix) then
        dt:SetUnixTime(unix)
    elseif isstring(unix) then
        local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"
        local year, month, day, hour, min, sec = string.match(unix, pattern)
        dt:SetUnixTime(os.time({
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day),
            hour = tonumber(hour),
            min = tonumber(min),
            sec = tonumber(sec)
        }))
    end
    return dt
end