Test = {}

function Test.Equals(a, b)
    Test.Assert(a == b, "Expected: " .. tostring(b) .. ", got: " .. tostring(a) .. "\n\n" .. debug.traceback(), 2)
end

function Test.Assert(cond, msg, level)
	level = level or 1
	if not cond then
		error(msg or "Assertion failed", level + 1)
	end
end

local TEST = Type.Register("UnitTest")
TEST:CreateProperty("Name")
TEST:CreateProperty("Func")

function TEST.Prototype:Initialize()
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

function TEST.Prototype:Run(l)
	l = l or 0
	return Promise.Run(function ()
		local f = self:GetFunc()
		local pass, fail = 0, 0

		MsgC(string.rep("  ", l), self:GetName())
		if f then
			MsgC(" -> ")
			local succ, msg = pcall(f)
			if succ then
				MsgC(Color(192, 255, 192), "PASS\n")
				pass = pass + 1
			else
				MsgC(Color(255, 192, 192), "FAIL: ", msg, "\n")
				succ = succ + 1
			end
		else
			MsgC(":\n")
		end

		for k, v in pairs(self:GetChildren()) do
			local succ, cpass, cfail = v:Run(l+1):Await()
			if succ then
				pass = pass + cpass
				fail = fail + cfail
			else
				fail = fail + 1
			end
		end

		return pass, fail
	end)
end


Test.All = new(TEST)
Test.All:SetName("Tests")

function Test.GetAll()
    return Test.All
end

function Test.Register(...)
    return Test.All:AddTest(...)
end

function Test.Get(name)
    for k, v in pairs(Test.All:GetChildren()) do
        if v:GetName() == name then
            return v
        end
    end
end

if CLIENT then
    concommand.Add("sym_test", function (ply, cmd, args)
		Promise.Run(function ()
			local succ, nsucc, nfail = Test.All:Run():Await()
			if succ then
				MsgC("\nResults:\n  ", Color(128, 255, 128), nsucc, Color(192, 255, 192), " PASS", color_white, " | ", Color(255, 128, 128), nfail, Color(255, 192, 192), " FAIL\n")
			else
				MsgC("\nResults:\n  ", Color(128, 255, 128), 0, Color(192, 255, 192), " PASS", color_white, " | ", Color(255, 128, 128), 1, Color(255, 192, 192), " FAIL\n")
			end
		end)
    end)
end

hook.Run("Test.Register")
