local STACK = Type.Register("Stack")
function STACK.Prototype:Push(element)
    table.insert(self, element)
end

function STACK.Prototype:Pop()
    return table.remove(self)
end

local QUEUE = Type.Register("Queue")
function QUEUE.Prototype:Enqueue(element)
    table.insert(self, element)
end

function QUEUE.Prototype:Dequeue()
    return table.remove(self, 1)
end

local DEQUEUE = Type.Register("Dequeue")
function DEQUEUE.Prototype:EnqueueFront(element)
    table.insert(self, 1, element)
end

function DEQUEUE.Prototype:DequeueFront()
    return table.remove(self, 1)
end

function DEQUEUE.Prototype:EnqueueBack(element)
    table.insert(self, element)
end

function DEQUEUE.Prototype:DequeueBack()
    return table.remove(self)
end

local SET = Type.Register("Set")
function SET.Prototype:Add(element)
    self[element] = true
end

function SET.Prototype:Remove(element)
    self[element] = nil
end

function SET.Prototype:Contains(element)
    return self[element] ~= nil
end

function SET.Prototype:Clear()
    for k, v in pairs(self) do
        self[k] = nil
    end
end

local MULTIMAP = Type.Register("Multimap")
function MULTIMAP.Prototype:Add(key, value)
    self[key] = self[key] or {}
    table.insert(self[key], value)
end

function MULTIMAP.Prototype:Remove(key, value)
    if not self[key] then
        return
    end

    for k, v in pairs(self[key]) do
        if v == value then
            table.remove(self[key], k)
            return
        end
    end
end

function MULTIMAP.Prototype:Contains(key, value)
    if not self[key] then
        return false
    end

    for k, v in pairs(self[key]) do
        if v == value then
            return true
        end
    end

    return false
end

function MULTIMAP.Prototype:Clear()
    for k, v in pairs(self) do
        self[k] = nil
    end
end

local CIRCULARBUFFER = Type.Register("CircularBuffer")
function CIRCULARBUFFER.Prototype:Push(element)
    self[self.Head] = element
    self.Head = self.Head + 1
    if self.Head > self.Size then
        self.Head = 1
    end
end

function CIRCULARBUFFER.Prototype:Pop()
    local element = self[self.Tail]
    self[self.Tail] = nil
    self.Tail = self.Tail + 1
    if self.Tail > self.Size then
        self.Tail = 1
    end
    return element
end

function CIRCULARBUFFER.Prototype:Clear()
    for i = 1, self.Size do
        self[i] = nil
    end
end

local BINARYTREE = Type.Register("BinaryTree")
function BINARYTREE.Prototype:Insert(value)
    if not self.Root then
        self.Root = { Value = value }
        return
    end

    local current = self.Root
    while true do
        if value < current.Value then
            if not current.Left then
                current.Left = { Value = value }
                return
            end
            current = current.Left
        else
            if not current.Right then
                current.Right = { Value = value }
                return
            end
            current = current.Right
        end
    end
end

function BINARYTREE.Prototype:Contains(value)
    local current = self.Root
    while current do
        if value == current.Value then
            return true
        end
        if value < current.Value then
            current = current.Left
        else
            current = current.Right
        end
    end
    return false
end

function BINARYTREE.Prototype:Remove(value)
    local parent = nil
    local current = self.Root
    while current do
        if value == current.Value then
            if not current.Left and not current.Right then
                if parent then
                    if parent.Left == current then
                        parent.Left = nil
                    else
                        parent.Right = nil
                    end
                else
                    self.Root = nil
                end
            elseif not current.Left then
                if parent then
                    if parent.Left == current then
                        parent.Left = current.Right
                    else
                        parent.Right = current.Right
                    end
                else
                    self.Root = current.Right
                end
            elseif not current.Right then
                if parent then
                    if parent.Left == current then
                        parent.Left = current.Left
                    else
                        parent.Right = current.Left
                    end
                else
                    self.Root = current.Left
                end
            else
                local replacement = current.Right
                while replacement.Left do
                    replacement = replacement.Left
                end
                current.Value = replacement.Value
                current = replacement
            end
            return
        end
        parent = current
        if value < current.Value then
            current = current.Left
        else
            current = current.Right
        end
    end
end

function BINARYTREE.Prototype:Clear()
    self.Root = nil
end


local PRIORITYQUEUE = Type.Register("PriorityQueue")

function PRIORITYQUEUE.Prototype:Insert(value, priority)
    table.insert(self, { Value = value, Priority = priority })
    local i = #self
    while i > 1 do
        local parent = math.floor(i / 2)
        if self[i].Priority < self[parent].Priority then
            self[i], self[parent] = self[parent], self[i]
            i = parent
        else
            break
        end
    end
end

function PRIORITYQUEUE.Prototype:Remove(value)
    for i = 1, #self do
        if self[i].Value == value then
            table.remove(self, i)
            break
        end
    end
    self:Heapify()
end

function PRIORITYQUEUE.Prototype:Heapify()
    local i = 1
    while i <= #self do
        local left = i * 2
        local right = i * 2 + 1
        local smallest = i
        if left <= #self and self[left].Priority < self[smallest].Priority then
            smallest = left
        end
        if right <= #self and self[right].Priority < self[smallest].Priority then
            smallest = right
        end
        if smallest == i then
            break
        end
        self[i], self[smallest] = self[smallest], self[i]
        i = smallest
    end
