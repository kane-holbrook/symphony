include("shared.lua")


--[[sym.http.Start()

sym.http.Hook("/", function (ply, req, resp, path)
    resp.Headers = resp.Headers or {}
    resp.Headers["Location"] = "https://sstrp.net"
    resp.StatusCode = 301
    return true
end)

sym.http.Hook("ping", function (ply, req, resp, path)
    return "Pong"
end)--]]

--sym.db.Connect()

sym.log("FRAMEWORK", "Framework finished loading in " .. math.Round((SysTime() - SYM_START_TIME) * 1000, 2) .. "ms.")