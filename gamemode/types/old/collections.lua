AddCSLuaFile()

--
-- SET 
--
do
	local Set = sym.RegisterType("hashset")

	function Set:Init(out, data)
		out.items = {}
		for k, v in pairs(data) do
			out:Add(v)
		end
		return out
	end

	function Set:Add(value)
		self.items[value] = true
	end

	function Set:Has(value)
		return self.items[value] == true
	end

	function Set:Remove(value)
		self.items[value] = false
	end

	function sym.hashset(...)
		local args = {...}
		if #args == 1 and istable(args[1]) then
			args = args[1]
		end

		local out = Set(args)
		return out
	end
end

--
-- CIRCULAR BUFFER
--
do
	-- Define the circular buffer class
	local CircularBuffer = sym.RegisterType("circularbuffer")

	function CircularBuffer:add(data)
		self.buffer[self.index] = data
		self.index = (self.index % self.size) + 1
	end

	function CircularBuffer:get(offset)
		local index = self.index - 1 - offset

		if index < 1 then
			index = index + self.size
		end

		return self.buffer[index]
	end

	function CircularBuffer:clear()
		self.buffer = {}
		self.index = 1
	end

	function CircularBuffer:setSize(sz)
		self.size = sz
	end

	local ReverseCircularBuffer = sym.RegisterType("reversecircularbuffer")

	function ReverseCircularBuffer:add(data)
		self.buffer[self.index] = data
		self.index = (self.index - 2) % self.size + 1
	end

	function ReverseCircularBuffer:get(offset)
		local index = self.index + offset

		if index > self.size then
			index = index - self.size
		end

		return self.buffer[index]
	end

	function ReverseCircularBuffer:clear()
		self.buffer = {}
		self.index = 1
	end

	function ReverseCircularBuffer:setSize(sz)
		self.size = sz
	end

	function sym.circularbuffer(size)
		local buffer = CircularBuffer()
		buffer.size = size or 10
		buffer.buffer = {}
		buffer.index = 1

		return buffer
	end

	function sym.rcircularbuffer(size)
		local buffer = ReverseCircularBuffer()
		buffer.size = size or 10
		buffer.buffer = {}
		buffer.index = 1

		return buffer
	end
end

--
-- DEQUEUE
--
do
	-- Define the deque class
	local Deque = {}
	Deque.__index = Deque

	function Deque:pushFront(value)
		self.front = self.front - 1
		self.data[self.front] = value
	end

	function Deque:pushBack(value)
		self.back = self.back + 1
		self.data[self.back] = value
	end

	function Deque:popFront()
		if self:isEmpty() then return nil end
		local value = self.data[self.front]
		self.data[self.front] = nil
		self.front = self.front + 1

		return value
	end

	function Deque:popBack()
		if self:isEmpty() then return nil end
		local value = self.data[self.back]
		self.data[self.back] = nil
		self.back = self.back - 1

		return value
	end

	function Deque:getFront()
		if self:isEmpty() then return nil end

		return self.data[self.front]
	end

	function Deque:getBack()
		if self:isEmpty() then return nil end

		return self.data[self.back]
	end

	function Deque:isEmpty()
		return self.front > self.back
	end

	function sym.deque()
		local deque = setmetatable({}, Deque)
		deque.front = 0
		deque.back = -1
		deque.data = {}

		return deque
	end
end

--
-- MULTIMAP
--
do
	-- Define the multimap class
	local Multimap = sym.RegisterType("multimap")

	function Multimap:Add(key, value)
		if not self.data[key] then
			self.data[key] = {}
		end

		table.insert(self.data[key], value)
	end

	function Multimap:Remove(key, value)
		if self.data[key] then
			for i, v in ipairs(self.data[key]) do
				if v == value then
					table.remove(self.data[key], i)
					break
				end
			end
		end
	end

	function Multimap:Get(key)
		return self.data[key] or {}
	end

	function Multimap:GetAll()
		return self.data
	end

	function Multimap:Contains(key, value)
		local t = self:get(key)

		return table.HasValue(t, value)
	end

	function sym.multimap()
		local multimap = Multimap()
		multimap.data = {}

		return multimap
	end
end

--
-- QUEUE
--
do
	-- Define the queue class
	local Queue = sym.RegisterType("queue")

	function Queue:enqueue(value)
		self.back = self.back + 1
		self.data[self.back] = value
	end

	function Queue:dequeue()
		if self:isEmpty() then return nil end
		local value = self.data[self.front]
		self.data[self.front] = nil
		self.front = self.front + 1

		return value
	end

	function Queue:getFront()
		if self:isEmpty() then return nil end

		return self.data[self.front]
	end

	function Queue:isEmpty()
		return self.front > self.back
	end

	function Queue:count()
		return self.back - self.front + 1
	end

	function sym.queue()
		local queue = Queue()
		queue.front = 1
		queue.back = 0
		queue.data = {}

		return queue
	end
end