end

function PRIORITYQUEUE.Prototype:Clear()
    for k, v in pairs(self) do
        self[k] = nil
    end
end

local OCTTREE = Type.Register("OctTree")

function OCTTREE.Prototype:Initialize()
    self.Root = { X = 0, Y = 0, Z = 0 }
    self.Children = {}
end

function OCTTREE.Prototype:Insert(value, x, y, z)
    local node = self.Root
    while true do
        if not node.Children then
            node.Children = {}
            for i = 1, 8 do
                node.Children[i] = { Value = nil }
            end
        end

        local index = 1
        if x > node.X then
            index = index + 1
        end
        if y > node.Y then
            index = index + 2
        end
        if z > node.Z then
            index = index + 4
        end

        if not node.Children[index].Value then
            node.Children[index].Value = value
            return
        end

        node = node.Children[index]
    end
end

function OCTTREE.Prototype:Contains(value, x, y, z)
    local node = self.Root
    while node do
        if node.Value == value then
            return true
        end

        local index = 1
        if x > node.X then
            index = index + 1
        end
        if y > node.Y then
            index = index + 2
        end
        if z > node.Z then
            index = index + 4
        end

        node = node.Children[index]
    end
    return false
end

function OCTTREE.Prototype:Remove(value, x, y, z)
    local node = self.Root
    local parent = nil
    local index = nil
    while node do
        if node.Value == value then
            node.Value = nil
            if parent then
                parent.Children[index] = nil
            end
            return
        end

        index = 1
        if x > node.X then
            index = index + 1
        end
        if y > node.Y then
            index = index + 2
        end
        if z > node.Z then
            index = index + 4
        end

        parent = node
        node = node.Children[index]
    end
end

function OCTTREE.Prototype:Clear()
    self.Root = { Value = nil }
end

function OCTTREE.Prototype:GetElements(x, y, z)
    local node = self.Root
    while node do
        if x == node.X and y == node.Y and z == node.Z then
            local elements = {}
            for i = 1, 8 do
                if node.Children[i].Value then
                    table.insert(elements, node.Children[i].Value)
                end
            end
            return elements
        end

        local index = 1
        if x > node.X then
            index = index + 1
        end
        if y > node.Y then
            index = index + 2
        end
        if z > node.Z then
            index = index + 4
        end

        node = node.Children[index]
    end
    return {}
end

local LINKEDLIST = Type.Register("LinkedList")
function LINKEDLIST.Prototype:Initialize()
    self.Head = nil
    self.Tail = nil
    self.Size = 0
    self.Elements = weaktable(false, true)
    self.Cache = nil
end

function LINKEDLIST.Prototype:Add(element, after)
    assert(not self.Elements[element], "Element already exists")
    local afterNode = after and self.Elements[after] or self.Tail
    local node = {
        Value = element,
        Next = nil,
        Prev = afterNode
    }

    if not afterNode then
        -- List is empty
        self.Head = node
        self.Tail = node
    else
        node.Next = afterNode.Next
        if afterNode.Next then
            afterNode.Next.Prev = node
        else
            self.Tail = node
        end

        afterNode.Next = node
    end

    self.Elements[element] = node
    self.Size = self.Size + 1
    self.Cache = nil
end

function LINKEDLIST.Prototype:AddBefore(element, before)
    assert(not self.Elements[element], "Element already exists")
    local beforeNode = before and self.Elements[before] or self.Head
    local node = {
        Value = element,
        Next = beforeNode,
        Prev = beforeNode and beforeNode.Prev or nil
    }

    if not beforeNode then
        -- List is empty
        self.Head = node
        self.Tail = node
    else
        if beforeNode.Prev then
            beforeNode.Prev.Next = node
        else
            self.Head = node
        end

        beforeNode.Prev = node
    end

    self.Elements[element] = node
    self.Size = self.Size + 1
    self.Cache = nil
end

function LINKEDLIST.Prototype:Remove(element)
    local node = self.Elements[element]
    if not node then return false end
    if node.Prev then
        node.Prev.Next = node.Next
    else
        self.Head = node.Next
    end

    if node.Next then
        node.Next.Prev = node.Prev
    else
        self.Tail = node.Prev
    end

    self.Elements[element] = nil
    self.Size = self.Size - 1
    self.Cache = nil
    return true
end

function LINKEDLIST.Prototype:Contains(element)
    return self.Elements[element] ~= nil
end

function LINKEDLIST.Prototype:Iterator()
    local current = self.Head
    return function()
        if not current then return nil end
        local value = current.Value
        current = current.Next
        return value
    end
end

function LINKEDLIST.Prototype:GetTable()
    if self.Cache then return self.Cache end
    local elements = {}
    local current = self.Head
    while current do
        table.insert(elements, current.Value)
        current = current.Next
    end

    self.Cache = elements
    return elements
end

function LINKEDLIST.Prototype:Next()
    local idx = 0
    local current = self.Head
    return function()
        if current then
            local value = current.Value
            current = current.Next
            idx = idx + 1
            return idx, value
        end
    end
end

function LINKEDLIST.Prototype:Previous()
    local idx = self.Size
    local current = self.Tail
    return function()
        if current then
            local value = current.Value
            current = current.Prev
            idx = idx - 1
            return value
        end
    end
end