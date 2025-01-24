Test = {}

function Test.Equals(a, b)
    assert(a == b, "Expected: " .. tostring(b) .. ", got: " .. tostring(a))
end

local TEST = Type.Register("UnitTest")
TEST:CreateProperty("Name")
TEST:CreateProperty("Func")

function TEST.Prototype:Init()
    self.Children = {}
end

function TEST.Prototype:GetChildren()
    return self.Children
end

function TEST.Prototype:AddTest(name, func)
    local t = new(TEST)
    t:SetName(name)
    t:SetFunc(func)
    table.insert(self.Children, t)
    return t
end

function TEST.Prototype:Run()
    local f = self:GetFunc()
    local succ, msg
    if f then
        succ = true
        xpcall(f, function (m)
                msg = m .. "\n" .. debug.traceback()
                succ = false
        end) 
    end

    local children = {}
    for k, v in pairs(self:GetChildren()) do
        table.insert(children, { v:Run() })
    end

    return self, succ, msg, children
end


Test.All = new(TEST)
Test.All:SetName("*")

function Test.GetAll()
    return Test.All
end

function Test.Register(...)
    return Test.All:AddTest(...)
end

if CLIENT then
    concommand.Add("sym_test", function (ply, cmd, args)
        --[[if #args == 0 then
            local function recurse(t, l)
                print(string.rep("  ", l) .. "• " .. t:GetName())
                for k, v in pairs(t:GetChildren()) do
                    recurse(v, l + 1)
                end
            end

            print("Available tests:")
            for k, v in pairs(Test.GetAll():GetChildren()) do
                recurse(v, 1)
            end
        end--]]

        local nsucc, nfail = 0, 0
        local _, _, _, result = Test.All:Run()
        
        local function recurse(t, l)
            local test = t[1]
            local succ = t[2]
            local msg = t[3]
            local children = t[4]

            local pfx = string.rep("  ", l)
            if succ == true then
                nsucc = nsucc + 1
                MsgC(pfx, test:GetName(), " -> ", Color(192, 255, 192), msg or "PASS", "\n")
            elseif succ == false then
                nfail = nfail + 1
                MsgC(pfx, test:GetName(), " -> ", Color(255, 192, 192), msg or "FAIL", "\n")
            else
                MsgC(pfx, test:GetName(), ":", msg or "", "\n")
            end
            
            for k, v in pairs(children) do
                recurse(v, l + 1)
            end
        end
        recurse(result[1], 1)

        MsgC("\nResults:\n  ", Color(128, 255, 128), nsucc, Color(192, 255, 192), " PASS", color_white, " | ", Color(255, 128, 128), nfail, Color(255, 192, 192), " FAIL\n")
    end)
end

hook.Run("Sym:RegisterTests")