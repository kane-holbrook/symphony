RPC = Type.Register("rpc")
RPC.ByName = {}
RPC.ByHash = weaktable(false, true)

RPC:CreateProperty("Name")
RPC:CreateProperty("Realm")
RPC:CreateProperty("Hash")
RPC:CreateProperty("Func")

function RPC.Register(name, realm, func)
    assert(name)
    assert(realm)
    assert(func)
    
    local t = new(RPC)
    local hash = util.CRC(name)

    t:SetName(name)
    t:SetRealm(realm)
    t:SetHash(hash)

    if realm == Realm then
        t:SetFunc(func)
    end

    RPC.ByName[name] = t
    RPC.ByHash[hash] = t
    return t
end

function RPC.Get(name)
    return RPC.ByName[name]
end

function RPC.Metamethods:__tostring()
    return "RPC[" .. self:GetName() .. "]"
end

function RPC.Metamethods:__call(...)
    local p = Promise.Create()
    return p
end


local RpcLibrary = {}
function RpcLibrary:__newindex(k, v)
    if istable(v) then
        assert(not getmetatable(v), "Tables added to RPC libraries must not have a metatable.")
        setmetatable(v, MT)
    else
        assert(isfunction(v), "RPC libraries must contain only functions or tables.")
        rawset(self, k, v)
    end
end

Server = {}

Server.Tests = {}
Server.Tests.RPC = {}
Server.Tests.RPC.





hook.Add("Test.Register", "symphony/rpc.lua", function ()
    Test.Register("RPC", function ()
        local r = RPC.Get("Test.Add")
        Test.Equals(r:GetName(), "Test.Add")
        Test.Equals(r:GetRealm(), Realm.Shared)
        Test.Equals(r:GetHash(), "2531216495")
        
        local r = r(32, 32)

    end)
end)