--
-- PRIORITY QUEUE
--
do
	-- Define the priority queue class
	local PriorityQueue = sym.RegisterType("priorityqueue")

	function PriorityQueue:enqueue(value, priority)
		local element = {
			value = value,
			priority = priority
		}

		table.insert(self.data, element)
		
		if istable(value) then
			value[self] = element
		end

		self:heapifyUp()
	end

	function PriorityQueue:dequeue()
		local top = self.data[1]
		local last = table.remove(self.data)

		if #self.data > 0 then
			self.data[1] = last
			self:heapifyDown()
		end

		return top and top.value
	end

	function PriorityQueue:isEmpty()
		return #self.data == 0
	end

	function PriorityQueue:heapifyUp(index)
		index = index or #self.data
		local parentIndex = math.floor(index / 2)

		while parentIndex > 0 and self.data[index].priority < self.data[parentIndex].priority do
			self.data[index], self.data[parentIndex] = self.data[parentIndex], self.data[index]
			index = parentIndex
			parentIndex = math.floor(index / 2)
		end
	end

	function PriorityQueue:heapifyDown(index)
		index = index or 1
		local leftChildIndex = index * 2
		local rightChildIndex = leftChildIndex + 1

		while leftChildIndex <= #self.data do
			local minIndex = index

			if self.data[leftChildIndex].priority < self.data[minIndex].priority then
				minIndex = leftChildIndex
			end

			if rightChildIndex <= #self.data and self.data[rightChildIndex].priority < self.data[minIndex].priority then
				minIndex = rightChildIndex
			end

			if minIndex == index then break end
			self.data[index], self.data[minIndex] = self.data[minIndex], self.data[index]
			index = minIndex
			leftChildIndex = index * 2
			rightChildIndex = leftChildIndex + 1
		end
	end

	function PriorityQueue:requeue(value, newPriority)
		for i, element in ipairs(self.data) do
			if element.value == value then
				element.priority = newPriority
				self:heapifyUp(i)
				self:heapifyDown(i)

				return true
			end
		end

		return false
	end

	function sym.PriorityQueue()
		local prioQueue = PriorityQueue()
		prioQueue.data = {}

		return prioQueue
	end
end

--
-- LINKEDLIST
--
do
	-- Define the queue class
	local LinkedListNode = {nil, nil, nil}

	LinkedListNode.__index = LinkedListNode

	function LinkedListNode:__call()
		return self[2]
	end

	function LinkedListNode:prev()
		return self[1]
	end

	function LinkedListNode:next()
		return self[3]
	end

	local LinkedList = sym.RegisterType("linkedlist")

	function LinkedList:insert(item)
		local t = setmetatable({nil, item, nil}, LinkedListNode)

		if self.last then
			self.last[3] = t
			t[1] = self.last
			self.last = t
		else
			self.first = t
			self.last = t
		end

		self.items = self.items + 1
		self.cache = nil

		if istable(item) then
			item[self] = t
		end

		return t
	end

	function LinkedList:insertAfter(target, item)
		target = target[self]
		if not target then return self:insert(item) end

		local t = setmetatable({target, item, nil}, LinkedListNode)

		local next = target:next()

		if next then
			next[1] = t
			t[3] = next
		else
			self.last = t
		end

		target[3] = t
		self.items = self.items + 1
		self.cache = nil

		if istable(t) then
			item[self] = t
		end

		return t
	end

	function LinkedList:insertBefore(target, item)
		target = target[self]
		if not target then return self:insert(item) end

		local t = setmetatable({nil, item, target}, LinkedListNode)

		local prev = target:prev()

		if prev then
			prev[3] = t
			t[1] = prev
		else
			self.first = t
		end

		target[1] = t
		self.items = self.items + 1
		self.cache = nil

		if istable(item) then
			item[self] = t
		end

		return t
	end

	function LinkedList:toTable()
		if self.cache then return self.cache end
		if self.first == nil then return nil end
		local idx = 1
		local out = {}
		local t = self.first

		while t do
			out[idx] = t
			t = t:next()
			idx = idx + 1
		end

		self.cache = out

		return out
	end

	function LinkedList:remove(value)
		item = value[self]

		local prev = item:prev()
		local next = item:next()

		if prev then
			prev[3] = next
		else
			self.first = next
		end

		if next then
			next[1] = prev
		else
			self.last = prev
		end

		self.cache = nil
		self.items = self.items - 1

		if istable(value) then
			value[self] = nil
		end
	end

	function LinkedList:iterator()
		local i = 0
		local next = self.first

		return function()
			if not next then return end
			local v = next()
			next = next:next()
			i = i + 1

			return i, v
		end
	end

	function sym.linkedlist(t)
		local linkedList = LinkedList()
		linkedList.first = nil
		linkedList.last = nil
		linkedList.items = 0

		if t then
			for k, v in pairs(t) do
				linkedList:insert(v)
			end
		end

		return linkedList
	end
end
