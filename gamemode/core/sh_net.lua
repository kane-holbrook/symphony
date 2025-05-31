AddCSLuaFile()

--[[
require("lanes")

-- Create two independent lindas
main_to_worker = lanes.linda()
worker_to_main = lanes.linda()

-- Worker lane
local worker = lanes.gen("*", {
    globals = {
        in_linda = main_to_worker,
        out_linda = worker_to_main
    }
}, function()
    while true do
        local _, msg = in_linda:receive(nil, "work")
        if msg == "stop" then
            out_linda:send("log", "Worker stopping.")
            break
        end

        local result = msg * 2
        out_linda:send("result", result)
    end
end)

-- Start worker lane
worker()

-- Send a task
main_to_worker:send("work", 21)

-- Poll result
hook.Add("Think", "PollWorkerResult", function()
    local _, result = worker_to_main:receive(0, "result")
    if result then
        print("Got result from lane:", result)

        -- Tell the lane to stop
        main_to_worker:send("work", "stop")
    end

    local _, log = worker_to_main:receive(0, "log")
    if log then
        print("Log:", log)
        hook.Remove("Think", "PollWorkerResult")
    end
end)
--]]