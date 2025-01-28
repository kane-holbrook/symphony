AddCSLuaFile()

Promise = {}
Promise.All = weaktable(true, false)

local PROMISE = Type.Register("Promise")
do
    PROMISE:CreateProperty("Result")
    PROMISE:CreateProperty("Completed")
    PROMISE:CreateProperty("TTL")
    PROMISE:CreateProperty("Error")

    -- @test sh_tests/Promises
    function PROMISE.Prototype:Initialize()
        base()

        self.Events = Type.New(Type.EventBus)
        self.awaits = {}
        self.coroutines = {}
        self.threads = {}

        self:SetCompleted(false)
        self:SetTTL(30)
        Promise.All[self] = true
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:SetFunc(func)
        self.func = func

        if func then
            self.thread = coroutine.create(func)
        else
            self.thread = nil
        end
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:Hook(...)
        self.Events:Hook("Complete", ...)
    end

    function PROMISE.Prototype:Unhook(...)
        self.Events:Unhook(...)
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:ThrowError(err)
        timer.Remove(self:GetId())
        err = err .. "\n" .. debug.traceback()
        self.Events:Invoke("Error", err)
        self:SetError(err)
        return err
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:Resume(...)
        local cr = self:GetCoroutine()
        assert(coroutine.status(cr) ~= "dead", "Promise is dead")
        
        local LAST_PROMISE = Promise.Current
        Promise.Current = self

        timer.Create(self:GetId(), self:GetTTL(), 0, function() error(tostring(self) .. " exceeded TTL=" .. self:GetTTL()) end)

        local args = { coroutine.resume(cr, ...) }
        local succ = args[1]
        
        if not succ then 
            args[2] = self:ThrowError(args[2]) 
        end
        
        if coroutine.status(cr) == "dead" then 
            self:Complete(unpack(args)) 
        end
     
        Promise.Current = LAST_PROMISE

        return self
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:Await()
        if self:IsComplete() then
            -- Consider delaying this 1 tick so that hooks run first, as this effectively sidesteps?
            return self:GetResult()
        end

        table.insert(self.awaits, Promise.Current)
        return coroutine.yield()
    end    

    -- @test sh_tests/Promises
    function PROMISE.Prototype:Complete(...)
        local args = {...}
        self:SetResult(args)
        timer.Simple(0, function ()
            
            self.Events:Run("Complete", unpack(args))

            for k, v in pairs(self.awaits) do
                v:Resume(unpack(args))
            end

            for k, v in pairs(self.coroutines) do
                coroutine.resume(v, unpack(args))
            end
            
        end)
        self.Completed = true
        
        timer.Remove(self:GetId())

        Promise.All[self] = nil
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:IsComplete()
        return self.Completed
    end

    -- @test sh_tests/Promises
    function PROMISE.Prototype:GetResult()
        return unpack(self.Result)
    end

    function PROMISE.Prototype:GetCoroutine()
        return self.thread
    end

    -- @test sh_tests/Promises
    function PROMISE.Metamethods:__tostring()
        return "Promise[" .. self:GetId() .. "](" .. coroutine.status(self:GetCoroutine()) .. ")"
    end

    PROMISE.Prototype.Start = PROMISE.Prototype.Resume
end

-- @test sh_tests/Promises
function Promise.Create(func, ttl)
    local p = Type.New(PROMISE)
    p:SetFunc(func)
    p:SetTTL(ttl or 30)
    return p
end

-- @test sh_tests/Promises
function Promise.Run(func, ttl)
    assert(func, "Must provide function if using Promise.Run")
    local p = Promise.Create(func, ttl)
    p:Start()
    return p
end

-- @test sh_tests/Promises
function Promise.Sleep(t)
    local cr = Promise.Current
    timer.Simple(t, function ()
        cr:Resume()
    end)
    coroutine.yield()
end

function Promise.GetPromise()
    return Promise.Current
end

function Promise.GetPromises()
    return Promise.All
end

function ispromise(obj)
    return Type.Is(obj, Type.Promise)
end

hook.Add("Test.Register", "Promises", function ()
    Test.Register("Promises", function ()
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
end)