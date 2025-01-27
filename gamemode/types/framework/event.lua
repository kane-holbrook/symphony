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

hook.Add("Test.Register", "EventBus", function()
    Test.Register("Events", function ()
        local ev = Type.New(Type.EventBus)
        
        local r = false
        local id = ev:Hook("Event", function (a)
            Test.Equals(a, 32)
            Test.Equals(Event:GetName(), "Event")
            Test.Equals(Event:GetCancelled(), nil)
            Test.Equals(Event:GetData()[1], 32)
            Test.Equals(Event:GetResult(), nil)
            r = true
            Event:SetResult(true)
        end)
        Test.Equals(getmetatable(ev["Event"]).n, 1) -- n/w

        local er = ev:Run("Event", 32)
        Test.Equals(r, true)
        Test.Equals(er:GetCancelled(), nil)
        Test.Equals(er:GetResult(), true)
        assert(getmetatable(ev["Event"]).Cache, "Cache not generated")

        ev:Hook("Event", function(a)
            Event:SetCancelled(true)
        end, id)		
        Test.Equals(getmetatable(ev["Event"]).n, 1)

        er = ev:Run("Event", 32)
        Test.Equals(er:GetCancelled(), true)

        r = false
        ev:Hook("Event", function(a)
            r = true
        end, id)		
        ev:Unhook("Event", id)
        Test.Equals(getmetatable(ev["Event"]).n, 0)
        assert(not getmetatable(ev["Event"]).Cache, "Cache still exists")

        er = ev:Run("Event", 32)
        Test.Equals(er:GetCancelled(), nil)
        Test.Equals(r, false)


        -- Priorities
        ev:Hook("Event", function (a)
            Test.Equals(Event:GetCancelled(), true)
            r = true
        end)

        ev:Hook("Event", function ()
            Test.Equals(Event:GetCancelled(), nil)
            Event:SetCancelled(true)			
            -- This should run first
        end, nil, -1)

        er = ev:Run("Event", 32)
        Test.Equals(er:GetCancelled(), true)
        Test.Equals(r, true)
    end)
end)