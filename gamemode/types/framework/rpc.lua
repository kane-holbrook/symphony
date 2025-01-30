RPC = Type.Register("rpc")
RPC.ByName = {}
RPC.ByHash = weaktable(false, true)
RPC.Requests = weaktable(false, true)

RPC:CreateProperty("Name")
RPC:CreateProperty("Realm")
RPC:CreateProperty("Func")

function RPC.Register(name, realm, func)
    assert(name)
    assert(realm)
    assert(func)
    
    local t = new(RPC)

    t:SetName(name)
    t:SetRealm(realm)
    if realm == Realm.Current then
        t:SetFunc(func)
    end

    RPC.ByName[name] = t
    return t
end

if CLIENT then
    function RPC.Call(name, ...)
        local p = Promise.Create()

        net.Start("RPC", false)
            net.WriteString(p:GetId())
            net.WriteString(name)
            net.WriteObject({...})
        net.SendToServer()

        RPC.Requests[p:GetId()] = p

        return p
    end
end

function RPC.Get(name)
    return RPC.ByName[name]
end

function RPC.Metamethods:__tostring()
    return "RPC[" .. self:GetName() .. "]"
end

RPC.Register("Test.RPC", Realm.Server, function (ply, a, b, asPromise)
    if asPromise then
        return Promise.Run(function ()
            Promise.Sleep(0)
            return "Results", a + b, a * b, a / b, a - b
        end)
    end

    return "Results", a + b, a * b, a / b, a - b
end)

hook.Add("Test.Register", "symphony/rpc.lua", function ()
    Test.Register("RPC", function ()
        local rpc = RPC.Get("Test.RPC")
        Test.Equals(rpc:GetName(), "Test.RPC")
        Test.Equals(rpc:GetRealm(), Realm.Server)
        
        local a, b, c, d, e = RPC.Call("Test.RPC", 8, 8):Await()
        Test.Equals(a, "Results")
        Test.Equals(b, 16)
        Test.Equals(c, 64)
        Test.Equals(d, 1)
        Test.Equals(e, 0)

        
        
        a, b, c, d, e = RPC.Call("Test.RPC", 8, 8, true):Await()
        Test.Equals(a, "Results")
        Test.Equals(b, 16)
        Test.Equals(c, 64)
        Test.Equals(d, 1)
        Test.Equals(e, 0)


    end)
end)

net.Receive("RPC_Result", function (len, ply)
    local id = net.ReadString()
    local result = net.ReadObject()

    local p = RPC.Requests[id]
    assert(p, "Invalid RPC request: " .. id)

    if SERVER and p.Player ~= ply then
       error("RPC sent by " .. tostring(p.Player) .. ", but response came from " .. tostring(ply)) 
    end

    p:Complete(unpack(result))
end)

if SERVER then
    net.Receive("RPC", function (len, ply)
        local id = net.ReadString()
        local name = net.ReadString()
        local data = net.ReadObject()

        local rpc = RPC.Get(name)
        assert(rpc, "Player " .. tostring(ply) .. " sent an invalid RPC (" .. name .. ").")
        
        local result = { rpc:GetFunc()(ply, unpack(data)) }
        if ispromise(result[1]) then
            result[1]:Hook(function (succ, ...)
                if not succ then
                    error(select(2, ...))
                end

                local result = {...}
                net.Start("RPC_Result")
                    net.WriteString(id)
                    net.WriteObject(result)
                net.Send(ply)
            end)
        else
            net.Start("RPC_Result")
                net.WriteString(id)
                net.WriteObject(result)
            net.Send(ply)
        end

    end)
    util.AddNetworkString("RPC")
    util.AddNetworkString("RPC_Result")
end