AddCSLuaFile()

Test = {}
Test.Registry = {}

function Test.Register(name, func, cleanup)
    assert(isstring(name), "Test name must be a string!")
    assert(isfunction(func), "Test func must be a function!")
    assert(not Test.Registry[name], "Test '" .. name .. "' is already registered!")

    table.insert(Test.Registry, {
        Name = name,    
        Func = func,
        Cleanup = cleanup,
    })
end

function Test.GetAll()
    return Test.Registry
end

function Test.Equals(a, b)
    assert(a == b, "Expected: " .. tostring(b) .. ", got: " .. tostring(a) .. "\n\n" .. debug.traceback(), 2)
end

function Test.Run()
    Promise.TTL = 1
    local p = Promise.Run(function ()
        MsgC("Running " .. #Test.Registry .. " tests...\n----------------------\n")
        for k, v in pairs(Test.Registry) do
            MsgC(v.Name .. " ... ")

            local success, err = pcall(v.Func)
            if not success then
                MsgC(Color(255, 0, 0, 255), "FAILED: " .. err .. "\n")
            else
                MsgC(Color(0, 255, 0, 255), "OK\n")
            end

            if v.Cleanup then
                v.Cleanup()
            end
        end

        Promise.TTL = 30
    end)
    return p
end

timer.Simple(0, function ()
    hook.Run("RegisterTests")
end)