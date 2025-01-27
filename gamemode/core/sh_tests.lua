Test = {}

function Test.Equals(a, b)
    assert(a == b, "Expected: " .. tostring(b) .. ", got: " .. tostring(a) .. "\n\n" .. debug.traceback())
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

-- Testing types
do
    local root = Test.Register("Type")
	root:AddTest("Registration", function()
		local t = Type.Register("TestType", nil, { Test = true })
		Test.Equals(t:GetName(), "TestType")
		Test.Equals(t:GetCode(), 3784073340)
		Test.Equals(t:GetSuper(), Type.Type)
		Test.Equals(t:GetOptions()["Test"], true)

		assert(Type.ByName["TestType"] == t, "Type not registered in ByName")
		assert(Type.ByCode[t:GetCode()] == t, "Type not registered in ByCode")
		assert(Type.IsDerived(t, Type.Type), "Type not derived from Type")
		local code = t:GetCode()
		t = nil
		Type.ByName["TestType"] = nil
		collectgarbage("collect")
		assert(not Type.ByCode[code], "Type not __gc'd in ByCode")
	end)

	root:AddTest("Instantiation", function ()
		local t = Type.Register("Life", nil, { TestOption = true })
		t:CreateProperty("CanFly")

		function t.Prototype:Fly()
			return self:GetCanFly() or false
		end

		local t2 = Type.Register("Mammal", t)
		Test.Equals(t2:GetOptions()["TestOption"], true)

		local t3 = Type.Register("Human", t2, { TestOption = 32 })
		function t3.Prototype:PlayGMod()
			return true
		end

		function t3.Metamethods:__tostring()
			return "HUMAN"
		end
		Test.Equals(t3:GetOptions()["TestOption"], 32)

		local t4 = Type.Register("Bird", t)
		function t4.Prototype:Initialize()
			base()
			self:SetCanFly(true)
		end
		Test.Equals(t4:GetOptions()["TestOption"], true)

		local t5 = Type.Register("Rock")
		assert(not t5:GetOptions()["TestOption"])

		local life = new(t)
		local mammal = new(t2)
		local human = new(t3)
		local bird = new(t4)
		local rock = new(t5)

		Test.Equals(life:Fly(), false)
		Test.Equals(mammal:Fly(), false)
		Test.Equals(human:Fly(), false)
		Test.Equals(bird:Fly(), true)
		assert(rock.Fly == nil)

		assert(not life.PlayGMod)
		assert(not mammal.PlayGMod)
		Test.Equals(human:PlayGMod(), true)
		assert(not bird.PlayGMod)
		assert(not rock.PlayGMod)

		Test.Equals(tostring(human), "HUMAN")
		assert(tostring(rock) ~= "HUMAN")
		assert(tostring(mammal) ~= "HUMAN")
		assert(tostring(life) ~= "HUMAN")
		assert(tostring(bird) ~= "HUMAN")

		Type.ByName["Life"] = nil
		Type.ByName["Mammal"] = nil
		Type.ByName["Human"] = nil
		Type.ByName["Bird"] = nil

		-- Check IDs and OBJ functions.
		assert(human:GetId() ~= bird:GetId())
		Test.Equals(human:GetType(), t3)
		Test.Equals(bird:GetType(), t4)
		Test.Equals(human:GetBase(), t2.Prototype)
		Test.Equals(bird:GetBase(), t.Prototype)
		assert(bird:GetProperties().CanFly == true)
	end)

	root:AddTest("Events", function ()
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

	root:AddTest("Proxy", function ()
		local proxy = Proxy(32)
		local valueChanged = false
		Test.Equals(proxy:GetValue(), 32)

		local id = proxy:Hook(function(newValue, oldValue)
			Test.Equals(oldValue, 32)
			Test.Equals(newValue, 42)
			valueChanged = true
		end)

		proxy:SetValue(42)
		Test.Equals(proxy:GetValue(), 42)
		Test.Equals(valueChanged, true)
		Test.Equals(tostring(proxy), "Proxy[42]")

		proxy:Unhook(id)
		
		proxy:SetValue("Hello")
		Test.Equals(tostring(proxy), "Proxy[\"Hello\"]")

		Test.Equals(IsProxy(proxy), true)
	end)

	root:AddTest("Primitives", function ()
		local num = Type.New(Type.Primitives[TYPE_NUMBER])
		num:SetValue(123)
		Test.Equals(num:GetValue(), 123)
		Test.Equals(tostring(num), "Proxy[123]")

		local str = Type.New(Type.Primitives[TYPE_STRING])
		str:SetValue("Hello")
		Test.Equals(str:GetValue(), "Hello")
		Test.Equals(tostring(str), "Proxy[\"Hello\"]")

		local bool = Type.New(Type.Primitives[TYPE_BOOL])
		bool:SetValue(true)
		Test.Equals(bool:GetValue(), true)
		Test.Equals(tostring(bool), "Proxy[true]")

		Test.Equals(IsPrimitive(num), true)
		Test.Equals(IsPrimitive(str), true)
		Test.Equals(IsPrimitive(bool), true)

		local x = FromPrimitive(32)
		Test.Equals(x:GetValue(), 32)
		Test.Equals(x:GetType(), Type.Primitives[TYPE_NUMBER])
	end)

	root:AddTest("Serialization", function ()

		-- Test the primitive types first
		Test.Equals(Type.Deserialize(Type.Serialize(32)), 32)
		Test.Equals(Type.Deserialize(Type.Serialize("Hello")), "Hello")
		Test.Equals(Type.Deserialize(Type.Serialize(true)), true)

		-- Now test a basic table
		local r = Type.Deserialize(Type.Serialize({
			Hello = "World",
			Number = 32,
			Bool = true,
			Table = {
				Hello = "World",
				Table2 = {
					A = 32
				}
			}
		}))
		Test.Equals(r.Hello, "World")
		Test.Equals(r.Number, 32)
		Test.Equals(r.Bool, true)
		Test.Equals(r.Table.Hello, "World")
		Test.Equals(r.Table.Table2.A, 32)

		local t = Type.Register("TestType")
		t:CreateProperty("Value")
		t:CreateProperty("Child")

		local i = new(t)
		i:SetValue(32)

		local i2 = new(t)
		i2:SetValue(40)
		i2:SetChild(i)
		r = Type.Deserialize(util.JSONToTable(util.TableToJSON(Type.Serialize(i2))))

		
		Test.Equals(r:GetType(), t)
		Test.Equals(r:GetChild():GetType(), t)

		Test.Equals(r:GetChild():GetValue(), 32)
		Test.Equals(r:GetValue(), 40)
		Test.Equals(r:GetId(), i2:GetId())

		Type.ByName["TestType"] = nil
		Type.ByCode[t:GetCode()] = nil
	end)

    root:AddTest("Promises", function ()
        local p
        local p2 
		local succ, a, b, c
		local hookSucc
		local startPromiseNum = table.Count(Promise.GetPromises())
		
		-- Asynchronous - happy path
        p = Promise.Create(function ()
            Promise.Sleep(0) -- Sleep for 1 tick   
			Test.Equals(tostring(p), "Promise[" .. p:GetId() .. "](running)")
            return 32, 64, 128
        end)

		Test.Equals(ispromise(p), true)
		Test.Equals(ispromise(root), false)
		Test.Equals(ispromise(32), false)
		assert(Promise.GetPromises()[p])
		Test.Equals(tostring(p), "Promise[" .. p:GetId() .. "](suspended)")

        p2 = Promise.Create(function ()
            p:Start()
            local succ, a, b, c = p:Await()
			Test.Equals(succ, true)
			Test.Equals(Promise.Current, p2)

			return a, b, c
        end)

		hookSucc = false
		p2:Hook(function(succ, a, b, c)
			Test.Equals(succ, true)
			Test.Equals(a, 32)
			Test.Equals(b, 64)
			Test.Equals(c, 128)
			hookSucc = true
		end)
		
		p2:Start()
		succ, a, b, c = p2:Await()
		Test.Equals(hookSucc, true)
		Test.Equals(p2:IsComplete(), true)
		Test.Equals(p2:GetError(), nil)
		Test.Equals(tostring(p), "Promise[" .. p:GetId() .. "](dead)")
		
		Test.Equals(succ, true)
		Test.Equals(a, 32)
		Test.Equals(b, 64)
		Test.Equals(c, 128)

		
		-- Asynchronous - error path
		p = Promise.Create(function()
			Promise.Sleep(0) -- Sleep for 1 tick   
			error("Test error")
			return 32, 64, 128
		end)

		p2 = Promise.Create(function()
			p:Start()
			local succ, a, b, c = p:Await()
			Test.Equals(succ, false)
			error(a)
			return a, b, c
		end)

		p2:Start()
		succ, a, b, c = p2:Await()
		Test.Equals(succ, false)

		-- Synchronous - happy path
        p = Promise.Create(function ()
            return 32, 64, 128
        end)

        p2 = Promise.Create(function ()
            p:Start()
            local succ, a, b, c = p:Await()
			Test.Equals(succ, true)

			return a, b, c
        end)
		
		p2:Start()
		succ, a, b, c = p2:Await()
		
		Test.Equals(succ, true)
		Test.Equals(a, 32)
		Test.Equals(b, 64)
		Test.Equals(c, 128)
		
		-- Synchronous - error path
		p = Promise.Create(function()
			error("Test error")
			return 32, 64, 128
		end)

		p2 = Promise.Create(function()
			p:Start()
			local succ, a, b, c = p:Await()
			Test.Equals(succ, false)
			error(a)
			return a, b, c
		end)

		p2:Start()
		succ, a, b, c = p2:Await()
		Test.Equals(succ, false)


		p = nil
		p2 = nil

		-- Test GC.
		collectgarbage("collect")
		assert(table.Count(Promise.GetPromises()) == startPromiseNum, "Promises not cleaned up")
    end)
end
