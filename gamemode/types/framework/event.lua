local EVENTRESULT = Type.Register("EventResult")
EVENTRESULT:CreateProperty("Cancelled")
EVENTRESULT:CreateProperty("Result")
EVENTRESULT:CreateProperty("Data")
EVENTRESULT:CreateProperty("Name")
local EVENTBUS = Type.Register("EventBus")
function EVENTBUS.Prototype:Initialize()
    base()
end

function EVENTBUS.Prototype:Hook(name, func, id, priority)
    assert(name, "Must provide a name.")
    local h = self[name]
    if not h then
        h = setmetatable({}, {
            n = 0
        })

        self[name] = h
    end

    -- If we already exist, just update ourselves
    local t = h[id]
    local mt = getmetatable(h)
    if t then
        t.Func = func
        if priority ~= t.Priority then
            t.Priority = priority
            mt.Cache = nil
        end
        return true
    end

    -- Otherwise create a new item
    id = id or uuid()
    mt.n = mt.n + 1
    local t = {
        Id = id,
        Func = func,
        Priority = priority or mt.n
    }

    mt.Cache = nil
    h[id] = t
    return id
end

function EVENTBUS.Prototype:Unhook(name, id)
    local h = self[name]
    if h then
        h[id] = nil
        local mt = getmetatable(h)
        mt.n = mt.n - 1
        mt.Cache = nil
    end
end

function EVENTBUS.Prototype:Run(name, ...)
    local h = self[name]
    if not h then return end
    local mt = getmetatable(h)
    if not mt.Cache then
        mt.Cache = table.ClearKeys(h)
        table.SortByMember(mt.Cache, "Priority", true)
    end

    local er = Type.New(EVENTRESULT)
    er:SetName(name)
    er:SetData({...})
    Event = er
    for k, v in pairs(mt.Cache) do
        v.Func(...)
    end

    Event = nil
    return er
end